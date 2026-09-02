// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_entry.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///One message in a [ConversationContext].
///
///Used by [ConversationContext.entries].
///
///**NOTE for iOS**: this maps to `UIConversationEntry` (`UIConversationContext.Entry` in Swift).
///The native type declares [text], [senderIdentifier], [sentDate] and [entryIdentifier] as
///**non-null**, and they are nullable here only so a malformed map cannot crash the bridge:
///**an entry missing any of the four is dropped natively rather than being sent half-built**, since
///a message with no sender or no date would reorder or mis-attribute the conversation the keyboard
///reasons about. Build entries with all four set.
class ConversationEntry {
  ///Uniquely identifies this entry within the conversation.
  String? entryIdentifier;

  ///Identifies the primary recipients of this message.
  ///
  ///A `Set` rather than a list because the native type is an `NSSet`: order carries no meaning and
  ///duplicates are not representable.
  Set<String>? primaryRecipientIdentifiers;

  ///When this entry is a reply to another message, the [entryIdentifier] of that message.
  ///
  ///`null` for a message that is not a reply, which is the common case.
  String? replyThreadIdentifier;

  ///Identifies the message's sender. Match this against the keys of
  ///[ConversationContext.participantNameByIdentifier] and the members of
  ///[ConversationContext.selfIdentifiers].
  String? senderIdentifier;

  ///When the sender added the message to the conversation.
  DateTime? sentDate;

  ///The message's text.
  String? text;
  ConversationEntry({
    this.entryIdentifier,
    this.primaryRecipientIdentifiers,
    this.replyThreadIdentifier,
    this.senderIdentifier,
    this.sentDate,
    this.text,
  });

  ///Gets a possible [ConversationEntry] instance from a [Map] value.
  static ConversationEntry? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = ConversationEntry(
      entryIdentifier: map['entryIdentifier'],
      primaryRecipientIdentifiers: map['primaryRecipientIdentifiers'] != null
          ? Set<String>.from(map['primaryRecipientIdentifiers']!.cast<String>())
          : null,
      replyThreadIdentifier: map['replyThreadIdentifier'],
      senderIdentifier: map['senderIdentifier'],
      sentDate: map['sentDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['sentDate'])
          : null,
      text: map['text'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "entryIdentifier": entryIdentifier,
      "primaryRecipientIdentifiers": primaryRecipientIdentifiers?.toList(),
      "replyThreadIdentifier": replyThreadIdentifier,
      "senderIdentifier": senderIdentifier,
      "sentDate": sentDate?.millisecondsSinceEpoch,
      "text": text,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'ConversationEntry{entryIdentifier: $entryIdentifier, primaryRecipientIdentifiers: $primaryRecipientIdentifiers, replyThreadIdentifier: $replyThreadIdentifier, senderIdentifier: $senderIdentifier, sentDate: $sentDate, text: $text}';
  }
}
