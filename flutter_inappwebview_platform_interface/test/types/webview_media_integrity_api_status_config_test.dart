import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the wire shape of [WebViewMediaIntegrityApiStatusConfig].
///
/// The `toMap`/`fromMap` here are generated, and the generator is not infallible: modelling
/// `overrideRules` as `Map<String, WebViewMediaIntegrityApiStatus>` produced code that cast raw
/// ints straight to the enum type and passed enum objects into the codec — broken both ways, and
/// invisible to the compiler and to `flutter analyze`. The list-of-rules shape avoids that, and
/// these tests pin the result so a regeneration cannot quietly change it.
///
/// The expected values are not arbitrary: they are exactly what
/// `InAppWebView.buildMediaIntegrityConfig` reads on the Kotlin side.
void main() {
  group('WebViewMediaIntegrityApiStatusConfig', () {
    test('toMap produces the shape the Android side parses', () {
      final config = WebViewMediaIntegrityApiStatusConfig(
        defaultStatus:
            WebViewMediaIntegrityApiStatus.ENABLED_WITHOUT_APP_IDENTITY,
        overrideRules: [
          WebViewMediaIntegrityApiStatusOverrideRule(
            origin: 'https://*.example.com',
            status: WebViewMediaIntegrityApiStatus.ENABLED,
          ),
        ],
      );

      final map = config.toMap();

      // Kotlin: map["defaultStatus"] as Int
      expect(map['defaultStatus'], 1);

      // Kotlin: map["overrideRules"] as? List<Map<String, Any?>>
      final rules = map['overrideRules'] as List;
      expect(rules, hasLength(1));
      final rule = rules.first as Map;
      // Kotlin: rule["origin"] as? String / rule["status"] as? Int
      expect(rule['origin'], 'https://*.example.com');
      expect(rule['status'], 2);
    });

    test('fromMap restores typed enums, not raw ints', () {
      final restored = WebViewMediaIntegrityApiStatusConfig.fromMap({
        'defaultStatus': 0,
        'overrideRules': [
          {'origin': 'https://example.org', 'status': 2},
        ],
      })!;

      expect(restored.defaultStatus, WebViewMediaIntegrityApiStatus.DISABLED);
      expect(
        restored.overrideRules!.single.status,
        WebViewMediaIntegrityApiStatus.ENABLED,
      );
      expect(restored.overrideRules!.single.origin, 'https://example.org');
    });

    test('overrideRules is optional', () {
      final map = WebViewMediaIntegrityApiStatusConfig(
        defaultStatus: WebViewMediaIntegrityApiStatus.DISABLED,
      ).toMap();

      expect(map['defaultStatus'], 0);
      expect(map['overrideRules'], isNull);
    });

    test('the config survives being nested in InAppWebViewSettings', () {
      final map = InAppWebViewSettings(
        webViewMediaIntegrityApiStatus: WebViewMediaIntegrityApiStatusConfig(
          defaultStatus: WebViewMediaIntegrityApiStatus.ENABLED,
        ),
      ).toMap();

      expect(map['webViewMediaIntegrityApiStatus']['defaultStatus'], 2);
    });
  });
}
