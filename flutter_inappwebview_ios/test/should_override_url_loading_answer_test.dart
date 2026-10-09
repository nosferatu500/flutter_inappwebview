import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_ios/flutter_inappwebview_ios.dart';
// `handleMethod` is on an extension the package barrel hides (see writing_tools_active_test.dart).
import 'package:flutter_inappwebview_ios/src/in_app_webview/in_app_webview_controller.dart'
    show InternalInAppWebViewController;
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// What `_handleMethod` answers the Swift for `shouldOverrideUrlLoading` (D1, §309).
///
/// The Swift reads an `Int` as the policy and anything else as no decision, which allows. So a null
/// answer and a missing handler must reach it as null, and a throwing handler must not: the channel
/// wrapper answers an `Error` as null and an `Exception` as an error reply, which the Swift also
/// allows. The controller answers CANCEL for both instead. What the WebView then does is pinned on
/// the device (`should_override_url_loading.dart`).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  IOSInAppWebViewController controllerWith(
    PlatformWebViewCreationParams params,
  ) => IOSInAppWebViewController(
    IOSInAppWebViewControllerCreationParams(id: 'sou', webviewParams: params),
  );

  const call = MethodCall('shouldOverrideUrlLoading', {
    'request': {'url': 'https://example.com/next', 'method': 'GET'},
    'isForMainFrame': true,
  });

  for (final (name, fail) in <(String, Never Function())>[
    ('an Error', () => throw StateError('an allow-list bug')),
    ('an Exception', () => throw Exception('an allow-list bug')),
  ]) {
    test('a handler that throws $name answers CANCEL', () async {
      final controller = controllerWith(
        IOSHeadlessInAppWebViewCreationParams(
          shouldOverrideUrlLoading: (_, a) async => fail(),
        ),
      );
      addTearDown(controller.dispose);
      expect(
        await controller.handleMethod(call),
        NavigationActionPolicy.CANCEL.toNativeValue(),
      );
    });
  }

  test('a null answer reaches the Swift as null (no decision)', () async {
    final controller = controllerWith(
      IOSHeadlessInAppWebViewCreationParams(
        shouldOverrideUrlLoading: (_, a) async => null,
      ),
    );
    addTearDown(controller.dispose);
    expect(await controller.handleMethod(call), isNull);
  });

  test('no handler reaches the Swift as null (no decision)', () async {
    final controller = controllerWith(IOSHeadlessInAppWebViewCreationParams());
    addTearDown(controller.dispose);
    expect(await controller.handleMethod(call), isNull);
  });

  test('an explicit answer is passed through', () async {
    for (final policy in [
      NavigationActionPolicy.ALLOW,
      NavigationActionPolicy.CANCEL,
    ]) {
      final controller = controllerWith(
        IOSHeadlessInAppWebViewCreationParams(
          shouldOverrideUrlLoading: (_, a) async => policy,
        ),
      );
      addTearDown(controller.dispose);
      expect(await controller.handleMethod(call), policy.toNativeValue());
    }
  });
}
