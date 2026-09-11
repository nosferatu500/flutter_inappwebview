import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/credential_database.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Boundary coverage for the sixth channel migrated to Pigeon (§163, `credential_database`), in the
/// shape §156 established and §157/§160/§161/§162 reused.
///
/// This is the first migrated channel with **structured return values**, so it is also the first
/// where the reply direction needs pinning: `getAllAuthCredentials` returns a list of nested
/// objects that the Dart side rebuilds into public `URLProtectionSpaceHttpAuthCredentials`
/// instances. A reconstruction that drops or transposes a field is invisible to the type system —
/// `host`, `protocol` and `realm` are all `String?` on the public type.
///
/// Six methods on six generated channels whose names differ only in the method segment, which is
/// the other failure this file exists for.
///
/// As in §156 this cannot prove the Kotlin half agrees — both halves cannot run in one process —
/// but they are generated from one schema and ship in the same package, so they cannot be
/// version-skewed.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = CredentialDatabaseHostApi.pigeonChannelCodec;
  const base =
      'dev.flutter.pigeon.flutter_inappwebview_android.CredentialDatabaseHostApi';
  const getAllChannel = '$base.getAllAuthCredentials';
  const getChannel = '$base.getHttpAuthCredentials';
  const setChannel = '$base.setHttpAuthCredential';
  const removeOneChannel = '$base.removeHttpAuthCredential';
  const removeAllForSpaceChannel = '$base.removeHttpAuthCredentials';
  const clearChannel = '$base.clearAllAuthCredentials';

  const allChannels = [
    getAllChannel,
    getChannel,
    setChannel,
    removeOneChannel,
    removeAllForSpaceChannel,
    clearChannel,
  ];

  late AndroidHttpAuthCredentialDatabase db;
  final Map<String, List<Object?>?> received = {};
  final Map<String, Object?> replies = {};
  List<Object?>? errorReply;

  /// The default reply has to match the method's declared return type: the two `get*` methods
  /// return lists and the other four return a bool. Replying `true` to a list-returning method
  /// fails inside the generated code with "type 'bool' is not a subtype of type 'List<Object?>'",
  /// which is the codec doing its job.
  Object? defaultReplyFor(String channel) =>
      channel == getAllChannel || channel == getChannel
      ? const <Object?>[]
      : true;

  void install(String channel) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(channel, (message) async {
          received[channel] = message == null
              ? null
              : codec.decodeMessage(message) as List<Object?>;
          if (errorReply != null) return codec.encodeMessage(errorReply);
          return codec.encodeMessage(<Object?>[
            replies[channel] ?? defaultReplyFor(channel),
          ]);
        });
  }

  setUp(() {
    received.clear();
    replies.clear();
    errorReply = null;
    db = AndroidInAppWebViewPlatform().createPlatformHttpAuthCredentialDatabase(
      const PlatformHttpAuthCredentialDatabaseCreationParams(),
    );
    for (final c in allChannels) {
      install(c);
    }
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final c in allChannels) {
      messenger.setMockMessageHandler(c, null);
    }
  });

  URLProtectionSpaceData sentSpace(String channel) =>
      (received[channel] as List<Object?>).first as URLProtectionSpaceData;

  group('outbound: the protection space Dart puts on the wire', () {
    test('every field crosses into its own slot', () async {
      await db.getHttpAuthCredentials(
        protectionSpace: URLProtectionSpace(
          host: 'host.example.com',
          protocol: 'https',
          realm: 'realm-value',
          port: 8443,
        ),
      );

      final space = sentSpace(getChannel);
      // Asserted separately with distinct values: host, protocol and realm are all strings, so a
      // transposition is invisible to anything comparing them as a group.
      expect(space.host, 'host.example.com');
      expect(space.protocol, 'https');
      expect(space.realm, 'realm-value');
      expect(space.port, 8443);
    });

    test('a host-only protection space sends null protocol and port', () async {
      // The public constructor requires only `host`, so this is a legal call -- and it is exactly
      // the shape that used to reach a Kotlin `!!` and come back as
      // PlatformException(error, null, null, NullPointerException).
      await db.getHttpAuthCredentials(
        protectionSpace: URLProtectionSpace(host: 'host.example.com'),
      );

      final space = sentSpace(getChannel);
      expect(space.host, 'host.example.com');
      expect(space.protocol, isNull);
      expect(space.port, isNull);
      expect(space.realm, isNull);
    });

    test('the credential fields are not transposed', () async {
      await db.setHttpAuthCredential(
        protectionSpace: URLProtectionSpace(
          host: 'host.example.com',
          protocol: 'https',
          port: 443,
        ),
        credential: URLCredential(username: 'the-user', password: 'the-pass'),
      );

      final args = received[setChannel] as List<Object?>;
      final credential = args[1] as URLCredentialData;
      // Both are nullable strings, so this is the same swap-invisibility problem.
      expect(credential.username, 'the-user');
      expect(credential.password, 'the-pass');
    });
  });

  group('inbound: replies rebuilt into the public types', () {
    test('getAllAuthCredentials rebuilds the nested structure', () async {
      replies[getAllChannel] = <URLProtectionSpaceHttpAuthCredentialsData>[
        URLProtectionSpaceHttpAuthCredentialsData(
          protectionSpace: URLProtectionSpaceData(
            host: 'a.example.com',
            protocol: 'https',
            realm: 'realm-a',
            port: 443,
          ),
          credentials: [
            URLCredentialData(username: 'user-a1', password: 'pass-a1'),
            URLCredentialData(username: 'user-a2', password: 'pass-a2'),
          ],
        ),
        URLProtectionSpaceHttpAuthCredentialsData(
          protectionSpace: URLProtectionSpaceData(
            host: 'b.example.com',
            protocol: 'http',
            port: 80,
          ),
          credentials: [
            URLCredentialData(username: 'user-b1', password: 'pass-b1'),
          ],
        ),
      ];

      final all = await db.getAllAuthCredentials();

      expect(all.length, 2);
      final first = all.first;
      expect(first.protectionSpace?.host, 'a.example.com');
      expect(first.protectionSpace?.protocol, 'https');
      expect(first.protectionSpace?.realm, 'realm-a');
      expect(first.protectionSpace?.port, 443);
      expect(first.credentials?.length, 2);
      expect(first.credentials?[0].username, 'user-a1');
      expect(first.credentials?[0].password, 'pass-a1');
      // The second entry's credentials must not leak into the first: the two lists are rebuilt in
      // one pass and a misplaced accumulator would merge them.
      expect(first.credentials?[1].username, 'user-a2');
      expect(all[1].credentials?.length, 1);
      expect(all[1].credentials?[0].username, 'user-b1');
      expect(all[1].protectionSpace?.host, 'b.example.com');
    });

    test('the rebuilt protection space leaves iOS-only fields null', () async {
      replies[getAllChannel] = <URLProtectionSpaceHttpAuthCredentialsData>[
        URLProtectionSpaceHttpAuthCredentialsData(
          protectionSpace: URLProtectionSpaceData(
            host: 'a.example.com',
            protocol: 'https',
            port: 443,
          ),
          credentials: [],
        ),
      ];

      final space = (await db.getAllAuthCredentials()).single.protectionSpace!;
      // These five used to arrive as literal nulls in the reply map; they are now simply absent
      // from the wire, and the rebuilt object must still present them as null rather than as
      // anything invented.
      expect(space.authenticationMethod, isNull);
      expect(space.distinguishedNames, isNull);
      expect(space.receivesCredentialSecurely, isNull);
      expect(space.proxyType, isNull);
      // Real on Android, but never populated by this channel -- the DAO nulls both.
      expect(space.sslCertificate, isNull);
      expect(space.sslError, isNull);
    });

    test('an empty reply is an empty list, not an error', () async {
      replies[getAllChannel] = <URLProtectionSpaceHttpAuthCredentialsData>[];
      expect(await db.getAllAuthCredentials(), isEmpty);

      replies[getChannel] = <URLCredentialData>[];
      expect(
        await db.getHttpAuthCredentials(
          protectionSpace: URLProtectionSpace(host: 'h'),
        ),
        isEmpty,
      );
    });

    test('getHttpAuthCredentials maps every credential', () async {
      replies[getChannel] = <URLCredentialData>[
        URLCredentialData(username: 'u1', password: 'p1'),
        URLCredentialData(username: 'u2', password: 'p2'),
      ];

      final credentials = await db.getHttpAuthCredentials(
        protectionSpace: URLProtectionSpace(host: 'h', protocol: 'https'),
      );

      expect(credentials.map((c) => c.username), ['u1', 'u2']);
      expect(credentials.map((c) => c.password), ['p1', 'p2']);
    });
  });

  group('channel routing', () {
    test('each method uses only its own channel', () async {
      final space = URLProtectionSpace(host: 'h', protocol: 'https', port: 443);
      final credential = URLCredential(username: 'u', password: 'p');

      // Six names differing only in the method segment; one call each, then assert exactly which
      // channels were touched. A copy-paste that points two Dart methods at one host method
      // compiles and returns plausible answers.
      replies[getAllChannel] = <URLProtectionSpaceHttpAuthCredentialsData>[];
      replies[getChannel] = <URLCredentialData>[];

      await db.getAllAuthCredentials();
      expect(received.keys, [getAllChannel]);

      received.clear();
      await db.getHttpAuthCredentials(protectionSpace: space);
      expect(received.keys, [getChannel]);

      received.clear();
      await db.setHttpAuthCredential(
        protectionSpace: space,
        credential: credential,
      );
      expect(received.keys, [setChannel]);

      received.clear();
      await db.removeHttpAuthCredential(
        protectionSpace: space,
        credential: credential,
      );
      expect(received.keys, [removeOneChannel]);

      received.clear();
      await db.removeHttpAuthCredentials(protectionSpace: space);
      expect(received.keys, [removeAllForSpaceChannel]);

      received.clear();
      await db.clearAllAuthCredentials();
      expect(received.keys, [clearChannel]);
      expect(received[clearChannel], isNull);
    });
  });

  test('a host error surfaces with its code and message', () async {
    // The replacement for the old bare NullPointerException: setHttpAuthCredential now rejects a
    // null protocol/port with a message that names them. Asserted on code and message, not just
    // isA<PlatformException>() -- with no handler at all Pigeon also throws a PlatformException
    // (code 'channel-error'), so the loose form proves nothing (§157's mutant B).
    errorReply = <Object?>[
      'java.lang.IllegalArgumentException',
      'setHttpAuthCredential requires protectionSpace.protocol and protectionSpace.port to be '
          'non-null, because the credential database keys rows on both.',
      null,
    ];

    await expectLater(
      db.setHttpAuthCredential(
        protectionSpace: URLProtectionSpace(host: 'h'),
        credential: URLCredential(username: 'u', password: 'p'),
      ),
      throwsA(
        isA<PlatformException>()
            .having((e) => e.code, 'code', 'java.lang.IllegalArgumentException')
            .having(
              (e) => e.message,
              'message',
              contains('protectionSpace.protocol'),
            ),
      ),
    );
  });
}
