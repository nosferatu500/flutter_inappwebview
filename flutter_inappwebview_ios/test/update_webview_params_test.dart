import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_ios/flutter_inappwebview_ios.dart';
// `handleMethod` is reachable only through the source file (see writing_tools_active_test.dart).
import 'package:flutter_inappwebview_ios/src/in_app_webview/in_app_webview_controller.dart'
    show InternalInAppWebViewController;
import 'package:flutter_test/flutter_test.dart';

/// `IOSInAppWebViewController.updateWebViewParams` (§282): once a rebuild has handed the controller
/// its new widget's params, events reach that widget's callbacks, a replaced one and one the
/// rebuild added. Before, the controller only ever read the creating widget's params, so a rebuild's
/// callbacks never ran (measured on a device). The widget half, that `didUpdateWidget` makes the
/// call, is the device test `a rebuild's callbacks receive the events`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('events go to the params a rebuild handed over', () async {
    final got = <String>[];
    final controller = IOSInAppWebViewController(
      IOSInAppWebViewControllerCreationParams(
        id: 'rebuild',
        webviewParams: IOSHeadlessInAppWebViewCreationParams(
          onLoadStop: (_, url) => got.add('first stop $url'),
        ),
      ),
    );

    await controller.handleMethod(
      const MethodCall('onLoadStop', {'url': 'https://example.com/1'}),
    );
    controller.updateWebViewParams(
      IOSHeadlessInAppWebViewCreationParams(
        onLoadStop: (_, url) => got.add('second stop $url'),
        onTitleChanged: (_, title) => got.add('second title $title'),
      ),
    );
    await controller.handleMethod(
      const MethodCall('onLoadStop', {'url': 'https://example.com/2'}),
    );
    await controller.handleMethod(
      const MethodCall('onTitleChanged', {'title': 'two'}),
    );

    expect(got, [
      'first stop https://example.com/1',
      'second stop https://example.com/2',
      'second title two',
    ]);
  });
}
