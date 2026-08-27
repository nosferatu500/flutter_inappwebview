part of 'main.dart';

void findInteractions() {
  final shouldSkip = !FindInteractionController.isClassSupported();

  skippableTestWidgets('find interactions', (WidgetTester tester) async {
    final Completer<void> pageLoaded = Completer<void>();
    final findInteractionController = FindInteractionController();

    await InAppWebViewController.clearAllCache();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialFile: "test_assets/in_app_webview_initial_file_test.html",
          findInteractionController: findInteractionController,
          initialSettings: InAppWebViewSettings(isFindInteractionEnabled: true),
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
        ),
      ),
    );

    await pageLoaded.future;

    await tester.pump();
    await Future.delayed(Duration(seconds: 1));

    const firstSearchText = "InAppWebViewInitialFileTest";
    await expectLater(
      findInteractionController.findAll(find: firstSearchText),
      completes,
    );
    expect(await findInteractionController.getSearchText(), firstSearchText);
    // Allow extra time for find results to be processed
    await Future.delayed(Duration(seconds: 1));
    final session = await findInteractionController.getActiveFindSession();
    expect(session!.resultCount, 2);
    await expectLater(
      findInteractionController.findNext(forward: true),
      completes,
    );
    await expectLater(
      findInteractionController.findNext(forward: false),
      completes,
    );
    await expectLater(findInteractionController.clearMatches(), completes);

    const secondSearchText = "text";
    await expectLater(
      findInteractionController.setSearchText(secondSearchText),
      completes,
    );
    if (FindInteractionController.isMethodSupported(
      PlatformFindInteractionControllerMethod.presentFindNavigator,
    )) {
      await expectLater(
        findInteractionController.presentFindNavigator(),
        completes,
      );
      expect(await findInteractionController.getSearchText(), secondSearchText);
      expect(await findInteractionController.isFindNavigatorVisible(), true);
      await expectLater(
        findInteractionController.updateResultCount(),
        completes,
      );
      await expectLater(
        findInteractionController.dismissFindNavigator(),
        completes,
      );
      expect(await findInteractionController.isFindNavigatorVisible(), false);
    }
  }, skip: shouldSkip);

  skippableTestWidgets('onFindResultReceived', (WidgetTester tester) async {
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<int> numberOfMatchesCompleter = Completer<int>();
    final findInteractionController = FindInteractionController(
      onFindResultReceived:
          (
            controller,
            int activeMatchOrdinal,
            int numberOfMatches,
            bool isDoneCounting,
          ) async {
            if (isDoneCounting && !numberOfMatchesCompleter.isCompleted) {
              numberOfMatchesCompleter.complete(numberOfMatches);
            }
          },
    );

    await InAppWebViewController.clearAllCache();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialFile: "test_assets/in_app_webview_initial_file_test.html",
          initialSettings: InAppWebViewSettings(
            isFindInteractionEnabled: false,
          ),
          findInteractionController: findInteractionController,
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
        ),
      ),
    );

    await pageLoaded.future;

    await tester.pump();
    await Future.delayed(Duration(seconds: 1));

    await findInteractionController.findAll(
      find: "InAppWebViewInitialFileTest",
    );
    final int numberOfMatches = await numberOfMatchesCompleter.future;
    expect(numberOfMatches, 2);
    final session = await findInteractionController.getActiveFindSession();
    expect(session!.resultCount, 2);
  }, skip: shouldSkip);

  // Regression: the iOS JS find path interpolated the search text straight into JavaScript
  // source with no escaping, so any apostrophe closed the string literal early and produced an
  // invalid script. `evaluateJavaScript` then failed silently and the search found nothing —
  // indistinguishable, from Dart, from a page with no matches.
  //
  // `isFindInteractionEnabled: false` is what forces that path on iOS 16+; with it `true` the
  // native UIFindInteraction handles the text and this test would pass either way.
  for (final searchText in const ["it's", '"hello"', r'C:\path']) {
    skippableTestWidgets('findAll with $searchText in the search text', (
      WidgetTester tester,
    ) async {
      final Completer<void> pageLoaded = Completer<void>();
      final Completer<int> numberOfMatchesCompleter = Completer<int>();
      final findInteractionController = FindInteractionController(
        onFindResultReceived:
            (
              controller,
              int activeMatchOrdinal,
              int numberOfMatches,
              bool isDoneCounting,
            ) async {
              if (isDoneCounting && !numberOfMatchesCompleter.isCompleted) {
                numberOfMatchesCompleter.complete(numberOfMatches);
              }
            },
      );

      await InAppWebViewController.clearAllCache();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialFile: "test_assets/find_apostrophe_test.html",
            initialSettings: InAppWebViewSettings(
              isFindInteractionEnabled: false,
            ),
            findInteractionController: findInteractionController,
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      await pageLoaded.future;
      await tester.pump();
      await Future.delayed(Duration(seconds: 1));

      await findInteractionController.findAll(find: searchText);
      expect(await numberOfMatchesCompleter.future, 2);
    }, skip: shouldSkip);
  }
}
