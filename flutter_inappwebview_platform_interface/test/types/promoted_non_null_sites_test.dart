import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Reaches the four lines that lost a no-op `!` when `unnecessary_non_null_assertion` was enabled
/// (§224). Three are `list.add` on a local the preceding `= <T>[]` had already promoted, and one is
/// `ActionModeMenuItem.|`, where `_nativeValue` is a private final field promoted by its `!= null`
/// check (the generator emits that operator, so the fix is in the generator).
void main() {
  /// A self-signed P-256 certificate made for this test with openssl, carrying two certificate
  /// policies: `1.2.3.4` without qualifiers, and `1.3.6.1.4.1.99999.1` with one CPS qualifier,
  /// `https://example.com/cps`. Only its public DER is here.
  final der = base64Decode(
    'MIIBnjCCAUOgAwIBAgIUcrWtS8U9e6E/byp21+5QvRjV2zgwCgYIKoZIzj0EAwIwGTEXMBUGA1UE'
    'AwwOcG9saWN5LWZpeHR1cmUwIBcNMjYxMDAyMDEzMjAxWhgPMjEyNjA5MDgwMTMyMDFaMBkxFzAV'
    'BgNVBAMMDnBvbGljeS1maXh0dXJlMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEjlXK6BVwoBYR'
    'xBFrUhBBnWsn1c3vRNOZZP4x9IW3qUsBLZmSCeXhCwkowjUAjR3hpxHpe9Jt9W1+X4cLdoS8t6Nn'
    'MGUwRAYDVR0gBD0wOzAFBgMqAwQwMgYJKwYBBAGGjR8BMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8v'
    'ZXhhbXBsZS5jb20vY3BzMB0GA1UdDgQWBBThHSyxLgjufPr9xZABXkFw+pIWVDAKBggqhkjOPQQD'
    'AgNJADBGAiEA4O2c/veg4TlT0znQyq1L02RqROUtw/7XDZz3FS36Qx0CIQCLzXzDFtZ35ehVLcIf'
    'SxRtGsWXsPFX9TSaghqAiTt3xA==',
  );
  final junk = Uint8List.fromList([1, 2, 3]);

  /// Runs [body] with its prints discarded, so the undecodable entry's log doesn't reach the output.
  T quiet<T>(T Function() body) => runZoned(
    body,
    zoneSpecification: ZoneSpecification(print: (_, _, _, _) {}),
  );

  test(
    'URLCredential keeps the certificates that decode and skips the rest',
    () {
      final credential = quiet(
        () => URLCredential.fromMap({
          'certificates': [der, junk],
        }),
      );
      expect(credential!.certificates, hasLength(1));
      expect(
        credential.certificates!.single.subjectDistinguishedName,
        contains('policy-fixture'),
      );
    },
  );

  test(
    'URLProtectionSpace keeps the distinguished names that decode and skips the rest',
    () {
      final space = quiet(
        () => URLProtectionSpace.fromMap({
          'host': 'example.com',
          'protocol': 'https',
          'port': 443,
          'distinguishedNames': [junk, der],
        }),
      );
      expect(space!.distinguishedNames, hasLength(1));
    },
  );

  test('certificate policies: qualifiers are collected only where present', () {
    final policies = X509Certificate.fromData(
      data: der,
    ).certificatePolicies!.policies!;
    expect(policies.map((p) => p.oid), ['1.2.3.4', '1.3.6.1.4.1.99999.1']);
    expect(policies[0].qualifiers, isNull);
    expect(policies[1].qualifiers, hasLength(1));
    expect(policies[1].qualifiers!.single.oid, '1.3.6.1.5.5.7.2.1');
    expect(policies[1].qualifiers!.single.value, 'https://example.com/cps');
  });

  test('ActionModeMenuItem | combines both the value and the native value', () {
    final both =
        ActionModeMenuItem.MENU_ITEM_SHARE |
        ActionModeMenuItem.MENU_ITEM_WEB_SEARCH;
    expect(both.toValue(), 3);
    expect(both.toNativeValue(), 3);
  });
}
