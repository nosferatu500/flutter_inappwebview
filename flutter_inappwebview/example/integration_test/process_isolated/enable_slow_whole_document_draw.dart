import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../util.dart';

/// `enableSlowWholeDocumentDraw` — **run as its own process, never from `webview_flutter_test.dart`**
/// (§187).
///
///     flutter test integration_test/process_isolated/enable_slow_whole_document_draw.dart -d <device>
///
/// It switches every WebView in the process to drawing the whole document, which Android documents
/// as "a significant performance cost", cannot be switched back, and belongs *before* any WebView is
/// created. Running it in the aggregate runner would change the drawing of every group after it. And
/// it cannot share a process with `disable_webview.dart` in either order: it loads WebView, which
/// `disableWebView` then refuses, and after `disableWebView` it would itself throw.
///
/// What is observable: the call succeeds before any WebView exists, and a WebView created afterwards
/// still loads. (Measured separately: it also does not throw *after* a WebView exists.) The drawing
/// change itself is not asserted — nothing in the plugin exposes it.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.enableSlowWholeDocumentDraw,
  );

  skippableTestWidgets(
    'enableSlowWholeDocumentDraw succeeds first, and WebViews still load',
    (WidgetTester tester) async {
      await expectLater(
        InAppWebViewController.enableSlowWholeDocumentDraw(),
        completes,
      );

      final loaded = Completer<void>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialData: InAppWebViewInitialData(
              data: '<html><body>whole document</body></html>',
            ),
            onLoadStop: (controller, url) {
              if (!loaded.isCompleted) {
                loaded.complete();
              }
            },
          ),
        ),
      );
      await expectLater(loaded.future, completes);
    },
    skip: shouldSkip,
  );
}
