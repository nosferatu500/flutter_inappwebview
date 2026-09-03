import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import '../in_app_webview/platform_webview.dart';
part 'should_go_to_back_forward_list_item_action.g.dart';

///Class that is used by [PlatformWebViewCreationParams.shouldGoToBackForwardListItem] event.
///It represents the policy to pass back to the decision handler.
@ExchangeableEnum()
class ShouldGoToBackForwardListItemAction_ {
  // ignore: unused_field
  final int _value;
  const ShouldGoToBackForwardListItemAction_._internal(this._value);

  ///Cancel the back/forward navigation. The `WebView` stays where it is.
  static const CANCEL = ShouldGoToBackForwardListItemAction_._internal(0);

  ///Allow the back/forward navigation to continue.
  static const ALLOW = ShouldGoToBackForwardListItemAction_._internal(1);
}
