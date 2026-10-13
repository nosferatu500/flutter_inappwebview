part of 'main.dart';

/// Device coverage for the **response** half of `ServiceWorkerClient.shouldInterceptRequest` (§185).
///
/// Every other test in this group answers the event with `null`, so no `WebResourceResponse` had
/// ever crossed this channel on a device: a broken response conversion — a dropped body, a lost
/// status code, headers decoded as the wrong type — would have shipped green. The group's other
/// tests also use a third-party page (`TEST_SERVICE_WORKER_URL`), whose worker's requests are not
/// ours to predict or assert on.
///
/// So this test brings its own Service Worker. `InAppLocalhostServer` serves `test_assets/` at
/// `http://localhost:8080` on the device itself, and localhost is a secure context, which a worker
/// needs to register. The page (`service_worker_intercept_test.html`) registers
/// `service_worker_intercept_test_sw.js` and waits until it controls the page. The worker answers a
/// fetch of the probe file by fetching it **again from the worker** — and that request, being a
/// Service Worker request, is the one that reaches `shouldInterceptRequest` here.
///
/// The control test lets the request through (the handler answers null) and must read the file's
/// real content; the replacement test answers with a custom response and must read *that*, with its
/// status and a custom header — three fields that each cross the wire separately.
///
/// 🚨 This path is the **blocking** one: the Kotlin side waits on a latch for the Dart answer
/// (`Util.invokeMethodAndWaitResult`), which is exactly what the Pigeon migration has to replace.
void serviceWorkerInterceptResponse() {
  final shouldSkip =
      !ServiceWorkerController.isMethodSupported(
        PlatformServiceWorkerControllerMethod.setServiceWorkerClient,
      ) ||
      kIsWeb;

  const probeFile = 'service_worker_intercept_test_probe.txt';
  final pageUrl = WebUri(
    'http://localhost:8080/test_assets/service_worker_intercept_test.html',
  );

  /// Loads the page, waits for the worker to control it, fetches the probe through it, and returns
  /// what the page read. Unregisters the worker afterwards, since registrations persist across runs.
  Future<Map<String, dynamic>> fetchProbeThroughWorker(
    WidgetTester tester,
  ) async {
    final server = InAppLocalhostServer();
    await server.start();
    addTearDown(server.close);

    final pageLoaded = Completer<InAppWebViewController>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: pageUrl),
          onLoadStop: (controller, url) {
            if (!pageLoaded.isCompleted) {
              pageLoaded.complete(controller);
            }
          },
        ),
      ),
    );
    final controller = await pageLoaded.future;

    final result = await controller.callAsyncJavaScript(
      functionBody:
          """
        await window.swReady;
        // A fresh query string and no-store: nothing may answer this from a cache.
        const response = await fetch('$probeFile?t=' + Date.now(), {cache: 'no-store'});
        const out = {
          status: response.status,
          text: await response.text(),
          probeHeader: response.headers.get('x-probe'),
        };
        const registration = await navigator.serviceWorker.getRegistration();
        if (registration) { await registration.unregister(); }
        return out;
      """,
    );
    expect(result?.error, isNull, reason: 'the page script failed');
    return Map<String, dynamic>.from(result!.value as Map);
  }

  Future<bool> interceptSupported() async =>
      await WebViewFeature.isFeatureSupported(
        WebViewFeature.SERVICE_WORKER_BASIC_USAGE,
      ) &&
      await WebViewFeature.isFeatureSupported(
        WebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST,
      );

  skippableTestWidgets(
    'a request the handler lets through reaches the server (control)',
    (WidgetTester tester) async {
      if (!await interceptSupported()) {
        markTestSkipped('Service Worker interception unsupported');
        return;
      }
      final seen = <WebResourceRequest>[];
      await ServiceWorkerController.instance().setServiceWorkerClient(
        ServiceWorkerClient(
          shouldInterceptRequest: (request) async {
            seen.add(request);
            return null;
          },
        ),
      );
      addTearDown(
        () => ServiceWorkerController.instance().setServiceWorkerClient(null),
      );

      final out = await fetchProbeThroughWorker(tester);

      // The fixture's real content, so the replacement test below is attributable to Dart.
      expect(out['text'], 'from-server');
      expect(out['status'], 200);
      // And the request payload crossed intact: the worker's fetch of the probe was delivered, as a
      // GET. Without this the control could pass on a page the worker never controlled.
      final probeRequests = seen.where(
        (r) => r.url.toString().contains(probeFile),
      );
      expect(
        probeRequests,
        isNotEmpty,
        reason: 'the worker fetch never reached shouldInterceptRequest',
      );
      expect(probeRequests.first.method, 'GET');
    },
    skip: shouldSkip,
  );

  skippableTestWidgets(
    'a response returned by the handler replaces the network response',
    (WidgetTester tester) async {
      if (!await interceptSupported()) {
        markTestSkipped('Service Worker interception unsupported');
        return;
      }
      await ServiceWorkerController.instance().setServiceWorkerClient(
        ServiceWorkerClient(
          shouldInterceptRequest: (request) async {
            if (!request.url.toString().contains(probeFile)) {
              return null;
            }
            return WebResourceResponse(
              contentType: 'text/plain',
              contentEncoding: 'utf-8',
              data: Uint8List.fromList(utf8.encode('intercepted-by-dart')),
              // 203 rather than 200, so the status is known to have crossed rather than defaulted.
              statusCode: 203,
              reasonPhrase: 'Non-Authoritative Information',
              headers: {'X-Probe': 'dart'},
            );
          },
        ),
      );
      addTearDown(
        () => ServiceWorkerController.instance().setServiceWorkerClient(null),
      );

      final out = await fetchProbeThroughWorker(tester);

      expect(out['text'], 'intercepted-by-dart');
      expect(out['status'], 203);
      expect(out['probeHeader'], 'dart');
    },
    skip: shouldSkip,
  );
}
