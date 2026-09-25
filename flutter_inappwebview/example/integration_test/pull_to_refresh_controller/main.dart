import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import '../util.dart';

part 'enabled.dart';
part 'refreshing.dart';
part 'appearance.dart';
part 'in_app_browser.dart';

/// Device coverage for `PullToRefreshChannelDelegate` — **ten channel methods that had none**.
///
/// Written as its own item *before* migrating that channel to Pigeon, per the rule §169 earned and
/// §174/§176 followed. The channel was the third instance of §176's trap: a test named
/// `launches with pull-to-refresh feature` already existed in the `in_app_webview` group and looks
/// like coverage, but it builds a webview with a `PullToRefreshSettings` and then asserts only that
/// the page loaded. Those settings travel in the **webview creation payload**, not on this channel,
/// so the test exercises `PullToRefreshLayout.prepare()` and not one of the ten methods. Measured,
/// not assumed: grepping every integration test for a call to any of the ten returns nothing at all.
///
/// What this group can and cannot reach:
///
///   * `setEnabled`/`isEnabled` and `beginRefreshing`/`endRefreshing`/`isRefreshing` are **real
///     round trips** — the platform answers from `SwipeRefreshLayout`'s own state, so these assert
///     behaviour rather than absence of a throw.
///   * `getDefaultSlingshotDistance` returns a constant, asserted against its measured value.
///   * The five remaining setters have **no getter on either side**, so they get transport coverage
///     only. That is recorded rather than dressed up (§171) — see `appearance.dart`.
///   * `onRefresh`, the channel's one event, needs a real drag on a platform view. See
///     `refreshing.dart`, where the reachable half of that is pinned instead.
///   * The delegate has **two construction sites** that compute the channel suffix independently —
///     `PullToRefreshLayout`'s constructor (the widget and headless paths) and `InAppBrowserActivity`
///     (XML-inflated). `in_app_browser.dart` covers the second; everything else here covers the first.
void main() {
  final shouldSkip = !PullToRefreshController.isClassSupported();

  skippableGroup('PullToRefreshController', () {
    enabled();
    refreshing();
    appearance();
    // Last: it opens a separate activity, and one left on screen by a failure would take every
    // widget test after it down with it (§178).
    inAppBrowser();
  }, skip: shouldSkip);
}

/// Builds an `InAppWebView` with a live `PullToRefreshController` attached and waits until the page
/// has loaded, which is the point at which `PullToRefreshLayout.prepare()` has run and the channel
/// is answering.
///
/// A local asset rather than a URL on purpose: none of these ten methods touches the network, and a
/// group that does not need DNS should not be able to fail on it.
Future<PullToRefreshController> _pumpWebViewWithPullToRefresh(
  WidgetTester tester, {
  PullToRefreshSettings? settings,
  void Function()? onRefresh,
}) async {
  final Completer<void> pageLoaded = Completer<void>();
  final controller = PullToRefreshController(
    settings: settings ?? PullToRefreshSettings(enabled: true),
    onRefresh: onRefresh ?? () {},
  );

  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: InAppWebView(
        key: GlobalKey(),
        initialFile: "test_assets/in_app_webview_initial_file_test.html",
        pullToRefreshController: controller,
        onLoadStop: (webViewController, url) {
          if (!pageLoaded.isCompleted) {
            pageLoaded.complete();
          }
        },
      ),
    ),
  );

  await pageLoaded.future;
  await tester.pump();

  return controller;
}
