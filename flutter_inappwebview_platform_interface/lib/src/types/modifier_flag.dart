import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'modifier_flag.g.dart';

///Class that represents a modifier key that was held down during a navigation.
///
///Modelled as a set rather than a single value because the native type,
///`UIKeyModifierFlags`, is a bit mask: more than one modifier can be held at once,
///so a navigation may report `[COMMAND, SHIFT]`.
@ExchangeableEnum()
class ModifierFlag_ {
  // ignore: unused_field
  final String _value;
  const ModifierFlag_._internal(this._value);

  ///The Caps Lock key. Corresponds to `UIKeyModifierAlphaShift` (`1 << 16`).
  static const ALPHA_SHIFT = ModifierFlag_._internal("ALPHA_SHIFT");

  ///The Shift key. Corresponds to `UIKeyModifierShift` (`1 << 17`).
  static const SHIFT = ModifierFlag_._internal("SHIFT");

  ///The Control key. Corresponds to `UIKeyModifierControl` (`1 << 18`).
  static const CONTROL = ModifierFlag_._internal("CONTROL");

  ///The Option/Alt key. Corresponds to `UIKeyModifierAlternate` (`1 << 19`).
  static const ALTERNATE = ModifierFlag_._internal("ALTERNATE");

  ///The Command key. Corresponds to `UIKeyModifierCommand` (`1 << 20`).
  static const COMMAND = ModifierFlag_._internal("COMMAND");

  ///A key on the numeric keypad. Corresponds to `UIKeyModifierNumericPad` (`1 << 21`).
  static const NUMERIC_PAD = ModifierFlag_._internal("NUMERIC_PAD");
}
