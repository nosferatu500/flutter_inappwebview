import 'package:flutter_inappwebview_example/utils/support_checker.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins that every entry on the Support Matrix actually resolves to a platform.
///
/// `SupportChecker` answers "which platforms support this?" by looking the entry's class up in
/// `_methodSupportResolvers` / `_eventSupportResolvers` and, **when the class is absent, returning
/// an empty set rather than "unknown"**. An empty set renders identically to "supported nowhere",
/// so a class missing from those maps makes the screen state something false about every one of its
/// entries — which is worse than the omission `support_checker_completeness_test.dart` guards, since
/// an absent row is merely invisible while a present one is read and believed.
///
/// That is not hypothetical: `_eventSupportResolvers` covered 2 of the 8 classes that carry events,
/// so all 13 `ChromeSafariBrowser` events, both `InAppBrowser` events and four singletons reported
/// "supported nowhere" until this test existed. No compiler could see it — the entries name their
/// enum values directly, so they are spelled correctly and simply never looked up.
///
/// The empty-set check also catches a resolver wired to the **wrong** enum: `_buildPropertyResolver`
/// resolves by name, so an enum whose names do not match yields `{}` for every entry. What it
/// cannot catch is a resolver wired to an enum that *overlaps* — the last group covers that by
/// pinning per-platform asymmetries that only the correct enum can produce.
void main() {
  final definitions = SupportChecker.getAllApiDefinitions();

  Set<SupportedPlatform> platformsForEvent(String className, String event) {
    final definition = definitions.firstWhere((d) => d.className == className);
    return definition.events
        .firstWhere((e) => e.name == event)
        .supportedPlatforms;
  }

  group('every listed API resolves to at least one platform', () {
    test('no method resolves to the empty set', () {
      final dead = <String>[
        for (final definition in definitions)
          for (final method in definition.methods)
            if (method.supportedPlatforms.isEmpty)
              '${definition.className}.${method.name}',
      ];
      expect(
        dead,
        isEmpty,
        reason:
            'These methods render as supported on no platform. Either their '
            'class is missing from SupportChecker._methodSupportResolvers, or '
            'its resolver is built from the wrong enum.',
      );
    });

    test('no event resolves to the empty set', () {
      final dead = <String>[
        for (final definition in definitions)
          for (final event in definition.events)
            if (event.supportedPlatforms.isEmpty)
              '${definition.className}.${event.name}',
      ];
      expect(
        dead,
        isEmpty,
        reason:
            'These events render as supported on no platform. Either their '
            'class is missing from SupportChecker._eventSupportResolvers, or '
            'its resolver is built from the wrong enum.',
      );
    });
  });

  group('every class carrying entries has a resolver registered', () {
    // The structural form of the same defect, kept alongside the empty-set checks because it names
    // the missing map entry directly, which is the actionable part when this fails.
    //
    // These must read the *per-map* key sets. `registeredClassNames` unions all three maps, so a
    // class with a method resolver and no event resolver looks registered -- the first draft of
    // this test used it and passed against the live bug.
    test('every definition with methods has a method resolver', () {
      final unregistered = definitions
          .where((d) => d.methods.isNotEmpty)
          .map((d) => d.className)
          .where(
            (name) => !SupportChecker.methodResolverClassNames.contains(name),
          )
          .toList();
      expect(
        unregistered,
        isEmpty,
        reason:
            'Add these to SupportChecker._methodSupportResolvers, or their '
            'methods resolve to the empty set.',
      );
    });

    test('every definition with events has an event resolver', () {
      final unregistered = definitions
          .where((d) => d.events.isNotEmpty)
          .map((d) => d.className)
          .where(
            (name) => !SupportChecker.eventResolverClassNames.contains(name),
          )
          .toList();
      expect(
        unregistered,
        isEmpty,
        reason:
            'Add these to SupportChecker._eventSupportResolvers, or their '
            'events resolve to the empty set.',
      );
    });
  });

  group('each resolver is wired to its own enum, not merely to some enum', () {
    // A resolver pointed at an overlapping enum would still answer non-empty, so the checks above
    // would pass while the answers were another class's. These pin asymmetries that only the right
    // generated check produces -- each pair is one Android-only and one iOS-only entry on the same
    // class, so a swapped resolver cannot satisfy both.
    test('ChromeSafariBrowser splits Android-only from iOS-only events', () {
      expect(
        platformsForEvent('ChromeSafariBrowser', 'onPostMessage'),
        contains(SupportedPlatform.android),
      );
      expect(
        platformsForEvent('ChromeSafariBrowser', 'onPostMessage'),
        isNot(contains(SupportedPlatform.ios)),
      );
      expect(
        platformsForEvent('ChromeSafariBrowser', 'onWillOpenInBrowser'),
        contains(SupportedPlatform.ios),
      );
      expect(
        platformsForEvent('ChromeSafariBrowser', 'onWillOpenInBrowser'),
        isNot(contains(SupportedPlatform.android)),
      );
    });

    test('WebAuthenticationSession.onComplete is iOS-only', () {
      final platforms = platformsForEvent(
        'WebAuthenticationSession',
        'onComplete',
      );
      expect(platforms, contains(SupportedPlatform.ios));
      expect(platforms, isNot(contains(SupportedPlatform.android)));
    });

    test('ServiceWorkerClient.shouldInterceptRequest is Android-only', () {
      // Listed under ServiceWorkerController, but the property belongs to ServiceWorkerClient --
      // the resolver has to reach across to that class's checker to answer at all.
      final platforms = platformsForEvent(
        'ServiceWorkerController',
        'shouldInterceptRequest',
      );
      expect(platforms, contains(SupportedPlatform.android));
      expect(platforms, isNot(contains(SupportedPlatform.ios)));
    });

    test('both browsers answer for their own lifecycle events', () {
      // InAppBrowser and ChromeSafariBrowser both declare onOpened/onClosed-shaped events through
      // separate enums; onBrowserCreated exists only on the former.
      expect(
        platformsForEvent('InAppBrowser', 'onBrowserCreated'),
        contains(SupportedPlatform.android),
      );
      expect(
        platformsForEvent('ChromeSafariBrowser', 'onOpened'),
        contains(SupportedPlatform.android),
      );
    });
  });
}
