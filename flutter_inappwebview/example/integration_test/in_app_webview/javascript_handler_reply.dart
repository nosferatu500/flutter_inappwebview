part of 'main.dart';

/// Two properties of the JavaScript-handler reply path that §122's iOS port could have changed
/// silently, and one capability it adds.
///
/// iOS moved `callHandler` from a hand-rolled callback-id table to
/// `WKScriptMessageHandlerWithReply`, where `postMessage` returns the promise and WebKit serialises
/// whatever the native side replies with. The old code interpolated Dart's `jsonEncode(result)`
/// straight into JS source as an *expression*, so the JS-visible **type** of every handler result
/// came from that interpolation. Nothing in the suite pinned it, and the two ways to get it wrong
/// are invisible from Dart:
///
///  * replying with the JSON **string** instead of its parsed value turns every object result into
///    a string (§65 named this one);
///  * replying with Swift `nil` resolves the promise with **`undefined`** where the old
///    `resolve(null)` produced **`null`** (§65 did not).
///
/// So the first test asserts `typeof` and the JSON round-trip of eight results rather than their
/// values, and it runs on **both** platforms — Android reaches the same JS through a different
/// mechanism, and the point of the assertion is that the two agree.
void javascriptHandlerReplyTypes() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.addJavaScriptHandler,
  );

  skippableTestWidgets('JavaScript Handler reply preserves the JS type', (
    WidgetTester tester,
  ) async {
    final Completer<Map<String, dynamic>> reported =
        Completer<Map<String, dynamic>>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialFile:
              "test_assets/in_app_webview_javascript_handler_reply_test.html",
          initialSettings: InAppWebViewSettings(javaScriptEnabled: true),
          onWebViewCreated: (controller) {
            controller.addJavaScriptHandler(
              handlerName: 'replyNull',
              callback: (data) => null,
            );
            controller.addJavaScriptHandler(
              handlerName: 'replyInt',
              callback: (data) => 7,
            );
            controller.addJavaScriptHandler(
              handlerName: 'replyString',
              callback: (data) => 'abc',
            );
            controller.addJavaScriptHandler(
              handlerName: 'replyBool',
              callback: (data) => true,
            );
            controller.addJavaScriptHandler(
              handlerName: 'replyList',
              callback: (data) => [1, 'two'],
            );
            controller.addJavaScriptHandler(
              handlerName: 'replyMap',
              callback: (data) => {'a': 1},
            );
            // Returns nothing at all, which is a different Dart value from `null` only in intent —
            // both reach the native side as `jsonEncode(null)`. Pinned so a future change that
            // starts distinguishing them has to say so.
            controller.addJavaScriptHandler(
              handlerName: 'replyNothing',
              callback: (data) {},
            );
            controller.addJavaScriptHandler(
              handlerName: 'reportReplies',
              callback: (data) {
                if (!reported.isCompleted) {
                  reported.complete(
                    (data.args[0] as Map).cast<String, dynamic>(),
                  );
                }
                return null;
              },
            );
          },
        ),
      ),
    );

    final results = await reported.future.timeout(const Duration(seconds: 20));

    Map<String, dynamic> shape(String name) =>
        (results[name] as Map).cast<String, dynamic>();

    // `null` must stay `null`. A Swift `nil` reply would make this `{'undefined', '<undefined>'}`,
    // which is the single assertion the whole `NSNull` mapping exists for.
    expect(shape('replyNull'), {'type': 'object', 'json': 'null'});
    expect(shape('replyNothing'), {'type': 'object', 'json': 'null'});

    // A handler name Dart never registered. This is the only case that reaches the native
    // fallback for "the response was not a decodable JSON string" — a registered handler always
    // answers with `jsonEncode(...)` — and it must still be `null`, not `undefined` and not a hang.
    expect(shape('replyUnregistered'), {'type': 'object', 'json': 'null'});

    // Scalars need `JSONSerialization.fragmentsAllowed` on iOS; without it the parse fails and the
    // reply falls back to `null`.
    expect(shape('replyInt'), {'type': 'number', 'json': '7'});
    expect(shape('replyString'), {'type': 'string', 'json': '"abc"'});
    expect(shape('replyBool'), {'type': 'boolean', 'json': 'true'});

    // Containers must arrive as containers, not as their JSON text.
    expect(shape('replyList'), {'type': 'object', 'json': '[1,"two"]'});
    expect(shape('replyMap'), {'type': 'object', 'json': '{"a":1}'});
  }, skip: shouldSkip);
}

/// `callHandler` from a **cross-origin iframe** now returns the handler's result.
///
/// It used to return `undefined`, immediately, with the Dart handler still running: the JS bridge
/// stored `{resolve, reject}` on `window.top`, which throws in a cross-origin frame, and the catch
/// called `resolve()` with no argument. `WKScriptMessageHandlerWithReply`'s promise belongs to the
/// frame that called `postMessage`, so there is nothing to store and nothing to throw.
///
/// **Android is skipped because it still has this defect** — its bridge keys the same table off
/// `(isMainFrame ? window : window.top)` inside the same `catch(e) { resolve(); }`. Filed in
/// `TODO.md`; there is no `WKScriptMessageHandlerWithReply` equivalent on that platform, so the fix
/// is a different design rather than the same one.
void javascriptHandlerCrossOriginIframe() {
  final shouldSkip =
      !InAppWebViewController.isMethodSupported(
        PlatformInAppWebViewControllerMethod.addJavaScriptHandler,
      ) ||
      ![
        TargetPlatform.iOS,
        TargetPlatform.macOS,
      ].contains(defaultTargetPlatform);

  skippableTestWidgets('JavaScript Handler reply reaches a cross-origin iframe', (
    WidgetTester tester,
  ) async {
    final Completer<Map<String, dynamic>> reported =
        Completer<Map<String, dynamic>>();
    final List<dynamic> echoArgs = <dynamic>[];

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          // The parent is loaded by the LAN address and the iframe by `localhost` — the same
          // node fixture, a different host, therefore a different origin.
          initialUrlRequest: URLRequest(
            url: WebUri(
              'http://${environment["NODE_SERVER_IP"]}:8082/test-cross-origin-iframe-parent',
            ),
          ),
          initialSettings: InAppWebViewSettings(javaScriptEnabled: true),
          onWebViewCreated: (controller) {
            controller.addJavaScriptHandler(
              handlerName: 'iframeEcho',
              callback: (data) {
                echoArgs.add(data.args[0]);
                return data.args[0];
              },
            );
            controller.addJavaScriptHandler(
              handlerName: 'reportIframeReply',
              callback: (data) {
                if (!reported.isCompleted) {
                  reported.complete(
                    (data.args[0] as Map).cast<String, dynamic>(),
                  );
                }
                return null;
              },
            );
          },
        ),
      ),
    );

    final result = await reported.future.timeout(const Duration(seconds: 20));

    // The message half worked before this change too — only the reply was lost — so asserting
    // the echo alone would prove nothing.
    expect(echoArgs, [42]);
    expect(result, {'type': 'number', 'json': '42'});
  }, skip: shouldSkip);
}
