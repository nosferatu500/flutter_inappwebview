import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the wire shape of [UserAgentMetadata].
///
/// The expected keys and value types are exactly what `InAppWebView.buildUserAgentMetadata` reads
/// on the Kotlin side. It pulls each field out with `as?` and skips anything absent, so a renamed
/// key or a changed value type does not fail — the hint is just silently never applied. These
/// tests are what make that visible.
void main() {
  group('UserAgentMetadata', () {
    test('toMap produces the keys and types the Android side reads', () {
      final metadata = UserAgentMetadata(
        brandVersionList: [
          UserAgentBrandVersion(
            brand: 'My WebView App',
            majorVersion: '120',
            fullVersion: '120.0.6099.43',
          ),
        ],
        fullVersion: '120.0.6099.43',
        platform: 'Android',
        platformVersion: '14',
        architecture: 'arm',
        model: 'Pixel 8',
        mobile: true,
        bitness: 64,
        wow64: false,
        formFactors: [UserAgentFormFactor.MOBILE, UserAgentFormFactor.XR],
      );

      final map = metadata.toMap();

      // Kotlin: (map["brandVersionList"] as? List<Map<String, Any?>>)
      final brands = map['brandVersionList'] as List;
      expect(brands, hasLength(1));
      final brand = brands.single as Map;
      expect(brand['brand'], 'My WebView App');
      expect(brand['majorVersion'], '120');
      expect(brand['fullVersion'], '120.0.6099.43');

      // Kotlin: (map["<key>"] as? String / Boolean / Int)
      expect(map['fullVersion'], '120.0.6099.43');
      expect(map['platform'], 'Android');
      expect(map['platformVersion'], '14');
      expect(map['architecture'], 'arm');
      expect(map['model'], 'Pixel 8');
      expect(map['mobile'], isTrue);
      expect(map['bitness'], 64);
      expect(map['wow64'], isFalse);

      // Kotlin: (map["formFactors"] as? List<String>) — the enum must flatten to its
      // native String value, not to an enum object or an index.
      expect(map['formFactors'], ['Mobile', 'XR']);
    });

    test('omitted fields stay absent so the builder keeps its defaults', () {
      final map = UserAgentMetadata(platform: 'Android').toMap();

      expect(map['platform'], 'Android');
      // Kotlin uses `?.let` per field, so null means "do not call the setter".
      expect(map['brandVersionList'], isNull);
      expect(map['model'], isNull);
      expect(map['mobile'], isNull);
      expect(map['bitness'], isNull);
      expect(map['formFactors'], isNull);
    });

    test('fromMap restores typed form factors, not raw strings', () {
      final restored = UserAgentMetadata.fromMap({
        'platform': 'Android',
        'formFactors': ['Tablet'],
        'brandVersionList': [
          {'brand': 'B', 'majorVersion': '1', 'fullVersion': '1.0.0'},
        ],
      })!;

      expect(restored.platform, 'Android');
      expect(restored.formFactors, [UserAgentFormFactor.TABLET]);
      expect(restored.brandVersionList!.single.brand, 'B');
    });

    test('every form factor maps to the Android constant string', () {
      expect(UserAgentFormFactor.DESKTOP.toNativeValue(), 'Desktop');
      expect(UserAgentFormFactor.AUTOMOTIVE.toNativeValue(), 'Automotive');
      expect(UserAgentFormFactor.MOBILE.toNativeValue(), 'Mobile');
      expect(UserAgentFormFactor.TABLET.toNativeValue(), 'Tablet');
      expect(UserAgentFormFactor.XR.toNativeValue(), 'XR');
      expect(UserAgentFormFactor.EINK.toNativeValue(), 'EInk');
      expect(UserAgentFormFactor.WATCH.toNativeValue(), 'Watch');
    });

    test('the metadata survives being nested in InAppWebViewSettings', () {
      final map = InAppWebViewSettings(
        userAgentMetadata: UserAgentMetadata(platform: 'Android'),
      ).toMap();

      expect(map['userAgentMetadata']['platform'], 'Android');
    });
  });
}
