import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the wire shape of [NavigationAction.modifierFlags] and
/// [NavigationAction.buttonNumber] (iOS 18.4+).
///
/// Both are bit masks natively (`UIKeyModifierFlags`, `UIEvent.ButtonMask`) and are decomposed
/// into string lists by `Util.getModifierFlagsString` / `Util.getButtonMaskString` on the Swift
/// side. Nothing in this repo compiles those two languages together, so the only thing keeping the
/// Swift strings and the Dart enum values in agreement is a test that names them literally — the
/// same reason `webview_feature_test.dart` exists (§24/§36).
///
/// The expected strings below are exactly the literals in `Util.swift`.
void main() {
  group('NavigationAction pointer/keyboard modifiers', () {
    test('ModifierFlag values match the strings Util.swift emits', () {
      // Swift: if flags.contains(.alphaShift) { result.append("ALPHA_SHIFT") } etc.
      expect(ModifierFlag.ALPHA_SHIFT.toNativeValue(), 'ALPHA_SHIFT');
      expect(ModifierFlag.SHIFT.toNativeValue(), 'SHIFT');
      expect(ModifierFlag.CONTROL.toNativeValue(), 'CONTROL');
      expect(ModifierFlag.ALTERNATE.toNativeValue(), 'ALTERNATE');
      expect(ModifierFlag.COMMAND.toNativeValue(), 'COMMAND');
      expect(ModifierFlag.NUMERIC_PAD.toNativeValue(), 'NUMERIC_PAD');
      expect(ModifierFlag.values, hasLength(6));
    });

    test('ButtonMask values match the strings Util.swift emits', () {
      expect(ButtonMask.PRIMARY.toNativeValue(), 'PRIMARY');
      expect(ButtonMask.SECONDARY.toNativeValue(), 'SECONDARY');
      // UIEvent.ButtonMask declares only these two constants; a third mouse button has no
      // symbol to test against and is deliberately not reported.
      expect(ButtonMask.values, hasLength(2));
    });

    test('fromMap decodes what the Swift toMap sends', () {
      final action = NavigationAction.fromMap({
        'request': {'url': 'https://example.com'},
        'isForMainFrame': true,
        // Swift sends a command-shift click as two separate strings.
        'modifierFlags': ['SHIFT', 'COMMAND'],
        'buttonNumber': ['SECONDARY'],
      })!;

      expect(action.modifierFlags, [ModifierFlag.SHIFT, ModifierFlag.COMMAND]);
      expect(action.buttonNumber, [ButtonMask.SECONDARY]);
    });

    test('an empty list and null mean different things', () {
      // Below iOS 18.4 the Swift side sends nil: "this platform did not report it".
      final unreported = NavigationAction.fromMap({
        'request': {'url': 'https://example.com'},
        'isForMainFrame': true,
      })!;
      expect(unreported.modifierFlags, isNull);
      expect(unreported.buttonNumber, isNull);

      // On 18.4+ an unmodified click reports an empty list: "reported, nothing held".
      final plainClick = NavigationAction.fromMap({
        'request': {'url': 'https://example.com'},
        'isForMainFrame': true,
        'modifierFlags': <String>[],
        'buttonNumber': <String>['PRIMARY'],
      })!;
      expect(plainClick.modifierFlags, isEmpty);
      expect(plainClick.buttonNumber, [ButtonMask.PRIMARY]);
    });

    test('CreateWindowAction inherits both fields', () {
      // CreateWindowAction extends NavigationAction, so onCreateWindow gets these for free —
      // and the generated part needs the imports in create_window_action.dart to say so.
      final action = CreateWindowAction.fromMap({
        'request': {'url': 'https://example.com'},
        'isForMainFrame': true,
        'windowId': 1,
        'modifierFlags': ['COMMAND'],
        'buttonNumber': ['PRIMARY'],
      })!;

      expect(action.modifierFlags, [ModifierFlag.COMMAND]);
      expect(action.buttonNumber, [ButtonMask.PRIMARY]);
    });
  });
}
