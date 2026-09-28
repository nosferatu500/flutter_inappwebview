part of 'main.dart';

/// Records every request Chrome makes to it. It listens on the device's own loopback, which the
/// Custom Tab can reach, so a test can read exactly what Chrome sent without the fixture server.
class _RequestRecorder {
  _RequestRecorder._(this._server) {
    _server.listen((request) {
      requests.add(request);
      request.response
        ..headers.contentType = ContentType.html
        ..write('<html><body>recorded</body></html>')
        ..close();
    });
  }

  static Future<_RequestRecorder> start() async => _RequestRecorder._(
    await HttpServer.bind(InternetAddress.loopbackIPv4, 0),
  );

  final HttpServer _server;
  final List<HttpRequest> requests = [];

  WebUri url(String pathAndQuery) =>
      WebUri('http://127.0.0.1:${_server.port}$pathAndQuery');

  /// The page request for [path], leaving out Chrome's own `/favicon.ico` fetch.
  HttpRequest document(String path) =>
      requests.singleWhere((r) => r.uri.path == path);

  Future<void> close() => _server.close(force: true);
}

/// What `ChromeSafariBrowserManager` receives, asserted before that channel is migrated (§200): the
/// same net §196 put under `InAppBrowserManager`. Each assertion is on a value only the right field
/// produces. Values measured on API 37 with Chrome 152.
///
/// Not covered, and why (each measured, not assumed):
///   * `referrer`: Chrome replaced both an `android-app://` and an `https://` referrer with
///     `android-app://dev.nosferatu500.inappwebview.example/`, so the field has no effect a server
///     can see.
///   * `otherLikelyURLs`: Chrome never requested the likely URL.
///   * `headers` other than CORS-safelisted ones: Chrome dropped `x-probe`; `accept-language` is
///     the one asserted.
///   * `isSingleInstance: true` and `noHistory: true`: the page request was identical to a plain
///     open. Only their key-presence reads are asserted, by the null test below.
///   * `actionButton`, `menuItemList`, `secondaryToolbar`: Chrome's own UI, which a test cannot read.
///     Their ints (`id`) are cast `as Int` when the Activity starts, so the existing tests that open
///     with them would crash the app if an int ever arrived as a `Long`.
void openPayload() {
  final shouldSkip =
      !ChromeSafariBrowser.isClassSupported() || !Platform.isAndroid;

  skippableGroup('open payload', () {
    late _RequestRecorder recorder;

    setUp(() async {
      recorder = await _RequestRecorder.start();
    });

    tearDown(() async {
      await recorder.close();
    });

    Future<void> openAndClose(
      String path, {
      Map<String, String>? headers,
      ChromeSafariBrowserSettings? settings,
    }) async {
      final browser = MyChromeSafariBrowser();
      await browser.open(
        url: recorder.url(path),
        headers: headers,
        settings: settings,
      );
      await browser.firstPageLoaded.future.timeout(const Duration(seconds: 30));
      await browser.close();
      await browser.closed.future.timeout(const Duration(seconds: 10));
    }

    skippableTest('open carries the url and the headers', () async {
      // The favicon request from the same tab carries Chrome's own `en-US`, so `it-IT` on the page
      // request can only have come from `headers`.
      await openAndClose('/payload?q=1', headers: {'accept-language': 'it-IT'});
      final page = recorder.document('/payload');
      expect(page.uri.toString(), '/payload?q=1');
      expect(page.headers.value('accept-language'), 'it-IT');
    });

    skippableTest('isTrustedWebActivity opens a Trusted Web Activity', () async {
      // The only request difference measured between the four launch targets: Chrome marks a
      // Trusted Web Activity's first load as user-initiated. The plain open is the control.
      await openAndClose('/plain');
      await openAndClose(
        '/twa',
        settings: ChromeSafariBrowserSettings(isTrustedWebActivity: true),
      );
      expect(
        recorder.document('/plain').headers.value('sec-fetch-user'),
        isNull,
      );
      expect(recorder.document('/twa').headers.value('sec-fetch-user'), '?1');
    });

    skippableTest('an int nested in the settings reaches the parser', () async {
      // `displayMode.displayCutoutMode` is the one int the settings parser reads out of a nested
      // map (`as Int`), and it is null by default, so no other test sends it. It has no effect a
      // test can see; the check is that the Activity starts rather than crashing on the cast.
      await openAndClose(
        '/display-mode',
        settings: ChromeSafariBrowserSettings(
          isTrustedWebActivity: true,
          displayMode: TrustedWebActivityImmersiveDisplayMode(
            isSticky: true,
            displayCutoutMode: LayoutInDisplayCutoutMode.SHORT_EDGES,
          ),
        ),
      );
      expect(recorder.document('/display-mode').uri.path, '/display-mode');
    });

    skippableTest('a null launch setting is not treated as absent', () async {
      // Pinned, not endorsed (§200). The manager reads these three keys by *presence*
      // (`Util.getOrDefault`), and `toMap()` always sends them, so a null arrives as a present
      // key and fails unboxing before anything is launched. This is the only observable of each
      // read: a transport that dropped null-valued keys would open the browser instead.
      for (final settings in [
        ChromeSafariBrowserSettings(isSingleInstance: null),
        ChromeSafariBrowserSettings(isTrustedWebActivity: null),
        ChromeSafariBrowserSettings(noHistory: null),
      ]) {
        await expectLater(
          MyChromeSafariBrowser().open(
            url: recorder.url('/null'),
            settings: settings,
          ),
          throwsA(
            isA<PlatformException>().having(
              (e) => e.message,
              'message',
              contains('booleanValue()'),
            ),
          ),
        );
      }
      expect(recorder.requests, isEmpty);
    });

    skippableTest('isAvailable and getMaxToolbarItems', () async {
      expect(await ChromeSafariBrowser.isAvailable(), isTrue);
      // `CustomTabsIntent.MAX_TOOLBAR_ITEMS`.
      expect(await ChromeSafariBrowser.getMaxToolbarItems(), 5);
    });

    skippableTest('getPackageName uses both its arguments', () async {
      // Chrome is the emulator's only Custom Tabs provider. Each call below changes one argument,
      // so a dropped or swapped argument gives a different answer.
      expect(await ChromeSafariBrowser.getPackageName(), 'com.android.chrome');
      expect(
        await ChromeSafariBrowser.getPackageName(
          packages: ['com.android.chrome'],
          ignoreDefault: true,
        ),
        'com.android.chrome',
      );
      expect(
        await ChromeSafariBrowser.getPackageName(
          packages: ['no.such.package'],
          ignoreDefault: true,
        ),
        isNull,
      );
      expect(
        await ChromeSafariBrowser.getPackageName(
          packages: ['no.such.package'],
          ignoreDefault: false,
        ),
        'com.android.chrome',
      );
    });
  }, skip: shouldSkip);
}
