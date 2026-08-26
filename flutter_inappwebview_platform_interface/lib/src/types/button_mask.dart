import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'button_mask.g.dart';

///Class that represents a pointing-device button that was pressed during a navigation.
///
///The native type is `UIEventButtonMask`, a bit mask defined as `1 << (buttonNumber - 1)`,
///**not** a button index. That matters because the WebKit property it comes from is called
///`buttonNumber`: a caller who reads the raw native value as a number gets `1` for the primary
///button and `2` for the secondary one — which looks like a one-based index but is not, since a
///third button would report `4`. Exposing it as a set of named buttons removes the ambiguity.
@ExchangeableEnum()
class ButtonMask_ {
  // ignore: unused_field
  final String _value;
  const ButtonMask_._internal(this._value);

  ///The primary button, normally a left click or a single-finger tap.
  ///Corresponds to `UIEventButtonMaskPrimary` (`1 << 0`).
  static const PRIMARY = ButtonMask_._internal("PRIMARY");

  ///The secondary button, normally a right click.
  ///Corresponds to `UIEventButtonMaskSecondary` (`1 << 1`).
  static const SECONDARY = ButtonMask_._internal("SECONDARY");
}
