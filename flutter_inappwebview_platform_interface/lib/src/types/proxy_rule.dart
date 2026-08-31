import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'enum_method.dart';
import 'proxy_relay_hop.dart';
import 'proxy_scheme_filter.dart';

part 'proxy_rule.g.dart';

///Class that holds a scheme filter and a proxy URL.
@ExchangeableObject()
class ProxyRule_ {
  ///Represents the scheme filter.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  ProxySchemeFilter_? schemeFilter;

  ///Represents the proxy URL.
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  String url;

  ///A Boolean that indicates whether or not a proxy configuration allows failover to non-proxied connections.
  ///Failover isn’t allowed by default.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  bool? allowFailover;

  ///Sets a username to use as authentication for a proxy configuration.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  String? username;

  ///Sets a password to use as authentication for a proxy configuration.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  String? password;

  ///Define an array of domains to determine which hosts should not use the proxy.
  ///If the array is empty, no domains are excluded.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  List<String>? excludedDomains;

  ///Define an array of domains to determine which hosts should use the proxy. If the array is empty,
  ///all domains are allowed to use the proxy other than domains listed in [excludedDomains].
  @SupportedPlatforms(platforms: [IOSPlatform()])
  List<String>? matchDomains;

  ///The first relay in the chain used to reach the proxy.
  ///
  ///Setting this switches the rule from a plain proxy endpoint to a **relay chain**: the
  ///configuration is built from [relayHop1] (and [relayHop2] if given) instead of from [url].
  ///
  ///[url] is still **required and must still parse**, even though it is not used to reach the
  ///proxy in this mode — an unparseable [url] makes the whole rule be dropped before the relay
  ///hops are looked at.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'ProxyConfiguration.init(relayHops:)',
        apiUrl:
            'https://developer.apple.com/documentation/network/proxyconfiguration/init(relayhops:)',
        available: '17.0',
      ),
    ],
  )
  ProxyRelayHop_? relayHop1;

  ///The second relay in the chain, used only when [relayHop1] is also set.
  ///
  ///A chain of two hops means the first relay cannot see the destination and the second cannot see
  ///the client. Setting this without [relayHop1] has no effect.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'ProxyConfiguration.init(relayHops:)',
        apiUrl:
            'https://developer.apple.com/documentation/network/proxyconfiguration/init(relayhops:)',
        available: '17.0',
      ),
    ],
  )
  ProxyRelayHop_? relayHop2;

  ProxyRule_({
    required this.url,
    this.schemeFilter,
    this.allowFailover,
    this.username,
    this.password,
    this.excludedDomains,
    this.matchDomains,
    this.relayHop1,
    this.relayHop2,
  });
}
