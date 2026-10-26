part of 'main.dart';

/// `globalPrivacyControlEnabled` (iOS 27): the Global Privacy Control signal, read on both sides. A
/// Dart `HttpServer` inside the test records the `Sec-GPC` header of every request it gets, and the
/// page reports `navigator.globalPrivacyControl`.
///
/// 🚨 **Measured (§351, iOS 27.0 simulator): WebKit sends `Sec-GPC` only to a secure origin.** Over
/// loopback (`http://127.0.0.1`, a secure context) the main frame and a subresource both carried
/// `Sec-GPC: 1`; the same server reached through the LAN address (not a secure context) got no header,
/// while the page still reported `navigator.globalPrivacyControl` as `true`. Both halves are pinned.
void globalPrivacyControl() {
  final shouldSkip =
      !InAppWebViewSettings.isPropertySupported(
        InAppWebViewSettingsProperty.globalPrivacyControlEnabled,
      ) ||
      defaultTargetPlatform != TargetPlatform.iOS;
  // `isPropertySupported` answers about the platform, not the OS version (see
  // `conversation_context.dart`), so the version gate is separate.
  final belowIOS27 = (_iosMajorVersion() ?? 0) < 27;

  skippableTestWidgets(
    'globalPrivacyControlEnabled sends the GPC signal, and responds to setSettings',
    (WidgetTester tester) async {
      if (belowIOS27) {
        markTestSkipped(
          'WKWebpagePreferences.globalPrivacyControlEnabled needs iOS 27',
        );
        return;
      }

      // Path -> the Sec-GPC header that request carried (null: none).
      final received = <String, String?>{};
      final server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
      addTearDown(server.close);
      server.listen((request) {
        received[request.uri.path] = request.headers.value('sec-gpc');
        request.response.headers.contentType = ContentType.html;
        request.response.write('<html><body>${request.uri.path}</body></html>');
        request.response.close();
      });
      var loadCount = 0;

      // One page load and one subresource fetch from it: (navigator.globalPrivacyControl,
      // isSecureContext, the page's Sec-GPC, the subresource's Sec-GPC).
      Future<(Object?, Object?, String?, String?)> load(
        InAppWebViewController controller,
        Stream<String> loads,
        String host,
      ) async {
        final page = '/page-${loadCount++}';
        final url = WebUri('http://$host:${server.port}$page');
        final loaded = loads.first;
        await controller.loadUrl(urlRequest: URLRequest(url: url));
        expect(await loaded, url.toString());
        final result = await controller.callAsyncJavaScript(
          functionBody:
              "await fetch('$page-sub');"
              'return [navigator.globalPrivacyControl, window.isSecureContext];',
        );
        final List<dynamic> values = result!.value;
        return (values[0], values[1], received[page], received['$page-sub']);
      }

      Future<(InAppWebViewController, Stream<String>)> open(
        InAppWebViewSettings settings,
      ) async {
        final created = Completer<InAppWebViewController>();
        final loads = StreamController<String>.broadcast();
        addTearDown(loads.close);
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialSettings: settings,
              onWebViewCreated: created.complete,
              onLoadStop: (controller, url) => loads.add(url.toString()),
            ),
          ),
        );
        return (await created.future, loads.stream);
      }

      const loopback = '127.0.0.1';

      // The control: unset leaves WebKit untouched, so no header and no `navigator.globalPrivacyControl`
      // at all (`undefined`, read as null). Measured: assigning `false` instead makes it `false`, which
      // is why an unset setting assigns nothing (§351).
      final (controller, loads) = await open(InAppWebViewSettings());
      expect(await load(controller, loads, loopback), (null, true, null, null));

      // Per-navigation, so a `setSettings` change reaches the next load (the doc's claim).
      await controller.setSettings(
        settings: InAppWebViewSettings(globalPrivacyControlEnabled: true),
      );
      expect(await load(controller, loads, loopback), (true, true, '1', '1'));

      // A non-secure origin: the JS flag, but no header (see the doc comment above).
      expect(await load(controller, loads, environment['NODE_SERVER_IP']!), (
        true,
        false,
        null,
        null,
      ));

      // Explicitly off: assigned, so the JS flag reads `false` rather than `undefined`.
      await controller.setSettings(
        settings: InAppWebViewSettings(globalPrivacyControlEnabled: false),
      );
      expect(await load(controller, loads, loopback), (
        false,
        true,
        null,
        null,
      ));

      // And at creation.
      final (created, createdLoads) = await open(
        InAppWebViewSettings(globalPrivacyControlEnabled: true),
      );
      expect(await load(created, createdLoads, loopback), (
        true,
        true,
        '1',
        '1',
      ));
    },
    skip: shouldSkip,
  );
}
