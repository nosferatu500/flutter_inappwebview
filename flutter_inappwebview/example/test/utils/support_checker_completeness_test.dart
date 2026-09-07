import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/utils/support_checker.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins that the example's Support Matrix lists every API the plugin exposes.
///
/// `support_checker.dart` is a hand-written inventory: a reader opens the support screen to answer
/// "is this supported on my device?", and an API that is missing from the list simply cannot be
/// found there. Nothing else notices — the app compiles and runs identically either way, which is
/// how the list drifted 43 entries behind the API before this test existed.
///
/// The ground truth is the `Platform*Method` / `Platform*Property` enums in
/// `flutter_inappwebview_platform_interface`: `SupportChecker` resolves every entry's `name`
/// against them at runtime, so an enum value with no entry is exactly an API the screen omits.
///
/// **This test does not check the `signature` strings.** They are free text, nothing derives them,
/// and Dart cannot reflect a method signature at test time — §137 found `'Future<void> flush()'`
/// still sitting here after the return type had changed, and this run found three more of the same
/// shape in `CookieManager`. Treat a signature next to an entry you are editing as unverified.
void main() {
  /// Enum values that are deliberately absent from an events list, with the reason.
  ///
  /// The enums these lists are checked against are *creation params* enums, not events enums: they
  /// carry the constructor's non-callback arguments too. The names below are values you pass in,
  /// not callbacks the object fires, so they have no place on an events list.
  const notEvents = <String>{
    // PlatformWebViewCreationParamsProperty
    'contextMenu',
    'findInteractionController',
    'initialData',
    'initialFile',
    'initialSettings',
    'initialUrlRequest',
    'initialUserScripts',
    'pullToRefreshController',
    'windowId',
    // PlatformPullToRefreshControllerCreationParamsProperty
    'settings',
  };

  /// `PlatformInAppBrowserEventsMethod` is not a list of the browser's own events: 68 of its 70
  /// values are `PlatformWebViewCreationParamsProperty` events, re-fired by the WebView the browser
  /// embeds. The support screen lists those once, under "InAppWebView Events", and gives
  /// `InAppBrowser` only the two that are genuinely its own. Demanding the shared 68 here would
  /// double the screen and teach a reader nothing.
  ///
  /// Subtracting rather than hard-coding the pair keeps the rule live: a new *browser-specific*
  /// event still fails this test, while a new WebView event is demanded on the WebView list.
  final webViewEventNames = PlatformWebViewCreationParamsProperty.values
      .map((property) => property.name)
      .toSet();

  /// The listed name -> enum-values pairs, keyed by the class name `SupportChecker` uses.
  final methodEnums = <String, List<String>>{
    SupportChecker.classNameOf(InAppWebViewController):
        PlatformInAppWebViewControllerMethod.values.map((e) => e.name).toList(),
    SupportChecker.classNameOf(HeadlessInAppWebView):
        PlatformHeadlessInAppWebViewMethod.values.map((e) => e.name).toList(),
    SupportChecker.classNameOf(InAppBrowser): PlatformInAppBrowserMethod.values
        .map((e) => e.name)
        .toList(),
    SupportChecker.classNameOf(ChromeSafariBrowser):
        PlatformChromeSafariBrowserMethod.values.map((e) => e.name).toList(),
    SupportChecker.classNameOf(CookieManager): PlatformCookieManagerMethod
        .values
        .map((e) => e.name)
        .toList(),
    SupportChecker.classNameOf(WebStorage): PlatformLocalStorageMethod.values
        .map((e) => e.name)
        .toList(),
    SupportChecker.classNameOf(
      FindInteractionController,
    ): PlatformFindInteractionControllerMethod.values
        .map((e) => e.name)
        .toList(),
    SupportChecker.classNameOf(
      PullToRefreshController,
    ): PlatformPullToRefreshControllerMethod.values
        .map((e) => e.name)
        .toList(),
    SupportChecker.classNameOf(PrintJobController):
        PlatformPrintJobControllerMethod.values.map((e) => e.name).toList(),
    SupportChecker.classNameOf(
      WebAuthenticationSession,
    ): PlatformWebAuthenticationSessionMethod.values
        .map((e) => e.name)
        .toList(),
    SupportChecker.classNameOf(
      ServiceWorkerController,
    ): PlatformServiceWorkerControllerMethod.values
        .map((e) => e.name)
        .toList(),
    SupportChecker.classNameOf(ProxyController): PlatformProxyControllerMethod
        .values
        .map((e) => e.name)
        .toList(),
    SupportChecker.classNameOf(TracingController):
        PlatformTracingControllerMethod.values.map((e) => e.name).toList(),
    SupportChecker.classNameOf(
      HttpAuthCredentialDatabase,
    ): PlatformHttpAuthCredentialDatabaseMethod.values
        .map((e) => e.name)
        .toList(),
    SupportChecker.classNameOf(ProcessGlobalConfig):
        PlatformProcessGlobalConfigMethod.values.map((e) => e.name).toList(),
    SupportChecker.classNameOf(WebMessageChannel):
        PlatformWebMessageChannelMethod.values.map((e) => e.name).toList(),
  };

  final eventEnums = <String, List<String>>{
    SupportChecker.eventClassNameOf(
      InAppWebView,
    ): PlatformWebViewCreationParamsProperty.values
        .map((e) => e.name)
        .where((name) => !notEvents.contains(name))
        .toList(),
    SupportChecker.classNameOf(InAppBrowser): PlatformInAppBrowserEventsMethod
        .values
        .map((e) => e.name)
        .where((name) => !webViewEventNames.contains(name))
        .toList(),
    SupportChecker.classNameOf(
      ChromeSafariBrowser,
    ): PlatformChromeSafariBrowserEventsMethod.values
        .map((e) => e.name)
        .toList(),
    SupportChecker.classNameOf(
      FindInteractionController,
    ): PlatformFindInteractionControllerCreationParamsProperty.values
        .map((e) => e.name)
        .toList(),
    SupportChecker.classNameOf(
      PullToRefreshController,
    ): PlatformPullToRefreshControllerCreationParamsProperty.values
        .map((e) => e.name)
        .where((name) => !notEvents.contains(name))
        .toList(),
    SupportChecker.classNameOf(PrintJobController):
        PlatformPrintJobControllerProperty.values.map((e) => e.name).toList(),
    SupportChecker.classNameOf(ServiceWorkerController):
        ServiceWorkerClientProperty.values.map((e) => e.name).toList(),
  };

  final definitions = SupportChecker.getAllApiDefinitions();

  ApiClassDefinition definitionFor(String className) => definitions.firstWhere(
    (definition) => definition.className == className,
    orElse: () => throw StateError(
      'No ApiClassDefinition named "$className". getAllApiDefinitions() must '
      'return one per class registered in the resolver maps.',
    ),
  );

  group('the Support Matrix lists every method', () {
    for (final entry in methodEnums.entries) {
      test(entry.key, () {
        final listed = definitionFor(
          entry.key,
        ).methods.map((method) => method.name).toSet();
        final missing = entry.value
            .where((name) => !listed.contains(name))
            .toList();
        expect(
          missing,
          isEmpty,
          reason:
              '${entry.key} exposes these methods and the support screen does '
              'not list them. Add an ApiMethodDefinition for each, in the '
              'category its neighbours use.',
        );
      });
    }
  });

  group('the Support Matrix lists every event', () {
    for (final entry in eventEnums.entries) {
      test(entry.key, () {
        final listed = definitionFor(
          entry.key,
        ).events.map((event) => event.name).toSet();
        final missing = entry.value
            .where((name) => !listed.contains(name))
            .toList();
        expect(
          missing,
          isEmpty,
          reason:
              '${entry.key} fires these events and the support screen does not '
              'list them. Add an ApiEventDefinition for each. If one of these '
              'is not an event at all, add it to `notEvents` with the reason.',
        );
      });
    }
  });

  group('the exclusion list stays honest', () {
    test('every notEvents name is still a creation-params property', () {
      final all = <String>{
        ...PlatformWebViewCreationParamsProperty.values.map((e) => e.name),
        ...PlatformPullToRefreshControllerCreationParamsProperty.values.map(
          (e) => e.name,
        ),
      };
      final stale = notEvents.where((name) => !all.contains(name)).toList();
      expect(
        stale,
        isEmpty,
        reason:
            'These names were excluded from an events list but no longer exist '
            'on the creation-params enum they came from. Drop them.',
      );
    });

    test('no excluded name looks like an event', () {
      // A callback is spelled `onX` or `shouldX` throughout this API. Anything matching that
      // belongs on the events list, not in the exclusion set -- this is what stops the set being
      // used to silence a genuinely missing event.
      final suspicious = notEvents
          .where((name) => name.startsWith('on') || name.startsWith('should'))
          .toList();
      expect(suspicious, isEmpty);
    });
  });
}
