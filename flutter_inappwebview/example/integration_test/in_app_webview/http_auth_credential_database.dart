part of 'main.dart';

void httpAuthCredentialDatabase() {
  final shouldSkip = !HttpAuthCredentialDatabase.isClassSupported();

  skippableGroup('Http Auth Credential Database', () {
    skippableTestWidgets('use saved credentials', (WidgetTester tester) async {
      HttpAuthCredentialDatabase httpAuthCredentialDatabase =
          HttpAuthCredentialDatabase.instance();
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      httpAuthCredentialDatabase.setHttpAuthCredential(
        protectionSpace: URLProtectionSpace(
          host: environment["NODE_SERVER_IP"]!,
          protocol: "http",
          realm: "Node",
          port: 8081,
        ),
        credential: URLCredential(username: "USERNAME", password: "PASSWORD"),
      );

      await InAppWebViewController.clearAllCache();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(
              url: WebUri("http://${environment["NODE_SERVER_IP"]}:8081/"),
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
            onReceivedHttpAuthRequest: (controller, challenge) async {
              return new HttpAuthResponse(
                action: HttpAuthResponseAction.USE_SAVED_HTTP_AUTH_CREDENTIALS,
              );
            },
          ),
        ),
      );
      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      final String h1Content = await controller.evaluateJavascript(
        source: "document.body.querySelector('h1').textContent",
      );
      expect(h1Content, "Authorized");

      var credentials = await httpAuthCredentialDatabase.getHttpAuthCredentials(
        protectionSpace: URLProtectionSpace(
          host: environment["NODE_SERVER_IP"]!,
          protocol: "http",
          realm: "Node",
          port: 8081,
        ),
      );
      expect(credentials.length, 1);

      await httpAuthCredentialDatabase.clearAllAuthCredentials();
      credentials = await httpAuthCredentialDatabase.getHttpAuthCredentials(
        protectionSpace: URLProtectionSpace(
          host: environment["NODE_SERVER_IP"]!,
          protocol: "http",
          realm: "Node",
          port: 8081,
        ),
      );
      expect(credentials, isEmpty);
    });

    skippableTestWidgets('save credentials', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await InAppWebViewController.clearAllCache();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(
              url: WebUri("http://${environment["NODE_SERVER_IP"]}:8081/"),
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
            onReceivedHttpAuthRequest: (controller, challenge) async {
              return new HttpAuthResponse(
                username: "USERNAME",
                password: "PASSWORD",
                action: HttpAuthResponseAction.PROCEED,
                permanentPersistence: true,
              );
            },
          ),
        ),
      );
      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      final String h1Content = await controller.evaluateJavascript(
        source: "document.body.querySelector('h1').textContent",
      );
      expect(h1Content, "Authorized");
    });

    // The two tests below run against port **8084**, the fixture's second protected origin, and
    // must keep running against it. Port 8081 is single-use per process: the two tests above
    // authenticate successfully there, after which Chromium pre-authenticates that origin and
    // `onReceivedHttpAuthRequest` never fires for it again — `clearAllCache()` does not clear the
    // HTTP-auth cache and the plugin exposes nothing that does. A test that needs to *observe* a
    // challenge therefore has to run somewhere no earlier test has unlocked. Neither of these ever
    // authenticates successfully, so 8084 stays locked for the whole run.

    skippableTestWidgets('a credential saved for another protection space is not offered', (
      WidgetTester tester,
    ) async {
      final httpAuthCredentialDatabase = HttpAuthCredentialDatabase.instance();
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await httpAuthCredentialDatabase.clearAllAuthCredentials();

      // Saved for 8081/realm "Node" — a different port *and* a different realm from the origin
      // this WebView will visit, so it is a different `URLProtectionSpace` in two dimensions.
      httpAuthCredentialDatabase.setHttpAuthCredential(
        protectionSpace: URLProtectionSpace(
          host: environment["NODE_SERVER_IP"]!,
          protocol: "http",
          realm: "Node",
          port: 8081,
        ),
        credential: URLCredential(username: "USERNAME", password: "PASSWORD"),
      );

      var challenges = 0;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(
              url: WebUri("http://${environment["NODE_SERVER_IP"]}:8084/"),
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              if (!pageLoaded.isCompleted) {
                pageLoaded.complete();
              }
            },
            onReceivedHttpAuthRequest: (controller, challenge) async {
              challenges++;
              // Ask for whatever is saved for *this* space. Nothing is, and the credential
              // saved above belongs to another one, so the guard is what decides the outcome.
              return HttpAuthResponse(
                action: challenges > 2
                    ? HttpAuthResponseAction.CANCEL
                    : HttpAuthResponseAction.USE_SAVED_HTTP_AUTH_CREDENTIALS,
              );
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      // The challenge firing at all is half the assertion: it proves 8084 is genuinely locked
      // and that this test is measuring something. Without it the check below would pass on an
      // origin that simply never asked.
      expect(
        challenges,
        greaterThan(0),
        reason:
            'no challenge fired — 8084 was already unlocked, so this '
            'test proves nothing. Check no earlier test authenticates there.',
      );

      final String h1Content = await controller.evaluateJavascript(
        source: "document.body.querySelector('h1').textContent",
      );
      expect(
        h1Content,
        "Unauthorized",
        reason:
            'the credential saved for 8081/"Node" was offered to '
            '8084/"Node2"',
      );

      await httpAuthCredentialDatabase.clearAllAuthCredentials();
    });

    skippableTestWidgets('previousFailureCount rises with each failure', (
      WidgetTester tester,
    ) async {
      final Completer<void> done = Completer<void>();
      final counts = <int>[];

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(
              url: WebUri("http://${environment["NODE_SERVER_IP"]}:8084/"),
            ),
            // Completion is driven by the challenges themselves, not by a load event. After
            // `CANCEL` the platforms do different things — Android settles the load and fires
            // `onLoadStop`, iOS treats it as a failed navigation and fires neither — so waiting on
            // a page event here times out on one platform. The challenges are what this test is
            // about, so they are what it waits for.
            onReceivedHttpAuthRequest: (controller, challenge) async {
              counts.add(challenge.previousFailureCount);
              if (counts.length >= 3) {
                if (!done.isCompleted) {
                  done.complete();
                }
                return HttpAuthResponse(action: HttpAuthResponseAction.CANCEL);
              }
              // Deliberately wrong: 8084 wants USERNAME2/PASSWORD2. Each rejection produces
              // another challenge, which is the sequence being measured.
              return HttpAuthResponse(
                username: "WRONG",
                password: "WRONG",
                action: HttpAuthResponseAction.PROCEED,
              );
            },
          ),
        ),
      );

      await done.future;

      expect(
        counts.length,
        greaterThanOrEqualTo(2),
        reason: 'expected repeated challenges after failed credentials',
      );
      // **Deliberately not asserting the first value.** Android counts the challenges, so it
      // starts at 1; iOS forwards `URLAuthenticationChallenge.previousFailureCount`, which starts
      // at 0 because nothing has failed yet. That divergence is documented on the field and was
      // preserved on purpose, so a literal here would pin one platform and fail on the other.
      // What both must agree on is that it rises.
      for (var i = 1; i < counts.length; i++) {
        expect(
          counts[i],
          greaterThan(counts[i - 1]),
          reason: 'previousFailureCount did not rise: $counts',
        );
      }
    });
  }, skip: shouldSkip);
}
