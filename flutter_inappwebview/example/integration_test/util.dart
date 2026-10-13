import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:nosferatu500_inappwebview/nosferatu500_inappwebview.dart';
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

bool _frameWatchdogInstalled = false;

/// Closes the live test binding's frame hole on iOS (§306, fixed §328) and, as a backstop on every
/// platform, asks the engine for a frame when a pump has had none for 2 s (§305), for every test.
///
/// The hole is the live test binding's, not the engine's (§306). For a frame no pump asked for, the
/// binding skips `handleBeginFrame`, so `hasScheduledFrame` stays true, and its `handleDrawFrame` asks
/// the engine for the next frame. A pump that starts in the engine's microtask flush between such a
/// frame's `onBeginFrame` and `onDrawFrame` sees `hasScheduledFrame` true and asks for nothing; that
/// frame's draw then completes the pump without drawing and asks for no next frame, and the following
/// pump waits forever. With merged platform and UI threads a native event runs its Dart handler at
/// once and leaves the handler's microtasks to the next flush, which can be a frame's, so a test
/// resuming from a WebView callback can pump there.
///
/// The fix: after a skipped frame's draw (the scheduler phase is still idle after its
/// `onBeginFrame`), ask the engine once more. When the binding has already asked, the engine's
/// one-slot frame request coalesces the two. Measured (§328) on iOS 26.5: 15 `WebView Windows` runs
/// caught 2 hangs in the act, each right after a skipped frame's draw; with the fix, 15 more runs had
/// none and no more frames (540 `onBeginFrame`s per run against 564). A forced repro (a pump started
/// in that window, no WebView) hung until the watchdog asked, 2.0 to 2.4 s, in 5 of 6 cases on iOS
/// 26.5 and Android 17 (a metrics change released the sixth); with the fix all 6 took 13 to 19 ms.
///
/// **iOS only.** On Android 17 the same request made frames come later after skipped frames, not
/// sooner: a full `in_app_webview` group had 176 gaps over 200 ms after a skipped frame's draw with it
/// (23 of them 0.8 s or more) against 19 without (all under 400 ms), and it didn't stop rescues that
/// follow a skipped frame there (3 with it, 0 without, over 2 full groups and 7 `find` runs against 1
/// and 6). Why isn't known: by the engine's source the extra request should be coalesced. So Android
/// keeps only the watchdog, as before §328.
///
/// The watchdog stays as a backstop for any other path to a stale `hasScheduledFrame`: 2 s without
/// `onBeginFrame` while a frame is scheduled and frames are enabled. On iOS it didn't fire once with
/// the fix (18 `WebView Windows` runs and every group). On Android it also catches a second kind,
/// after a frame that was drawn, not skipped: 5 in the 16 Android runs above, with the fix or
/// without. Each rescue, and any gap over 200 ms after a skipped frame's draw, is recorded and printed at the
/// end of its test. Installed once, at registration, wrapping the binding's own `onBeginFrame` and
/// `onDrawFrame`.
void installFrameWatchdog() {
  if (_frameWatchdogInstalled) return;
  final binding = SchedulerBinding.instance;
  final dispatcher = binding.platformDispatcher;
  // The binding registers its frame callbacks lazily, with `??=`, from `scheduleFrame`, which
  // returns early while frames are disabled, as they still were when tests register (measured,
  // §305: "no onBeginFrame to wrap" every time). This is the same registration, unconditionally.
  // ignore: invalid_use_of_protected_member
  binding.ensureFrameCallbacksRegistered();
  final FrameCallback? handleBeginFrame = dispatcher.onBeginFrame;
  if (handleBeginFrame == null) {
    _frameWatchdogEvents.add('not installed: no onBeginFrame to wrap');
    return;
  }
  final VoidCallback? handleDrawFrame = dispatcher.onDrawFrame;
  if (handleDrawFrame == null) {
    _frameWatchdogEvents.add('not installed: no onDrawFrame to wrap');
    return;
  }
  _frameWatchdogInstalled = true;
  _frameWatchdogEvents.add('frame watchdog installed (§305)');
  // iOS only: on Android the same request made the next frame come later, not sooner (§328).
  final askAfterSkippedFrame = defaultTargetPlatform == TargetPlatform.iOS;
  _lastBeginFrame = DateTime.now();
  dispatcher.onBeginFrame = (Duration timeStamp) {
    final now = DateTime.now();
    final skippedDraw = _lastSkippedDraw;
    if (skippedDraw != null) {
      final gap = now.difference(skippedDraw);
      if (gap > const Duration(milliseconds: 200)) {
        _frameWatchdogEvents.add(
          'stall after a skipped frame: next onBeginFrame ${gap.inMilliseconds} ms after its draw'
          '${_watchdogAskedSinceSkip ? ', after the watchdog asked' : ''} (§328)',
        );
      }
      _lastSkippedDraw = null;
    }
    _lastBeginFrame = now;
    handleBeginFrame(timeStamp);
    _frameSkipped = binding.schedulerPhase == SchedulerPhase.idle;
  };
  dispatcher.onDrawFrame = () {
    handleDrawFrame();
    if (_frameSkipped) {
      _lastSkippedDraw = DateTime.now();
      _watchdogAskedSinceSkip = false;
      if (askAfterSkippedFrame) {
        // The binding asked for nothing if this draw completed a pump (§306); otherwise the engine
        // coalesces this request with the binding's.
        dispatcher.scheduleFrame();
      }
    }
  };
  Timer.periodic(const Duration(milliseconds: 500), (_) {
    _frameWatchdogTicks++;
    final idle = DateTime.now().difference(_lastBeginFrame);
    if (idle < const Duration(seconds: 2) ||
        !binding.hasScheduledFrame ||
        !binding.framesEnabled) {
      return;
    }
    // Printed from the test's zone by `skippableTestWidgets` (a print from here reaches no test).
    final skippedDraw = _lastSkippedDraw;
    _frameWatchdogEvents.add(
      'frame watchdog: no frame for ${idle.inMilliseconds} ms with one scheduled; '
      'asked the engine again (§305); last frame '
      '${skippedDraw == null ? 'not skipped' : 'skipped, its draw ${DateTime.now().difference(skippedDraw).inMilliseconds} ms ago'}',
    );
    _watchdogAskedSinceSkip = true;
    _lastBeginFrame = DateTime.now();
    dispatcher.scheduleFrame();
  });
}

