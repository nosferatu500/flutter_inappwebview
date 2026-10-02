import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'enum_method.dart';
import 'trusted_web_activity_display_mode.dart';

part 'trusted_web_activity_default_display_mode.g.dart';

///Class that represents the default display mode of a Trusted Web Activity.
///The system UI (status bar, navigation bar) is shown, and the browser toolbar is hidden while the user is on a verified origin.
@ExchangeableObject(fromMapFactory: false)
class TrustedWebActivityDefaultDisplayMode_
    implements TrustedWebActivityDisplayMode_ {
  static final _type = "DEFAULT_MODE";

  @ExchangeableObjectMethod(toMapMergeWith: true)
  // Generator input only: the generated copy is the one `toMap` calls, with `enumMethod`.
  // ignore: unused_element, unused_element_parameter
  Map<String, dynamic> _toMapMergeWith({EnumMethod? enumMethod}) {
    return {"type": _type};
  }

  @override
  @ExchangeableObjectMethod(ignore: true)
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
