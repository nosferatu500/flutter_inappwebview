import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/proxy.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Boundary coverage for the third channel migrated to Pigeon (§160, `proxy`), in the shape §156
/// established for the pilot and §157 reused.
///
/// The migration's risk is entirely on the wire. `ProxySettings` has six fields of four different
/// shapes — two `List<String>`, a list of nested objects, one non-null bool and two *tri-state*
/// bools — and the hand-written channel passed all of it as an untyped `Map<String, Any?>` parsed
/// key-by-key on the Kotlin side. Nothing static can see a mismatch there, so these drive the
/// **real generated codec** on the **real generated channel names** and assert the exact payload.
///
/// As in §156 this cannot prove the Kotlin half agrees — both halves cannot run in one process —
/// but they are generated from one schema and ship in the same package, so they cannot be
/// version-skewed.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = ProxyHostApi.pigeonChannelCodec;

  // No messageChannelSuffix: androidx's ProxyController is a process-wide singleton.
  const setChannel =
      'dev.flutter.pigeon.flutter_inappwebview_android.ProxyHostApi.setProxyOverride';
  const clearChannel =
      'dev.flutter.pigeon.flutter_inappwebview_android.ProxyHostApi.clearProxyOverride';

  late AndroidProxyController proxy;
  Object? sent;
  Uint8List? sentBytes;
  int setCalls = 0;
  int clearCalls = 0;
  List<Object?>? errorReply;

  void install(String channel, void Function() countCall) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(channel, (message) async {
          countCall();
          sent = message == null ? null : codec.decodeMessage(message);
          sentBytes = message?.buffer.asUint8List(
            message.offsetInBytes,
            message.lengthInBytes,
          );
          if (errorReply != null) return codec.encodeMessage(errorReply);
          return codec.encodeMessage(<Object?>[true]);
        });
  }

  setUp(() {
    sent = null;
    sentBytes = null;
    setCalls = 0;
    clearCalls = 0;
    errorReply = null;
    // The factory returns the process-wide singleton (§155), which is what an app actually gets;
    // using it here keeps the test on the production path.
    proxy = AndroidInAppWebViewPlatform().createPlatformProxyController(
      const PlatformProxyControllerCreationParams(),
    );
    install(setChannel, () => setCalls++);
    install(clearChannel, () => clearCalls++);
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMessageHandler(setChannel, null);
    messenger.setMockMessageHandler(clearChannel, null);
  });

  /// The single argument Dart put on the wire, as the generated data class.
  ProxySettingsData sentSettings() =>
      (sent as List<Object?>).single as ProxySettingsData;

  test('the two string lists are not interchangeable', () async {
    await proxy.setProxyOverride(
      settings: ProxySettings(
        bypassRules: ['*.bypass.test'],
        directs: ['*.direct.test'],
      ),
    );

    final settings = sentSettings();
    // Distinct values, asserted separately: both fields are List<String>, so a swapped assignment
    // at the boundary is invisible to any check that treats them as a pair.
    expect(settings.bypassRules, ['*.bypass.test']);
    expect(settings.directs, ['*.direct.test']);
    expect(setCalls, 1);
  });

  test(
    'a proxy rule carries its url and the scheme filter native value',
    () async {
      await proxy.setProxyOverride(
        settings: ProxySettings(
          proxyRules: [
            ProxyRule(
              url: 'http://proxy.test:8080',
              schemeFilter: ProxySchemeFilter.MATCH_HTTPS,
            ),
          ],
        ),
      );

      final rule = sentSettings().proxyRules.single;
      expect(rule.url, 'http://proxy.test:8080');
      // The enum crosses as androidx's own string, not as an index or a Dart name -- androidx types
      // this parameter `@ProxyConfig.ProxyScheme String`.
      expect(rule.schemeFilter, 'https');
    },
  );

  test('a rule with no scheme filter sends null', () async {
    await proxy.setProxyOverride(
      settings: ProxySettings(
        proxyRules: [ProxyRule(url: 'http://proxy.test:8080')],
      ),
    );

    // Null is not a cosmetic difference: it selects androidx's one-argument
    // `addProxyRule(url)` overload instead of `addProxyRule(url, schemeFilter)`.
    expect(sentSettings().proxyRules.single.schemeFilter, isNull);
  });

  test('the seven iOS-only ProxyRule fields never reach the wire', () async {
    await proxy.setProxyOverride(
      settings: ProxySettings(
        proxyRules: [
          ProxyRule(
            url: 'http://proxy.test:8080',
            username: 'uniq-username-marker',
            password: 'uniq-password-marker',
            allowFailover: true,
            excludedDomains: ['uniq-excluded-marker'],
            matchDomains: ['uniq-match-marker'],
          ),
        ],
      ),
    );

    final rule = sentSettings().proxyRules.single;
    expect(rule.url, 'http://proxy.test:8080');

    // The typed ProxyRuleData has no field to carry them, but that is an argument about the schema
    // rather than about the bytes. Search the actual encoded message: the hand-written channel
    // really did put these on the wire, because `ProxyRule.toMap()` emits all nine fields
    // unconditionally and the Kotlin side read none of them.
    final wire = String.fromCharCodes(sentBytes!);
    for (final marker in [
      'uniq-username-marker',
      'uniq-password-marker',
      'uniq-excluded-marker',
      'uniq-match-marker',
    ]) {
      expect(
        wire.contains(marker),
        isFalse,
        reason:
            '$marker crossed the wire; the payload should carry only url + schemeFilter',
      );
    }
  });

  test('reverseBypassEnabled defaults to false and is never null', () async {
    await proxy.setProxyOverride(settings: ProxySettings());

    // Non-null in the schema on purpose: the platform interface defaults it to false, so the
    // Kotlin side's old `!= null` guard could never fail. If this ever arrives null the schema and
    // the platform interface have drifted apart.
    expect(sentSettings().reverseBypassEnabled, isFalse);
  });

  test('reverseBypassEnabled true crosses as true', () async {
    await proxy.setProxyOverride(
      settings: ProxySettings(reverseBypassEnabled: true),
    );

    expect(sentSettings().reverseBypassEnabled, isTrue);
  });

  test('the two builder-call flags are tri-state: unset stays null', () async {
    await proxy.setProxyOverride(settings: ProxySettings());

    final settings = sentSettings();
    // Must be null, not false. androidx exposes these as builder calls with no inverse, so the
    // Kotlin side tests `== true`; collapsing unset to false would read the same here but would
    // erase the distinction the next reader depends on.
    expect(settings.bypassSimpleHostnames, isNull);
    expect(settings.removeImplicitRules, isNull);
  });

  test('an explicit false is preserved and is distinct from unset', () async {
    await proxy.setProxyOverride(
      settings: ProxySettings(
        bypassSimpleHostnames: false,
        removeImplicitRules: false,
      ),
    );

    final settings = sentSettings();
    expect(settings.bypassSimpleHostnames, isFalse);
    expect(settings.removeImplicitRules, isFalse);
  });

  test('the two flags are not interchangeable', () async {
    await proxy.setProxyOverride(
      settings: ProxySettings(
        bypassSimpleHostnames: true,
        removeImplicitRules: false,
      ),
    );

    final settings = sentSettings();
    expect(settings.bypassSimpleHostnames, isTrue);
    expect(settings.removeImplicitRules, isFalse);
  });

  test('clearProxyOverride sends no arguments on its own channel', () async {
    await proxy.clearProxyOverride();

    expect(clearCalls, 1);
    // Its own channel, not setProxyOverride's -- the generated names differ only in the method
    // segment, which is exactly the kind of thing a copy-paste migration gets wrong.
    expect(setCalls, 0);
    expect(sent, isNull);
  });

  test('a host error surfaces with its code and message', () async {
    errorReply = <Object?>[
      'proxy-failed',
      'androidx rejected the config',
      null,
    ];

    // Asserted on `code` and `message`, not just `isA<PlatformException>()`. With no handler at
    // all Pigeon also throws a PlatformException (code 'channel-error'), so the loose form passes
    // while proving nothing about the error envelope -- the vacuity §157's mutant B exposed.
    await expectLater(
      proxy.setProxyOverride(settings: ProxySettings()),
      throwsA(
        isA<PlatformException>()
            .having((e) => e.code, 'code', 'proxy-failed')
            .having(
              (e) => e.message,
              'message',
              'androidx rejected the config',
            ),
      ),
    );
  });
}
