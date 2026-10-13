// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'http_authentication_challenge.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the challenge of the [PlatformWebViewCreationParams.onReceivedHttpAuthRequest] event.
///It provides all the information about the challenge.
class HttpAuthenticationChallenge extends URLAuthenticationChallenge {
  ///The error object representing the last authentication failure.
  ///This value is `null` if the protocol doesn’t use errors to indicate an authentication failure.
  ///
  ///**NOTE**: available only on iOS.
  String? error;

  ///The URL response object representing the last authentication failure.
  ///This value is `null` if the protocol doesn’t use responses to indicate an authentication failure.
  ///
  ///**NOTE**: available only on iOS.
  URLResponse? failureResponse;

  ///A count of previous failed authentication attempts.
  ///
  ///Scoped to this WebView and this protection space: a challenge from a different host, scheme,
  ///realm or port starts its own count, and so does another WebView. It resets when the page
  ///finishes or fails loading, and when you answer [HttpAuthResponseAction.CANCEL].
  ///
  ///**The first challenge for a protection space reports `0`** — the value counts attempts that
  ///have *already* failed, and on the first one nothing has. Three challenges for the same space
  ///report `0`, `1`, `2`, on every platform. "Give up after N attempts" is the usual reason to
  ///read this, so it is safe to compare against a literal.
  ///
  ///**This changed on Android in 7.0.0.** Before it, Android counted the challenges themselves and
  ///reported `1` for the first, one ahead of iOS. If you carry a workaround for that offset,
  ///remove it.
  int previousFailureCount;

  ///The proposed credential for this challenge.
  ///This method returns `null` if there is no default credential for this challenge.
  ///If you have previously attempted to authenticate and failed, this method returns the most recent failed credential.
  ///If the proposed credential is not nil and returns true when you call its hasPassword method, then the credential is ready to use as-is.
  ///If the proposed credential’s hasPassword method returns false, then the credential provides a default user name,
  ///and the client must prompt the user for a corresponding password.
  URLCredential? proposedCredential;
  HttpAuthenticationChallenge({
    this.error,
    this.failureResponse,
    required this.previousFailureCount,
    this.proposedCredential,
    required super.protectionSpace,
  });

  ///Gets a possible [HttpAuthenticationChallenge] instance from a [Map] value.
  static HttpAuthenticationChallenge? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = HttpAuthenticationChallenge(
      protectionSpace: URLProtectionSpace.fromMap(
        map['protectionSpace']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      )!,
      error: map['error'],
      failureResponse: URLResponse.fromMap(
        map['failureResponse']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
      previousFailureCount: map['previousFailureCount'],
      proposedCredential: URLCredential.fromMap(
        map['proposedCredential']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
    );
    return instance;
  }

  ///Converts instance to a map.
  @override
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "protectionSpace": protectionSpace.toMap(enumMethod: enumMethod),
      "error": error,
      "failureResponse": failureResponse?.toMap(enumMethod: enumMethod),
      "previousFailureCount": previousFailureCount,
      "proposedCredential": proposedCredential?.toMap(enumMethod: enumMethod),
    };
  }

  ///Converts instance to a map.
  @override
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'HttpAuthenticationChallenge{protectionSpace: $protectionSpace, error: $error, failureResponse: $failureResponse, previousFailureCount: $previousFailureCount, proposedCredential: $proposedCredential}';
  }
}
