part of 'main.dart';

/// The device half of the registration guard.
///
/// Every `AndroidServiceWorkerController` attaches its method-call handler to the same
/// `const MethodChannel`, and `setMethodCallHandler` is last-writer-wins per channel name — so the
/// most recently constructed controller owns every incoming call. `ServiceWorkerController()`
/// constructs a new one each time it is called, which means a single extra construction anywhere in
/// an app used to silently orphan the client registered through `setServiceWorkerClient`.
///
/// The unit tests in `flutter_inappwebview_android/test/service_worker_client_registration_test.dart`
/// pin this deterministically by driving the channel directly. This one proves it end to end, where
/// the handler is installed by a real second controller and the request comes from Chromium.
void clientSurvivesSecondController() {
  final shouldSkip = !ServiceWorkerController.isMethodSupported(
    PlatformServiceWorkerControllerMethod.setServiceWorkerClient,
  );

  skippableTestWidgets('the client survives a second ServiceWorkerController', (
    WidgetTester tester,
  ) async {
    if (!await WebViewFeature.isFeatureSupported(
          WebViewFeature.SERVICE_WORKER_BASIC_USAGE,
        ) ||
        !await WebViewFeature.isFeatureSupported(
          WebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST,
        )) {
      markTestSkipped(
        'Service Worker interception unsupported on this WebView',
      );
      return;
    }

    final Completer<void> intercepted = Completer<void>();

    await ServiceWorkerController.instance().setServiceWorkerClient(
      ServiceWorkerClient(
        shouldInterceptRequest: (request) async {
          if (!intercepted.isCompleted) {
            intercepted.complete();
          }
          return null;
        },
      ),
    );

    // The whole point: a second controller, constructed the way an app would, *after* the client is
    // registered. Its own handler takes over the shared channel. Held per instance, the client
    // above would never be consulted again and this test would time out.
    ServiceWorkerController();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_SERVICE_WORKER_URL),
        ),
      ),
    );

    await expectLater(intercepted.future, completes);

    // Process-global, and now genuinely so: leave nothing registered for later tests.
    await ServiceWorkerController.instance().setServiceWorkerClient(null);
  }, skip: shouldSkip);
}
