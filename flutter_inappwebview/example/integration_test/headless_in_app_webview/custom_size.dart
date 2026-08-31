part of 'main.dart';

void customSize() {
  final shouldSkip = !HeadlessInAppWebView.isMethodSupported(
    PlatformHeadlessInAppWebViewMethod.getSize,
  );

  skippableTest('set and get custom size', () async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();

    var headlessWebView = new HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
      initialSize: Size(600, 800),
      onWebViewCreated: (controller) {
        controllerCompleter.complete(controller);
      },
    );

    await headlessWebView.run();
    expect(headlessWebView.isRunning(), true);

    final Size? size = await headlessWebView.getSize();
    expect(size, isNotNull);
    expect(size, Size(600, 800));

    await headlessWebView.setSize(Size(1080, 1920));
    final Size? newSize = await headlessWebView.getSize();
    expect(newSize, isNotNull);
    expect(newSize, Size(1080, 1920));

    // A size whose physical-pixel product is fractional at *every* density. Android applies the
    // size as `int` layout params, so this is where a dp -> px -> dp conversion drops what was
    // asked for (TODO.md P0b.8). The two sizes above survive on the test AVDs only because
    // density 420 (scale 2.625) makes 600, 800, 1080 and 1920 whole numbers of pixels — an AVD at
    // density 390 returns 599.795 for 600.
    await headlessWebView.setSize(Size(600.25, 800.75));
    final Size? fractionalSize = await headlessWebView.getSize();
    expect(fractionalSize, isNotNull);
    expect(fractionalSize, Size(600.25, 800.75));

    await headlessWebView.dispose();

    expect(headlessWebView.isRunning(), false);
  }, skip: shouldSkip);

  skippableTest('a -1 size is reported back in logical pixels', () async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();

    var headlessWebView = new HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
      initialSize: Size(-1, -1),
      onWebViewCreated: (controller) {
        controllerCompleter.complete(controller);
      },
    );

    await headlessWebView.run();
    expect(headlessWebView.isRunning(), true);

    final Size? size = await headlessWebView.getSize();
    expect(size, isNotNull);

    // -1 means "match the screen on this axis", so there is no requested value to echo back.
    // What getSize still owes the caller is the *unit* it accepts: logical pixels. The screen is
    // the upper bound in that unit, so a physical-pixel count cannot pass on any device whose
    // devicePixelRatio is above 1.
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final logicalScreen = view.physicalSize / view.devicePixelRatio;
    expect(size!.width, greaterThan(0));
    expect(size.height, greaterThan(0));
    expect(size.width, lessThanOrEqualTo(logicalScreen.width + 1));
    expect(size.height, lessThanOrEqualTo(logicalScreen.height + 1));

    await headlessWebView.dispose();

    expect(headlessWebView.isRunning(), false);
  }, skip: shouldSkip);
}
