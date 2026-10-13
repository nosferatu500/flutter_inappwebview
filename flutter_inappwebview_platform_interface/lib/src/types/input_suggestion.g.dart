// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input_suggestion.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///A suggestion the system keyboard offered and the user selected, delivered to
///[PlatformWebViewCreationParams.onInsertInputSuggestion] so the app can insert it into the page.
///
///**NOTE for iOS**: this maps to `UIInputSuggestion`, which **declares no properties at all** — the
///SDK header says *"No properties at this time"*. Everything a suggestion can currently carry comes
///from its one subclass, `UISmartReplySuggestion`, whose entire payload is [smartReply]. So a
///suggestion that is not a Smart Reply arrives with every field `null`: the event still fires,
///because the *fact* that the user picked something is itself the signal, but there is nothing to
///read from it. Fields will be added here as Apple adds subclasses.
///
///Pair it with [PlatformInAppWebViewController.setConversationContext] — without a conversation the
///keyboard has nothing to base a Smart Reply on and this event will not fire.
class InputSuggestion {
  ///The text of the Smart Reply the user selected, when the suggestion is a Smart Reply.
  ///
  ///`null` for any other kind of suggestion. Apple describes it as *"a signal of the user's
  ///intention"* rather than the literal text to commit: you are expected to use it as the basis for
  ///the reply you generate, not necessarily to insert it verbatim.
  String? smartReply;
  InputSuggestion({this.smartReply});

  ///Gets a possible [InputSuggestion] instance from a [Map] value.
  static InputSuggestion? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = InputSuggestion(smartReply: map['smartReply']);
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {"smartReply": smartReply};
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'InputSuggestion{smartReply: $smartReply}';
  }
}
