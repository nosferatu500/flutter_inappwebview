part of 'main.dart';

void onLoadResourceWithCustomScheme() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.onLoadResourceWithCustomScheme,
  );

  skippableTestWidgets('onLoadResourceWithCustomScheme', (
    WidgetTester tester,
  ) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> imageLoaded = Completer<void>();

    await InAppWebViewController.clearAllCache();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialFile:
              "test_assets/in_app_webview_on_load_resource_custom_scheme_test.html",
          initialSettings: InAppWebViewSettings(
            resourceCustomSchemes: ["my-special-custom-scheme"],
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);

            controller.addJavaScriptHandler(
              handlerName: "imageLoaded",
              callback: (data) {
                imageLoaded.complete();
              },
            );
          },
          onLoadResourceWithCustomScheme: (controller, request) async {
            if (request.url.scheme == "my-special-custom-scheme") {
              var bytes = await rootBundle.load(
                "test_assets/" +
                    request.url.toString().replaceFirst(
                      "my-special-custom-scheme://",
                      "",
                      0,
                    ),
              );
              var response = CustomSchemeResponse(
                data: bytes.buffer.asUint8List(),
                contentType: "image/svg+xml",
                contentEncoding: "utf-8",
              );
              return response;
            }
            return null;
          },
        ),
      ),
    );

    await expectLater(imageLoaded.future, completes);
  }, skip: shouldSkip);
}
