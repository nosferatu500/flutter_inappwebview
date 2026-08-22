import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the `profileName` argument key on the cookie-manager channel.
///
/// `MyCookieManager` reads it with `call.argument<String>("profileName")` and treats null as
/// "the default cookie store". So a renamed or dropped key does not fail — every call silently
/// lands on the **default** profile, which for a WebView running on another profile means cookies
/// written nowhere useful and cookies read that do not exist. Nothing in the compiler, the
/// analyzer or the widget tests can see that.
///
/// These tests capture the argument map the Android implementation actually sends.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(
    'dev.nosferatu500.inappwebview/inappwebview_cookiemanager',
  );

  late AndroidCookieManager cookieManager;
  final List<MethodCall> calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    cookieManager = AndroidCookieManager(
      const PlatformCookieManagerCreationParams(),
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          calls.add(call);
          // Shapes each caller accepts: a bool for the mutating calls, a list for getCookies.
          if (call.method == 'getCookies') return <dynamic>[];
          return true;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Map<Object?, Object?> argsOf(MethodCall call) =>
      call.arguments as Map<Object?, Object?>;

  group('AndroidCookieManager profileName', () {
    test('is sent under the key the Android side reads', () async {
      await cookieManager.setCookie(
        url: WebUri('https://example.com'),
        name: 'session',
        value: 'abc',
        profileName: 'signed_in',
      );

      expect(calls.single.method, 'setCookie');
      expect(argsOf(calls.single)['profileName'], 'signed_in');
    });

    test('is null when not given, which means the default store', () async {
      await cookieManager.setCookie(
        url: WebUri('https://example.com'),
        name: 'session',
        value: 'abc',
      );

      // Present-but-null rather than absent is what the Kotlin reader expects; either would work
      // there, but asserting it pins the shape the reader was written against.
      expect(argsOf(calls.single).containsKey('profileName'), isTrue);
      expect(argsOf(calls.single)['profileName'], isNull);
    });

    test('reaches every method that accepts it', () async {
      final url = WebUri('https://example.com');
      await cookieManager.getCookies(url: url, profileName: 'p');
      await cookieManager.getCookie(url: url, name: 'n', profileName: 'p');
      await cookieManager.deleteCookie(url: url, name: 'n', profileName: 'p');
      await cookieManager.deleteCookies(url: url, profileName: 'p');
      await cookieManager.deleteAllCookies(profileName: 'p');
      await cookieManager.removeSessionCookies(profileName: 'p');
      await cookieManager.flush(profileName: 'p');

      // getCookie is implemented on top of the getCookies channel method, so 7 calls arrive as
      // 7 invocations but only 6 distinct method names.
      expect(calls.length, 7);
      for (final call in calls) {
        expect(
          argsOf(call)['profileName'],
          'p',
          reason: '${call.method} dropped profileName',
        );
      }
    });
  });
}
