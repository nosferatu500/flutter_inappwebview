import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'navigation_action.dart';
import 'window_features.dart';
import 'url_request.dart';
import 'frame_info.dart';
import 'navigation_type.dart';
// Inherited from NavigationAction_: the generated part references these types, and a part cannot
// carry its own imports, so every type used by a *superclass* field has to be imported here too.
import 'modifier_flag.dart';
import 'button_mask.dart';
import '../in_app_webview/platform_webview.dart';
import 'enum_method.dart';

part 'create_window_action.g.dart';

///Class that represents the navigation request used by the [PlatformWebViewCreationParams.onCreateWindow] event.
@ExchangeableObject()
class CreateWindowAction_ extends NavigationAction_ {
  ///The window id. Used by `WebView` to create a new WebView.
  int windowId;

  ///Indicates if the new window should be a dialog, rather than a full-size window.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  bool? isDialog;

  ///Window features requested by the webpage.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "WKWindowFeatures",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwindowfeatures",
      ),
      MacOSPlatform(
        apiName: "WKWindowFeatures",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwindowfeatures",
      ),
      WindowsPlatform(
        apiName: "ICoreWebView2WindowFeatures",
        apiUrl:
            "https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2windowfeatures?view=webview2-1.0.2210.55",
      ),
    ],
  )
  WindowFeatures_? windowFeatures;

  CreateWindowAction_({
    required this.windowId,
    this.isDialog,
    this.windowFeatures,
    required super.request,
    required super.isForMainFrame,
    super.hasGesture,
    super.isRedirect,
    super.navigationType,
    super.sourceFrame,
    super.targetFrame,
  });
}
