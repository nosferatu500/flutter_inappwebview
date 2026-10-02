import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// [DefaultInAppLocalhostServer] serves app assets and, in debug builds only, prints each served
/// response's headers.
///
/// The print used to run in release builds too: measured in a profile build on API 37, five header
/// lines reached logcat per file served. It's now behind `kDebugMode`, like the file's other prints.
/// A host test always runs in debug, so it can't see the release half. What it pins is the debug
/// half, and that what's printed is the *response*'s headers, never the request's.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const port = 18089;

  setUp(() {
    // The test binding answers every `HttpClient` request with a 400 of its own; the server is real
    // here, so the client must be too.
    HttpOverrides.global = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
          final key = utf8.decode(message!.buffer.asUint8List());
          return key == 'www/page.html'
              ? ByteData.sublistView(utf8.encode('<p>hi</p>'))
              : null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  /// Starts a server, sends one GET for [path] with a cookie and a bearer token, and returns the
  /// response and everything printed meanwhile.
  Future<(int, String, String?, List<String>)> fetch(
    String path, {
    Future<bool> Function(HttpRequest)? onData,
  }) async {
    final printed = <String>[];
    late (int, String, String?) result;
    await runZoned(
      () async {
        final server = DefaultInAppLocalhostServer(
          PlatformInAppLocalhostServerCreationParams(
            port: port,
            documentRoot: 'www',
            onData: onData,
          ),
        );
        await server.start();
        final client = HttpClient();
        try {
          final request = await client.getUrl(
            Uri.parse('http://127.0.0.1:$port/$path'),
          );
          request.headers.set('Cookie', 'session=request-secret');
          request.headers.set('Authorization', 'Bearer request-token');
          final response = await request.close();
          result = (
            response.statusCode,
            await utf8.decodeStream(response),
            response.headers.value('content-type'),
          );
        } finally {
          client.close();
          await server.close();
        }
      },
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) => printed.add(line),
      ),
    );
    return (result.$1, result.$2, result.$3, printed);
  }

  test(
    'serves an asset with its content type, and never prints the request\'s headers',
    () async {
      final (status, body, contentType, printed) = await fetch('page.html');
      expect(status, 200);
      expect(body, '<p>hi</p>');
      expect(contentType, 'text/html; charset=utf-8');
      final all = printed.join('\n');
      expect(all, isNot(contains('request-secret')));
      expect(all, isNot(contains('request-token')));
    },
  );

  test('in debug, prints each served response\'s headers once', () async {
    final (_, _, _, printed) = await fetch('page.html');
    final headerDumps = printed
        .where((l) => l.contains('content-type: text/html; charset=utf-8'))
        .toList();
    expect(headerDumps, hasLength(1));
    expect(headerDumps.single, contains('x-content-type-options: nosniff'));
  });

  test('a request onData handles prints no headers', () async {
    final (status, body, _, printed) = await fetch(
      'anything',
      onData: (request) async {
        request.response.write('custom');
        await request.response.close();
        return true;
      },
    );
    expect(status, 200);
    expect(body, 'custom');
    expect(printed.where((l) => l.contains('content-type')), isEmpty);
  });
}
