import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import 'pigeons/in_app_webview.g.dart';

// The Pigeon forms of a web resource request and response, shared by the three blocking waits that
// carry them: the service worker's intercept (§186), the WebView's intercept and custom-scheme load
// (W5, §216), and the custom path handler (§205, typed in W5). Internal: not exported.

/// Conversions from the request every blocking wait receives.
extension WebResourceRequestDataConversions on WebResourceRequestData {
  /// The public request the app's handler is given.
  WebResourceRequest toWebResourceRequest() => WebResourceRequest(
    url: WebUri(url),
    headers: headers,
    isRedirect: isRedirect,
    hasGesture: hasGesture,
    isForMainFrame: isForMainFrame,
    method: method,
  );

  /// The map Kotlin's `WebResourceRequestExt.toMap()` sent on the MethodChannel, key for key, for
  /// the controller's `_handleMethod`.
  Map<String, dynamic> toMethodChannelMap() => {
    'url': url,
    'headers': headers,
    'isRedirect': isRedirect,
    'hasGesture': hasGesture,
    'isForMainFrame': isForMainFrame,
    'method': method,
  };
}

/// The Pigeon form of an app's response.
extension WebResourceResponsePigeon on WebResourceResponse {
  /// Every field, nullability included: Kotlin's `toWebResourceResponse` branches on which are
  /// present.
  WebResourceResponseData toPigeon() => WebResourceResponseData(
    contentType: contentType,
    contentEncoding: contentEncoding,
    statusCode: statusCode,
    reasonPhrase: reasonPhrase,
    headers: headers,
    data: data,
    cookies: cookies,
  );
}
