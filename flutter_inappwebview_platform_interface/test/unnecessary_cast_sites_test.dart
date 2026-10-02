import 'dart:typed_data';

import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins the two places `unnecessary_cast` found (§225).
///
/// `ContextMenu.toMap`: the hand-written `_toMapMergeWith` existed to fall back to the deprecated
/// `options` when `settings` was null. Once `options` was removed it only rewrote `"settings"` with
/// the value the generated `toMap` had just written, so it was deleted. These tests fix the map
/// `toMap` produces, so its deletion is visible only if that map changes.
///
/// `InAppBrowserMenuItem.fromMap`'s icon deserializer: the `is Map<String, dynamic>` check already
/// promotes the value, so the cast after it did nothing.
void main() {
  group('ContextMenu.toMap', () {
    test('carries the settings map once, after the menu items', () {
      final map = ContextMenu(
        settings: ContextMenuSettings(hideDefaultSystemContextMenuItems: true),
      ).toMap();
      expect(map.keys, ['menuItems', 'settings']);
      expect(map['menuItems'], isEmpty);
      expect(map['settings'], {'hideDefaultSystemContextMenuItems': true});
    });

    test('settings stays a null entry when unset', () {
      final map = ContextMenu().toMap();
      expect(map.keys, ['menuItems', 'settings']);
      expect(map['settings'], isNull);
    });
  });

  group('InAppBrowserMenuItem.fromMap icon', () {
    InAppBrowserMenuItem? item(Object? icon) =>
        InAppBrowserMenuItem.fromMap({'id': 1, 'title': 't', 'icon': icon});

    test('a map with defType becomes an AndroidResource', () {
      final icon = item(<String, dynamic>{
        'name': 'ic_menu',
        'defType': 'drawable',
        'defPackage': 'android',
      })!.icon;
      expect(icon, isA<AndroidResource>());
      expect((icon as AndroidResource).name, 'ic_menu');
      expect(icon.defType, 'drawable');
    });

    test('a map with systemName becomes a UIImage', () {
      final icon = item(<String, dynamic>{'systemName': 'star'})!.icon;
      expect(icon, isA<UIImage>());
      expect((icon as UIImage).systemName, 'star');
    });

    test('bytes stay bytes', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      expect(item(bytes)!.icon, same(bytes));
    });
  });
}
