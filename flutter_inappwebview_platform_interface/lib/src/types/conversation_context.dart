import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'conversation_entry.dart';
import 'enum_method.dart';
import 'person_name_components.dart';

part 'conversation_context.g.dart';

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
@ExchangeableObject()
class ConversationContext_ {
  ///Uniquely identifies this conversation, and stays the same for its whole life.
  ///
  ///The keyboard uses it to tell one thread from another; reusing an identifier across unrelated
  ///conversations mixes their context.
  String? threadIdentifier;

  ///The messages in the conversation, oldest first.
  ///
  ///An entry missing any of its four required fields is dropped natively — see [ConversationEntry].
  List<ConversationEntry_>? entries;

  ///Identifies the person using this device, so the keyboard knows which messages are "mine" and
  ///which it should be drafting a reply to.
  ///
  ///A `Set` because the same person may appear under more than one identifier (an email address and
  ///a phone number, say) and order carries no meaning.
  Set<String>? selfIdentifiers;

  ///Identifies the people a reply would primarily go to.
  Set<String>? responsePrimaryRecipientIdentifiers;

  ///Maps a participant identifier — the same values used in [ConversationEntry.senderIdentifier]
  ///and [selfIdentifiers] — to that person's name.
  ///
  ///Names are [PersonNameComponents] rather than plain strings so the platform can abbreviate them
  ///per locale instead of the app guessing at word order.
  Map<String, PersonNameComponents_>? participantNameByIdentifier;

  ConversationContext_({
    this.threadIdentifier,
    this.entries,
    this.selfIdentifiers,
    this.responsePrimaryRecipientIdentifiers,
    this.participantNameByIdentifier,
  });
}
