import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'web_authentication_support.g.dart';

///Class used to configure the level of [Web Authentication API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Authentication_API)
///support a WebView provides, i.e. whether web content may use passkeys.
///
///Used by [InAppWebViewSettings.webAuthenticationSupport].
@ExchangeableEnum()
class WebAuthenticationSupport_ {
  // ignore: unused_field
  final int _value;
  const WebAuthenticationSupport_._internal(this._value);

  ///The WebView does not support the Web Authentication API. This is the default.
  static const NONE = WebAuthenticationSupport_._internal(0);

  ///The WebView supports the Web Authentication API for the app that embeds it.
  ///
  ///Credentials are scoped to the embedding app, so a passkey created here is not shared with the
  ///user's browser. Use this for an app that signs users in to its own service.
  static const FOR_APP = WebAuthenticationSupport_._internal(1);

  ///The WebView supports the Web Authentication API at browser level.
  ///
  ///Intended for apps that are themselves a browser: credentials behave as they would in one,
  ///rather than being scoped to the embedding app. Requires the app to be the registered default
  ///browser or otherwise privileged; see the Android documentation before using it.
  static const FOR_BROWSER = WebAuthenticationSupport_._internal(2);
}
