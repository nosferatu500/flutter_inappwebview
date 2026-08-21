// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_agent_brand_version.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents one entry of the
///[User-Agent Client Hints](https://developer.mozilla.org/en-US/docs/Web/HTTP/Client_hints#user-agent_client_hints)
///brand list, i.e. one `brand`/`version` pair in `Sec-CH-UA`.
///
///Used by [UserAgentMetadata.brandVersionList].
class UserAgentBrandVersion {
  ///The brand name, e.g. `My WebView App`.
  String brand;

  ///The full version, sent in the high-entropy `Sec-CH-UA-Full-Version-List` hint,
  ///e.g. `120.0.6099.43`.
  String fullVersion;

  ///The major version, sent in the low-entropy `Sec-CH-UA` hint, e.g. `120`.
  String majorVersion;
  UserAgentBrandVersion({
    required this.brand,
    required this.fullVersion,
    required this.majorVersion,
  });

  ///Gets a possible [UserAgentBrandVersion] instance from a [Map] value.
  static UserAgentBrandVersion? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = UserAgentBrandVersion(
      brand: map['brand'],
      fullVersion: map['fullVersion'],
      majorVersion: map['majorVersion'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "brand": brand,
      "fullVersion": fullVersion,
      "majorVersion": majorVersion,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'UserAgentBrandVersion{brand: $brand, fullVersion: $fullVersion, majorVersion: $majorVersion}';
  }
}
