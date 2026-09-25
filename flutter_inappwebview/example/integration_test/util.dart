import 'dart:async';
import 'dart:collection';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
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
    return {'bar': this.bar, 'baz': this.baz};
  }
}

class MyInAppBrowser extends InAppBrowser {
  final Completer<void> browserCreated = Completer<void>();
  final Completer<void> firstPageLoaded = Completer<void>();
  final Completer<void> browserClosed = Completer<void>();

  MyInAppBrowser({
    int? windowId,
    UnmodifiableListView<UserScript>? initialUserScripts,
    PullToRefreshController? pullToRefreshController,
  }) : super(
         windowId: windowId,
         initialUserScripts: initialUserScripts,
         pullToRefreshController: pullToRefreshController,
       );

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
  void onMessageChannelReady() async {
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