DateTime _lastBeginFrame = DateTime.now();
bool _frameSkipped = false;
DateTime? _lastSkippedDraw;
bool _watchdogAskedSinceSkip = false;
int _frameWatchdogTicks = 0;
final List<String> _frameWatchdogEvents = <String>[];

/// The watchdog's state, for failure messages.
String frameWatchdogState() =>
    'watchdog: installed $_frameWatchdogInstalled, ticks $_frameWatchdogTicks, '
    'last onBeginFrame ${DateTime.now().difference(_lastBeginFrame).inMilliseconds} ms ago, '
    'events $_frameWatchdogEvents';

/// Prints, from the current test's zone, what the watchdog did since the last call.
void printFrameWatchdogEvents() {
  for (final event in _frameWatchdogEvents) {
    // ignore: avoid_print
    print(event);
  }
  _frameWatchdogEvents.clear();
}

/// True when every group runs in one process (`webview_flutter_test.dart` sets it before
/// registering them). Tests that leave state no later group can recover from skip there (§304).
bool runningAllGroups = false;

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

  /// [step] for a `pump` or `pumpWidget`. A pump the live binding would leave with no frame
  /// requested (§306) gets one from [installFrameWatchdog]'s draw hook on iOS (§328); the 2 s watchdog
  /// rescues it on Android, and anything else on either platform (§305).
  Future<void> frame(
    String name,
    Future<void> pumping, {
    String Function()? state,
  }) => step(name, pumping, state: state);

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
      'lifecycle ${scheduler.lifecycleState?.name}; ${frameWatchdogState()}]',
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
    installFrameWatchdog();
    testWidgets(
      description,
      (tester) async {
        try {
          await callback(tester);
        } finally {
          printFrameWatchdogEvents();
        }
      },
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
