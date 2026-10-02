import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers/mock_inappwebview_platform.dart';

/// Pins the facade's narrowing `platform` getters (§222, `overridden_fields`).
///
/// [LocalStorage], [SessionStorage] and the four path handlers used to redeclare their base's
/// `platform` field with a narrower type. Both copies held the same object, so nothing was wrong;
/// now there is one copy and a getter that narrows it. Each test reads the getter directly and
/// through a base-class member that delegates to `platform`. For a path handler, the base
/// constructor's body also reads it, to set `eventHandler`, before the subclass constructor has
/// finished. None of this can tell one stored copy from two.
void main() {
  group('Storage', () {
    test('LocalStorage.platform is the platform it was built from', () {
      final platform = MockPlatformLocalStorage(
        PlatformLocalStorageCreationParams(
          const PlatformStorageCreationParams(
            controller: null,
            webStorageType: WebStorageType.LOCAL_STORAGE,
          ),
        ),
      );
      final storage = LocalStorage.fromPlatform(platform: platform);
      expect(storage.platform, same(platform));
      expect(storage.webStorageType, WebStorageType.LOCAL_STORAGE);
    });

    test('SessionStorage.platform is the platform it was built from', () {
      final platform = MockPlatformSessionStorage(
        PlatformSessionStorageCreationParams(
          const PlatformStorageCreationParams(
            controller: null,
            webStorageType: WebStorageType.SESSION_STORAGE,
          ),
        ),
      );
      final storage = SessionStorage.fromPlatform(platform: platform);
      expect(storage.platform, same(platform));
      expect(storage.webStorageType, WebStorageType.SESSION_STORAGE);
    });
  });

  group('PathHandler', () {
    test('AssetsPathHandler.platform is the platform it was built from', () {
      final platform = _FakeAssetsPathHandler();
      final handler = AssetsPathHandler.fromPlatform(platform: platform);
      expect(handler.platform, same(platform));
      expect(handler.path, '/assets/');
      expect(platform.eventHandler, same(handler));
    });

    test('ResourcesPathHandler.platform is the platform it was built from', () {
      final platform = _FakeResourcesPathHandler();
      final handler = ResourcesPathHandler.fromPlatform(platform: platform);
      expect(handler.platform, same(platform));
      expect(handler.path, '/res/');
      expect(platform.eventHandler, same(handler));
    });

    test(
      'InternalStoragePathHandler.platform is the platform it was built from',
      () {
        final platform = _FakeInternalStoragePathHandler();
        final handler = InternalStoragePathHandler.fromPlatform(
          platform: platform,
        );
        expect(handler.platform, same(platform));
        expect(handler.path, '/files/');
        expect(handler.directory, 'dir');
        expect(platform.eventHandler, same(handler));
      },
    );

    test('CustomPathHandler.platform is the platform it was built from', () {
      final platform = _FakeCustomPathHandler();
      final handler = _CustomPathHandler(platform);
      expect(handler.platform, same(platform));
      expect(handler.path, '/custom/');
      expect(platform.eventHandler, same(handler));
    });
  });
}

class _FakeAssetsPathHandler extends PlatformAssetsPathHandler {
  _FakeAssetsPathHandler()
    : super.implementation(
        PlatformAssetsPathHandlerCreationParams(
          const PlatformPathHandlerCreationParams(path: '/assets/'),
        ),
      );

  @override
  late final PlatformPathHandlerEvents? eventHandler;

  @override
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) => {};

  @override
  Map<String, dynamic> toJson() => {};
}

class _FakeResourcesPathHandler extends PlatformResourcesPathHandler {
  _FakeResourcesPathHandler()
    : super.implementation(
        PlatformResourcesPathHandlerCreationParams(
          const PlatformPathHandlerCreationParams(path: '/res/'),
        ),
      );

  @override
  late final PlatformPathHandlerEvents? eventHandler;

  @override
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) => {};

  @override
  Map<String, dynamic> toJson() => {};
}

class _FakeInternalStoragePathHandler
    extends PlatformInternalStoragePathHandler {
  _FakeInternalStoragePathHandler()
    : super.implementation(
        PlatformInternalStoragePathHandlerCreationParams(
          const PlatformPathHandlerCreationParams(path: '/files/'),
          directory: 'dir',
        ),
      );

  @override
  late final PlatformPathHandlerEvents? eventHandler;

  @override
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) => {};

  @override
  Map<String, dynamic> toJson() => {};
}

class _FakeCustomPathHandler extends PlatformCustomPathHandler {
  _FakeCustomPathHandler()
    : super.implementation(
        PlatformCustomPathHandlerCreationParams(
          const PlatformPathHandlerCreationParams(path: '/custom/'),
        ),
      );

  @override
  late final PlatformPathHandlerEvents? eventHandler;

  @override
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) => {};

  @override
  Map<String, dynamic> toJson() => {};
}

class _CustomPathHandler extends CustomPathHandler {
  _CustomPathHandler(PlatformCustomPathHandler platform)
    : super.fromPlatform(platform: platform);
}
