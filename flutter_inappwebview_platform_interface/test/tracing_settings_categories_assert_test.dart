import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards `TracingSettings`'s constructor assert, which used to be wrong in **both** directions
/// (§164) — so this file has to test both, and a one-sided test would have passed against the bug.
///
/// The old check was:
///
/// ```dart
/// categories.map((e) => e.runtimeType is String || e.runtimeType is TracingCategory)
///           .contains(false)
/// ```
///
/// `e.runtimeType` is a `Type` and a `Type` is never a `String`, so the predicate was false for
/// every element; and `.contains(false)` asks "did any element *fail*?", the negation of the
/// invariant. Net effect: the empty default threw, and any non-empty list was accepted whatever it
/// held.
///
/// **Asserts are debug-only.** These pass because `flutter test` runs with them enabled; in a
/// release build the constructor accepts anything, which is why
/// `AndroidTracingController.start` still filters the list defensively rather than trusting it.
void main() {
  group('the valid cases the old assert rejected', () {
    test('the default construction does not throw', () {
      // This is the whole bug: `categories` defaults to `const []`, which mapped to an empty
      // iterable, whose `.contains(false)` is false, which fired the assert.
      expect(() => TracingSettings(), returnsNormally);
      expect(TracingSettings().categories, isEmpty);
    });

    test('an explicitly empty category list does not throw', () {
      expect(() => TracingSettings(categories: []), returnsNormally);
    });

    test('tracingMode without categories does not throw', () {
      // The most likely real-world call, and it crashed.
      expect(
        () => TracingSettings(tracingMode: TracingMode.RECORD_CONTINUOUSLY),
        returnsNormally,
      );
    });

    test('strings, categories and a mix of both are all accepted', () {
      expect(
        () => TracingSettings(categories: ['blink*', 'renderer.scheduler']),
        returnsNormally,
      );
      expect(
        () => TracingSettings(
          categories: [
            TracingCategory.CATEGORIES_ANDROID_WEBVIEW,
            TracingCategory.CATEGORIES_FRAME_VIEWER,
          ],
        ),
        returnsNormally,
      );
      expect(
        () => TracingSettings(
          categories: [TracingCategory.CATEGORIES_ANDROID_WEBVIEW, 'blink*'],
        ),
        returnsNormally,
      );
    });
  });

  group('the invalid cases the old assert accepted', () {
    test('a non-String, non-TracingCategory element throws', () {
      // `TracingSettings(categories: [3.14, #notACategory])` constructed happily before the fix.
      expect(
        () => TracingSettings(categories: [3.14]),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => TracingSettings(categories: [42]),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => TracingSettings(categories: [#notACategory]),
        throwsA(isA<AssertionError>()),
      );
    });

    test('one bad element among good ones still throws', () {
      // `every` must look at all of them, not just the first.
      expect(
        () => TracingSettings(
          categories: [
            'blink*',
            TracingCategory.CATEGORIES_ANDROID_WEBVIEW,
            3.14,
          ],
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('null is rejected like any other non-category', () {
      expect(
        () => TracingSettings(categories: [null]),
        throwsA(isA<AssertionError>()),
      );
    });

    test('the message names the offending runtime types', () {
      // A bare `isA<AssertionError>()` would also pass if the assert fired for the *wrong* reason —
      // which is exactly what the old one did for the empty list. Pin the message so this test
      // cannot be satisfied by the bug it exists to exclude.
      expect(
        () => TracingSettings(categories: [3.14]),
        throwsA(
          isA<AssertionError>().having(
            (e) => e.message.toString(),
            'message',
            allOf(contains('String or TracingCategory'), contains('double')),
          ),
        ),
      );
    });
  });
}
