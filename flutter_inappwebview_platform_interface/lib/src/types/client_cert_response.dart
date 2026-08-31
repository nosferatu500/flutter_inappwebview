import '../in_app_webview/platform_webview.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../util.dart';
import 'client_cert_response_action.dart';
import 'enum_method.dart';

part 'client_cert_response.g.dart';

///Class that represents the response used by the [PlatformWebViewCreationParams.onReceivedClientCertRequest] event.
@ExchangeableObject()
class ClientCertResponse_ {
  ///The file path of the certificate to use.
  ///
  ///On iOS this is read as a PKCS#12 container via `SecPKCS12Import`. **If it cannot be loaded the
  ///request silently continues without a client certificate** — see
  ///[PlatformWebViewCreationParams.onReceivedClientCertRequest] for the failure mode and for the
  ///iOS 17.x limitation that rejects OpenSSL 3's default encryption.
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  String certificatePath;

  ///The certificate password.
  ///
  ///**A "passphrase is not correct" error from iOS does not reliably mean the password is wrong.**
  ///`SecPKCS12Import` reports `errSecAuthFailed` for a container it cannot parse at all, which on
  ///iOS 17.x includes any file using OpenSSL 3's default `PBES2 / AES-256-CBC` encryption. Check
  ///the container's algorithms before changing this value —
  ///[PlatformWebViewCreationParams.onReceivedClientCertRequest] has the command.
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  String? certificatePassword;

  ///An Android-specific property used by Java [KeyStore](https://developer.android.com/reference/java/security/KeyStore) class to get the instance.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  String? keyStoreType;

  ///Indicate the [ClientCertResponseAction] to take in response of the client certificate challenge.
  ClientCertResponseAction_? action;

  @ExchangeableObjectConstructor()
  ClientCertResponse_({
    this.certificatePath = "",
    this.certificatePassword = "",
    this.keyStoreType = "PKCS12",
    this.action = ClientCertResponseAction_.CANCEL,
  }) {
    if (action == ClientCertResponseAction_.PROCEED && !Util.isWindows) {
      assert(certificatePath.isNotEmpty);
    }

    if (Util.isAndroid) assert(keyStoreType != null);
  }
}
