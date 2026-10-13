part of 'main.dart';

void setContextMenu() {
  // Android only: this is the only platform the values below were measured on (API 37).
  final shouldSkip =
      !InAppWebViewController.isMethodSupported(
        PlatformInAppWebViewControllerMethod.setContextMenu,
      ) ||
      defaultTargetPlatform != TargetPlatform.android;

  // Replaces the menu's items after creation, then clicks the item the same way as
  // context_menu_events.dart. Measured on API 37: the click reports the NEW item (id 9, "New"), so
  // the Kotlin side draws the replacement.
  //
  // 🚨 It reaches the ORIGINAL menu's `onContextMenuActionItemClicked`, not the new one's. The Dart
  // dispatcher looks callbacks up on the `contextMenu` the web view was created with, and
  // `setContextMenu` does not replace it for an `InAppWebView`. The test pins that behaviour as it
  // stands rather than changing it (§193).
  skippableTestWidgets('setContextMenu', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<ContextMenuItem> clickedOnOriginal =
        Completer<ContextMenuItem>();
    var clickedOnReplacement = false;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          contextMenu: ContextMenu(
            menuItems: [ContextMenuItem(id: 7, title: 'Old')],
            settings: ContextMenuSettings(
              hideDefaultSystemContextMenuItems: true,
            ),
            onContextMenuActionItemClicked: (item) {
              if (!clickedOnOriginal.isCompleted) {
                clickedOnOriginal.complete(item);
              }
            },
          ),
          initialData: InAppWebViewInitialData(
            data:
                '<!DOCTYPE html><html><head>'
                '<meta name="viewport" content="width=device-width, initial-scale=1"></head>'
                '<body style="margin:0;font-size:48px">'
                '<p style="margin-top:40vh">selectable words here</p></body></html>',
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            if (!pageLoaded.isCompleted) pageLoaded.complete();
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;
    await _pumpFrames(tester);

    await controller.setContextMenu(
      ContextMenu(
        menuItems: [ContextMenuItem(id: 9, title: 'New')],
        settings: ContextMenuSettings(hideDefaultSystemContextMenuItems: true),
        onContextMenuActionItemClicked: (item) {
          clickedOnReplacement = true;
        },
      ),
    );

    final size = tester.getSize(find.byType(InAppWebView));
    final press = Offset(size.width * 0.3, size.height * 0.43);
    await tester.longPressAt(press);
    await _pumpFrames(tester);
    await _pumpFrames(tester);
    final num selectionTop = await controller.evaluateJavascript(
      source: 'window.getSelection().getRangeAt(0).getClientRects()[0].y',
    );
    await tester.tapAt(Offset(press.dx, selectionTop - 34));

    final item = await clickedOnOriginal.future.timeout(
      const Duration(seconds: 10),
    );
    expect(item.id, 9);
    expect(item.title, 'New');
    expect(clickedOnReplacement, isFalse);
  }, skip: shouldSkip);
}
