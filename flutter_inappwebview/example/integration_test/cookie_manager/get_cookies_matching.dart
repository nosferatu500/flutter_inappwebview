part of 'main.dart';

/// iOS `getCookies` returns the cookies a request to the URL would send (§353): domain or host-only, path,
/// and Secure. On iOS 27 that's WebKit's own answer (`WKHTTPCookieStore.getCookies(for:)`); below, the
/// plugin's RFC 6265 matcher, which gave the same table on iOS 26.5 as WebKit on iOS 27.0.
///
/// Until §353 the iOS filter was a domain suffix match over every cookie: it ignored path and Secure, gave
/// `example.com`'s host-only cookies to `sub.example.com`, and gave them to `notexample.com` too
/// (`"notexample.com".hasSuffix("example.com")`). Each row below that differs from that old result is a
/// case it got wrong.
void getCookiesMatching() {
  final shouldSkip = defaultTargetPlatform != TargetPlatform.iOS;

  skippableTestWidgets(
    'getCookies returns what a request to the URL would send',
    (WidgetTester tester) async {
      final cookieManager = CookieManager.instance();
      await cookieManager.deleteAllCookies();
      addTearDown(cookieManager.deleteAllCookies);

      Future<void> set(
        String url,
        String name, {
        String? domain,
        String? path,
        bool? secure,
      }) async {
        expect(
          await cookieManager.setCookie(
            url: WebUri(url),
            name: name,
            value: '1',
            domain: domain,
            path: path ?? '/',
            isSecure: secure,
          ),
          isTrue,
          reason: 'setting $name',
        );
      }

      await set('https://example.com/', 'hostOnly');
      await set('https://example.com/', 'domainWide', domain: '.example.com');
      await set('https://example.com/a', 'pathA', path: '/a');
      await set('https://example.com/', 'secureOnly', secure: true);
      await set('https://sub.example.com/', 'subOnly');
      await set('https://notexample.com/', 'otherSite');

      Future<List<String>> namesFor(String url) async =>
          (await cookieManager.getCookies(url: WebUri(url)))
              .map((c) => c.name)
              .toList()
            ..sort();

      final expected = <String, List<String>>{
        'https://example.com/': ['domainWide', 'hostOnly', 'secureOnly'],
        'https://example.com/a': [
          'domainWide',
          'hostOnly',
          'pathA',
          'secureOnly',
        ],
        'https://example.com/a/x': [
          'domainWide',
          'hostOnly',
          'pathA',
          'secureOnly',
        ],
        // `/ab` extends `/a`, but not at a `/`.
        'https://example.com/ab': ['domainWide', 'hostOnly', 'secureOnly'],
        // Secure cookies don't go over plain HTTP.
        'http://example.com/': ['domainWide', 'hostOnly'],
        // Host-only cookies stay on their host; the domain cookie reaches the subdomain.
        'https://sub.example.com/': ['domainWide', 'subOnly'],
        // A different site that merely ends with the same letters.
        'https://notexample.com/': ['otherSite'],
      };
      for (final MapEntry(key: url, value: names) in expected.entries) {
        expect(await namesFor(url), names, reason: url);
      }

      // getCookie goes through the same native call.
      expect(
        await cookieManager.getCookie(
          url: WebUri('http://example.com/'),
          name: 'secureOnly',
        ),
        isNull,
      );
    },
    skip: shouldSkip,
  );
}
