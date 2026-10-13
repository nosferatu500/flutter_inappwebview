part of 'main.dart';

void videoPlaybackPolicy() {
  final shouldSkip = !InAppWebViewSettings.isPropertySupported(
    InAppWebViewSettingsProperty.mediaPlaybackRequiresUserGesture,
  );

  skippableGroup('Video playback policy', () {
    String videoTestBase64 = "";
    setUpAll(() async {
      final ByteData videoData = await rootBundle.load(
        'test_assets/sample_video.mp4',
      );
      final String base64VideoData = base64Encode(
        Uint8List.view(videoData.buffer),
      );
      final String videoTest =
          '''
        <!DOCTYPE html><html>
        <head><title>Video auto play</title>
          <script type="text/javascript">
            function play() {
              var video = document.getElementById("video");
              video.play();
            }
            function isPaused() {
              var video = document.getElementById("video");
              return video.paused;
            }
            // `allowsInlineMediaPlayback: false` makes iOS play the video in its own NATIVE
            // fullscreen player, which is not the DOM Fullscreen API: measured on iOS 17.5 and
            // 26.5, `document.fullscreenElement` and `document.webkitFullscreenElement` are both
            // null while `video.webkitDisplayingFullscreen` is true. `document.exitFullscreen()`
            // therefore has nothing to exit and does nothing at all — which is what this test used
            // to call. `HTMLVideoElement.webkitExitFullscreen()` is the one that leaves native
            // video fullscreen, so try it first and keep the DOM calls as the fallback for
            // platforms that really are in document fullscreen.
            function exitFullscreen() {
              var video = document.getElementById("video");
              if (video && video.webkitExitFullscreen) {
                video.webkitExitFullscreen();
              } else if (document.exitFullscreen) {
                document.exitFullscreen();
              } else if (document.webkitExitFullscreen) {
                document.webkitExitFullscreen();
              }
            }
          </script>
        </head>
        <body onload="play();">
        <video controls playsinline autoplay id="video">
          <source src="data:video/mp4;charset=utf-8;base64,$base64VideoData">
        </video>
        </body>
        </html>
      ''';
      videoTestBase64 = base64Encode(const Utf8Encoder().convert(videoTest));
    });

    // Waits for the native fullscreen player, and on a timeout fails with the video's own state, so
    // a hang says whether the video never started or played without going fullscreen (§276: the
    // two fullscreen tests waited without a limit; one hung a run for 17 minutes).
    Future<void> expectEntersFullscreen(
      InAppWebViewController controller,
      Completer<void> onEnterFullscreen,
    ) async {
      try {
        await onEnterFullscreen.future.timeout(const Duration(seconds: 15));
      } on TimeoutException {
        final state = await controller.evaluateJavascript(
          source:
              "(function() { var v = document.getElementById('video'); return v ? JSON.stringify({"
              "paused: v.paused, readyState: v.readyState, currentTime: v.currentTime, "
              "displayingFullscreen: v.webkitDisplayingFullscreen, "
              "error: v.error ? v.error.code : null}) : 'no video element'; })()",
        );
        fail('onEnterFullscreen did not come in 15 s; the video: $state');
      }
    }

    skippableTestWidgets('Auto media playback', (WidgetTester tester) async {
      Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(
              url: WebUri(
                'data:text/html;charset=utf-8;base64,$videoTestBase64',
              ),
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              mediaPlaybackRequiresUserGesture: false,
            ),
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );
      InAppWebViewController controller = await controllerCompleter.future;
      await pageLoaded.future;

      bool isPaused = await controller.evaluateJavascript(
        source: 'isPaused();',
      );
      expect(isPaused, false);

      controllerCompleter = Completer<InAppWebViewController>();
      pageLoaded = Completer<void>();

      // We change the key to re-create a new webview as we change the mediaPlaybackRequiresUserGesture
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(
              url: WebUri(
                'data:text/html;charset=utf-8;base64,$videoTestBase64',
              ),
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              mediaPlaybackRequiresUserGesture: true,
            ),
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      controller = await controllerCompleter.future;
      await pageLoaded.future;

      isPaused = await controller.evaluateJavascript(source: 'isPaused();');
      expect(isPaused, true);
    });

    final shouldSkipTest2 = !InAppWebViewSettings.isPropertySupported(
      InAppWebViewSettingsProperty.allowsInlineMediaPlayback,
    );

    skippableTestWidgets(
      'Video plays inline when allowsInlineMediaPlayback is true',
      (WidgetTester tester) async {
        Completer<InAppWebViewController> controllerCompleter =
            Completer<InAppWebViewController>();
        Completer<void> pageLoaded = Completer<void>();
        Completer<void> onEnterFullscreenCompleter = Completer<void>();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest: URLRequest(
                url: WebUri(
                  'data:text/html;charset=utf-8;base64,$videoTestBase64',
                ),
              ),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
              ),
              onLoadStop: (controller, url) {
                pageLoaded.complete();
              },
              onEnterFullscreen: (controller) {
                onEnterFullscreenCompleter.complete();
              },
            ),
          ),
        );

        await pageLoaded.future;
        expect(onEnterFullscreenCompleter.future, doesNotComplete);
      },
      skip: shouldSkipTest2,
    );

    final shouldSkipTest3 = !InAppWebViewSettings.isPropertySupported(
      InAppWebViewSettingsProperty.allowsInlineMediaPlayback,
    );

    testWidgets(
      'Video plays fullscreen when allowsInlineMediaPlayback is false',
      (WidgetTester tester) async {
        Completer<InAppWebViewController> controllerCompleter =
            Completer<InAppWebViewController>();
        Completer<void> pageLoaded = Completer<void>();
        Completer<void> onEnterFullscreenCompleter = Completer<void>();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest: URLRequest(
                url: WebUri(
                  'data:text/html;charset=utf-8;base64,$videoTestBase64',
                ),
              ),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: false,
              ),
              onLoadStop: (controller, url) {
                pageLoaded.complete();
              },
              onEnterFullscreen: (controller) {
                onEnterFullscreenCompleter.complete();
              },
            ),
          ),
        );

        final controller = await controllerCompleter.future;
        await pageLoaded.future.timeout(
          const Duration(seconds: 15),
          onTimeout: () => fail('the video page did not load in 15 s'),
        );

        await tester.pump();

        await expectEntersFullscreen(controller, onEnterFullscreenCompleter);
      },
      skip: shouldSkipTest3,
    );

    final shouldSkipTest4 = !InAppWebViewSettings.isPropertySupported(
      InAppWebViewSettingsProperty.allowsInlineMediaPlayback,
    );
    // on Android, entering fullscreen requires user interaction
    skippableTestWidgets('exit fullscreen event', (WidgetTester tester) async {
      Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      Completer<void> pageLoaded = Completer<void>();
      Completer<void> onEnterFullscreenCompleter = Completer<void>();
      Completer<void> onExitFullscreenCompleter = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(
              url: WebUri(
                'data:text/html;charset=utf-8;base64,$videoTestBase64',
              ),
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: false,
            ),
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
            onEnterFullscreen: (controller) {
              if (!onEnterFullscreenCompleter.isCompleted) {
                onEnterFullscreenCompleter.complete();
              }
            },
            onExitFullscreen: (controller) {
              if (!onExitFullscreenCompleter.isCompleted) {
                onExitFullscreenCompleter.complete();
              }
            },
          ),
        ),
      );

      InAppWebViewController controller = await controllerCompleter.future;
      // Each wait fails at its own step, so a hang names where it was (§276: this test once timed
      // out at 60 s on iOS with nothing to say which step it was in).
      await pageLoaded.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () => fail('the video page did not load in 15 s'),
      );
      await tester.pump();

      // Wait for the video to actually BE fullscreen instead of sleeping a fixed 2s and hoping.
      await expectEntersFullscreen(controller, onEnterFullscreenCompleter);

      // The native player ignores webkitExitFullscreen() while its presentation animation is still
      // running — measured on iOS 17.5 and 26.5, a single call fires nothing and the element is
      // still reporting webkitDisplayingFullscreen afterwards, while retrying succeeds after about
      // one second. So ask repeatedly until the event arrives rather than sleeping a guessed amount.
      for (var i = 0; i < 40 && !onExitFullscreenCompleter.isCompleted; i++) {
        await controller.evaluateJavascript(source: "exitFullscreen();");
        if (onExitFullscreenCompleter.isCompleted) break;
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (!onExitFullscreenCompleter.isCompleted) {
        fail(
          'onExitFullscreen did not come after 40 exitFullscreen() calls '
          '500 ms apart',
        );
      }
      expect(
        await controller.evaluateJavascript(
          source: 'document.getElementById("video").webkitDisplayingFullscreen',
        ),
        false,
        reason: 'the video should have left native fullscreen',
      );
    }, skip: shouldSkipTest4);
  }, skip: shouldSkip);
}
