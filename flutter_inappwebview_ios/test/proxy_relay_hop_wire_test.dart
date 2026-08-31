import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins the wire contract between Dart's `ProxyRule.relayHop1` / `.relayHop2` and the Swift that
/// consumes them.
///
/// `ProxyRelayHop` shipped as an exported, iOS-annotated type that **no Dart code could reach**:
/// `ProxyRule_` had no field of that type and never had, so the map keys `ProxyManager.swift` reads
/// were never sent. §77 nearly deleted the type as dead before noticing the Swift half was complete
/// and waiting. The fields added in 7.0.0 close that gap, and this test is what stops it silently
/// reopening — nothing compiles the two languages together.
///
/// The expected keys are what `ProxyManager.swift` parses:
///
///   ProxyRule.fromMap:      map["relayHop1"], map["relayHop2"]      (nested [String: Any?])
///   ProxyRelayHop.fromMap:  map["http3RelayEndpoint"], map["http2RelayEndpoint"],
///                           map["additionalHTTPHeaders"]
void main() {
  group('ProxyRule relay hops serialise under the keys ProxyManager.swift reads', () {
    test('relayHop1 and relayHop2 are nested maps under those exact keys', () {
      final map = ProxyRule(
        url: 'https://proxy.example.com:443',
        relayHop1: ProxyRelayHop(
          http3RelayEndpoint: 'https://relay1.example.com/h3',
          http2RelayEndpoint: 'https://relay1.example.com/h2',
          additionalHTTPHeaders: {'X-Token': 'abc'},
        ),
        relayHop2: ProxyRelayHop(
          http2RelayEndpoint: 'https://relay2.example.com/h2',
        ),
      ).toMap();

      // Swift: ProxyRelayHop.fromMap(map: map["relayHop1"] as? [String: Any?])
      expect(map['relayHop1'], isA<Map<String, dynamic>>());
      expect(map['relayHop2'], isA<Map<String, dynamic>>());

      final hop1 = map['relayHop1'] as Map<String, dynamic>;
      expect(hop1['http3RelayEndpoint'], 'https://relay1.example.com/h3');
      expect(hop1['http2RelayEndpoint'], 'https://relay1.example.com/h2');
      expect(hop1['additionalHTTPHeaders'], {'X-Token': 'abc'});

      final hop2 = map['relayHop2'] as Map<String, dynamic>;
      expect(hop2['http2RelayEndpoint'], 'https://relay2.example.com/h2');
      expect(hop2['http3RelayEndpoint'], isNull);
    });

    test(
      'both hops are absent-as-null when not set, which Swift reads as no relay chain',
      () {
        // Swift's `as? [String: Any?]` yields nil for a missing or null value, and
        // `ProxyRelayHop.fromMap` returns nil for it, so `proxyRelayHops` is empty and
        // `toProxyConfiguration()` takes the plain-endpoint branch off `url`.
        final map = ProxyRule(url: 'https://proxy.example.com:443').toMap();
        expect(map['relayHop1'], isNull);
        expect(map['relayHop2'], isNull);
      },
    );

    test('a hop with neither endpoint is rejected before it can be sent', () {
      // ProxyRelayHop_'s constructor asserts that at least one endpoint is non-null, matching
      // Swift's `if http3RelayEndpoint == nil, http2RelayEndpoint == nil { return nil }`.
      expect(() => ProxyRelayHop(), throwsAssertionError);
    });

    test('url survives alongside a relay chain', () {
      // Not cosmetic: Swift's toProxyConfiguration() parses `url` in a guard *before* it looks at
      // the relay hops and returns nil for the whole rule if it fails. A relay-chain rule with an
      // unparseable url is silently dropped, so the field has to keep travelling.
      final map = ProxyRule(
        url: 'https://proxy.example.com:443',
        relayHop1: ProxyRelayHop(
          http3RelayEndpoint: 'https://relay1.example.com/h3',
        ),
      ).toMap();
      expect(map['url'], 'https://proxy.example.com:443');
    });

    test('a relay-hop rule survives a fromMap round trip', () {
      final original = ProxyRule(
        url: 'https://proxy.example.com:443',
        relayHop1: ProxyRelayHop(
          http3RelayEndpoint: 'https://relay1.example.com/h3',
          additionalHTTPHeaders: {'X-Token': 'abc'},
        ),
      );
      final restored = ProxyRule.fromMap(original.toMap())!;
      expect(
        restored.relayHop1?.http3RelayEndpoint,
        'https://relay1.example.com/h3',
      );
      expect(restored.relayHop1?.additionalHTTPHeaders, {'X-Token': 'abc'});
      expect(restored.relayHop2, isNull);
    });
  });
}
