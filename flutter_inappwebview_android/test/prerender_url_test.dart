import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the wire shape of `WebViewFeature.PRERENDER_WITH_URL` — `prerenderUrl`.
///
/// Two things are pinned because both fail quietly:
///
///  * **the URL is sent as a `String`, not a `WebUri`.** The standard message codec cannot encode a
///    `WebUri`, so a regression here is a `PlatformException` at the call site rather than a
///    compile error.
///  * **the `false` return.** Prerendering is best-effort: a device without the feature, or a
///    profile that cannot host it, answers `false`, and the navigation simply loads normally later.
///    `?? false` also means an absent reply reads as "not prerendered", which is the safe direction.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('dev.nosferatu500.inappwebview/inappwebview_3');

  late AndroidInAppWebViewController controller;
  final List<MethodCall> calls = <MethodCall>[];
  Object? reply;

  setUp(() {
    calls.clear();
    reply = true;
    controller = AndroidInAppWebViewController(
      AndroidInAppWebViewControllerCreationParams(id: 3),
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          calls.add(call);
          return reply;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    controller.dispose();
  });

  Map<Object?, Object?> argsOf(MethodCall call) =>
      call.arguments as Map<Object?, Object?>;

  group('AndroidInAppWebViewController.prerenderUrl', () {
    test('sends the url as a string under the key Kotlin reads', () async {
      await controller.prerenderUrl(WebUri('https://flutter.dev/'));

      expect(calls.single.method, 'prerenderUrl');
      expect(argsOf(calls.single)['url'], 'https://flutter.dev/');
      expect(argsOf(calls.single)['url'], isA<String>());
    });

    test('preserves the query and fragment the caller asked for', () async {
      await controller.prerenderUrl(
        WebUri('https://example.com/search?q=a%20b#frag'),
      );

      expect(
        argsOf(calls.single)['url'],
        'https://example.com/search?q=a%20b#frag',
      );
    });

    test('reports false when the platform declined', () async {
      reply = false;
      expect(await controller.prerenderUrl(WebUri('https://example.com/')), isFalse);
    });

    test('a missing reply reads as "not prerendered"', () async {
      reply = null;
      expect(await controller.prerenderUrl(WebUri('https://example.com/')), isFalse);
    });
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
