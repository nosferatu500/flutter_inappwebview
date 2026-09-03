import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_ios/flutter_inappwebview_ios.dart';
// The package barrel hides `InternalInAppWebViewController`, so the controller's channel dispatch
// is reachable only through the source file.
import 'package:flutter_inappwebview_ios/src/in_app_webview/in_app_webview_controller.dart'
    show InternalInAppWebViewController;
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins the wire contract of `shouldGoToBackForwardListItem` (B4,
/// `WKNavigationDelegate.webView(_:shouldGoTo:willUseInstantBack:completionHandler:)`, iOS 26.0+).
///
/// Unlike the other two 26.0 events this fork added, the *behaviour* here is testable on a
/// simulator and `integration_test/in_app_webview/should_go_to_back_forward_list_item.dart` covers
/// it. What only a unit test can pin is the hand-written map: the Swift builds
/// `["backForwardListItem": <WebHistoryItem map>, "willUseInstantBack": Bool]` and the enum crosses
/// as an `int`, and nothing compiles the two languages together.
///
/// The `int` in particular is load-bearing in a way a device run would not notice: the Swift's
/// `decodeResult` treats `1` as allow and **anything else, including a dropped answer, as allow
/// too**, so a Dart side that sent the wrong shape would fail open — the navigation would proceed
/// and the test would look like a working "allow".
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  IOSInAppWebViewController controllerWith(
    PlatformWebViewCreationParams params,
  ) => IOSInAppWebViewController(
    IOSInAppWebViewControllerCreationParams(id: 'test', webviewParams: params),
  );

  /// The map `WKBackForwardListItem.toMap(index:currentIndex:)` emits.
  Map<String, dynamic> itemMap({int? index, int? offset}) => <String, dynamic>{
    'originalUrl': 'https://example.com/one',
    'title': 'One',
    'url': 'https://example.com/one',
    'index': index,
    'offset': offset,
  };

  group('ShouldGoToBackForwardListItemAction', () {
    test('native values match what the Swift callback decodes', () {
      // Swift: `decodeResult = { (obj) in if let action = obj as? Int { return action == 1 } ... }`
      expect(ShouldGoToBackForwardListItemAction.CANCEL.toNativeValue(), 0);
      expect(ShouldGoToBackForwardListItemAction.ALLOW.toNativeValue(), 1);
    });

    test('only two cases, matching a BOOL completion handler', () {
      expect(ShouldGoToBackForwardListItemAction.values, hasLength(2));
    });
  });

  group('shouldGoToBackForwardListItem dispatch', () {
    test('decodes the item map and the instant-back flag', () async {
      WebHistoryItem? received;
      bool? receivedInstantBack;
      final controller = controllerWith(
        IOSHeadlessInAppWebViewCreationParams(
          shouldGoToBackForwardListItem: (dynamic _, item, willUseInstantBack) {
            received = item;
            receivedInstantBack = willUseInstantBack;
            return ShouldGoToBackForwardListItemAction.ALLOW;
          },
        ),
      );

      final result = await controller.handleMethod(
        MethodCall('shouldGoToBackForwardListItem', <String, dynamic>{
          'backForwardListItem': itemMap(index: 0, offset: -1),
          'willUseInstantBack': true,
        }),
      );

      expect(result, 1, reason: 'ALLOW crosses back as its native int');
      expect(received!.url.toString(), 'https://example.com/one');
      expect(received!.title, 'One');
      expect(
        received!.offset,
        -1,
        reason: 'one step back, computed natively from the current list',
      );
      expect(receivedInstantBack, isTrue);
    });

    test('CANCEL crosses back as 0', () async {
      final controller = controllerWith(
        IOSHeadlessInAppWebViewCreationParams(
          shouldGoToBackForwardListItem: (dynamic a, b, c) =>
              ShouldGoToBackForwardListItemAction.CANCEL,
        ),
      );

      expect(
        await controller.handleMethod(
          MethodCall('shouldGoToBackForwardListItem', <String, dynamic>{
            'backForwardListItem': itemMap(index: 0, offset: -1),
            'willUseInstantBack': false,
          }),
        ),
        0,
      );
    });

    test('a null answer leaves the decision to the native default', () async {
      final controller = controllerWith(
        IOSHeadlessInAppWebViewCreationParams(
          shouldGoToBackForwardListItem: (dynamic a, b, c) => null,
        ),
      );

      expect(
        await controller.handleMethod(
          MethodCall('shouldGoToBackForwardListItem', <String, dynamic>{
            'backForwardListItem': itemMap(),
            'willUseInstantBack': false,
          }),
        ),
        isNull,
        reason:
            'the Swift reads a non-int as allow, which is what WebKit does with no delegate at all',
      );
    });

    test('an item that could not be located carries null index/offset', () async {
      WebHistoryItem? received;
      final controller = controllerWith(
        IOSHeadlessInAppWebViewCreationParams(
          shouldGoToBackForwardListItem: (dynamic a, item, b) {
            received = item;
            return null;
          },
        ),
      );

      await controller.handleMethod(
        MethodCall('shouldGoToBackForwardListItem', <String, dynamic>{
          'backForwardListItem': itemMap(),
          'willUseInstantBack': false,
        }),
      );

      // WebKit hands over the item without saying where it sits, and the Swift looks it up by
      // identity; a miss must not be reported as index 0.
      expect(received!.index, isNull);
      expect(received!.offset, isNull);
    });

    test('does nothing when no handler is registered', () async {
      final controller = controllerWith(
        IOSHeadlessInAppWebViewCreationParams(),
      );
      expect(
        await controller.handleMethod(
          MethodCall('shouldGoToBackForwardListItem', <String, dynamic>{
            'backForwardListItem': itemMap(),
            'willUseInstantBack': false,
          }),
        ),
        isNull,
      );
    });
  });

  group('support table', () {
    test('the event and its gate are iOS-only', () {
      final params = IOSHeadlessInAppWebViewCreationParams();
      expect(
        params.isPropertySupported(
          PlatformWebViewCreationParamsProperty.shouldGoToBackForwardListItem,
          platform: TargetPlatform.iOS,
        ),
        isTrue,
      );
      expect(
        params.isPropertySupported(
          PlatformWebViewCreationParamsProperty.shouldGoToBackForwardListItem,
          platform: TargetPlatform.android,
        ),
        isFalse,
      );
      expect(
        InAppWebViewSettings.isPropertySupported(
          InAppWebViewSettingsProperty.useShouldGoToBackForwardListItem,
          platform: TargetPlatform.android,
        ),
        isFalse,
        reason:
            'android.webkit has no back/forward veto; shouldOverrideUrlLoading does not see them',
      );
    });

    test('the gate crosses as null until something sets it', () {
      // Null rather than false, and the distinction is the whole point: `null` is what lets
      // `IOSInAppWebView` infer `true` when a handler is supplied. The *default* lives natively
      // (`var useShouldGoToBackForwardListItem = false` in InAppWebViewSettings.swift), so a null
      // on the wire leaves the gate shut.
      expect(
        InAppWebViewSettings().toMap()['useShouldGoToBackForwardListItem'],
        isNull,
      );
      expect(
        InAppWebViewSettings(
          useShouldGoToBackForwardListItem: true,
        ).toMap()['useShouldGoToBackForwardListItem'],
        isTrue,
      );
    });
  });
}
