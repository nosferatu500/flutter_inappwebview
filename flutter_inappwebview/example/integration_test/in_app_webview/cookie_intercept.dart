part of 'main.dart';

/// Pins both directions of `androidx.webkit`'s `COOKIE_INTERCEPT` (§125), which the plugin exposes
/// as one setting and one response field:
///
/// - **in** — [InAppWebViewSettings.includeCookiesOnShouldInterceptRequest] puts a `Cookie` header
///   into the [WebResourceRequest] handed to `shouldInterceptRequest`.
/// - **out** — [WebResourceResponse.cookies] applies `Set-Cookie` values from the response you
///   return.
///
/// **Every test here is a pair**, because the interesting failure mode is silence: with the switch
/// off, `cookies` is ignored with nothing thrown and nothing logged. A one-sided test asserting
/// "the cookie arrived" would pass against an implementation that ignored the switch entirely, and
/// a one-sided test asserting "no cookie" would pass against one that had simply stopped
/// intercepting. So each case runs the same code twice, one argument apart.
void cookieIntercept() {
  final shouldSkip = defaultTargetPlatform != TargetPlatform.android;

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 200));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
  }

  skippableTestWidgets(
    'the Cookie header reaches shouldInterceptRequest only when enabled',
    (WidgetTester tester) async {
      if (!await WebViewFeature.isFeatureSupported(
        WebViewFeature.COOKIE_INTERCEPT,
      )) {
        markTestSkipped('COOKIE_INTERCEPT unsupported on this WebView');
        return;
      }

      final origin = 'http://${environment['NODE_SERVER_IP']}:8082';
      await CookieManager.instance().deleteAllCookies();
      await CookieManager.instance().setCookie(
        url: WebUri(origin),
        name: 'interceptProbe',
        value: 'present',
      );

      /// Returns (the Cookie header seen by the intercept, what getSettings() reports).
      Future<(String?, bool?)> load({bool? include}) async {
        String? cookieHeader;
        final Completer<InAppWebViewController> controllerCompleter =
            Completer<InAppWebViewController>();
        final Completer<void> loaded = Completer<void>();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest: URLRequest(url: WebUri(origin)),
              initialSettings: InAppWebViewSettings(
                useShouldInterceptRequest: true,
                includeCookiesOnShouldInterceptRequest: include,
              ),
              onWebViewCreated: (c) => controllerCompleter.complete(c),
              onLoadStop: (c, url) {
                if (!loaded.isCompleted) loaded.complete();
              },
              shouldInterceptRequest: (controller, request) async {
                // The main document only: a favicon request carries the same cookies and would
                // make the assertion pass for the wrong navigation.
                if (request.url.path == '/' && cookieHeader == null) {
                  cookieHeader =
                      request.headers?.entries
                          .firstWhere(
                            (e) => e.key.toLowerCase() == 'cookie',
                            orElse: () => const MapEntry('', ''),
                          )
                          .value ??
                      '';
                }
                return null;
              },
            ),
          ),
        );

        final controller = await controllerCompleter.future;
        await tester.pump();
        await loaded.future.timeout(const Duration(seconds: 30));
        await settle(tester);
        final real = await controller.getSettings();
        return (cookieHeader, real?.includeCookiesOnShouldInterceptRequest);
      }

      // Negative control first, and `null` rather than `false`: this also measures the platform
      // default, which androidx documents nowhere. Measured false on WebView 149 and 151.
      final untouched = await load();
      expect(
        untouched.$2,
        isFalse,
        reason:
            'the platform default for cookie interception was expected to be off; '
            'getSettings() reported ${untouched.$2}',
      );
      expect(
        untouched.$1,
        isNullOrEmpty,
        reason:
            'a Cookie header reached the intercept without the setting being enabled',
      );

      final off = await load(include: false);
      expect(off.$2, isFalse);
      expect(
        off.$1,
        isNullOrEmpty,
        reason: 'an explicit false still let the Cookie header through',
      );

      final on = await load(include: true);
      expect(on.$2, isTrue, reason: 'the setting did not reach the WebView');
      expect(
        on.$1,
        contains('interceptProbe=present'),
        reason:
            'the Cookie header did not reach shouldInterceptRequest when enabled '
            '(got ${on.$1})',
      );
    },
    skip: shouldSkip,
  );

  skippableTestWidgets(
    'WebResourceResponse.cookies applies Set-Cookie only when enabled',
    (WidgetTester tester) async {
      if (!await WebViewFeature.isFeatureSupported(
        WebViewFeature.COOKIE_INTERCEPT,
      )) {
        markTestSkipped('COOKIE_INTERCEPT unsupported on this WebView');
        return;
      }

      final origin = 'http://${environment['NODE_SERVER_IP']}:8082';

      /// Serves an intercepted page that sets three cookies, and reports what stuck.
      Future<(List<String>, String)> load({
        required bool include,
        required String tag,
      }) async {
        await CookieManager.instance().deleteAllCookies();

        final Completer<InAppWebViewController> controllerCompleter =
            Completer<InAppWebViewController>();
        final Completer<void> loaded = Completer<void>();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest: URLRequest(url: WebUri('$origin/ci-$tag')),
              initialSettings: InAppWebViewSettings(
                useShouldInterceptRequest: true,
                javaScriptEnabled: true,
                includeCookiesOnShouldInterceptRequest: include,
              ),
              onWebViewCreated: (c) => controllerCompleter.complete(c),
              onLoadStop: (c, url) {
                if (!loaded.isCompleted) loaded.complete();
              },
              shouldInterceptRequest: (controller, request) async {
                if (!request.url.path.startsWith('/ci-')) return null;
                return WebResourceResponse(
                  contentType: 'text/html',
                  contentEncoding: 'utf-8',
                  statusCode: 200,
                  reasonPhrase: 'OK',
                  headers: {'Content-Type': 'text/html'},
                  // Three, deliberately: a Map of headers could not express more than one
                  // Set-Cookie, which is the reason this is a List and not a header entry.
                  cookies: [
                    'fromIntercept=one; Path=/',
                    'second=two; Path=/',
                    'httpOnlyOne=three; Path=/; HttpOnly',
                  ],
                  data: Uint8List.fromList(
                    utf8.encode('<html><body>ci $tag</body></html>'),
                  ),
                );
              },
            ),
          ),
        );

        final controller = await controllerCompleter.future;
        await tester.pump();
        await loaded.future.timeout(const Duration(seconds: 30));
        await settle(tester);

        final stored = await CookieManager.instance().getCookies(
          url: WebUri(origin),
        );
        final fromScript =
            await controller.evaluateJavascript(source: 'document.cookie')
                as String? ??
            '';
        return (stored.map((c) => '${c.name}=${c.value}').toList(), fromScript);
      }

      final off = await load(include: false, tag: 'off');
      expect(
        off.$1,
        isEmpty,
        reason:
            'response cookies were applied with interception disabled; they are '
            'documented as silently ignored (got ${off.$1})',
      );

      final on = await load(include: true, tag: 'on');
      expect(
        on.$1,
        containsAll(<String>[
          'fromIntercept=one',
          'second=two',
          'httpOnlyOne=three',
        ]),
        reason: 'not every Set-Cookie value was applied (got ${on.$1})',
      );

      // HttpOnly is the assertion that proves these went through the real cookie store rather
      // than anything document.cookie-shaped: script must see the other two and not this one.
      expect(on.$2, contains('fromIntercept=one'));
      expect(on.$2, contains('second=two'));
      expect(
        on.$2,
        isNot(contains('httpOnlyOne')),
        reason:
            'an HttpOnly cookie was readable from script, so these are not real cookies',
      );
    },
    skip: shouldSkip,
  );
}
