import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../util.dart';

/// `disableWebView` — **run as its own process, never from `webview_flutter_test.dart`** (§187).
///
///     flutter test integration_test/process_isolated/disable_webview.dart -d <device>
///
/// The call is irreversible for the process: afterwards every `android.webkit` use throws. Inside the
/// aggregate runner it would take down every group after it, so it is deliberately left out of that
/// file, and a fresh process is also a precondition — the call is documented to throw once WebView
/// has been loaded in the process.
///
/// Measured before writing (Pixel_10, API 37): in a fresh process the call succeeds — so the plugin
/// does not load WebView at start-up — and the next `android.webkit` use fails with
/// `PlatformException(error, WebView.disableWebView() was called: WebView is disabled, …)`. A second
/// call is a no-op.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.disableWebView,
  );

  skippableTest(
    'disableWebView makes every later android.webkit call fail',
    () async {
      await InAppWebViewController.disableWebView();

      // `getDefaultUserAgent` reaches `WebSettings.getDefaultUserAgent`, the cheapest android.webkit
      // call on the channel — and one that cannot be answered by a Dart-side default, because the
      // platform throws before answering.
      await expectLater(
        InAppWebViewController.getDefaultUserAgent(),
        throwsA(
          isA<PlatformException>().having(
            (e) => e.message,
            'message',
            contains('WebView is disabled'),
          ),
        ),
      );

      // Idempotent: calling it again is not itself an android.webkit use that throws.
      await expectLater(InAppWebViewController.disableWebView(), completes);
    },
    skip: shouldSkip,
  );
}
