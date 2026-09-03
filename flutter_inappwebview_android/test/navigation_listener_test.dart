import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
// The package barrel hides the `InternalInAppWebViewController` extension, so `_handleMethod` is
// reachable only through the source file. Importing it directly is what lets this test drive the
// controller's channel dispatch without a platform channel or a live WebView.
import 'package:flutter_inappwebview_android/src/in_app_webview/in_app_webview_controller.dart'
    show InternalInAppWebViewController;
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards C1's first half — `onNavigationStarted` / `onNavigationRedirected` /
/// `onNavigationCompleted`, backed by `androidx.webkit.NavigationListener`.
///
/// Three things are pinned here because each of them fails silently on a device and nowhere else:
///
///  * **the wire keys.** `WebViewChannelDelegate` sends `["navigation": <map>]` and
///    `WebViewNavigationExt.toMap()` writes fourteen keys by literal string, which
///    `WebViewNavigation.fromMap` then reads by literal string. Nothing compiles those two halves
///    together, so a rename on either side is invisible until an event arrives with half its fields
///    null.
///  * **the feature constants' values.** §36 measured that an unregistered feature string makes
///    `WebViewFeature.isFeatureSupported` **throw** `RuntimeException("Unknown feature ...")` rather
///    than return `false`, and that six neighbouring `NAVIGATION_*` constants in androidx are
///    exactly such tombstones. A typo here is a crash on every device that reaches the check.
///  * **the id, which the plugin invents.** androidx identifies a navigation by object identity and
///    identity cannot cross a channel, so `id` is synthesised in Kotlin. It is the only thing tying
///    the three events together, and it is the one field no platform test could catch drifting.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  AndroidInAppWebViewController controllerWith(
    PlatformWebViewCreationParams params,
  ) => AndroidInAppWebViewController(
    AndroidInAppWebViewControllerCreationParams(id: 1, webviewParams: params),
  );

  /// Exactly the map `WebViewNavigationExt.toMap()` builds, for a committed navigation.
  Map<String, Object?> navigationMap({
    int id = 7,
    int? pageId = 3,
    String? url = 'https://example.com/',
    bool didCommit = true,
    int? statusCode = 200,
    Map<String, Object?>? webResourceError,
  }) => <String, Object?>{
    'id': id,
    'pageId': pageId,
    'url': url,
    'wasInitiatedByPage': true,
    'isSameDocument': false,
    'isReload': false,
    'isHistory': false,
    'isBack': false,
    'isForward': false,
    'isRestore': false,
    'didCommit': didCommit,
    'didCommitErrorPage': false,
    'statusCode': statusCode,
    'webResourceError': webResourceError,
  };

  group('the three events read the map Kotlin builds', () {
    test(
      'every field survives the hop, including the synthesised ids',
      () async {
        final List<WebViewNavigation> received = <WebViewNavigation>[];
        final controller = controllerWith(
          AndroidHeadlessInAppWebViewCreationParams(
            onNavigationCompleted: (dynamic _, WebViewNavigation n) =>
                received.add(n),
          ),
        );

        await controller.handleMethod(
          MethodCall('onNavigationCompleted', {'navigation': navigationMap()}),
        );

        final navigation = received.single;
        expect(navigation.id, 7);
        expect(navigation.pageId, 3);
        expect(navigation.url, WebUri('https://example.com/'));
        expect(navigation.wasInitiatedByPage, isTrue);
        expect(navigation.isSameDocument, isFalse);
        expect(navigation.didCommit, isTrue);
        expect(navigation.didCommitErrorPage, isFalse);
        expect(navigation.statusCode, 200);
        expect(navigation.webResourceError, isNull);
      },
    );

    test('a status code on the happy path is the point of the feature', () async {
      // `onReceivedHttpError` only ever fires for error responses, so before this event a 200 was
      // indistinguishable from no response at all. Assert the success case specifically.
      final List<int?> codes = <int?>[];
      final controller = controllerWith(
        AndroidHeadlessInAppWebViewCreationParams(
          onNavigationCompleted: (dynamic _, WebViewNavigation n) =>
              codes.add(n.statusCode),
        ),
      );

      await controller.handleMethod(
        MethodCall('onNavigationCompleted', {
          'navigation': navigationMap(statusCode: 200),
        }),
      );
      await controller.handleMethod(
        MethodCall('onNavigationCompleted', {
          'navigation': navigationMap(didCommit: false, statusCode: null),
        }),
      );

      expect(
        codes,
        <int?>[200, null],
        reason:
            'a committed navigation reports its status; an uncommitted one reports null rather '
            'than a fabricated zero',
      );
    });

    test('started and redirected reach their own handlers', () async {
      final List<String> order = <String>[];
      final controller = controllerWith(
        AndroidHeadlessInAppWebViewCreationParams(
          onNavigationStarted: (dynamic _, WebViewNavigation n) =>
              order.add('started:${n.id}:${n.url}'),
          onNavigationRedirected: (dynamic _, WebViewNavigation n) =>
              order.add('redirected:${n.id}:${n.url}'),
        ),
      );

      await controller.handleMethod(
        MethodCall('onNavigationStarted', {
          'navigation': navigationMap(url: 'https://example.com/one'),
        }),
      );
      await controller.handleMethod(
        MethodCall('onNavigationRedirected', {
          'navigation': navigationMap(url: 'https://example.com/two'),
        }),
      );

      expect(
        order,
        <String>[
          'started:7:https://example.com/one',
          'redirected:7:https://example.com/two',
        ],
        reason: 'the id is stable across the sequence while the url changes',
      );
    });

    test('the nested WebResourceError is decoded, not dropped', () async {
      final List<WebResourceError?> errors = <WebResourceError?>[];
      final controller = controllerWith(
        AndroidHeadlessInAppWebViewCreationParams(
          onNavigationCompleted: (dynamic _, WebViewNavigation n) =>
              errors.add(n.webResourceError),
        ),
      );

      await controller.handleMethod(
        MethodCall('onNavigationCompleted', {
          'navigation': navigationMap(
            didCommit: false,
            statusCode: null,
            webResourceError: <String, Object?>{
              'type': -2,
              'description': 'net::ERR_NAME_NOT_RESOLVED',
            },
          ),
        }),
      );

      expect(errors.single?.description, 'net::ERR_NAME_NOT_RESOLVED');
      expect(errors.single?.type, WebResourceErrorType.HOST_LOOKUP);
    });

    test(
      'an event with no handler registered is ignored, not thrown',
      () async {
        final controller = controllerWith(
          AndroidHeadlessInAppWebViewCreationParams(),
        );
        await expectLater(
          controller.handleMethod(
            MethodCall('onNavigationStarted', {'navigation': navigationMap()}),
          ),
          completes,
        );
      },
    );
  });

  group('feature constants', () {
    // Values read from `javap -constants` on webkit-1.17.0.aar. Both happen to equal their names,
    // unlike `PRERENDER_WITH_URL` — but that is a fact to pin, not one to assume, and §36 found six
    // sibling constants that are registered nowhere and throw when passed to isFeatureSupported.
    test('NAVIGATION_LISTENER carries the registered androidx name', () {
      expect(
        WebViewFeature.NAVIGATION_LISTENER.toNativeValue(),
        'NAVIGATION_LISTENER',
      );
    });

    test(
      'NAVIGATION_GET_WEB_RESOURCE_ERROR carries the registered androidx name',
      () {
        expect(
          WebViewFeature.NAVIGATION_GET_WEB_RESOURCE_ERROR.toNativeValue(),
          'NAVIGATION_GET_WEB_RESOURCE_ERROR',
        );
      },
    );

    test('neither constant is one of the six tombstones', () {
      // Deprecated *and* unregistered in 1.17.0; passing one to isFeatureSupported throws.
      const tombstones = <String>[
        'WEB_VIEW_NAVIGATION_CLIENT_BASIC_USAGE',
        'NAVIGATION_LISTENER_V1',
        'NAVIGATION_LISTENER_V2',
        'NAVIGATION_LISTENER_ON_COMPLETED_FIRES_FOR_NON_COMMITTED',
        'NAVIGATION_LISTENER_NON_NULL_PAGE_FOR_SAME_DOCUMENT_NAVIGATIONS',
        'PAGE_GET_URL',
      ];
      expect(
        tombstones,
        isNot(contains(WebViewFeature.NAVIGATION_LISTENER.toNativeValue())),
      );
      expect(
        tombstones,
        isNot(
          contains(
            WebViewFeature.NAVIGATION_GET_WEB_RESOURCE_ERROR.toNativeValue(),
          ),
        ),
      );
    });
  });

  group('the settings gate', () {
    test('useNavigationListener serialises under the key Kotlin reads', () {
      final settings = InAppWebViewSettings(useNavigationListener: true);
      expect(settings.toMap()['useNavigationListener'], isTrue);
    });

    test('it is absent rather than false when never set', () {
      // `null` is what lets the widget infer the setting from a supplied handler; a default of
      // `false` would make that inference impossible to distinguish from an explicit opt-out.
      final settings = InAppWebViewSettings();
      expect(settings.useNavigationListener, isNull);
    });

    test('the events and the setting are reported Android-only', () {
      final params = AndroidHeadlessInAppWebViewCreationParams();
      for (final property in <PlatformWebViewCreationParamsProperty>[
        PlatformWebViewCreationParamsProperty.onNavigationStarted,
        PlatformWebViewCreationParamsProperty.onNavigationRedirected,
        PlatformWebViewCreationParamsProperty.onNavigationCompleted,
      ]) {
        expect(
          params.isPropertySupported(
            property,
            platform: TargetPlatform.android,
          ),
          isTrue,
          reason: '$property should be supported on Android',
        );
        expect(
          params.isPropertySupported(property, platform: TargetPlatform.iOS),
          isFalse,
          reason:
              '$property has no WebKit counterpart: WKNavigationDelegate reports no status code '
              'on the happy path and no redirect event for navigations the app cannot override',
        );
      }
    });
  });
}
