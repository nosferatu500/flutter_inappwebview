import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/in_app_webview_manager.g.dart';
import 'package:flutter_test/flutter_test.dart';

/// Boundary coverage for the in-app-webview manager API (§188): the hand-written conversions at the
/// Dart end of the wire, through the real generated codec on the real channel names.
///
/// The device groups (§187) cover every method end to end, but a device cannot reach the two
/// fallbacks here: the platform answering null for the user agent (only when the plugin has gone
/// away) and for the policy URL (only where the feature is missing). Those, and the package mapping
/// with distinct values in both fields, are what this pins.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const base =
      'dev.flutter.pigeon.flutter_inappwebview_android.InAppWebViewManagerHostApi';
  const codec = InAppWebViewManagerHostApi.pigeonChannelCodec;
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final installed = <String>[];

  void answer(String method, Object? value) {
    installed.add('$base.$method');
    messenger.setMockMessageHandler(
      '$base.$method',
      (_) async => codec.encodeMessage(<Object?>[value]),
    );
  }

  tearDown(() {
    for (final c in installed) {
      messenger.setMockMessageHandler(c, null);
    }
    installed.clear();
  });

  final controller = AndroidInAppWebViewController.static();

  test('a null user agent reads as the empty string, as before', () async {
    answer('getDefaultUserAgent', null);
    expect(await controller.getDefaultUserAgent(), '');
  });

  test('the package crosses with each field in its own slot', () async {
    // Distinct values, so a transposed pair cannot pass.
    answer(
      'getCurrentWebViewPackage',
      WebViewPackageInfoData(
        versionName: '151.0.1',
        packageName: 'com.google.android.webview',
      ),
    );
    final info = await controller.getCurrentWebViewPackage();
    expect(info?.versionName, '151.0.1');
    expect(info?.packageName, 'com.google.android.webview');
  });

  test('no package stays null rather than becoming an empty one', () async {
    answer('getCurrentWebViewPackage', null);
    expect(await controller.getCurrentWebViewPackage(), isNull);
  });

  test('the policy URL is a WebUri, and a missing one stays null', () async {
    answer('getSafeBrowsingPrivacyPolicyUrl', 'https://example.com/policy');
    expect(
      (await controller.getSafeBrowsingPrivacyPolicyUrl()).toString(),
      'https://example.com/policy',
    );

    answer('getSafeBrowsingPrivacyPolicyUrl', null);
    expect(await controller.getSafeBrowsingPrivacyPolicyUrl(), isNull);
  });
}
