import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'writing_tools_behavior.g.dart';

///Class used to configure how much of the Apple Intelligence Writing Tools UI a WebView offers.
@ExchangeableEnum()
class WritingToolsBehavior_ {
  // ignore: unused_field
  final int _value;
  const WritingToolsBehavior_._internal(this._value);

  ///Writing Tools will ignore this view.
  ///
  ///Corresponds to `UIWritingToolsBehaviorNone`, whose native value is `-1` and not `0`.
  static const NONE = WritingToolsBehavior_._internal(-1);

  ///System-defined behavior, which may itself resolve to [NONE], [COMPLETE] or [LIMITED].
  ///
  ///Note that this is *not* the WebView's default: WebKit documents the default as being
  ///equivalent to [LIMITED]. Selecting [DEFAULT] hands the decision to the system, which may
  ///resolve it differently depending on the device and the OS version.
  static const DEFAULT = WritingToolsBehavior_._internal(0);

  ///The complete inline-editing experience will be provided if possible.
  static const COMPLETE = WritingToolsBehavior_._internal(1);

  ///The limited, overlay-panel experience will be provided if possible.
  ///
  ///This is what a WebView does when the behavior is not set at all.
  static const LIMITED = WritingToolsBehavior_._internal(2);
}
