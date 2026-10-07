import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/in_app_webview.g.dart';
import 'package:flutter_test/flutter_test.dart';

/// `AndroidInAppWebViewController.updateWebViewParams` (§282): once a rebuild has handed the
/// controller its new widget's params, events reach that widget's callbacks, a replaced one and one
/// the rebuild added. Before, the controller only ever read the creating widget's params, so a
/// rebuild's callbacks never ran (measured on a device). Events are delivered as real Pigeon
/// messages, as Kotlin sends them. The widget half, that `didUpdateWidget` makes the call, is the
/// device test `a rebuild's callbacks receive the events`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = InAppWebViewFlutterApi.pigeonChannelCodec;
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  Future<ByteData?> deliver(String method, List<Object?> args) =>
      messenger.handlePlatformMessage(
        'dev.flutter.pigeon.flutter_inappwebview_android.InAppWebViewFlutterApi'
        '.$method.inappwebview_21',
        codec.encodeMessage(args),
        (_) {},
      );

  test('events go to the params a rebuild handed over', () async {
    final got = <String>[];
    final controller = AndroidInAppWebViewController(
      AndroidInAppWebViewControllerCreationParams(
        id: 21,
        webviewParams: AndroidHeadlessInAppWebViewCreationParams(
          onLoadStop: (_, url) => got.add('first stop $url'),
        ),
      ),
    );
    addTearDown(controller.dispose);

    await deliver('onLoadStop', ['https://example.com/1']);
    controller.updateWebViewParams(
      AndroidHeadlessInAppWebViewCreationParams(
        onLoadStop: (_, url) => got.add('second stop $url'),
        onTitleChanged: (_, title) => got.add('second title $title'),
      ),
    );
    await deliver('onLoadStop', ['https://example.com/2']);
    await deliver('onTitleChanged', ['two']);

    expect(got, [
      'first stop https://example.com/1',
      'second stop https://example.com/2',
      'second title two',
    ]);
  });
}
