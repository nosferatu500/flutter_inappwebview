import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../in_app_webview/in_app_webview_settings.dart';

part 'layout_algorithm.g.dart';

///Class used to set the underlying layout algorithm.
@ExchangeableEnum()
class LayoutAlgorithm_ {
  // ignore: unused_field
  final String _value;
  const LayoutAlgorithm_._internal(this._value);

  ///NORMAL means no rendering changes. This is the recommended choice for maximum compatibility across different platforms and Android versions.
  static const NORMAL = LayoutAlgorithm_._internal("NORMAL");

  ///TEXT_AUTOSIZING boosts font size of paragraphs based on heuristics to make the text readable when viewing a wide-viewport layout in the overview mode.
  ///It is recommended to enable zoom support [InAppWebViewSettings.supportZoom] when using this mode.
  ///
  ///**NOTE**: available on Android 19+.
  static const TEXT_AUTOSIZING = LayoutAlgorithm_._internal("TEXT_AUTOSIZING");
}
