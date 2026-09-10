import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/models/setting_definition.dart';
import 'package:flutter_inappwebview_example/utils/support_checker.dart';

enum _FakeMethod { alpha }

enum _FakeProperty { beta }

void main() {
  group('SupportedPlatform', () {
    test('declares exactly the platforms this fork builds for', () {
      // §9 dropped macOS, Windows and Linux; Web was never implemented. Each
      // constant here becomes a column in the support matrix, so re-adding one
      // means committing to producing a truthful column for it.
      expect(SupportedPlatform.values, [
        SupportedPlatform.android,
        SupportedPlatform.ios,
      ]);
    });

    test('every platform maps to a distinct, real TargetPlatform', () {
      final mapped = SupportedPlatform.values
          .map((p) => p.targetPlatform)
          .toList();
      expect(mapped, [TargetPlatform.android, TargetPlatform.iOS]);
      expect(mapped.toSet().length, mapped.length);
    });
  });

  group('SupportCheckHelper', () {
    test('targetPlatformFor maps to expected TargetPlatform', () {
      expect(
        SupportCheckHelper.targetPlatformFor(SupportedPlatform.android),
        TargetPlatform.android,
      );
      expect(
        SupportCheckHelper.targetPlatformFor(SupportedPlatform.ios),
        TargetPlatform.iOS,
      );
    });

    // THE regression test for the removed `Web` column.
    //
    // The generated `is*Supported` checks evaluate `platform ?? defaultTargetPlatform`,
    // so forwarding `null` does not ask "is this unsupported?" — it asks "is this
    // supported on the device running right now?". The old `web` constant took
    // exactly that path, which made the Web column echo the host.
    //
    // Proved red before the fix: with `SupportedPlatform.web` present, each of
    // the three helpers forwarded `null` for it.
    test('no helper ever forwards a null TargetPlatform', () {
      final forwarded = <TargetPlatform?>[];

      bool classChecker({TargetPlatform? platform}) {
        forwarded.add(platform);
        return false;
      }

      bool methodChecker(_FakeMethod method, {TargetPlatform? platform}) {
        forwarded.add(platform);
        return false;
      }

      bool propertyChecker(dynamic property, {TargetPlatform? platform}) {
        forwarded.add(platform);
        return false;
      }

      for (final platform in SupportedPlatform.values) {
        SupportCheckHelper.isClassSupportedForPlatform(
          platform: platform,
          checker: classChecker,
        );
        SupportCheckHelper.isMethodSupportedForPlatform(
          platform: platform,
          method: _FakeMethod.alpha,
          checker: methodChecker,
        );
        SupportCheckHelper.isPropertySupportedForPlatform(
          platform: platform,
          property: _FakeProperty.beta,
          checker: propertyChecker,
        );
      }

      expect(forwarded, isNotEmpty);
      expect(forwarded, isNot(contains(null)));
      expect(forwarded.length, SupportedPlatform.values.length * 3);
    });

    test('isMethodSupportedForPlatform forwards target platform', () {
      final calledPlatforms = <TargetPlatform?>[];
      bool fakeChecker(_FakeMethod method, {TargetPlatform? platform}) {
        calledPlatforms.add(platform);
        return platform == TargetPlatform.android;
      }

      final result = SupportCheckHelper.isMethodSupportedForPlatform(
        platform: SupportedPlatform.android,
        method: _FakeMethod.alpha,
        checker: fakeChecker,
      );

      expect(result, isTrue);
      expect(calledPlatforms, [TargetPlatform.android]);
    });

    test('supportedPlatformsForMethod aggregates supported platforms', () {
      bool fakeChecker(_FakeMethod method, {TargetPlatform? platform}) {
        return platform == TargetPlatform.android;
      }

      final supported = SupportCheckHelper.supportedPlatformsForMethod(
        method: _FakeMethod.alpha,
        checker: fakeChecker,
      );

      expect(supported, contains(SupportedPlatform.android));
      expect(supported, isNot(contains(SupportedPlatform.ios)));
    });

    test('isPropertySupportedForPlatform forwards target platform', () {
      final calledPlatforms = <TargetPlatform?>[];
      bool fakeChecker(dynamic property, {TargetPlatform? platform}) {
        calledPlatforms.add(platform);
        return platform == TargetPlatform.iOS;
      }

      final result = SupportCheckHelper.isPropertySupportedForPlatform(
        platform: SupportedPlatform.ios,
        property: _FakeProperty.beta,
        checker: fakeChecker,
      );

      expect(result, isTrue);
      expect(calledPlatforms, [TargetPlatform.iOS]);
    });
  });

  group('support answers do not depend on the host device', () {
    // These go through InAppWebViewSettings.isPropertySupported, a generated
    // static that MockInAppWebViewPlatform does NOT replace (it substitutes the
    // platform *instance*, not the static support tables), so unlike anything
    // routed through `PlatformInAppWebViewController.static()` these assertions
    // read the real per-platform data.
    // The fixture is deliberately a property supported on EXACTLY ONE platform.
    // A both-platform property makes this whole group vacuous: a spurious extra
    // entry would be `true` under either host, so the two sets still compare
    // equal and the test stays green through the very defect it guards.
    const androidOnly = SettingDefinition(
      name: 'algorithmicDarkeningAllowed',
      description: 'test fixture — Android-only',
      type: SettingType.boolean,
      defaultValue: false,
      property: InAppWebViewSettingsProperty.algorithmicDarkeningAllowed,
    );

    Set<SupportedPlatform> computeUnderHost(TargetPlatform host) {
      debugDefaultTargetPlatformOverride = host;
      try {
        return androidOnly.supportedPlatforms;
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    }

    test('the fixture really is single-platform', () {
      // Without this, the assertions below could pass vacuously.
      expect(
        InAppWebViewSettings.isPropertySupported(
          androidOnly.property,
          platform: TargetPlatform.android,
        ),
        isTrue,
      );
      expect(
        InAppWebViewSettings.isPropertySupported(
          androidOnly.property,
          platform: TargetPlatform.iOS,
        ),
        isFalse,
      );
    });

    test('an Android-only setting reports {android} on any host', () {
      // The defect this replaces: the Web column answered `platform: null`,
      // so it reported 108 of 159 properties on an Android host and 89 on an
      // iOS host — the column changed meaning with the device.
      expect(computeUnderHost(TargetPlatform.android), {
        SupportedPlatform.android,
      });
      expect(computeUnderHost(TargetPlatform.iOS), {SupportedPlatform.android});
    });

    test('hasPlatformLimitations is host-independent too', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final underAndroid = androidOnly.hasPlatformLimitations;
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final underIos = androidOnly.hasPlatformLimitations;
      debugDefaultTargetPlatformOverride = null;

      expect(underAndroid, isTrue); // not supported on iOS
      expect(underIos, underAndroid);
    });
  });
}
