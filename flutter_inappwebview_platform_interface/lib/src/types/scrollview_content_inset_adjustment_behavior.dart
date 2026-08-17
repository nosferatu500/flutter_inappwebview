import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'scrollview_content_inset_adjustment_behavior.g.dart';

///Class used to configure how safe area insets are added to the adjusted content inset.
@ExchangeableEnum()
class ScrollViewContentInsetAdjustmentBehavior_ {
  // ignore: unused_field
  final int _value;
  const ScrollViewContentInsetAdjustmentBehavior_._internal(this._value);

  ///Automatically adjust the scroll view insets.
  static const AUTOMATIC = ScrollViewContentInsetAdjustmentBehavior_._internal(
    0,
  );

  ///Adjust the insets only in the scrollable directions.
  static const SCROLLABLE_AXES =
      ScrollViewContentInsetAdjustmentBehavior_._internal(1);

  ///Do not adjust the scroll view insets.
  static const NEVER = ScrollViewContentInsetAdjustmentBehavior_._internal(2);

  ///Always include the safe area insets in the content adjustment.
  static const ALWAYS = ScrollViewContentInsetAdjustmentBehavior_._internal(3);
}
