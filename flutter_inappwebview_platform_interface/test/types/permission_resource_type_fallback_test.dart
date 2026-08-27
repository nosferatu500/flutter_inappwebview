import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression guard for the force-unwrap in `PermissionRequest.fromMap` /
/// `PermissionResponse.fromMap` (§72, regressed by §73's sweep, restored in §78).
///
/// `resources` is a non-nullable `List<PermissionResourceType>`, so the generator used to emit
/// `PermissionResourceType.fromNativeValue(e)!`. One resource string this enum does not map —
/// a `PermissionRequest.RESOURCE_*` constant Android adds, or a new `WKMediaCaptureType` raw
/// value — made that `!` throw **inside the channel handler**, and `onPermissionRequest` then
/// never reached app code at all. The symptom is a permission prompt that silently never appears,
/// not an exception the app can see.
///
/// The generator degrades to an enum's catch-all constant where one exists, matched **by name**
/// (`_findCatchAllConstant`), which is why deleting `UNKNOWN` re-armed the bug with no gate
/// noticing. These tests fail if it is deleted again, and they fail on the `!`, not on the enum.
void main() {
  group('PermissionResourceType.UNKNOWN as the unmapped-value fallback', () {
    test('an unmapped Android resource string decodes instead of throwing', () {
      final request = PermissionRequest.fromMap({
        'origin': 'https://example.com',
        'resources': ['android.webkit.resource.SOMETHING_NEW'],
      });

      expect(request, isNotNull);
      expect(request!.resources, [PermissionResourceType.UNKNOWN]);
    });

    test('an unmapped iOS capture type decodes instead of throwing', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      // WKMediaCaptureType declares 0/1/2; 3 stands in for one Apple has not shipped yet.
      final request = PermissionRequest.fromMap({
        'origin': 'https://example.com',
        'resources': [3],
      });

      expect(request!.resources, [PermissionResourceType.UNKNOWN]);
    });

    test('PermissionResponse.fromMap has the same fallback', () {
      final response = PermissionResponse.fromMap({
        'action': 1,
        'resources': ['android.webkit.resource.SOMETHING_NEW'],
      });

      expect(response!.resources, [PermissionResourceType.UNKNOWN]);
    });

    test('the fallback does not swallow the values that do map', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      final request = PermissionRequest.fromMap({
        'origin': 'https://example.com',
        'resources': [
          'android.webkit.resource.AUDIO_CAPTURE',
          'android.webkit.resource.VIDEO_CAPTURE',
          'android.webkit.resource.NOT_A_REAL_ONE',
        ],
      });

      expect(request!.resources, [
        PermissionResourceType.MICROPHONE,
        PermissionResourceType.CAMERA,
        PermissionResourceType.UNKNOWN,
      ]);
    });

    test('UNKNOWN is platform-independent and inert on the wire', () {
      // No @EnumSupportedPlatforms, so it takes its own name as its native value on every
      // platform rather than switching on defaultTargetPlatform. Neither native ever sends
      // this string, and Android's PermissionRequest.grant ignores resources it did not ask
      // for, so passing it back grants nothing.
      expect(PermissionResourceType.UNKNOWN.toNativeValue(), 'UNKNOWN');
      expect(PermissionResourceType.UNKNOWN.toValue(), 'UNKNOWN');

      for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
        debugDefaultTargetPlatformOverride = platform;
        expect(PermissionResourceType.UNKNOWN.toNativeValue(), 'UNKNOWN');
      }
      debugDefaultTargetPlatformOverride = null;
    });

    test('UNKNOWN does not shadow a real constant in fromNativeValue', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      expect(
        PermissionResourceType.fromNativeValue(
          'android.webkit.resource.AUDIO_CAPTURE',
        ),
        PermissionResourceType.MICROPHONE,
      );
      // fromNativeValue itself still reports "not mapped" as null; only the generated fromMap
      // substitutes UNKNOWN. Keeping that split means a caller doing its own lookup can still
      // tell the two apart.
      expect(
        PermissionResourceType.fromNativeValue('android.webkit.resource.NOPE'),
        isNull,
      );
    });
  });
}
