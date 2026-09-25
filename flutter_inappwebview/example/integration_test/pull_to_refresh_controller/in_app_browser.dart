part of 'main.dart';

void inAppBrowser() {
  final shouldSkip =
      !InAppBrowser.isClassSupported() ||
      !InAppBrowser.isPropertySupported(
        PlatformInAppBrowserProperty.pullToRefreshController,
      );

  // 🚨 **The second construction site, and the one a migration nearly missed.**
  // `InAppBrowserActivity` inflates its `PullToRefreshLayout` from XML, so the layout cannot build
  // its own delegate; the activity constructs `PullToRefreshChannelDelegate` by hand and computes
  // the `messageChannelSuffix` itself, from the bundle's `id`. That is a separate code path from the
  // widget's, so the other tests in this group — which all go through `InAppWebView` — say nothing
  // about it. During the Pigeon migration (§182) this site was found by the compiler, not by a
  // search, and before this test nothing on a device would have noticed its suffix being wrong.
  //
  // Not `testWidgets`: the browser is its own activity and covers the Flutter UI, so only channel
  // calls are meaningful while it is open — trap 83's narrower reading (§176).
  skippableTest('the InAppBrowser path answers on its own suffix', () async {
    final controller = PullToRefreshController(
      settings: PullToRefreshSettings(enabled: true),
      onRefresh: () {},
    );
    final browser = MyInAppBrowser(pullToRefreshController: controller);
    // An activity left open poisons every test after it (§178's Custom Tab), and a failed
    // assertion below would never reach an inline `close()`.
    addTearDown(() async {
      if (browser.isOpened()) {
        await browser.close();
      }
    });

    await browser.openFile(
      assetFilePath: "test_assets/in_app_webview_initial_file_test.html",
    );
    await browser.browserCreated.future;
    await browser.firstPageLoaded.future;

    // The same round trip as `enabled.dart`, through the other construction site. A wrong suffix on
    // this path fails the first host call within ~2s with a `channel-error` naming the channel
    // (§177), rather than hanging.
    expect(await controller.isEnabled(), true);
    await controller.setEnabled(false);
    expect(await controller.isEnabled(), false);
    await controller.setEnabled(true);
    expect(await controller.isEnabled(), true);

    await browser.close();
    await browser.browserClosed.future;
  }, skip: shouldSkip);
}
