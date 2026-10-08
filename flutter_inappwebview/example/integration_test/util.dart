import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

/// Returns a matcher that matches the isNullOrEmpty property.
const Matcher isNullOrEmpty = _NullOrEmpty();

/// The iOS major version, from `dart:io`, or `null` on any other platform.
///
/// `Platform.operatingSystemVersion` on iOS reads `"Version 26.5 (Build 23F79)"`, so the first
/// integer in the string is the major.
///
/// **`isMethodSupported` is not a substitute for this.** It answers about the *platform* and is
/// `true` on every iOS version, so a test gated only on it runs on simulators where the API does
/// not exist — which is the whole point of a version-floored API: below the floor the *correct*
/// answer is a different one, not an absent one, and a suite that runs on a single simulator cannot
/// tell a working availability guard from a missing one.
///
/// `in_app_webview/screen_time.dart` carries a private copy of this for its own group; it predates
/// this one and was deliberately left alone rather than folded in from a different feature's commit.
int? iosMajorVersion() {
  if (defaultTargetPlatform != TargetPlatform.iOS) {
    return null;
  }
  final match = RegExp(r'\d+').firstMatch(Platform.operatingSystemVersion);
  return match == null ? null : int.tryParse(match.group(0)!);
}

/// [pumping] (a `pump` or `pumpWidget`), asking the engine for its frame again every 2 s that it
/// has not come, up to 10 times, and printing each time.
///
/// The engine sometimes drops a frame request (§298). Measured on Android: right after a popup
/// WebView was mounted, a pump's frame did not come in 5 s, with frames enabled, a frame scheduled
/// and the platform thread answering a plugin call; one more `platformDispatcher.scheduleFrame()`
/// brought it. Unrescued, the pump waited forever and every later test in the run failed on the
/// test binding's asserts. With this: 4 rescues in 41 `WebView Windows` group runs (2 on Android, 2
/// on iOS, all after mounting a popup) and 1 in a full Android group (removing a WebView), each
/// needing one request.
Future<void> rescueFrame(String name, Future<void> pumping) async {
  var done = false;
  unawaited(
    pumping.then<void>((_) => done = true, onError: (Object _) => done = true),
  );
  for (var rescues = 0; rescues < 10; rescues++) {
    await Future.any<void>([
      pumping,
      Future<void>.delayed(const Duration(seconds: 2)),
    ]);
    if (done) break;
    // ignore: avoid_print
    print(
      'frame watchdog: "$name" has waited ${2 * (rescues + 1)} s for a frame; '
      'asking the engine again (§298)',
    );
    SchedulerBinding.instance.platformDispatcher.scheduleFrame();
  }
  return pumping;
}

/// One deadline for a whole test, shared by its waits, so a hang fails naming the step it was in
/// instead of reaching the 60 s test timeout with nothing to say which (§297). Pumps are steps too:
/// a `pump` once hung on iOS with no wait of its own (§283). 50 s leaves the failure inside the test.
class TestDeadline {
  TestDeadline([Duration total = const Duration(seconds: 50)])
    : _end = DateTime.now().add(total);

  final DateTime _end;

  /// [future], failing with [name] and [state] if the deadline passes first.
  Future<T> step<T>(String name, Future<T> future, {String Function()? state}) {
    final left = _end.difference(DateTime.now());
    return future.timeout(
      left.isNegative ? Duration.zero : left,
      onTimeout: () => _fail(name, state),
    );
  }

  /// [step] for a `pump` or `pumpWidget`, with [rescueFrame].
  Future<void> frame(
    String name,
    Future<void> pumping, {
    String Function()? state,
  }) => step(name, rescueFrame(name, pumping), state: state);

  /// Polls [done] every 50 ms until it holds, failing like [step] if the deadline passes first.
  /// For events a test records as they come: waiting on a broadcast stream's `first` misses one
  /// that fired before the wait began (§297).
  Future<void> until(
    String name,
    bool Function() done, {
    String Function()? state,
  }) async {
    while (!done()) {
      if (!DateTime.now().isBefore(_end)) _fail(name, state);
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }

  Never _fail(String name, String Function()? state) {
    final scheduler = SchedulerBinding.instance;
    fail(
      '$name: not done when the test deadline passed'
      '${state == null ? '' : ' (${state()})'}'
      ' [frames: enabled ${scheduler.framesEnabled}, '
      'scheduled ${scheduler.hasScheduledFrame}, '
      'phase ${scheduler.schedulerPhase.name}, '
      'lifecycle ${scheduler.lifecycleState?.name}]',
    );
  }
}

class _NullOrEmpty extends Matcher {
  const _NullOrEmpty();

  @override
  bool matches(Object? item, Map matchState) =>
      item == null || (item as dynamic).isEmpty;

