part of 'main.dart';

void onGeolocationPermissionsShowPrompt() {
  // Android only: this is the only platform the values below were measured on (API 37).
  final shouldSkip =
      !InAppWebView.isPropertySupported(
        PlatformWebViewCreationParamsProperty
            .onGeolocationPermissionsShowPrompt,
      ) ||
      defaultTargetPlatform != TargetPlatform.android;

  // `onGeolocationPermissionsHidePrompt` is deliberately not tested. Nothing a test can do raised
  // it on API 37: navigating away with the prompt pending, reloading, and navigating cross-site
  // were each tried, and none was reported (§192).
  skippableTestWidgets('onGeolocationPermissionsShowPrompt', (
    WidgetTester tester,
  ) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<String> promptOrigin = Completer<String>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          // Geolocation needs a secure origin, which an https base URL gives the page.
          initialData: InAppWebViewInitialData(
            data:
                '<!DOCTYPE html><html><body>geo<script>var geo = "pending";</script>'
                '</body></html>',
            baseUrl: WebUri('https://example.com/'),
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            if (!pageLoaded.isCompleted) pageLoaded.complete();
          },
          onGeolocationPermissionsShowPrompt: (controller, origin) async {
            if (!promptOrigin.isCompleted) promptOrigin.complete(origin);
            return GeolocationPermissionShowPromptResponse(
              origin: origin,
              allow: false,
              retain: false,
            );
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;

    await controller.evaluateJavascript(
      source:
          'navigator.geolocation.getCurrentPosition('
          'function() { geo = "granted"; },'
          'function(e) { geo = "denied " + e.code; });',
    );

    expect(
      await promptOrigin.future.timeout(const Duration(seconds: 15)),
      'https://example.com/',
    );

    // The answer must reach the page: a refusal is PERMISSION_DENIED (code 1).
    String? geo;
    for (var i = 0; i < 50; i++) {
      geo = await controller.evaluateJavascript(source: 'geo');
      if (geo != 'pending') break;
      await Future.delayed(const Duration(milliseconds: 100));
    }
    expect(geo, 'denied 1');
  }, skip: shouldSkip);

  // The refusal above is also what the plugin answers when Dart says nothing, so it cannot tell a
  // used answer from an ignored one. This test answers the opposite on every field and reads each
  // one back (§215). Measured on API 37: the page gets POSITION_UNAVAILABLE (code 2) rather than
  // PERMISSION_DENIED, because the app holds no runtime location permission, and the decision is
  // stored under the origin the prompt reported.
  skippableTestWidgets('onGeolocationPermissionsShowPrompt allow and retain', (
    WidgetTester tester,
  ) async {
    final permissions = GeolocationPermissions.instance();
    // Process-wide: a decision left behind would stop the prompt firing in later tests.
    await permissions.clearAll();
    addTearDown(permissions.clearAll);

    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<String> promptOrigin = Completer<String>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialData: InAppWebViewInitialData(
            data:
                '<!DOCTYPE html><html><body>geo<script>var geo = "pending";</script>'
                '</body></html>',
            baseUrl: WebUri('https://example.com/'),
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            if (!pageLoaded.isCompleted) pageLoaded.complete();
          },
          onGeolocationPermissionsShowPrompt: (controller, origin) async {
            if (!promptOrigin.isCompleted) promptOrigin.complete(origin);
            return GeolocationPermissionShowPromptResponse(
              origin: origin,
              allow: true,
              retain: true,
            );
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;

    await controller.evaluateJavascript(
      source:
          'navigator.geolocation.getCurrentPosition('
          'function() { geo = "granted"; },'
          'function(e) { geo = "denied " + e.code; }, {timeout: 8000});',
    );

    expect(
      await promptOrigin.future.timeout(const Duration(seconds: 15)),
      'https://example.com/',
    );

    String? geo;
    for (var i = 0; i < 120; i++) {
      geo = await controller.evaluateJavascript(source: 'geo');
      if (geo != 'pending') break;
      await Future.delayed(const Duration(milliseconds: 100));
    }
    expect(geo, isNot('pending'));
    expect(geo, isNot('denied 1'), reason: 'the allow was not used');

    expect(
      await permissions.getAllowed(origin: 'https://example.com/'),
      isTrue,
      reason: 'retain was not used',
    );
    expect(await permissions.getOrigins(), ['https://example.com/']);
  }, skip: shouldSkip);

  // iOS 27: `WKUIDelegate.webView(_:requestGeolocationPermissionFor:initiatedByFrame:decisionHandler:)`
  // (§352). Measured first on an iPhone 17 (iOS 27.0.1) in a normal app: the event fires once per page,
  // with the origin without a trailing slash; `allow: false` reaches the page as PERMISSION_DENIED in
  // about 10 ms; `allow: true` grants the position; a `null` answer gives WebKit's own website prompt,
  // which is also what a plugin that doesn't implement the method gets. That last case needs a tap, so
  // it isn't tested here.
  //
  // 🚨 **WebKit holds a geolocation request while the page isn't on screen**: polling with
  // `Future.delayed` left the request pending for 12 s with no event, on the simulator and on the device;
  // pumping frames while polling delivered it in 422 ms. So this test pumps.
  //
  // `allow: true` is read as "not PERMISSION_DENIED": whether a position follows depends on the
  // simulator's or device's location authorization and fix, which the test doesn't control.
  final iosShouldSkip =
      !InAppWebView.isPropertySupported(
        PlatformWebViewCreationParamsProperty
            .onGeolocationPermissionsShowPrompt,
      ) ||
      defaultTargetPlatform != TargetPlatform.iOS;
  for (final allow in [false, true]) {
    skippableTestWidgets(
      'onGeolocationPermissionsShowPrompt on iOS 27: allow $allow reaches the page',
      (WidgetTester tester) async {
        if ((_iosMajorVersion() ?? 0) < 27) {
          markTestSkipped('the geolocation permission delegate needs iOS 27');
          return;
        }
        final controllerCompleter = Completer<InAppWebViewController>();
        final pageLoaded = Completer<void>();
        final origins = <String>[];

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialData: InAppWebViewInitialData(
                data:
                    '<!DOCTYPE html><html><body>geo<script>var geo = "pending";</script>'
                    '</body></html>',
                baseUrl: WebUri('https://example.com/'),
              ),
              onWebViewCreated: controllerCompleter.complete,
              onLoadStop: (controller, url) {
                if (!pageLoaded.isCompleted) pageLoaded.complete();
              },
              onGeolocationPermissionsShowPrompt: (controller, origin) async {
                origins.add(origin);
                return GeolocationPermissionShowPromptResponse(
                  origin: origin,
                  allow: allow,
                );
              },
            ),
          ),
        );
        final controller = await controllerCompleter.future;
        await pageLoaded.future;

        await controller.evaluateJavascript(
          source:
              'navigator.geolocation.getCurrentPosition('
              'function() { geo = "granted"; },'
              'function(e) { geo = "denied " + e.code; }, {timeout: 8000});',
        );
        String? geo;
        for (var i = 0; i < 150; i++) {
          geo = await controller.evaluateJavascript(source: 'geo');
          if (geo != 'pending') break;
          await tester.pump(const Duration(milliseconds: 100));
        }

        expect(origins, ['https://example.com']);
        expect(geo, isNot('pending'));
        if (allow) {
          expect(geo, isNot('denied 1'), reason: 'the allow was not used');
        } else {
          expect(geo, 'denied 1');
        }
      },
      skip: iosShouldSkip,
    );
  }
}
