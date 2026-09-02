import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'enum_method.dart';

part 'person_name_components.g.dart';

///The parts of a person's name, kept separate so the platform can compose or abbreviate them
///according to the user's locale rather than the app guessing at word order.
///
///Every field is optional. Supply only the parts you have — a conversation that knows nothing but a
///first name is a perfectly valid [PersonNameComponents] with only [givenName] set.
///
///Used by [ConversationContext.participantNameByIdentifier].
///
///**NOTE for iOS**: this maps to `NSPersonNameComponents`. Its `phoneticRepresentation` property —
///which is itself another `NSPersonNameComponents` — is **not** modelled here: it is recursive, it
///is only meaningful for languages where pronunciation cannot be derived from the written form, and
///nothing in the Smart Reply path reads it.
@ExchangeableObject()
class PersonNameComponents_ {
  ///Pre-nominal letters, e.g. `Dr.` or `Mr.`.
  String? namePrefix;

  ///The person's given (first) name, e.g. `Johnathan`.
  String? givenName;

  ///The person's middle name, e.g. `Maple`.
  String? middleName;

  ///The person's family (last) name, e.g. `Appleseed`.
  String? familyName;

  ///Post-nominal letters, e.g. `Esq.` or `Jr.`.
  String? nameSuffix;

  ///The name the person prefers to be called, e.g. `Johnny`.
  String? nickname;

  PersonNameComponents_({
    this.namePrefix,
    this.givenName,
    this.middleName,
    this.familyName,
    this.nameSuffix,
    this.nickname,
  });
}
