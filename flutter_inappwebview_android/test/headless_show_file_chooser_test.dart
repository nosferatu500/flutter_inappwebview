import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
// The package barrel hides the `InternalInAppWebViewController` extension, so `handleMethod` is
// reachable only through the source file.
import 'package:flutter_inappwebview_android/src/in_app_webview/in_app_webview_controller.dart'
    show InternalInAppWebViewController;
import 'package:flutter_inappwebview_android/src/pigeons/headless_webview.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// A headless webview's `onShowFileChooser` reaches its handler.
///
/// It didn't: `AndroidHeadlessInAppWebViewCreationParams` took every other field of its platform
/// base but this one, so the conversion the facade's `HeadlessInAppWebView` goes through dropped
/// it. With the handler gone, `useOnShowFileChooser` was never inferred and Kotlin opened its own
/// picker without asking. Every other field the Android params leave out is iOS-only.
///
/// The tests below build the webview from the *platform* params, the way the facade does, except
/// where they say otherwise. The device half is `an onShowFileChooser handler turns on
/// useOnShowFileChooser` in the example's headless group.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = HeadlessWebViewHostApi.pigeonChannelCodec;
  const managerRun =
      'dev.flutter.pigeon.flutter_inappwebview_android.HeadlessInAppWebViewManagerHostApi.run';

  Future<ShowFileChooserResponse?> handler(
    dynamic controller,
    ShowFileChooserRequest request,
  ) async => ShowFileChooserResponse(handledByClient: true);

  /// Runs [headless] against a stubbed manager and returns the `initialSettings` map it sent.
  Future<Map<Object?, Object?>> runAndReadSettings(
    AndroidHeadlessInAppWebView headless,
  ) async {
    Object? sent;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(managerRun, (message) async {
          sent = codec.decodeMessage(message);
          return codec.encodeMessage(<Object?>[true]);
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(managerRun, null),
    );
    await headless.run();
    final params = (sent! as List<Object?>)[1]! as Map<Object?, Object?>;
    return params['initialSettings']! as Map<Object?, Object?>;
  }

  test('the conversion from the platform params keeps the handler', () {
    final headless = AndroidHeadlessInAppWebView(
      PlatformHeadlessInAppWebViewCreationParams(onShowFileChooser: handler),
    );
    expect(headless.params, isA<AndroidHeadlessInAppWebViewCreationParams>());
    expect(headless.params.onShowFileChooser, same(handler));
  });

  test('the Android params take it directly', () {
    expect(
      AndroidHeadlessInAppWebViewCreationParams(
        onShowFileChooser: handler,
      ).onShowFileChooser,
      same(handler),
    );
  });

  group('run infers useOnShowFileChooser', () {
    test('from the handler', () async {
      final settings = await runAndReadSettings(
        AndroidHeadlessInAppWebView(
          PlatformHeadlessInAppWebViewCreationParams(
            onShowFileChooser: handler,
          ),
        ),
      );
      expect(settings['useOnShowFileChooser'], isTrue);
    });

    test('but not over an explicit false', () async {
      final settings = await runAndReadSettings(
        AndroidHeadlessInAppWebView(
          PlatformHeadlessInAppWebViewCreationParams(
            initialSettings: InAppWebViewSettings(useOnShowFileChooser: false),
            onShowFileChooser: handler,
          ),
        ),
      );
      expect(settings['useOnShowFileChooser'], isFalse);
    });

    test('and leaves it unset with no handler', () async {
      final settings = await runAndReadSettings(
        AndroidHeadlessInAppWebView(
          const PlatformHeadlessInAppWebViewCreationParams(),
        ),
      );
      expect(settings['useOnShowFileChooser'], isNull);
    });
  });

  test('the event reaches the handler and its answer goes back', () async {
    final requests = <ShowFileChooserRequest>[];
    final headless = AndroidHeadlessInAppWebView(
      PlatformHeadlessInAppWebViewCreationParams(
        onShowFileChooser: (_, request) async {
          requests.add(request);
          return ShowFileChooserResponse(
            handledByClient: true,
            filePaths: ['file:///a.txt'],
          );
        },
      ),
    );
    await runAndReadSettings(headless);

    // `ShowFileChooserRequest.toMap()` as Kotlin sends it.
    final reply = await headless.webViewController!.handleMethod(
      const MethodCall('onShowFileChooser', {
        'mode': 1,
        'acceptTypes': ['image/*'],
        'isCaptureEnabled': true,
      }),
    );

    expect(requests, hasLength(1));
    expect(requests.single.mode, ShowFileChooserRequestMode.OPEN_MULTIPLE);
    expect(requests.single.acceptTypes, ['image/*']);
    expect(requests.single.isCaptureEnabled, isTrue);
    expect(reply, {
      'handledByClient': true,
      'filePaths': ['file:///a.txt'],
    });
  });
}
