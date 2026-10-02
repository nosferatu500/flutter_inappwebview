part of 'main.dart';

void onPermissionRequest() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.onPermissionRequest,
  );

  skippableTestWidgets('onPermissionRequest', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<List<PermissionResourceType>> onPermissionRequestCompleter =
        Completer<List<PermissionResourceType>>();
    final expectedValue = [PermissionResourceType.CAMERA];

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_PERMISSION_SITE),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            if (!pageLoaded.isCompleted) {
              pageLoaded.complete();
            }
          },
          onPermissionRequest: (controller, permissionRequest) async {
            onPermissionRequestCompleter.complete(permissionRequest.resources);
            return PermissionResponse(
              resources: permissionRequest.resources,
              action: PermissionResponseAction.GRANT,
            );
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;

    await tester.pump();

    await controller.evaluateJavascript(
      source: "document.querySelector('#camera').click();",
    );
    final List<PermissionResourceType> resources =
        await onPermissionRequestCompleter.future;

    expect(listEquals(resources, expectedValue), true);
  }, skip: shouldSkip);

  // The test above reads the request but never the answer: the page is not asked what happened, so
  // a GRANT the plugin ignored passes it. These two read the page's own outcome (§215), on a local
  // page so nothing depends on permission.site. A Widevine key-system request asks for
  // PROTECTED_MEDIA_ID, which needs no hardware and no Android runtime permission, so the page sees
  // exactly what Dart answered. Measured on API 37: GRANT resolves, DENY rejects with
  // NotSupportedError. A microphone request does not separate them as cleanly: granted, it still
  // fails with NotReadableError because the app holds no RECORD_AUDIO.
  Future<String?> requestProtectedMedia(
    WidgetTester tester,
    PermissionResponseAction action,
    List<PermissionRequest> requests,
  ) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialData: InAppWebViewInitialData(
            data:
                '<!DOCTYPE html><html><body>media<script>var media = "pending";</script>'
                '</body></html>',
            baseUrl: WebUri('https://example.com/'),
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            if (!pageLoaded.isCompleted) pageLoaded.complete();
          },
          onPermissionRequest: (controller, permissionRequest) async {
            requests.add(permissionRequest);
            return PermissionResponse(
              resources: permissionRequest.resources,
              action: action,
            );
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;

    await controller.evaluateJavascript(
      source:
          'navigator.requestMediaKeySystemAccess("com.widevine.alpha", [{'
          'initDataTypes: ["cenc"], '
          'videoCapabilities: [{contentType: \'video/mp4; codecs="avc1.42E01E"\'}]}])'
          '.then(function() { media = "granted"; })'
          '.catch(function(e) { media = "denied " + e.name; });',
    );

    String? media;
    for (var i = 0; i < 100; i++) {
      media = await controller.evaluateJavascript(source: 'media');
      if (media != 'pending') break;
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return media;
  }

  final shouldSkipAnswer =
      shouldSkip || defaultTargetPlatform != TargetPlatform.android;

  skippableTestWidgets('onPermissionRequest GRANT reaches the page', (
    WidgetTester tester,
  ) async {
    final requests = <PermissionRequest>[];
    final media = await requestProtectedMedia(
      tester,
      PermissionResponseAction.GRANT,
      requests,
    );

    expect(requests, hasLength(1));
    expect(requests.single.origin.toString(), 'https://example.com/');
    expect(requests.single.resources, [
      PermissionResourceType.PROTECTED_MEDIA_ID,
    ]);
    expect(media, 'granted');
  }, skip: shouldSkipAnswer);

  skippableTestWidgets('onPermissionRequest DENY reaches the page', (
    WidgetTester tester,
  ) async {
    final requests = <PermissionRequest>[];
    final media = await requestProtectedMedia(
      tester,
      PermissionResponseAction.DENY,
      requests,
    );

    expect(requests, hasLength(1));
    expect(media, 'denied NotSupportedError');
  }, skip: shouldSkipAnswer);

  final shouldSkip2 = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.onPermissionRequestCanceled,
  );

  skippableTestWidgets('onPermissionRequestCanceled', (
    WidgetTester tester,
  ) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<List<PermissionResourceType>> onPermissionRequestCompleter =
        Completer<List<PermissionResourceType>>();
    final Completer<List<PermissionResourceType>>
    onPermissionRequestCancelCompleter =
        Completer<List<PermissionResourceType>>();
    final expectedValue = [PermissionResourceType.MICROPHONE];
    // Until §213 only `resources` was read. Measured on API 37: the origin is the permission
    // site's own, the same one the request reported.
    String? canceledOrigin;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_PERMISSION_SITE),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            if (!pageLoaded.isCompleted) {
              pageLoaded.complete();
            }
          },
          onPermissionRequest: (controller, permissionRequest) async {
            onPermissionRequestCompleter.complete(permissionRequest.resources);
            await Future.delayed(const Duration(seconds: 5));
            return PermissionResponse(
              resources: permissionRequest.resources,
              action: PermissionResponseAction.GRANT,
            );
          },
          onPermissionRequestCanceled: (controller, permissionRequest) {
            canceledOrigin = permissionRequest.origin.toString();
            onPermissionRequestCancelCompleter.complete(
              permissionRequest.resources,
            );
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;

    await tester.pump();

    await controller.evaluateJavascript(
      source: "document.querySelector('#microphone').click();",
    );

    final List<PermissionResourceType> resources =
        await onPermissionRequestCompleter.future;
    expect(listEquals(resources, expectedValue), true);

    // Reload the webview to cancel the permission request
    unawaited(controller.reload());

    final List<PermissionResourceType> canceledResources =
        await onPermissionRequestCancelCompleter.future;
    expect(listEquals(canceledResources, expectedValue), true);
    expect(canceledOrigin, TEST_PERMISSION_SITE.toString());
  }, skip: shouldSkip2);
}
