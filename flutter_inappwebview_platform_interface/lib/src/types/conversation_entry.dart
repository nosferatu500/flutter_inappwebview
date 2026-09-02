import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'enum_method.dart';

part 'conversation_entry.g.dart';

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
@ExchangeableObject()
class ConversationEntry_ {
  ///The message's text.
  String? text;

  ///Identifies the message's sender. Match this against the keys of
  ///[ConversationContext.participantNameByIdentifier] and the members of
  ///[ConversationContext.selfIdentifiers].
  String? senderIdentifier;

  ///When the sender added the message to the conversation.
  DateTime? sentDate;

  ///Uniquely identifies this entry within the conversation.
  String? entryIdentifier;

  ///When this entry is a reply to another message, the [entryIdentifier] of that message.
  ///
  ///`null` for a message that is not a reply, which is the common case.
  String? replyThreadIdentifier;

  ///Identifies the primary recipients of this message.
  ///
  ///A `Set` rather than a list because the native type is an `NSSet`: order carries no meaning and
  ///duplicates are not representable.
  Set<String>? primaryRecipientIdentifiers;

  ConversationEntry_({
    this.text,
    this.senderIdentifier,
    this.sentDate,
    this.entryIdentifier,
    this.replyThreadIdentifier,
    this.primaryRecipientIdentifiers,
  });
}
