import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/in_app_webview.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the wire shape of `WebViewFeature.PRERENDER_WITH_URL` — `prerenderUrl`, on
/// `InAppWebViewHostApi` since §207 (it was a MethodChannel call).
///
/// Two things are pinned because both fail quietly:
///
///  * **the URL is sent as a `String`, not a `WebUri`**, with its query and fragment intact.
///  * **the `false` return.** Prerendering is best-effort: a device without the feature, or a
///    profile that cannot host it, answers `false`, and the navigation simply loads normally later.
///    A controller with no transport (disposed) also reads as "not prerendered", the safe direction.
///    §207: the platform can no longer answer *null*. The return is a non-null Pigeon `bool`, and
///    Kotlin always sends one (`webView?.prerenderUrl(url) == true`), so the old "missing reply"
///    case is unrepresentable and was replaced by the disposed one.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = InAppWebViewHostApi.pigeonChannelCodec;
  const hostChannel =
      'dev.flutter.pigeon.flutter_inappwebview_android.InAppWebViewHostApi'
      '.prerenderUrl.inappwebview_3';

  late AndroidInAppWebViewController controller;
  final List<List<Object?>> calls = <List<Object?>>[];
  Object? reply;
  // A second dispose() asserts ("used after being disposed"), so a test that disposes sets this.
  var disposed = false;

  setUp(() {
    calls.clear();
    reply = true;
    disposed = false;
    controller = AndroidInAppWebViewController(
      AndroidInAppWebViewControllerCreationParams(id: 3),
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(hostChannel, (message) async {
          calls.add(codec.decodeMessage(message) as List<Object?>);
          return codec.encodeMessage(<Object?>[reply]);
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(hostChannel, null);
    if (!disposed) controller.dispose();
  });

  group('AndroidInAppWebViewController.prerenderUrl', () {
    test('sends the url as a string', () async {
      await controller.prerenderUrl(WebUri('https://flutter.dev/'));

      expect(calls.single, ['https://flutter.dev/']);
      expect(calls.single.single, isA<String>());
    });

    test('preserves the query and fragment the caller asked for', () async {
      await controller.prerenderUrl(
        WebUri('https://example.com/search?q=a%20b#frag'),
      );

      expect(calls.single, ['https://example.com/search?q=a%20b#frag']);
    });

    test('reports false when the platform declined', () async {
      reply = false;
      expect(
        await controller.prerenderUrl(WebUri('https://example.com/')),
        isFalse,
      );
    });

    test(
      'a disposed controller reads as "not prerendered" and sends nothing',
      () async {
        controller.dispose();
        disposed = true;
        expect(
          await controller.prerenderUrl(WebUri('https://example.com/')),
          isFalse,
        );
        expect(calls, isEmpty);
      },
    );
  });

  group('platform gating', () {
    test('reports Android-only', () {
      expect(
        controller.isMethodSupported(
          PlatformInAppWebViewControllerMethod.prerenderUrl,
          platform: TargetPlatform.android,
        ),
        isTrue,
      );
      expect(
        controller.isMethodSupported(
          PlatformInAppWebViewControllerMethod.prerenderUrl,
          platform: TargetPlatform.iOS,
        ),
        isFalse,
      );
    });
  });
}
