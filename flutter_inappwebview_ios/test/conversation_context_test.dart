import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the wire contract for `ConversationContext` (iOS 26.0+, `WKWebView.conversationContext`).
///
/// `Types/UIConversationContext.swift` is hand-written on the native side and reads every key by
/// literal string, so — as in §24/§36 — nothing but a test holds the two languages in agreement.
/// Three things here are easy to get wrong and silent when wrong:
///
///  * **`sentDate` crosses as milliseconds**, because that is what the generator emits for a
///    `DateTime`, while `Date(timeIntervalSince1970:)` takes *seconds*. The Swift divides by 1000.
///    A missed conversion puts the message ~55,000 years in the future and nothing errors.
///  * **Sets cross as arrays.** `NSSet` has no wire form, so `Set<String>` is serialised as a list
///    and rebuilt on both sides.
///  * **An entry missing one of the four required fields is dropped natively.** Dart cannot see that
///    happen, so the test pins the *shape* the Swift guard reads.
void main() {
  final entry = ConversationEntry(
    text: 'Are we still on for lunch?',
    senderIdentifier: 'them',
    sentDate: DateTime.fromMillisecondsSinceEpoch(1735689600000),
    entryIdentifier: 'e1',
    primaryRecipientIdentifiers: {'me'},
  );

  group('ConversationEntry', () {
    test('serialises under the keys the Swift guard reads', () {
      // Swift: `guard let text = map["text"] as? String, ... let sentDate = map["sentDate"] as? Int64`
      final map = entry.toMap();
      expect(map['text'], 'Are we still on for lunch?');
      expect(map['senderIdentifier'], 'them');
      expect(map['entryIdentifier'], 'e1');
      expect(map['replyThreadIdentifier'], isNull);
    });

    test('sentDate crosses as epoch MILLISECONDS, not seconds', () {
      // The Swift divides by 1000 before `Date(timeIntervalSince1970:)`. If this ever becomes
      // seconds, that division silently moves every message to 1970.
      expect(entry.toMap()['sentDate'], 1735689600000);
    });

    test('a Set crosses as a list, because NSSet has no wire form', () {
      expect(entry.toMap()['primaryRecipientIdentifiers'], isA<List>());
      expect(entry.toMap()['primaryRecipientIdentifiers'], contains('me'));
    });

    test('round-trips through fromMap, dates included', () {
      final back = ConversationEntry.fromMap(entry.toMap())!;
      expect(back.text, entry.text);
      expect(back.senderIdentifier, entry.senderIdentifier);
      expect(back.sentDate, entry.sentDate);
      expect(back.entryIdentifier, entry.entryIdentifier);
      expect(back.primaryRecipientIdentifiers, {'me'});
    });

    test('an incomplete entry still serialises — the drop happens natively', () {
      // Dart deliberately does not enforce the four required fields: the map is well-formed with
      // nulls in it, and `UIConversationContext.Entry.fromMap` is what refuses it. This pins that
      // the nulls actually reach the wire, which is what the Swift guard tests against.
      final map = ConversationEntry(text: 'orphan').toMap();
      expect(map['text'], 'orphan');
      expect(map['senderIdentifier'], isNull);
      expect(map['sentDate'], isNull);
      expect(map['entryIdentifier'], isNull);
    });
  });

  group('ConversationContext', () {
    final context = ConversationContext(
      threadIdentifier: 't1',
      entries: [entry],
      selfIdentifiers: {'me'},
      responsePrimaryRecipientIdentifiers: {'them'},
      participantNameByIdentifier: {
        'them': PersonNameComponents(givenName: 'Alex', familyName: 'Kim'),
      },
    );

    test('serialises under the keys the Swift side reads', () {
      final map = context.toMap();
      expect(map['threadIdentifier'], 't1');
      expect(map['entries'], isA<List>());
      expect(map['selfIdentifiers'], isA<List>());
      expect(map['responsePrimaryRecipientIdentifiers'], isA<List>());
      expect(map['participantNameByIdentifier'], isA<Map>());
    });

    test('nests entries and names as maps, not as objects', () {
      // The channel codec carries no custom types, so both have to be plain maps by the time they
      // leave Dart — a nested object would arrive as null in Swift.
      final map = context.toMap();
      expect((map['entries'] as List).first, isA<Map>());
      expect(
        ((map['entries'] as List).first as Map)['senderIdentifier'],
        'them',
      );
      final names = map['participantNameByIdentifier'] as Map;
      expect(names['them'], isA<Map>());
      expect((names['them'] as Map)['givenName'], 'Alex');
      expect((names['them'] as Map)['familyName'], 'Kim');
    });

    test('round-trips whole through fromMap', () {
      final back = ConversationContext.fromMap(context.toMap())!;
      expect(back.threadIdentifier, 't1');
      expect(back.entries, hasLength(1));
      expect(back.entries!.first.sentDate, entry.sentDate);
      expect(back.selfIdentifiers, {'me'});
      expect(back.responsePrimaryRecipientIdentifiers, {'them'});
      expect(back.participantNameByIdentifier!['them']!.givenName, 'Alex');
    });

    test('an empty context is representable — that is how you clear it', () {
      // The native property is non-null, so "stop offering suggestions" is an empty context rather
      // than a nil one. This pins that an empty context survives the round trip as empty.
      final back = ConversationContext.fromMap(ConversationContext().toMap())!;
      expect(back.threadIdentifier, isNull);
      expect(back.entries, isNull);
    });
  });

  group('PersonNameComponents', () {
    test('carries the six flat fields and nothing recursive', () {
      // `NSPersonNameComponents.phoneticRepresentation` is deliberately not modelled: it is another
      // NSPersonNameComponents, and nothing in the Smart Reply path reads it.
      final map = PersonNameComponents(
        namePrefix: 'Dr.',
        givenName: 'Johnathan',
        middleName: 'Maple',
        familyName: 'Appleseed',
        nameSuffix: 'Jr.',
        nickname: 'Johnny',
      ).toMap();
      expect(map.keys.toSet(), <String>{
        'namePrefix',
        'givenName',
        'middleName',
        'familyName',
        'nameSuffix',
        'nickname',
      });
    });
  });
}
