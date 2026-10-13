part of 'main.dart';

void contextMenuEvents() {
  // Android only: this is the only platform the values below were measured on (API 37). The
  // plugin draws its own floating menu only with hybrid composition, which is the default.
  final shouldSkip =
      !InAppWebView.isPropertySupported(
        PlatformWebViewCreationParamsProperty.contextMenu,
      ) ||
      defaultTargetPlatform != TargetPlatform.android;

  // A long press on text selects a word and opens the plugin's floating menu. Its only item is ours
  // (`hideDefaultSystemContextMenuItems`), so a tap on the menu can only land on that item. The menu
  // is centred on the touch x and laid out from the selection's top edge. Measured on API 37: a tap
  // 34 logical pixels above that edge hits the item, and raises `onHideContextMenu` then
  // `onContextMenuActionItemClicked`, in that order (§192).
  skippableTestWidgets('context menu events', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<InAppWebViewHitTestResult> created =
        Completer<InAppWebViewHitTestResult>();
    final Completer<ContextMenuItem> clicked = Completer<ContextMenuItem>();
    final events = <String>[];

    final contextMenu = ContextMenu(
      menuItems: [ContextMenuItem(id: 7, title: 'Test item')],
      settings: ContextMenuSettings(hideDefaultSystemContextMenuItems: true),
      onCreateContextMenu: (hitTestResult) {
        events.add('create');
        if (!created.isCompleted) created.complete(hitTestResult);
      },
      onHideContextMenu: () {
        events.add('hide');
      },
      onContextMenuActionItemClicked: (item) {
        events.add('clicked');
        if (!clicked.isCompleted) clicked.complete(item);
      },
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          contextMenu: contextMenu,
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

    final size = tester.getSize(find.byType(InAppWebView));
    final press = Offset(size.width * 0.3, size.height * 0.43);
    await tester.longPressAt(press);

    final hitTestResult = await created.future.timeout(
      const Duration(seconds: 10),
    );
    expect(
      hitTestResult.type,
      InAppWebViewHitTestResultType.UNKNOWN_TYPE,
      reason: 'plain text is neither a link nor an image',
    );

    // Let the menu lay itself out.
    await tester.pump(const Duration(seconds: 2));
    await Future.delayed(const Duration(seconds: 2));
    expect(
      await controller.evaluateJavascript(
        source: 'window.getSelection().toString()',
      ),
      'selectable',
    );
    final num selectionTop = await controller.evaluateJavascript(
      source: 'window.getSelection().getRangeAt(0).getClientRects()[0].y',
    );

    await tester.tapAt(Offset(press.dx, selectionTop - 34));

    final item = await clicked.future.timeout(const Duration(seconds: 10));
    expect(item.id, 7);
    expect(item.title, 'Test item');
    expect(events, ['create', 'hide', 'clicked']);
  }, skip: shouldSkip);
}
