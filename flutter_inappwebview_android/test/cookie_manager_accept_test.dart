import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the wire shape of the cookie master switch — `CookieManager.setAcceptCookie` /
/// `acceptCookie`.
///
/// Two things here can only fail at runtime, so both are pinned:
///
///  * the **argument keys**. `MyCookieManager` reads `call.argument("accept")` and
///    `call.argument<String>("profileName")`; a renamed key arrives as null, and the Kotlin side
///    then reports failure rather than crashing — a silently dead switch.
///  * the **null return**. `isAcceptCookieEnabled` deliberately does *not* collapse null to false.
///    The platform default is `true`, so `null` (store unresolvable) and `false` (cookies actively
///    rejected) are opposite claims and must stay distinguishable.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(
    'dev.nosferatu500.inappwebview/inappwebview_cookiemanager',
  );

  late AndroidCookieManager cookieManager;
  final List<MethodCall> calls = <MethodCall>[];
  Object? reply;

  setUp(() {
    calls.clear();
    reply = true;
    cookieManager = AndroidCookieManager(
      const PlatformCookieManagerCreationParams(),
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          calls.add(call);
          return reply;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Map<Object?, Object?> argsOf(MethodCall call) =>
      call.arguments as Map<Object?, Object?>;

  group('AndroidCookieManager.setAcceptCookie', () {
    test('sends the accept flag under the key the Kotlin side reads', () async {
      await cookieManager.setAcceptCookie(false);

      expect(calls.single.method, 'setAcceptCookie');
      expect(argsOf(calls.single)['accept'], false);
    });

    test('carries profileName like every other method here', () async {
      await cookieManager.setAcceptCookie(true, profileName: 'signed_in');

      expect(argsOf(calls.single)['accept'], true);
      expect(argsOf(calls.single)['profileName'], 'signed_in');
    });

    test('reports false when the native side could not apply it', () async {
      // Kotlin sends false when the cookie store cannot be resolved -- no WebView provider, or a
      // profileName that does not exist.
      reply = false;
      expect(await cookieManager.setAcceptCookie(true), isFalse);
    });
  });

  group('AndroidCookieManager.isAcceptCookieEnabled', () {
    test('sends no arguments beyond profileName', () async {
      await cookieManager.isAcceptCookieEnabled();

      expect(calls.single.method, 'isAcceptCookieEnabled');
      expect(argsOf(calls.single).containsKey('profileName'), isTrue);
      expect(argsOf(calls.single)['profileName'], isNull);
      expect(argsOf(calls.single).containsKey('accept'), isFalse);
    });

    test('returns what the native side read', () async {
      reply = false;
      expect(await cookieManager.isAcceptCookieEnabled(), isFalse);

      reply = true;
      expect(await cookieManager.isAcceptCookieEnabled(), isTrue);
    });

    test('null survives instead of becoming false', () async {
      // This is the whole point of the bool? return type. Kotlin sends null when it could not
      // resolve the store; the platform default is true, so a `?? false` here would report
      // "cookies are rejected" for a state that was never measured.
      reply = null;
      expect(await cookieManager.isAcceptCookieEnabled(), isNull);
    });
  });

  group('PlatformCookieManagerMethod', () {
    test('reports both methods as Android-only', () {
      expect(
        cookieManager.isMethodSupported(
          PlatformCookieManagerMethod.setAcceptCookie,
          platform: TargetPlatform.android,
        ),
        isTrue,
      );
      expect(
        cookieManager.isMethodSupported(
          PlatformCookieManagerMethod.isAcceptCookieEnabled,
          platform: TargetPlatform.android,
        ),
        isTrue,
      );
      expect(
        cookieManager.isMethodSupported(
          PlatformCookieManagerMethod.setAcceptCookie,
          platform: TargetPlatform.iOS,
        ),
        isFalse,
      );
    });
  });
}
