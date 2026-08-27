// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_cert_challenge.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the challenge of the [PlatformWebViewCreationParams.onReceivedClientCertRequest] event.
///It provides all the information about the challenge.
class ClientCertChallenge extends URLAuthenticationChallenge {
  ///Returns the acceptable types of asymmetric keys.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 21+ ([Official API - ClientCertRequest.getKeyTypes](https://developer.android.com/reference/android/webkit/ClientCertRequest#getKeyTypes()))
  List<String>? keyTypes;

  ///The acceptable certificate issuers for the certificate matching the private key.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 21+ ([Official API - ClientCertRequest.getPrincipals](https://developer.android.com/reference/android/webkit/ClientCertRequest#getPrincipals()))
  List<String>? principals;
  ClientCertChallenge({
    this.keyTypes,
    this.principals,
    required super.protectionSpace,
  });

  ///Gets a possible [ClientCertChallenge] instance from a [Map] value.
  static ClientCertChallenge? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = ClientCertChallenge(
      protectionSpace: URLProtectionSpace.fromMap(
        map['protectionSpace']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      )!,
      keyTypes: map['keyTypes'] != null
          ? List<String>.from(map['keyTypes']!.cast<String>())
          : null,
      principals: map['principals'] != null
          ? List<String>.from(map['principals']!.cast<String>())
          : null,
    );
    return instance;
  }

  ///Converts instance to a map.
  @override
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "protectionSpace": protectionSpace.toMap(enumMethod: enumMethod),
      "keyTypes": keyTypes,
      "principals": principals,
    };
  }

  ///Converts instance to a map.
  @override
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'ClientCertChallenge{protectionSpace: $protectionSpace, keyTypes: $keyTypes, principals: $principals}';
  }
}