  @override
  Description describe(Description description) =>
      description.add('null or empty');
}

void skippableGroup(
  Object description,
  void Function() body, {
  bool skip = false,
}) {
  if (!skip) {
    group(description.toString(), body, skip: skip);
  } else {
    // A skipped group is never registered, so this line is its only trace.
    // ignore: avoid_print
    print(
      'SKIPPING GROUP "$description" for platform ${defaultTargetPlatform.toString()}',
    );
  }
}

void skippableTest(
  Object description,
  dynamic Function() body, {
  String? testOn,
  Timeout? timeout = const Timeout(Duration(seconds: 60)),
  bool skip = false,
  dynamic tags,
  Map<String, dynamic>? onPlatform,
  int? retry,
}) {
  if (!skip) {
    test(
      description.toString(),
      body,
      testOn: testOn,
      timeout: timeout,
      skip: skip,
      onPlatform: onPlatform,
      tags: tags,
      retry: retry,
    );
  } else {
    // A skipped test is never registered, so this line is its only trace.
    // ignore: avoid_print
    print(
      'SKIPPING TEST "$description" for platform ${defaultTargetPlatform.toString()}',
    );
  }
}

void skippableTestWidgets(
  String description,
  WidgetTesterCallback callback, {
  bool skip = false,
  Timeout? timeout = const Timeout(Duration(seconds: 60)),
  bool semanticsEnabled = true,
  TestVariant<Object?> variant = const DefaultTestVariant(),
  dynamic tags,
}) {
  if (!skip) {
    testWidgets(
      description,
      callback,
      skip: skip,
      timeout: timeout,
      semanticsEnabled: semanticsEnabled,
      variant: variant,
      tags: tags,
    );
  } else {
    // A skipped test is never registered, so this line is its only trace.
    // ignore: avoid_print
    print(
      'SKIPPING TEST WIDGET "$description" for platform ${defaultTargetPlatform.toString()}',
    );
  }
}

class Foo {
  String? bar;
  String? baz;

  Foo({this.bar, this.baz});

  Map<String, dynamic> toJson() {
    return {'bar': bar, 'baz': baz};
  }
}

class MyInAppBrowser extends InAppBrowser {
  final Completer<void> browserCreated = Completer<void>();
  final Completer<void> firstPageLoaded = Completer<void>();
  final Completer<void> browserClosed = Completer<void>();

  MyInAppBrowser({
    super.windowId,
    super.initialUserScripts,
    super.pullToRefreshController,
  });

  @override
  Future onBrowserCreated() async {
    browserCreated.complete();
  }

  @override
  void onLoadStop(WebUri? url) {
    super.onLoadStop(url);

    if (!firstPageLoaded.isCompleted) {
      firstPageLoaded.complete();
    }
  }

  @override
  void onExit() {
    if (!browserClosed.isCompleted) {
      browserClosed.complete();
    }
  }
}

class MyChromeSafariBrowser extends ChromeSafariBrowser {
  /// Every instance created by a test, so a group's `tearDown` can close one a failing test left
  /// open.
  ///
  /// 🚨 **This exists because a Custom Tab left on screen poisons every test after it** — the same
  /// shape as the print dialog (trap 83), in a different activity. §178 measured it: `request and
  /// send post messages` timed out at 60s without reaching its `close()`, and the tab it left up
  /// then took down three unrelated tests that all pass in isolation. Closing inline at the end of
  /// each test is not enough, because a failure never gets there.
  static final List<MyChromeSafariBrowser> openInstances =
      <MyChromeSafariBrowser>[];

  /// Closes anything still open. Safe to call when nothing is.
  static Future<void> closeAllOpen() async {
    for (final browser in List<MyChromeSafariBrowser>.from(openInstances)) {
      try {
        if (browser.isOpened()) {
          await browser.close();
        }
      } catch (_) {
        // A browser that is already gone, or whose channel has been torn down, throws here. There
        // is nothing useful to do about it and a throwing tearDown would mask the real failure.
      }
    }
    openInstances.clear();
  }

  MyChromeSafariBrowser() {
    openInstances.add(this);
  }

  final Completer<void> serviceConnected = Completer<void>();
  final Completer<void> opened = Completer<void>();
  final Completer<bool?> firstPageLoaded = Completer<bool?>();
  final Completer<void> closed = Completer<void>();
  final Completer<CustomTabsNavigationEventType?> navigationEvent =
      Completer<CustomTabsNavigationEventType?>();
  final Completer<void> navigationFinished = Completer<void>();
  final Completer<void> messageChannelReady = Completer<void>();
  final Completer<String> postMessageReceived = Completer<String>();
  final Completer<bool> relationshipValidationResult = Completer<bool>();

  @override
  void onServiceConnected() {
    serviceConnected.complete();
  }

  @override
  void onOpened() {
    opened.complete();
  }

  @override
  void onCompletedInitialLoad(didLoadSuccessfully) {
    firstPageLoaded.complete(didLoadSuccessfully);
  }

  @override
  void onNavigationEvent(CustomTabsNavigationEventType? type) {
    if (!navigationEvent.isCompleted) {
      navigationEvent.complete(type);
    }
    if (!navigationFinished.isCompleted &&
        type == CustomTabsNavigationEventType.FINISHED) {
      navigationFinished.complete();
    }
  }

  @override
  void onMessageChannelReady() {
    if (!messageChannelReady.isCompleted) {
      messageChannelReady.complete();
    }
  }

  @override
  void onPostMessage(String message) {
    if (!postMessageReceived.isCompleted) {
      postMessageReceived.complete(message);
    }
  }

  @override
  void onRelationshipValidationResult(
    CustomTabsRelationType? relation,
    Uri? requestedOrigin,
    bool result,
  ) {
    relationshipValidationResult.complete(result);
  }

  @override
  void onClosed() {
    closed.complete();
  }
}
