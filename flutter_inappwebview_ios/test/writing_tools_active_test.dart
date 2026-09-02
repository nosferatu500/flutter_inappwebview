import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_ios/flutter_inappwebview_ios.dart';
// The package barrel deliberately hides `InternalInAppWebViewController`, so `_handleMethod` is
// reachable only through the source file. Importing it directly is what lets this test drive the
// controller's channel dispatch without a platform channel or a live WebView.
import 'package:flutter_inappwebview_ios/src/in_app_webview/in_app_webview_controller.dart'
    show InternalInAppWebViewController;
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards `onWritingToolsActiveChanged` (B2, `WKWebView.writingToolsActive`, iOS 18.0+).
///
/// **The event itself cannot be exercised anywhere in this repo.** Writing Tools needs Apple
/// Intelligence, a real device and a user invoking Rewrite or Proofread on text in the page; a
/// simulator will never fire it. So the device suite can say nothing, exactly as in §111, and what
/// is left to protect is the one thing that silently breaks: **the wire key**.
///
/// The Swift sends `["active": Bool]` under the method name `onWritingToolsActiveChanged`, and
/// `IOSInAppWebViewController._handleMethod` reads `call.arguments["active"]` by literal string.
/// Nothing compiles those two together. The first group drives a real controller through its real
/// `_handleMethod` with the map the Swift builds, so a rename on either side fails here rather than
/// on a device nobody in this repo owns.
///
/// The KVO side needs no test: `#keyPath(WKWebView.isWritingToolsActive)` is compiler-checked, and a
/// mismatched `addObserver`/`removeObserver` pair throws at runtime on the first dispose — the full
/// `in_app_webview` baseline is what covers that, since every test disposes a WebView.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// A controller wired to `params`, driven directly rather than through a platform channel.
  IOSInAppWebViewController controllerWith(
    PlatformWebViewCreationParams params,
  ) => IOSInAppWebViewController(
    IOSInAppWebViewControllerCreationParams(id: 'test', webviewParams: params),
  );

  group('onWritingToolsActiveChanged wire shape', () {
    test('reads `active` out of the map the Swift builds', () async {
      final List<bool> received = <bool>[];
      final controller = controllerWith(
        IOSHeadlessInAppWebViewCreationParams(
          onWritingToolsActiveChanged: (dynamic _, bool active) =>
              received.add(active),
        ),
      );

      // Exactly what `WebViewChannelDelegate.onWritingToolsActiveChanged` sends.
      await controller.handleMethod(
        const MethodCall('onWritingToolsActiveChanged', {'active': true}),
      );
      await controller.handleMethod(
        const MethodCall('onWritingToolsActiveChanged', {'active': false}),
      );

      expect(
        received,
        <bool>[true, false],
        reason:
            'both directions are delivered: the event reports Writing Tools finishing as well as '
            'starting',
      );
    });

    test('does nothing when no handler is registered', () async {
      // The `if` in `_handleMethod` guards a force-unwrap; without it this would throw rather than
      // ignore an event the app never asked for.
      final controller = controllerWith(
        IOSHeadlessInAppWebViewCreationParams(),
      );
      await expectLater(
        controller.handleMethod(
          const MethodCall('onWritingToolsActiveChanged', {'active': true}),
        ),
        completes,
      );
    });
  });

  group('support table', () {
    test('the event is reported iOS-only', () {
      final params = IOSHeadlessInAppWebViewCreationParams();
      expect(
        params.isPropertySupported(
          PlatformWebViewCreationParamsProperty.onWritingToolsActiveChanged,
          platform: TargetPlatform.iOS,
        ),
        isTrue,
      );
      expect(
        params.isPropertySupported(
          PlatformWebViewCreationParamsProperty.onWritingToolsActiveChanged,
          platform: TargetPlatform.android,
        ),
        isFalse,
        reason:
            'Writing Tools is an Apple feature; there is no Android counterpart',
      );
    });
  });

  // Deliberately no assertion that `InAppWebViewSettings.writingToolsBehavior` still serialises:
  // `writing_tools_behavior_test.dart` already covers it, and restating it here would be a test
  // that cannot go red for anything this file is about.
}
