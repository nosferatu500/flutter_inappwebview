import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins the default `excludeFilter` of
/// [PlatformInAppWebViewController.debugLoggingSettings].
///
/// The filter suppresses events that fire often enough to drown a debug log. It listed three
/// patterns until 7.0.0 removed `onFaviconChanged` — an Android-only event whose framework source,
/// `WebChromeClient.onReceivedIcon`, is no longer dispatched (`WebIconDatabase` has been inert
/// since API 19), so it could not fire on any supported platform.
///
/// This is a **public default**, not an implementation detail: an app that never touches
/// `debugLoggingSettings` gets exactly these exclusions, and adding a pattern here silently hides
/// an event from every consumer's debug output. The entries are `RegExp`s matched against the event
/// name, so the assertions below test the matching behaviour rather than comparing `RegExp`
/// objects — `RegExp` has no value equality, and a test doing `equals(RegExp(...))` would pass for
/// the wrong reason.
void main() {
  group('PlatformInAppWebViewController.debugLoggingSettings defaults', () {
    final filter =
        PlatformInAppWebViewController.debugLoggingSettings.excludeFilter;

    test('excludes exactly the two high-frequency scroll events', () {
      expect(filter, hasLength(2));
      expect(
        filter.where((r) => r.hasMatch('onScrollChanged')),
        hasLength(1),
        reason: 'onScrollChanged fires on every scroll frame',
      );
      expect(
        filter.where((r) => r.hasMatch('onOverScrolled')),
        hasLength(1),
        reason: 'onOverScrolled fires on every over-scroll frame',
      );
    });

    test('no longer excludes onFaviconChanged, which no longer exists', () {
      expect(
        filter.any((r) => r.hasMatch('onFaviconChanged')),
        isFalse,
        reason:
            'the event was removed in 7.0.0; a filter entry for it would be dead weight '
            'that also swallows any future event whose name contains it',
      );
    });

    test('does not exclude the ordinary navigation events', () {
      for (final event in const [
        'onLoadStart',
        'onLoadStop',
        'onReceivedError',
        'onProgressChanged',
        'onTitleChanged',
        'onReceivedTouchIconUrl',
      ]) {
        expect(
          filter.any((r) => r.hasMatch(event)),
          isFalse,
          reason: '$event must reach the debug log',
        );
      }
    });

    test('maxLogMessageLength default is unchanged', () {
      expect(
        PlatformInAppWebViewController.debugLoggingSettings.maxLogMessageLength,
        1000,
      );
    });
  });
}
