part of 'main.dart';

/// Device coverage for [PrintJobController]'s four channel methods — `getInfo`, `cancel`, `restart`
/// and `dispose` (§176). The channel had none before this.
///
/// 🚨 **Read this before adding a test here: reaching this channel at all raises an OS print dialog,
/// and this group is one test for that reason.**
///
/// A `PrintJobController` exists on Android only when `printCurrentPage` is given
/// `PrintJobSettings(handledByClient: true)` — measured in `InAppWebView.kt`, where the controller
/// is constructed inside `if (settings != null && settings.handledByClient && ...)` and the very
/// next statement is `printManager.print(...)`, which raises
/// `com.android.printspooler/.ui.PrintActivity`. **There is no path to a controller that does not
/// raise the modal.** So the whole lifecycle runs inside a single test against a single job rather
/// than as four tests raising four dialogs, and the group lives in its own file rather than in
/// `in_app_webview`, where `printCurrentPage` is pinned last for exactly this reason.
///
/// **Trap 83 turns out to be narrower than its wording.** It says the dialog cannot be dismissed and
/// that tests scheduled after it time out at 60 s — true of *widget* tests, which need the Flutter
/// UI the dialog is covering. It is **not** true of channel calls: every method below is invoked
/// while `PrintActivity` owns the screen (confirmed in logcat: `VRI[PrintActivity] visibilityChanged
/// oldVisibility=true`) and all four answer normally. That is what makes this group possible at all.
void controllerLifecycle() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.printCurrentPage,
  );

  skippableTestWidgets('the four channel methods over one job\'s lifetime', (
    WidgetTester tester,
  ) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
          onWebViewCreated: (controller) =>
              controllerCompleter.complete(controller),
          onLoadStop: (controller, url) {
            if (!pageLoaded.isCompleted) pageLoaded.complete();
          },
        ),
      ),
    );

    final controller = await controllerCompleter.future;
    await tester.pump();
    await pageLoaded.future.timeout(const Duration(seconds: 30));

    // The modal goes up here and stays up for the rest of the test.
    final printJob = await controller.printCurrentPage(
      settings: PrintJobSettings(handledByClient: true),
    );

    expect(
      printJob,
      isNotNull,
      reason:
          'handledByClient: true must yield a controller; without one none of the four channel '
          'methods is reachable at all',
    );

    // ---- getInfo: the fields Android populates -------------------------------------------------
    final info = await printJob!.getInfo();
    expect(
      info,
      isNotNull,
      reason: 'getInfo answered null — the job was not registered natively',
    );
    expect(
      info!.state,
      PrintJobState.CREATED,
      reason:
          'a job that has only just been handed to the print manager is CREATED; the assertions '
          'below depend on that being the starting state',
    );
    expect(info.copies, isNotNull);
    expect(info.label, isNotNull);
    expect(info.creationTime, isNotNull);

    // ---- getInfo: the fields Android never sends -----------------------------------------------
    // Eight of the fifteen keys `PrintJobInfo.fromMap` reads have **zero** occurrences anywhere in
    // the Android Kotlin source — measured by grep over the module, not inferred. They are iOS-only
    // and arrive null here. Pinned so that a migration which started populating them, or which
    // dropped one of the seven Android does send, shows up as a failure rather than as a shrug.
    expect(
      info.showsPrintPanel,
      isNull,
      reason: 'showsPrintPanel is iOS-only and must stay absent on Android',
    );
    expect(info.showsProgressPanel, isNull);
    expect(info.currentPage, isNull);
    expect(info.firstPage, isNull);
    expect(info.lastPage, isNull);
    expect(info.isCopyingOperation, isNull);
    expect(info.canSpawnSeparateThread, isNull);
    expect(info.preferredRenderingQuality, isNull);

    // ---- cancel and restart: reachable, and measurably no-ops in CREATED ------------------------
    // `PrintJob.cancel()` does nothing while the job is CREATED, and `restart()` applies only to a
    // FAILED job — both measured here rather than taken from trap 83's wording. So these assertions
    // are **not** "cancellation works"; they are "the call reaches the platform, answers, and
    // leaves the job alone". That is still worth pinning: it is exactly what a migration that wired
    // `cancel` to `dispose` would break, and the `isNotNull` is what catches it.
    await printJob.cancel();
    final afterCancel = await printJob.getInfo();
    expect(
      afterCancel,
      isNotNull,
      reason: 'cancel disposed the job — it must not; that is dispose\'s job',
    );
    expect(afterCancel!.state, PrintJobState.CREATED);

    await printJob.restart();
    final afterRestart = await printJob.getInfo();
    expect(afterRestart, isNotNull);
    expect(afterRestart!.state, PrintJobState.CREATED);

    // ---- dispose: the one teardown that is observable -------------------------------------------
    // `void`, not `Future<void>` — the facade drops the platform future, so this is fire-and-forget
    // and there is nothing to await. Recorded rather than worked around.
    printJob.dispose();
    expect(
      await printJob.getInfo(),
      isNull,
      reason:
          'after dispose the native controller has no job, so getInfo must answer null — this is '
          'the only teardown effect this channel exposes',
    );

    // ---- printCurrentPage's settings reach the job's attributes (§211) -------------------------
    // Until §211 no test sent orientation, mediaSize, colorMode, duplexMode or resolution (the job
    // above sends only handledByClient), so seven ints that Pigeon will deliver as Long were never
    // read. They come back in getInfo().attributes. Two jobs, because orientation is applied as a
    // media size (UNKNOWN_LANDSCAPE), which an explicit mediaSize overrides. Values are distinct
    // across same-typed fields: colorMode 1 ≠ duplex 4, width ≠ height, vertical ≠ horizontal dpi.
    // Android only, as measured (Pixel_10, API 37): both jobs, while the modal is up.
    if (defaultTargetPlatform == TargetPlatform.android) {
      final landscape = await controller.printCurrentPage(
        settings: PrintJobSettings(
          handledByClient: true,
          orientation: PrintJobOrientation.LANDSCAPE,
        ),
      );
      final landscapeAttributes = (await landscape!.getInfo())!.attributes!;
      expect(landscapeAttributes.orientation, PrintJobOrientation.LANDSCAPE);
      expect(landscapeAttributes.mediaSize?.id, 'UNKNOWN_LANDSCAPE');
      landscape.dispose();

      final configured = await controller.printCurrentPage(
        settings: PrintJobSettings(
          handledByClient: true,
          mediaSize: PrintJobMediaSize.ISO_A5,
          colorMode: PrintJobColorMode.MONOCHROME,
          duplexMode: PrintJobDuplexMode.SHORT_EDGE,
          resolution: const PrintJobResolution(
            id: 'fork-resolution',
            label: 'Fork',
            verticalDpi: 300,
            horizontalDpi: 600,
          ),
        ),
      );
      final attributes = (await configured!.getInfo())!.attributes!;
      expect(attributes.mediaSize?.id, 'ISO_A5');
      expect(attributes.mediaSize?.widthMils, 5830);
      expect(attributes.mediaSize?.heightMils, 8270);
      expect(attributes.colorMode, PrintJobColorMode.MONOCHROME);
      expect(attributes.duplex, PrintJobDuplexMode.SHORT_EDGE);
      expect(attributes.resolution?.id, 'fork-resolution');
      expect(attributes.resolution?.verticalDpi, 300);
      expect(attributes.resolution?.horizontalDpi, 600);
      configured.dispose();
    }
  }, skip: shouldSkip);
}

// WHAT THIS GROUP DOES NOT COVER, deliberately.
//
// `onComplete`, the channel's one event, is **unreachable from an automated test**. It fires from
// `InAppWebViewPrintDocumentAdapter.onFinish()`, which runs only once a print job actually completes
// — which requires choosing a destination in the modal and confirming it. Nothing in the plugin API
// drives that UI, and an integration test cannot reach for `adb shell input`. §171 wrote a test that
// measured nothing and said so; this says so instead of writing one.
