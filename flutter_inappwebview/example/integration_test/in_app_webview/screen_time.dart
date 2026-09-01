part of 'main.dart';

/// The iOS major version, from `dart:io`. `Platform.operatingSystemVersion` on iOS reads
/// `"Version 26.5 (Build 23F79)"`, so the first integer in the string is the major.
///
/// Needed because the Screen Time family is iOS 26.0+ and the *correct* answer below that floor is
/// different, not absent — `isBlockedByScreenTime()` must return `null` there, and a test that only
/// ran on one simulator could not tell a working availability guard from a missing one.
int? _iosMajorVersion() {
  if (defaultTargetPlatform != TargetPlatform.iOS) {
    return null;
  }
  final match = RegExp(r'\d+').firstMatch(Platform.operatingSystemVersion);
  return match == null ? null : int.tryParse(match.group(0)!);
}

void screenTime() {
  final shouldSkip =
      !InAppWebViewController.isMethodSupported(
        PlatformInAppWebViewControllerMethod.isBlockedByScreenTime,
      ) ||
      defaultTargetPlatform != TargetPlatform.iOS;

  final url = TEST_CROSS_PLATFORM_URL_1;

  // Two-sided across the two simulators this repo baselines on: iOS 17.5 must answer `null` and
  // iOS 26.5 must answer `false`. Collapsing the unavailable case to `false` — the obvious thing to
  // write in the Swift, and what `hasOnlySecureContent` next to it does — fails the 17.5 run.
  //
  // `false` rather than `true` because a simulator has no Screen Time restriction configured; a
  // `true` here would mean the fixture URL is actually blocked, which is not something this suite
  // can arrange.
  skippableTestWidgets('isBlockedByScreenTime', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: url),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            if (!pageLoaded.isCompleted) {
              pageLoaded.complete();
            }
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;

    final blocked = await controller.isBlockedByScreenTime();
    final major = _iosMajorVersion();

    if (major != null && major >= 26) {
      expect(
        blocked,
        false,
        reason:
            'iOS $major has WKWebView.isBlockedByScreenTime and nothing is blocked here',
      );
    } else {
      expect(
        blocked,
        isNull,
        reason:
            'iOS $major has no WKWebView.isBlockedByScreenTime, and null must not be reported as false',
      );
    }
  }, skip: shouldSkip);

  // `showsSystemScreenTimeBlockingView` is a `WKWebViewConfiguration` property, so it is
  // creation-only for the reason §95 measured: `WKWebView.configuration` hands out a fresh copy on
  // every access. This is the same contract `set_get_settings.dart` pins for the older
  // configuration settings, with `minimumFontSize` as the live control again.
  //
  // Gated on iOS 26 rather than merely on iOS, because below that floor `getRealSettings` cannot
  // read the property back at all and simply reports what Dart last sent — so on iOS 17.5 the
  // second half of this test would assert the Dart round-trip, not the native contract, and would
  // fail while nothing was wrong.
  skippableTestWidgets(
    'showsSystemScreenTimeBlockingView is creation-only',
    (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: url),
            initialSettings: InAppWebViewSettings(
              showsSystemScreenTimeBlockingView: false,
              minimumFontSize: 8,
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              if (!pageLoaded.isCompleted) {
                pageLoaded.complete();
              }
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      var settings = await controller.getSettings();
      expect(settings, isNotNull);
      expect(
        settings!.showsSystemScreenTimeBlockingView,
        false,
        reason: 'the creation-time value must reach the real configuration',
      );

      await controller.setSettings(
        settings: InAppWebViewSettings(
          showsSystemScreenTimeBlockingView: true,
          minimumFontSize: 22,
        ),
      );

      settings = await controller.getSettings();
      expect(settings, isNotNull);
      expect(settings!.minimumFontSize, 22, reason: 'the control must change');
      expect(
        settings.showsSystemScreenTimeBlockingView,
        false,
        reason: 'creation-only: setSettings must not be able to change it',
      );
    },
    skip: shouldSkip || (_iosMajorVersion() ?? 0) < 26,
  );
}
