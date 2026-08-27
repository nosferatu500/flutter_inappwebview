import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins the wire contract between the Swift `ShowFileChooserRequest`/`ShowFileChooserResponse` and
/// their Dart counterparts.
///
/// The iOS side of `onShowFileChooser` is hand-written Swift that builds the request map and reads
/// the response map by literal key. Nothing compiles the two languages together, so — exactly as in
/// §24/§36 — the only thing holding them in agreement is a test that names the keys and the mode
/// integers explicitly.
///
/// The expected values below are what `Types/ShowFileChooserRequest.swift` emits and
/// `Types/ShowFileChooserResponse.swift` parses.
void main() {
  group('ShowFileChooserRequestMode native values', () {
    test('match the integers the Swift side assigns', () {
      // Swift: `var mode = parameters.allowsMultipleSelection ? 1 : 0`, then 2 for directories.
      expect(ShowFileChooserRequestMode.OPEN.toNativeValue(), 0);
      expect(ShowFileChooserRequestMode.OPEN_MULTIPLE.toNativeValue(), 1);
      expect(ShowFileChooserRequestMode.OPEN_FOLDER.toNativeValue(), 2);
      // SAVE exists for other platforms; iOS never produces it because WebKit has no save panel.
      expect(ShowFileChooserRequestMode.SAVE.toNativeValue(), 3);
    });
  });

  group('ShowFileChooserRequest.fromMap', () {
    test('decodes the map Swift sends for a single-file picker', () {
      // Swift toMap(): mode/acceptTypes/isCaptureEnabled/title/filenameHint
      final request = ShowFileChooserRequest.fromMap({
        'mode': 0,
        'acceptTypes': <String>[],
        'isCaptureEnabled': false,
        'title': null,
        'filenameHint': null,
      })!;

      expect(request.mode, ShowFileChooserRequestMode.OPEN);
      // WKOpenPanelParameters exposes neither the `accept` attribute nor a capture hint, so these
      // are always empty/false on iOS. Asserted so the emptiness reads as intentional.
      expect(request.acceptTypes, isEmpty);
      expect(request.isCaptureEnabled, isFalse);
      expect(request.title, isNull);
      expect(request.filenameHint, isNull);
    });

    test('decodes allowsMultipleSelection and allowsDirectories', () {
      expect(
        ShowFileChooserRequest.fromMap({
          'mode': 1,
          'acceptTypes': <String>[],
          'isCaptureEnabled': false,
        })!.mode,
        ShowFileChooserRequestMode.OPEN_MULTIPLE,
      );
      expect(
        ShowFileChooserRequest.fromMap({
          'mode': 2,
          'acceptTypes': <String>[],
          'isCaptureEnabled': false,
        })!.mode,
        ShowFileChooserRequestMode.OPEN_FOLDER,
      );
    });
  });

  group('ShowFileChooserResponse.toMap', () {
    test('uses the keys the Swift side reads', () {
      final response = ShowFileChooserResponse(
        handledByClient: true,
        filePaths: ['file:///tmp/a.png', 'file:///tmp/b.png'],
      );

      final map = response.toMap();

      // Swift: map["handledByClient"] as? Bool ?? false
      expect(map['handledByClient'], true);
      // Swift: map["filePaths"] as? [String], then URL(string:) on each
      expect(map['filePaths'], ['file:///tmp/a.png', 'file:///tmp/b.png']);
    });

    test('null filePaths is the cancel signal, distinct from an empty list', () {
      // Swift toURLs() returns nil for a null filePaths -> completionHandler(nil) -> cancel.
      expect(
        ShowFileChooserResponse(handledByClient: true).toMap()['filePaths'],
        isNull,
      );
      // An empty list is a successful empty selection, NOT a cancel.
      expect(
        ShowFileChooserResponse(
          handledByClient: true,
          filePaths: const [],
        ).toMap()['filePaths'],
        isEmpty,
      );
    });

    test('handledByClient false is what cancels the upload on iOS', () {
      // Documented divergence from Android, where false falls through to the plugin's own picker.
      // On iOS the Swift `defaultBehaviour` calls completionHandler(nil).
      final map = ShowFileChooserResponse(handledByClient: false).toMap();
      expect(map['handledByClient'], false);
    });
  });

  group('useOnShowFileChooser, the gate that makes the event fire', () {
    test('is claimed on iOS as well as Android', () {
      // §46's whole delta is that iOS now honours this setting. The Swift side only installs
      // `runOpenPanelWith` when it is true, so an annotation regression here would present as
      // "the event never fires on iOS" — the same silent shape as §68, with no compile error.
      expect(
        InAppWebViewSettings.isPropertySupported(
          InAppWebViewSettingsProperty.useOnShowFileChooser,
          platform: TargetPlatform.iOS,
        ),
        isTrue,
      );
      expect(
        InAppWebViewSettings.isPropertySupported(
          InAppWebViewSettingsProperty.useOnShowFileChooser,
          platform: TargetPlatform.android,
        ),
        isTrue,
      );
    });

    test('serialises under the key the Swift side reads', () {
      expect(
        InAppWebViewSettings(
          useOnShowFileChooser: true,
        ).toMap()['useOnShowFileChooser'],
        true,
      );
    });

    test('unset means absent, and the Swift side reads absent as off', () {
      // Measured, not assumed: the Dart field is `bool?` with no default, so an app that never
      // asked sends null — and `InAppWebViewSettings.swift` declares `var useOnShowFileChooser =
      // false` while the selector gate reads `settings?.useOnShowFileChooser ?? false`. Both halves
      // have to keep agreeing that "absent" is "off", or the plugin starts intercepting uploads for
      // apps that never opted in.
      expect(InAppWebViewSettings().toMap()['useOnShowFileChooser'], isNull);
    });
  });
}
