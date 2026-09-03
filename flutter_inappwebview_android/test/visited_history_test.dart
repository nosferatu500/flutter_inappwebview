import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
// The package barrel hides the `InternalInAppWebViewController` extension, so `_handleMethod` is
// reachable only through the source file.
import 'package:flutter_inappwebview_android/src/in_app_webview/in_app_webview_controller.dart'
    show InternalInAppWebViewController;
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards D4 — `onRequestVisitedHistory`, backed by `WebChromeClient.getVisitedHistory`.
///
/// This is a *reply*-shaped event, so what needs pinning is not a payload but the **return value**,
/// and it has three distinguishable states that Kotlin acts on differently:
///
///  * a **list** is forwarded to the engine as a `String[]`;
///  * **`null`** falls through to `super.getVisitedHistory`, i.e. the platform default, where the
///    callback is never answered and no `:visited` styling appears;
///  * an **empty list** is a real answer — "nothing has been visited" — and is forwarded as an
///    empty array.
///
/// Collapsing `null` into `[]` anywhere along the way would erase that distinction silently, which
/// is exactly the kind of thing no device test would notice: both look identical on screen.
///
/// The `WebUri` -> `String` conversion is the other half. `WebUri` cannot cross a method channel,
/// so a regression there is a `PlatformException` at runtime rather than a compile error.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  AndroidInAppWebViewController controllerWith(
    PlatformWebViewCreationParams params,
  ) => AndroidInAppWebViewController(
    AndroidInAppWebViewControllerCreationParams(id: 1, webviewParams: params),
  );

  group('onRequestVisitedHistory reply shape', () {
    test('a list of WebUri is returned as a list of plain strings', () async {
      final controller = controllerWith(
        AndroidHeadlessInAppWebViewCreationParams(
          onRequestVisitedHistory: (dynamic _) async => <WebUri>[
            WebUri('https://example.com/one'),
            WebUri('https://example.com/two?q=a%20b#frag'),
          ],
        ),
      );

      final result = await controller.handleMethod(
        const MethodCall('onRequestVisitedHistory', <String, dynamic>{}),
      );

      expect(result, isA<List<String>>());
      expect(result, <String>[
        'https://example.com/one',
        'https://example.com/two?q=a%20b#frag',
      ], reason: 'the query and fragment survive the conversion verbatim');
    });

    test('null stays null rather than becoming an empty list', () async {
      // The distinction Kotlin depends on: null means "keep the platform default", where the
      // callback is left unanswered. An empty list would instead assert that nothing was visited.
      final controller = controllerWith(
        AndroidHeadlessInAppWebViewCreationParams(
          onRequestVisitedHistory: (dynamic _) async => null,
        ),
      );

      expect(
        await controller.handleMethod(
          const MethodCall('onRequestVisitedHistory', <String, dynamic>{}),
        ),
        isNull,
      );
    });

    test('an empty list is preserved as a real answer', () async {
      final controller = controllerWith(
        AndroidHeadlessInAppWebViewCreationParams(
          onRequestVisitedHistory: (dynamic _) async => <WebUri>[],
        ),
      );

      final result = await controller.handleMethod(
        const MethodCall('onRequestVisitedHistory', <String, dynamic>{}),
      );

      expect(result, isNotNull);
      expect(result, isEmpty);
    });

    test('a synchronous handler works as well as an async one', () async {
      // The signature is `FutureOr<List<WebUri>?>`, so an app answering from an in-memory store
      // should not have to make its callback async.
      final controller = controllerWith(
        AndroidHeadlessInAppWebViewCreationParams(
          onRequestVisitedHistory: (dynamic _) => <WebUri>[
            WebUri('https://example.com/'),
          ],
        ),
      );

      expect(
        await controller.handleMethod(
          const MethodCall('onRequestVisitedHistory', <String, dynamic>{}),
        ),
        <String>['https://example.com/'],
      );
    });

    test('no handler leaves the platform default in place', () async {
      // Returning null here is what makes the Kotlin fall through to `super`, so a WebView with no
      // Dart handler behaves exactly like a WebView without this plugin.
      final controller = controllerWith(
        AndroidHeadlessInAppWebViewCreationParams(),
      );

      expect(
        await controller.handleMethod(
          const MethodCall('onRequestVisitedHistory', <String, dynamic>{}),
        ),
        isNull,
      );
    });
  });

  group('platform gating', () {
    test('the event is reported Android-only', () {
      final params = AndroidHeadlessInAppWebViewCreationParams();
      expect(
        params.isPropertySupported(
          PlatformWebViewCreationParamsProperty.onRequestVisitedHistory,
          platform: TargetPlatform.android,
        ),
        isTrue,
      );
      expect(
        params.isPropertySupported(
          PlatformWebViewCreationParamsProperty.onRequestVisitedHistory,
          platform: TargetPlatform.iOS,
        ),
        isFalse,
        reason:
            'WebKit never asks the app for visited history — it has no counterpart to '
            'WebChromeClient.getVisitedHistory',
      );
    });
  });
}
