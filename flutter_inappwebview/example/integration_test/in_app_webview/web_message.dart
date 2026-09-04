part of 'main.dart';

void webMessage() {
  final shouldSkip = !WebMessageChannel.isClassSupported();

  skippableGroup('WebMessage', () {
    skippableTestWidgets('WebMessageChannel post String', (
      WidgetTester tester,
    ) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer webMessageCompleter = Completer<String>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialData: InAppWebViewInitialData(
              data: """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WebMessageChannel Test</title>
</head>
<body>
    <button id="button" onclick="port.postMessage(input.value);" />Send</button>
    <br />
    <input id="input" type="text" value="JavaScript To Native" />

    <script>
      var port;
      window.addEventListener('message', function(event) {
          if (event.data == 'capturePort') {
              if (event.ports[0] != null) {
                  port = event.ports[0];
                  port.onmessage = function (event) {
                      console.log(event.data);
                  };
              }
          }
      }, false);
    </script>
</body>
</html>
                      """,
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onConsoleMessage: (controller, consoleMessage) {
              webMessageCompleter.complete(consoleMessage.message);
            },
            onLoadStop: (controller, url) async {
              var webMessageChannel = await controller
                  .createWebMessageChannel();
              var port1 = webMessageChannel!.port1;
              var port2 = webMessageChannel.port2;

              await port1.setWebMessageCallback((message) async {
                await port1.postMessage(
                  WebMessage(data: message!.data + " and back"),
                );
              });
              await controller.postWebMessage(
                message: WebMessage(data: "capturePort", ports: [port2]),
                targetOrigin: WebUri("*"),
              );
              await controller.evaluateJavascript(
                source: "document.getElementById('button').click();",
              );
            },
          ),
        ),
      );
      await controllerCompleter.future;

      final String message = await webMessageCompleter.future;
      expect(message, 'JavaScript To Native and back');
    });

    skippableTestWidgets('WebMessageChannel post ArrayBuffer', (
      WidgetTester tester,
    ) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer webMessageCompleter = Completer<String>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialData: InAppWebViewInitialData(
              data: """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WebMessageChannel Test</title>
</head>
<body>
    <button id="button" onclick="port.postMessage(stringToBuffer(input.value));" />Send</button>
    <br />
    <input id="input" type="text" value="JavaScript To Native" />

    <script>
      function bufferToString(buffer) {
          return String.fromCharCode.apply(null, Array.from(new Uint8Array(buffer)));
      }
      
      function stringToBuffer(value) {
          var buffer = new ArrayBuffer(value.length);
          var view = new Uint8Array(buffer);
          for (var i = 0, length = value.length; i < length; i++) {
              view[i] = value.charCodeAt(i);
          }
          return buffer;
      }
      
      var port;
      window.addEventListener('message', function(event) {
          if (bufferToString(event.data) == 'capturePort') {
              if (event.ports[0] != null) {
                  port = event.ports[0];
                  port.onmessage = function (event) {
                      console.log(bufferToString(event.data));
                  };
              }
          }
      }, false);
    </script>
</body>
</html>
                      """,
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onConsoleMessage: (controller, consoleMessage) {
              webMessageCompleter.complete(consoleMessage.message);
            },
            onLoadStop: (controller, url) async {
              var webMessageChannel = await controller
                  .createWebMessageChannel();
              var port1 = webMessageChannel!.port1;
              var port2 = webMessageChannel.port2;

              await port1.setWebMessageCallback((message) async {
                await port1.postMessage(
                  WebMessage(
                    data: utf8.encode(utf8.decode(message!.data) + " and back"),
                    type: WebMessageType.ARRAY_BUFFER,
                  ),
                );
              });
              await controller.postWebMessage(
                message: WebMessage(
                  data: utf8.encode("capturePort"),
                  type: WebMessageType.ARRAY_BUFFER,
                  ports: [port2],
                ),
                targetOrigin: WebUri("*"),
              );
              await controller.evaluateJavascript(
                source: "document.getElementById('button').click();",
              );
            },
          ),
        ),
      );
      await controllerCompleter.future;

      final String message = await webMessageCompleter.future;
      expect(message, 'JavaScript To Native and back');
    });

    skippableTestWidgets('WebMessageListener post String', (
      WidgetTester tester,
    ) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();
      final Completer webMessageCompleter = Completer<String>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            onWebViewCreated: (controller) async {
              await controller.addWebMessageListener(
                WebMessageListener(
                  jsObjectName: "myTestObj",
                  allowedOriginRules: Set.from(["https://*.example.com"]),
                  onPostMessage:
                      (message, sourceOrigin, isMainFrame, replyProxy) {
                        if (isMainFrame &&
                            (sourceOrigin.toString() + '/') ==
                                TEST_URL_EXAMPLE.toString()) {
                          replyProxy.postMessage(
                            WebMessage(data: message!.data + " and back"),
                          );
                        } else {
                          replyProxy.postMessage(WebMessage(data: "Nope"));
                        }
                      },
                ),
              );
              controllerCompleter.complete(controller);
            },
            onConsoleMessage: (controller, consoleMessage) {
              webMessageCompleter.complete(consoleMessage.message);
            },
            onLoadStop: (controller, url) async {
              if (url.toString() == TEST_URL_EXAMPLE.toString()) {
                pageLoaded.complete();
              }
            },
          ),
        ),
      );
      final controller = await controllerCompleter.future;
      await controller.loadUrl(urlRequest: URLRequest(url: TEST_URL_EXAMPLE));
      await pageLoaded.future;

      await controller.evaluateJavascript(
        source: """
          myTestObj.addEventListener('message', function(event) {
            console.log(event.data);
          });
          myTestObj.postMessage('JavaScript To Native');
        """,
      );

      final String message = await webMessageCompleter.future;
      expect(message, 'JavaScript To Native and back');
    });

    skippableTestWidgets('WebMessageListener post ArrayBuffer', (
      WidgetTester tester,
    ) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();
      final Completer webMessageCompleter = Completer<String>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            onWebViewCreated: (controller) async {
              await controller.addWebMessageListener(
                WebMessageListener(
                  jsObjectName: "myTestObj",
                  allowedOriginRules: Set.from(["https://*.example.com"]),
                  onPostMessage:
                      (message, sourceOrigin, isMainFrame, replyProxy) {
                        if (isMainFrame &&
                            (sourceOrigin.toString() + '/') ==
                                TEST_URL_EXAMPLE.toString()) {
                          replyProxy.postMessage(
                            WebMessage(
                              data: utf8.encode(
                                utf8.decode(message!.data) + " and back",
                              ),
                              type: WebMessageType.ARRAY_BUFFER,
                            ),
                          );
                        } else {
                          replyProxy.postMessage(
                            WebMessage(
                              data: utf8.encode("Nope"),
                              type: WebMessageType.ARRAY_BUFFER,
                            ),
                          );
                        }
                      },
                ),
              );
              controllerCompleter.complete(controller);
            },
            onConsoleMessage: (controller, consoleMessage) {
              webMessageCompleter.complete(consoleMessage.message);
            },
            onLoadStop: (controller, url) async {
              if (url.toString() == TEST_URL_EXAMPLE.toString()) {
                pageLoaded.complete();
              }
            },
          ),
        ),
      );
      final controller = await controllerCompleter.future;
      await controller.loadUrl(urlRequest: URLRequest(url: TEST_URL_EXAMPLE));
      await pageLoaded.future;

      await controller.evaluateJavascript(
        source: """
          function bufferToString(buffer) {
              return String.fromCharCode.apply(null, Array.from(new Uint8Array(buffer)));
          }
          
          function stringToBuffer(value) {
              var buffer = new ArrayBuffer(value.length);
              var view = new Uint8Array(buffer);
              for (var i = 0, length = value.length; i < length; i++) {
                  view[i] = value.charCodeAt(i);
              }
              return buffer;
          }
          
          myTestObj.addEventListener('message', function(event) {
            console.log(bufferToString(event.data));
          });
          myTestObj.postMessage(stringToBuffer('JavaScript To Native'));
        """,
      );

      final String message = await webMessageCompleter.future;
      expect(message, 'JavaScript To Native and back');
    });
    skippableTestWidgets('WebMessageListener wildcard rule is end-anchored', (
      WidgetTester tester,
    ) async {
      // The page origin is `foo.example.com.evil.test`: a host that *contains* `.example.com` but
      // whose registrable domain belongs to somebody else. The rule `https://*.example.com` must
      // not reach it. Before the fix the check was `host.indexOf(suffix) >= 0`, so it did.
      //
      // A `baseUrl` is what makes this fixture-free and DNS-free — the document takes the origin
      // of the base URL without anything being fetched, so the attacker host does not have to
      // exist. It is also the exact real-world shape, which a reachable host could not have been.
      const attackerOrigin = 'https://foo.example.com.evil.test/';

      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            onWebViewCreated: (controller) async {
              await controller.addWebMessageListener(
                WebMessageListener(
                  jsObjectName: "myUnanchoredObj",
                  allowedOriginRules: Set.from(["https://*.example.com"]),
                  onPostMessage:
                      (message, sourceOrigin, isMainFrame, replyProxy) {},
                ),
              );
              // The control. Without it a broken injection path — a JS syntax error, a listener
              // never registered, the page never loading — would satisfy the assertion below for
              // entirely the wrong reason.
              await controller.addWebMessageListener(
                WebMessageListener(
                  jsObjectName: "myAnchoredObj",
                  allowedOriginRules: Set.from(["https://*.evil.test"]),
                  onPostMessage:
                      (message, sourceOrigin, isMainFrame, replyProxy) {},
                ),
              );
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) async {
              if (!pageLoaded.isCompleted) {
                pageLoaded.complete();
              }
            },
          ),
        ),
      );
      final controller = await controllerCompleter.future;
      await controller.loadData(
        data: "<html><body>anchored</body></html>",
        baseUrl: WebUri(attackerOrigin),
      );
      await pageLoaded.future;

      final hostname = await controller.evaluateJavascript(
        source: "window.location.hostname",
      );
      final unanchored = await controller.evaluateJavascript(
        source: "typeof window.myUnanchoredObj",
      );
      final anchored = await controller.evaluateJavascript(
        source: "typeof window.myAnchoredObj",
      );

      // If the base URL did not carry its origin to the document, every assertion below is
      // meaningless — say so instead of reporting a pass.
      expect(hostname, 'foo.example.com.evil.test');
      expect(
        anchored,
        'object',
        reason: 'the control listener must be installed',
      );
      expect(
        unanchored,
        'undefined',
        reason:
            'https://*.example.com must not match foo.example.com.evil.test',
      );
    });

    skippableTestWidgets(
      'WebMessageListener contentWorld isolates the injected object',
      (WidgetTester tester) async {
        // Two listeners, added at the same moment and differing only in their content world.
        // Both halves are load-bearing: the page-world one proves the injection path works at
        // all, so a `undefined` from the isolated one means isolation rather than a listener
        // that was never installed. A single-sided test passes against an implementation that
        // ignores `contentWorld` entirely — that is exactly mutant A below.
        const worldName = 'myIsolatedWorld';

        final Completer<InAppWebViewController> controllerCompleter =
            Completer<InAppWebViewController>();
        final Completer<void> pageLoaded = Completer<void>();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              onWebViewCreated: (controller) async {
                await controller.addWebMessageListener(
                  WebMessageListener(
                    jsObjectName: "myIsolatedObj",
                    contentWorld: ContentWorld.world(name: worldName),
                    onPostMessage:
                        (message, sourceOrigin, isMainFrame, replyProxy) {},
                  ),
                );
                await controller.addWebMessageListener(
                  WebMessageListener(
                    jsObjectName: "myPageObj",
                    onPostMessage:
                        (message, sourceOrigin, isMainFrame, replyProxy) {},
                  ),
                );
                controllerCompleter.complete(controller);
              },
              onLoadStop: (controller, url) async {
                if (!pageLoaded.isCompleted) {
                  pageLoaded.complete();
                }
              },
            ),
          ),
        );
        final controller = await controllerCompleter.future;
        await controller.loadUrl(urlRequest: URLRequest(url: TEST_URL_EXAMPLE));
        await pageLoaded.future;

        // Read both names from both worlds. Four answers, and only one arrangement of them is
        // consistent with the worlds actually being separate.
        Future<Object?> readFromPage(String name) =>
            controller.evaluateJavascript(source: "typeof window.$name");
        Future<Object?> readFromWorld(String name) =>
            controller.evaluateJavascript(
              source: "typeof window.$name",
              contentWorld: ContentWorld.world(name: worldName),
            );

        expect(
          await readFromPage('myPageObj'),
          'object',
          reason:
              'the page-world control must be installed, or nothing below means anything',
        );
        expect(
          await readFromPage('myIsolatedObj'),
          'undefined',
          reason:
              'a listener asked for an isolated world must not be visible to page scripts',
        );
        expect(
          await readFromWorld('myIsolatedObj'),
          'object',
          reason:
              'the isolated listener must be reachable from its own content world',
        );
        expect(
          await readFromWorld('myPageObj'),
          'undefined',
          reason: 'a page-world listener must not leak into the isolated world',
        );
      },
      // iOS-only by design. Android's `ContentWorld` is an `<iframe>` emulation that
      // `androidx`'s isolated worlds are not part of; see the dartdoc on
      // `PlatformWebMessageListenerCreationParams.contentWorld`.
      skip:
          shouldSkip ||
          !WebMessageListener.isPropertySupported(
            PlatformWebMessageListenerCreationParamsProperty.contentWorld,
          ),
    );
  }, skip: shouldSkip);
}
