part of 'main.dart';

/// A parent rebuild constructs a new `InAppWebView`, and with it a new platform widget object, but
/// keeps the same `State`, the same platform view and the same controller. The controller used to
/// stay with the first platform object, so the widget's dispose ran on one that had none and the
/// controller was never disposed (§269: measured on both platforms).
/// Lays its child out twice in every layout, 300 px wide and then 100 px wide, so a `LayoutBuilder`
/// child builds twice in one frame.
class _LayoutTwice extends SingleChildRenderObjectWidget {
  const _LayoutTwice({super.child});

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderLayoutTwice();
}

class _RenderLayoutTwice extends RenderProxyBox {
  @override
  void performLayout() {
    child!.layout(const BoxConstraints.tightFor(width: 300, height: 300));
    child!.layout(const BoxConstraints.tightFor(width: 100, height: 100));
    size = constraints.constrain(const Size(300, 300));
  }
}

void widgetRebuild() {
  final shouldSkip = ![
    TargetPlatform.android,
    TargetPlatform.iOS,
  ].contains(defaultTargetPlatform);

  final data = InAppWebViewInitialData(
    data: '<html><body>rebuild</body></html>',
    baseUrl: WebUri('https://www.example.com/'),
  );

  Future<InAppWebViewController> created(
    WidgetTester tester,
    TestDeadline deadline,
    Completer<InAppWebViewController> controller,
    Completer<void> loaded,
  ) async {
    final c = await deadline.step('onWebViewCreated', controller.future);
    await deadline.step('the first onLoadStop', loaded.future);
    // Composite the view first, as an app's next frame would; with no pointer activity the binding
    // draws only the frames a test pumps (§268).
    await deadline.step('the first frame after loading', tester.pump());
    // Disposing the controller drops its JavaScript handlers (the app's closures), and reading
    // them back needs neither the platform nor a live channel, so this tells a disposed
    // controller from a leaked one on both platforms.
    c.addJavaScriptHandler(handlerName: 'rebuild', callback: (_) {});
    expect(c.hasJavaScriptHandler(handlerName: 'rebuild'), isTrue);
    return c;
  }

  void expectDisposed(InAppWebViewController controller) {
    expect(
      controller.hasJavaScriptHandler(handlerName: 'rebuild'),
      isFalse,
      reason: 'the controller was not disposed with its widget',
    );
  }

  skippableTestWidgets('the controller is disposed with its widget', (
    WidgetTester tester,
  ) async {
    final deadline = TestDeadline();
    final controller = Completer<InAppWebViewController>();
    final loaded = Completer<void>();
    await deadline.step(
      'mounting the WebView',
      tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialData: data,
            onWebViewCreated: (c) => controller.complete(c),
            onLoadStop: (c, url) {
              if (!loaded.isCompleted) loaded.complete();
            },
          ),
        ),
      ),
    );
    final c = await created(tester, deadline, controller, loaded);
    await deadline.step(
      'unmounting the WebView',
      tester.pumpWidget(const SizedBox()),
    );
    expectDisposed(c);
  }, skip: shouldSkip);

  skippableTestWidgets(
    'the controller is disposed with its widget after a parent rebuild',
    (WidgetTester tester) async {
      final deadline = TestDeadline();
      final controller = Completer<InAppWebViewController>();
      final loaded = Completer<void>();
      final generation = ValueNotifier<int>(0);
      final key = GlobalKey();
      await deadline.step(
        'mounting the WebView',
        tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: ValueListenableBuilder<int>(
              valueListenable: generation,
              // A new InAppWebView, and so a new platform widget object, on every rebuild.
              builder: (context, _, _) => InAppWebView(
                key: key,
                initialData: data,
                onWebViewCreated: (c) => controller.complete(c),
                onLoadStop: (c, url) {
                  if (!loaded.isCompleted) loaded.complete();
                },
              ),
            ),
          ),
        ),
      );
      final c = await created(tester, deadline, controller, loaded);
      generation.value++;
      await deadline.step('the first rebuild', tester.pump());
      generation.value++;
      await deadline.step('the second rebuild', tester.pump());
      await deadline.step(
        'unmounting the WebView',
        tester.pumpWidget(const SizedBox()),
      );
      expectDisposed(c);
    },
    skip: shouldSkip,
  );

  skippableTestWidgets(
    'the controller is disposed with its widget after a rebuild that keeps the platform object',
    (WidgetTester tester) async {
      final controller = Completer<InAppWebViewController>();
      final loaded = Completer<void>();
      final generation = ValueNotifier<int>(0);
      final key = GlobalKey();
      final platform = InAppWebView(
        initialData: data,
        onWebViewCreated: (c) => controller.complete(c),
        onLoadStop: (c, url) {
          if (!loaded.isCompleted) loaded.complete();
        },
      ).platform;
      final deadline = TestDeadline();
      await deadline.step(
        'mounting the WebView',
        tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: ValueListenableBuilder<int>(
              valueListenable: generation,
              // A new InAppWebView on every rebuild, sharing one platform widget object.
              builder: (context, _, _) =>
                  InAppWebView.fromPlatform(key: key, platform: platform),
            ),
          ),
        ),
      );
      final c = await created(tester, deadline, controller, loaded);
      generation.value++;
      await deadline.step('the rebuild', tester.pump());
      await deadline.step(
        'unmounting the WebView',
        tester.pumpWidget(const SizedBox()),
      );
      expectDisposed(c);
    },
    skip: shouldSkip,
  );

  // A WebView mounted and unmounted in the same frame (here: under a `LayoutBuilder` laid out twice,
  // the second time too narrow for it) never gets `onPlatformViewCreated` on iOS, so before §283 its
  // widget had no id to dispose it by, and the page kept running until some later frame composited
  // another platform view (measured: 3.6 s, then released when a second WebView appeared). Its page
  // writes a cookie every 100 ms, read here a second apart: a cookie that still changes is a page
  // that is still running. Nothing else is composited meanwhile, which would release it anyway.
  // iOS only: on Android this setup fails inside Flutter itself, `_PlatformViewPlaceholderBox`'s
  // post-frame callback calling `localToGlobal` on the box the second layout detached (debug
  // assertion 'attached', measured §283), before the plugin is involved.
  skippableTestWidgets(
    'a WebView unmounted in the frame that mounted it stops running',
    (WidgetTester tester) async {
      final origin = WebUri('http://${environment["NODE_SERVER_IP"]}:8082/');
      final cookies = CookieManager.instance();
      await cookies.deleteAllCookies();
      var builds = 0;
      var created = false;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: _LayoutTwice(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  builds++;
                  return constraints.maxWidth > 150
                      ? InAppWebView(
                          initialData: InAppWebViewInitialData(
                            data:
                                '<html><body>tick<script>setInterval(function() {'
                                ' document.cookie = "tick=" + Date.now() + "; path=/"; },'
                                ' 100);</script></body></html>',
                            baseUrl: origin,
                          ),
                          onWebViewCreated: (_) => created = true,
                        )
                      : const SizedBox();
                },
              ),
            ),
          ),
        ),
      );
      expect(
        builds,
        2,
        reason: 'the LayoutBuilder must build twice in one frame',
      );

      Future<String?> tick() async => (await cookies.getCookie(
        url: origin,
        name: 'tick',
      ))?.value?.toString();
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      final first = await tick();
      await Future<void>.delayed(const Duration(milliseconds: 1000));
      final second = await tick();
      expect(
        created,
        isFalse,
        reason: 'the path under test: no onPlatformViewCreated',
      );
      expect(
        second,
        first,
        reason:
            'the unmounted WebView is still running its page ("tick" changed '
            'from $first to $second)',
      );
      await cookies.deleteAllCookies();
    },
    skip: defaultTargetPlatform != TargetPlatform.iOS,
  );

  // A rebuild's callbacks are the ones called: a replaced `onLoadStop` and an `onTitleChanged`
  // the rebuild added. Before §282 the controller kept the first widget's params, so both went
  // to the first build's closures, or nowhere (measured on both platforms).
  skippableTestWidgets("a rebuild's callbacks receive the events", (
    WidgetTester tester,
  ) async {
    final page1 = WebUri('data:text/html,<title>one</title><!--RBP1-->');
    final page2 = WebUri('data:text/html,<title>two</title><!--RBP2-->');
    String name(WebUri? url) => '$url'.contains('RBP1')
        ? 'p1'
        : '$url'.contains('RBP2')
        ? 'p2'
        : '$url';
    final log = <String>[];
    final controller = Completer<InAppWebViewController>();
    final generation = ValueNotifier<int>(0);
    final key = GlobalKey();

    Future<void> waitFor(bool Function() done, String what) async {
      final deadline = DateTime.now().add(const Duration(seconds: 20));
      while (!done() && DateTime.now().isBefore(deadline)) {
        await tester.pump(const Duration(milliseconds: 100));
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      expect(done(), isTrue, reason: '$what: $log');
    }

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ValueListenableBuilder<int>(
          valueListenable: generation,
          builder: (context, gen, _) => InAppWebView(
            key: key,
            initialUrlRequest: URLRequest(url: page1),
            onWebViewCreated: (c) => controller.complete(c),
            onLoadStop: (c, url) => log.add('g$gen stop ${name(url)}'),
            onTitleChanged: gen == 0
                ? null
                : (c, title) => log.add('g$gen title $title'),
          ),
        ),
      ),
    );
    final c = await controller.future.timeout(const Duration(seconds: 20));
    await waitFor(() => log.contains('g0 stop p1'), 'page 1 never loaded');

    generation.value = 1;
    await tester.pump();
    final rebuiltAt = log.length;
    await c.loadUrl(urlRequest: URLRequest(url: page2));
    await waitFor(
      () => log.skip(rebuiltAt).any((e) => e.endsWith('stop p2')),
      'page 2 never finished loading after the rebuild',
    );
    await waitFor(
      () => log.contains('g1 title two'),
      "the rebuild's onTitleChanged never received page 2's title",
    );
    expect(
      log.skip(rebuiltAt).where((e) => !e.startsWith('g1 ')),
      isEmpty,
      reason:
          "an event after the rebuild reached the first build's callbacks: $log",
    );
  }, skip: shouldSkip);
}
