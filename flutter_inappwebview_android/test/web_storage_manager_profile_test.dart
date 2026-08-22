import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the `profileName` argument key on the web-storage channel.
///
/// `MyWebStorage` reads it with `call.argument<String>("profileName")` and treats null as "the
/// default profile's storage". So a renamed or dropped key does not fail — the call silently acts
/// on the **default** profile, which for a WebView running on another profile means reading quotas
/// that are not its own and, worse, reporting a successful delete after clearing somebody else's
/// storage. Nothing in the compiler, the analyzer or the widget tests can see that.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(
    'dev.nosferatu500.inappwebview/inappwebview_webstoragemanager',
  );

  late AndroidWebStorageManager webStorageManager;
  final List<MethodCall> calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    webStorageManager = AndroidWebStorageManager(
      const PlatformWebStorageManagerCreationParams(),
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          calls.add(call);
          // The reply shape each caller accepts.
          switch (call.method) {
            case 'getOrigins':
              return <dynamic>[];
            case 'getQuotaForOrigin':
            case 'getUsageForOrigin':
              return 0;
            case 'deleteBrowsingDataForSite':
              return 'example.com';
            default:
              return true;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Map<Object?, Object?> argsOf(MethodCall call) =>
      call.arguments as Map<Object?, Object?>;

  group('AndroidWebStorageManager profileName', () {
    test('is sent under the key the Android side reads', () async {
      await webStorageManager.deleteAllData(profileName: 'signed_in');

      expect(calls.single.method, 'deleteAllData');
      expect(argsOf(calls.single)['profileName'], 'signed_in');
    });

    test('is null when not given, which means the default profile', () async {
      await webStorageManager.deleteAllData();

      expect(argsOf(calls.single).containsKey('profileName'), isTrue);
      expect(argsOf(calls.single)['profileName'], isNull);
    });

    test('reaches every method that accepts it', () async {
      await webStorageManager.getOrigins(profileName: 'p');
      await webStorageManager.deleteAllData(profileName: 'p');
      await webStorageManager.deleteOrigin(
        origin: 'https://example.com',
        profileName: 'p',
      );
      await webStorageManager.deleteBrowsingData(profileName: 'p');
      await webStorageManager.deleteBrowsingDataForSite(
        site: 'https://example.com',
        profileName: 'p',
      );
      await webStorageManager.getQuotaForOrigin(
        origin: 'https://example.com',
        profileName: 'p',
      );
      await webStorageManager.getUsageForOrigin(
        origin: 'https://example.com',
        profileName: 'p',
      );

      expect(calls.length, 7);
      for (final call in calls) {
        expect(
          argsOf(call)['profileName'],
          'p',
          reason: '${call.method} dropped profileName',
        );
      }
    });

    test('does not disturb the other arguments', () async {
      await webStorageManager.deleteBrowsingDataForSite(
        site: 'https://www.example.com',
        profileName: 'p',
      );

      expect(argsOf(calls.single)['site'], 'https://www.example.com');
      expect(argsOf(calls.single)['profileName'], 'p');
    });
  });
}
