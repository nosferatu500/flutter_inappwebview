import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression guard for the generated `_alsoAcceptsNativeValues` closure (§72 added it, §83 fixed
/// it).
///
/// `WebResourceErrorType.HOST_LOOKUP` accepts a second inbound native value on iOS (`-1006`
/// alongside `-1003`), so the generator emits a second closure and `_internalMultiPlatform` casts
/// its result with `as List<int?>`. The closure's fall-through branch returned a bare `const []`,
/// which infers `List<dynamic>` — **not** a `List<int?>` — so on every platform that takes the
/// default branch, merely *reading the constant* threw a `TypeError` from its own initialiser.
///
/// Android takes that branch. The symptom was not a bad value but a crash in
/// `WebResourceErrorType.HOST_LOOKUP` itself, which made the `onReceivedError invalid url`
/// integration test fail on Android 13 and 17 — inside `expect(...)`, not inside the plugin.
///
/// **These constants are `static final`**: the platform closure runs once, at first access, for the
/// life of the isolate. So the override has to be set before *anything* touches the enum, and one
/// test file can only ever exercise one platform. This file is the Android one, because Android is
/// the platform that was broken.
void main() {
  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
  });
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  group('WebResourceErrorType on Android', () {
    test('reading a constant with extra accepted values does not throw', () {
      // The bug was here, in the initialiser -- not in any conversion.
      expect(() => WebResourceErrorType.HOST_LOOKUP, returnsNormally);
      expect(WebResourceErrorType.HOST_LOOKUP.toNativeValue(), -2);
    });

    test('every constant initialises', () {
      // `values` forces every constant, so this covers any enum that gains a multi-value
      // constant later without anyone remembering this trap.
      expect(() => WebResourceErrorType.values, returnsNormally);
      expect(WebResourceErrorType.values, isNotEmpty);
      for (final value in WebResourceErrorType.values) {
        expect(() => value.toNativeValue(), returnsNormally);
      }
    });

    test('Android resolves its own native code', () {
      expect(
        WebResourceErrorType.fromNativeValue(-2),
        WebResourceErrorType.HOST_LOOKUP,
      );
    });

    test("iOS's extra inbound value is not offered on Android", () {
      // -1006 is an iOS NSError code. The extra-values list is per-platform, so on Android it is
      // empty and this must not resolve -- if it did, the closure would be returning iOS's list
      // on every platform, which is the opposite mistake.
      expect(WebResourceErrorType.fromNativeValue(-1006), isNull);
    });
  });
}
