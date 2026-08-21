import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'webview_media_integrity_api_status.g.dart';

///Class used to configure how much the
///[WebView Media Integrity API](https://developer.android.com/privacy-and-security/webview-media-integrity)
///reveals to a media provider, letting it verify that the WebView is genuine and unmodified before
///serving protected content.
///
///Used by [WebViewMediaIntegrityApiStatusConfig].
@ExchangeableEnum()
class WebViewMediaIntegrityApiStatus_ {
  // ignore: unused_field
  final int _value;
  const WebViewMediaIntegrityApiStatus_._internal(this._value);

  ///The API is turned off. Calls to it fail.
  static const DISABLED = WebViewMediaIntegrityApiStatus_._internal(0);

  ///The API works, but the tokens it issues do not identify the embedding app.
  ///
  ///Use this when a media provider needs to confirm the WebView is genuine but has no need to
  ///know which app it is running in.
  static const ENABLED_WITHOUT_APP_IDENTITY =
      WebViewMediaIntegrityApiStatus_._internal(1);

  ///The API works and its tokens include the embedding app's identity. This is the most permissive
  ///value.
  static const ENABLED = WebViewMediaIntegrityApiStatus_._internal(2);
}
