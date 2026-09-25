import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
// `init` lives on the internal extension, and the event callback can only be
// supplied through creation params, so the test drives the controller exactly
// the way `InAppWebViewController` does at runtime.
import 'package:flutter_inappwebview_android/src/find_interaction/find_interaction_controller.dart';
import 'package:flutter_inappwebview_android/src/pigeons/find_interaction.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runtime coverage for the **only** channel migrated to Pigeon so far (§14,
/// `find_interaction`), which P0a item 4 blocks the rest of the migration on.
///
/// WHY THIS EXISTS. A Pigeon migration fails as a runtime type/serialization
/// mismatch, and no static gate in this repo can see one: not kotlinc, not
/// `flutter analyze`, not the widget tests. P0a offered two ways to get some
/// coverage — a device run, or unit tests over the migrated boundary. This is
/// the second.
///
/// WHAT IT ACTUALLY COVERS, AND WHAT IT CANNOT.
/// Every message here goes through the **real generated codec**
/// (`FindInteractionHostApi.pigeonChannelCodec`) on the real generated channel
/// names, in both directions. So it covers the Dart half of the wire plus the
/// hand-written conversion at the boundary — which the schema's own header
/// calls "the standing cost of adopting Pigeon here", and which is the part a
/// human wrote and can get wrong.
///
/// It does **not** prove the Kotlin half agrees, because both halves cannot run
/// in one process. That is a weaker gap than it sounds: both are generated from
/// one schema and ship inside `flutter_inappwebview_android`, so they are
/// always in lockstep and cannot be version-skewed the way a federated package
/// pair could. A byte-level golden was considered and rejected for that reason
/// — it would pin the codec's private format without testing anything that can
/// realistically drift.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const suffix = 'boundary-test';
  const codec = FindInteractionHostApi.pigeonChannelCodec;

  String hostChannel(String method) =>
      'dev.flutter.pigeon.flutter_inappwebview_android.FindInteractionHostApi'
      '.$method.$suffix';

  String flutterChannel(String method) =>
      'dev.flutter.pigeon.flutter_inappwebview_android.FindInteractionFlutterApi'
      '.$method.$suffix';

  late AndroidFindInteractionController controller;
  final sent = <String, Object?>{};

  /// Captured from the FlutterApi event. The callback is constructor-injected
  /// via creation params, so it has to be wired before `init`.
  final received = <String, Object?>{};

  /// Answers one HostApi method with [result], recording what Dart sent.
  /// Pigeon's success envelope is a one-element list.
  void stubHost(String method, Object? result) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(hostChannel(method), (message) async {
          sent[method] = codec.decodeMessage(message);
          return codec.encodeMessage(<Object?>[result]);
        });
  }

  setUp(() {
    sent.clear();
    received.clear();
    controller = AndroidFindInteractionController(
      AndroidFindInteractionControllerCreationParams(
        onFindResultReceived:
            (c, activeMatchOrdinal, numberOfMatches, isDoneCounting) {
              received['controller'] = c;
              received['activeMatchOrdinal'] = activeMatchOrdinal;
              received['numberOfMatches'] = numberOfMatches;
              received['isDoneCounting'] = isDoneCounting;
            },
      ),
    );
    controller.init(suffix);
  });

  tearDown(() {
    for (final m in [
      'findAll',
      'findNext',
      'clearMatches',
      'setSearchText',
      'getSearchText',
      'getActiveFindSession',
    ]) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(hostChannel(m), null);
    }
  });

  group('Dart -> Kotlin (HostApi)', () {
    test('findAll puts the search string on the wire', () async {
      stubHost('findAll', null);
      await controller.findAll(find: 'needle');
      expect(sent['findAll'], <Object?>['needle']);
    });

    test('findNext carries the direction, including false', () async {
      stubHost('findNext', null);
      await controller.findNext(forward: false);
      expect(sent['findNext'], <Object?>[false]);
    });

    test('setSearchText can send an explicit null', () async {
      // The schema types this `String?` deliberately; null is a real value
      // here (it clears the text), not an absent argument.
      stubHost('setSearchText', null);
      await controller.setSearchText(null);
      expect(sent['setSearchText'], <Object?>[null]);
    });
  });

  group('Kotlin -> Dart (replies, and the hand-written conversion)', () {
    test('getActiveFindSession maps every field', () async {
      // Exactly what the Kotlin side builds: resultCount and
      // highlightedResultIndex as Long, and searchResultDisplayStyle = 2,
      // which is `FindSession.searchResultDisplayStyle` default on Android.
      stubHost(
        'getActiveFindSession',
        FindSessionData(
          resultCount: 7,
          highlightedResultIndex: 3,
          searchResultDisplayStyle: 2,
        ),
      );

      final session = await controller.getActiveFindSession();

      expect(session, isNotNull);
      expect(session!.resultCount, 7);
      expect(session.highlightedResultIndex, 3);
      expect(session.searchResultDisplayStyle, SearchResultDisplayStyle.NONE);
    });

    test(
      'a null session stays null rather than becoming an empty one',
      () async {
        stubHost('getActiveFindSession', null);
        expect(await controller.getActiveFindSession(), isNull);
      },
    );

    test('an unrecognised display style falls back to NONE', () async {
      // Pins the `?? SearchResultDisplayStyle.NONE` branch. It is unreachable
      // from today's Kotlin, which always sends 2 — so without this the
      // fallback has no coverage in either direction.
      stubHost(
        'getActiveFindSession',
        FindSessionData(
          resultCount: 1,
          highlightedResultIndex: 0,
          searchResultDisplayStyle: 9999,
        ),
      );
      final session = await controller.getActiveFindSession();
      expect(session!.searchResultDisplayStyle, SearchResultDisplayStyle.NONE);
    });

    test('getSearchText round-trips a string', () async {
      stubHost('getSearchText', 'needle');
      expect(await controller.getSearchText(), 'needle');
    });

    test('getSearchText returns null, never the old `false`', () async {
      // The hand-written channel this replaced answered `false` when the
      // controller had gone away, giving Dart a value it could not type. The
      // schema makes that unrepresentable; this pins it.
      stubHost('getSearchText', null);
      expect(await controller.getSearchText(), isNull);
    });
  });

  group('Kotlin -> Dart (FlutterApi event)', () {
    test('onFindResultReceived reaches the controller callback', () async {
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            flutterChannel('onFindResultReceived'),
            codec.encodeMessage(<Object?>[2, 5, true]),
            (_) {},
          );

      expect(received['activeMatchOrdinal'], 2);
      expect(received['numberOfMatches'], 5);
      expect(received['isDoneCounting'], isTrue);
      // The controller hands itself to the callback; a different object here
      // would mean the FlutterApi impl captured the wrong instance.
      expect(identical(received['controller'], controller), isTrue);
    });
  });

  group('dispose and the event handler', () {
    /// Delivers `onFindResultReceived` and returns the raw platform reply. A
    /// registered Pigeon handler always answers with an encoded envelope; a
    /// channel with no handler answers null. That observes registration
    /// itself, independent of anything the handler does — the technique §183
    /// established after two other assertions (an outbound-mock check, and
    /// "the callback stayed silent") were both measured blind.
    Future<ByteData?> deliverEvent() {
      final reply = Completer<ByteData?>();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            flutterChannel('onFindResultReceived'),
            codec.encodeMessage(<Object?>[0, 0, false]),
            reply.complete,
          );
      return reply.future;
    }

    test('dispose unregisters the event handler for this suffix', () async {
      // Positive control: without it a null below could mean a misspelt
      // channel rather than an unregistered one.
      expect(await deliverEvent(), isNotNull);
      controller.dispose();
      expect(await deliverEvent(), isNull);
    });

    test('a keep-alive dispose leaves the event handler registered', () async {
      // Mirrors the hand-written `disposeChannel(removeMethodCallHandler:
      // !isKeepAlive)`: a keep-alive webview re-attaches and still needs it.
      controller.dispose(isKeepAlive: true);
      expect(await deliverEvent(), isNotNull);
    });
  });

  group('an uninitialised controller', () {
    test('tolerates calls instead of throwing on a null host API', () async {
      // `AndroidFindInteractionController.static()` never calls init(), so
      // every method has to survive a null _hostApi — the previous
      // hand-written channel was null and `channel?.invokeMethod` no-opped.
      final uninitialised = AndroidFindInteractionController(
        AndroidFindInteractionControllerCreationParams(),
      );
      await uninitialised.findAll(find: 'x');
      await uninitialised.findNext();
      await uninitialised.clearMatches();
      await uninitialised.setSearchText('x');
      expect(await uninitialised.getSearchText(), isNull);
      expect(await uninitialised.getActiveFindSession(), isNull);
    });
  });
}
