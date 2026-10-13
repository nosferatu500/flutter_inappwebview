// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_context.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///A conversation — a mail or messaging thread — that the WebView can hand to the system keyboard so
///it can offer **Smart Replies** while the user types into a web text field.
///
///This describes a conversation your *app* owns; the WebView does not read it from the page and
///cannot infer it. Give the keyboard the messages, who sent them and who the participants are, and
///it proposes replies in context.
///
///Set it with [PlatformInAppWebViewController.setConversationContext], **before the keyboard
///appears**, and set it again whenever the conversation changes — the keyboard reads it when it
///comes up, so a context set while the keyboard is already open affects the *next* appearance.
///
///**NOTE for iOS**: this maps to `UIConversationContext`, iOS 26.0+ through
///`WKWebView.conversationContext`. It is a property of the WebView rather than of its
///configuration, so it applies immediately and does not need the WebView recreated.
///
///**NOTE for iOS**: nothing here is transmitted to Apple by this plugin — it is handed to the
///on-device keyboard. It is still conversation content, so send the minimum that makes the replies
///useful, and remember that [entries] is a full message history you are copying across the platform
///channel on every update.
class ConversationContext {
  ///The messages in the conversation, oldest first.
  ///
  ///An entry missing any of its four required fields is dropped natively — see [ConversationEntry].
  List<ConversationEntry>? entries;

  ///Maps a participant identifier — the same values used in [ConversationEntry.senderIdentifier]
  ///and [selfIdentifiers] — to that person's name.
  ///
  ///Names are [PersonNameComponents] rather than plain strings so the platform can abbreviate them
  ///per locale instead of the app guessing at word order.
  Map<String, PersonNameComponents>? participantNameByIdentifier;

  ///Identifies the people a reply would primarily go to.
  Set<String>? responsePrimaryRecipientIdentifiers;

  ///Identifies the person using this device, so the keyboard knows which messages are "mine" and
  ///which it should be drafting a reply to.
  ///
  ///A `Set` because the same person may appear under more than one identifier (an email address and
  ///a phone number, say) and order carries no meaning.
  Set<String>? selfIdentifiers;

  ///Uniquely identifies this conversation, and stays the same for its whole life.
  ///
  ///The keyboard uses it to tell one thread from another; reusing an identifier across unrelated
  ///conversations mixes their context.
  String? threadIdentifier;
  ConversationContext({
    this.entries,
    this.participantNameByIdentifier,
    this.responsePrimaryRecipientIdentifiers,
    this.selfIdentifiers,
    this.threadIdentifier,
  });

  ///Gets a possible [ConversationContext] instance from a [Map] value.
  static ConversationContext? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = ConversationContext(
      entries: map['entries'] != null
          ? List<ConversationEntry>.from(
              map['entries'].map(
                (e) => ConversationEntry.fromMap(
                  e?.cast<String, dynamic>(),
                  enumMethod: enumMethod,
                )!,
              ),
            )
          : null,
      participantNameByIdentifier: map['participantNameByIdentifier'] != null
          ? Map<String, PersonNameComponents>.fromEntries(
              (map['participantNameByIdentifier'] as Map).entries
                  .map<MapEntry<String, PersonNameComponents>>(
                    (e) => MapEntry(
                      e.key as String,
                      PersonNameComponents.fromMap(
                        e.value?.cast<String, dynamic>(),
                        enumMethod: enumMethod,
                      )!,
                    ),
                  ),
            )
          : null,
      responsePrimaryRecipientIdentifiers:
          map['responsePrimaryRecipientIdentifiers'] != null
          ? Set<String>.from(
              map['responsePrimaryRecipientIdentifiers']!.cast<String>(),
            )
          : null,
      selfIdentifiers: map['selfIdentifiers'] != null
          ? Set<String>.from(map['selfIdentifiers']!.cast<String>())
          : null,
      threadIdentifier: map['threadIdentifier'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "entries": entries?.map((e) => e.toMap(enumMethod: enumMethod)).toList(),
      "participantNameByIdentifier": participantNameByIdentifier?.map(
        (k, v) => MapEntry(k, v.toMap(enumMethod: enumMethod)),
      ),
      "responsePrimaryRecipientIdentifiers": responsePrimaryRecipientIdentifiers
          ?.toList(),
      "selfIdentifiers": selfIdentifiers?.toList(),
      "threadIdentifier": threadIdentifier,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'ConversationContext{entries: $entries, participantNameByIdentifier: $participantNameByIdentifier, responsePrimaryRecipientIdentifiers: $responsePrimaryRecipientIdentifiers, selfIdentifiers: $selfIdentifiers, threadIdentifier: $threadIdentifier}';
  }
}
