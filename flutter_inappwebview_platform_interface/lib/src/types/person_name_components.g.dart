// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person_name_components.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

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
class PersonNameComponents {
  ///The person's family (last) name, e.g. `Appleseed`.
  String? familyName;

  ///The person's given (first) name, e.g. `Johnathan`.
  String? givenName;

  ///The person's middle name, e.g. `Maple`.
  String? middleName;

  ///Pre-nominal letters, e.g. `Dr.` or `Mr.`.
  String? namePrefix;

  ///Post-nominal letters, e.g. `Esq.` or `Jr.`.
  String? nameSuffix;

  ///The name the person prefers to be called, e.g. `Johnny`.
  String? nickname;
  PersonNameComponents({
    this.familyName,
    this.givenName,
    this.middleName,
    this.namePrefix,
    this.nameSuffix,
    this.nickname,
  });

  ///Gets a possible [PersonNameComponents] instance from a [Map] value.
  static PersonNameComponents? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = PersonNameComponents(
      familyName: map['familyName'],
      givenName: map['givenName'],
      middleName: map['middleName'],
      namePrefix: map['namePrefix'],
      nameSuffix: map['nameSuffix'],
      nickname: map['nickname'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "familyName": familyName,
      "givenName": givenName,
      "middleName": middleName,
      "namePrefix": namePrefix,
      "nameSuffix": nameSuffix,
      "nickname": nickname,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'PersonNameComponents{familyName: $familyName, givenName: $givenName, middleName: $middleName, namePrefix: $namePrefix, nameSuffix: $nameSuffix, nickname: $nickname}';
  }
}
