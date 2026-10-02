import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins the narrowing getters that replaced seven overriding fields (§222, `overridden_fields`).
///
/// Each subclass used to redeclare the base field with a narrower type and set only its own copy,
/// so the base copy stayed null (`allowedOriginRules`: null even where the conversion gave the
/// subclass `{"*"}`). Now the value goes to the base and the getter narrows it. These tests read
/// the getters through the direct constructor and through the conversion from the
/// platform-interface params, which is the path the app-facing package takes. They cannot tell one
/// stored copy from two: only the analyzer sees that.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final ptr = AndroidPullToRefreshController(
    AndroidPullToRefreshControllerCreationParams(),
  );
  final fic = AndroidFindInteractionController(
    AndroidFindInteractionControllerCreationParams(),
  );

  void expectControllers(dynamic params) {
    expect(params.pullToRefreshController, same(ptr));
    expect(params.findInteractionController, same(fic));
  }

  void expectNoControllers(dynamic params) {
    expect(params.pullToRefreshController, isNull);
    expect(params.findInteractionController, isNull);
  }

  group('AndroidInAppBrowserCreationParams', () {
    test('returns the controllers it was given', () {
      expectControllers(
        AndroidInAppBrowserCreationParams(
          pullToRefreshController: ptr,
          findInteractionController: fic,
        ),
      );
    });

    test('keeps them through the platform-interface conversion', () {
      expectControllers(
        AndroidInAppBrowserCreationParams.fromPlatformInAppBrowserCreationParams(
          PlatformInAppBrowserCreationParams(
            pullToRefreshController: ptr,
            findInteractionController: fic,
          ),
        ),
      );
    });

    test('defaults both to null', () {
      expectNoControllers(AndroidInAppBrowserCreationParams());
    });
  });

  group('AndroidHeadlessInAppWebViewCreationParams', () {
    test('returns the controllers it was given', () {
      expectControllers(
        AndroidHeadlessInAppWebViewCreationParams(
          pullToRefreshController: ptr,
          findInteractionController: fic,
        ),
      );
    });

    test('keeps them through the platform-interface conversion', () {
      expectControllers(
        AndroidHeadlessInAppWebViewCreationParams.fromPlatformHeadlessInAppWebViewCreationParams(
          PlatformHeadlessInAppWebViewCreationParams(
            pullToRefreshController: ptr,
            findInteractionController: fic,
          ),
        ),
      );
    });

    test('defaults both to null', () {
      expectNoControllers(AndroidHeadlessInAppWebViewCreationParams());
    });
  });

  group('AndroidInAppWebViewWidgetCreationParams', () {
    test('returns the controllers it was given', () {
      expectControllers(
        AndroidInAppWebViewWidgetCreationParams(
          pullToRefreshController: ptr,
          findInteractionController: fic,
        ),
      );
    });

    test('keeps them through the platform-interface conversion', () {
      expectControllers(
        AndroidInAppWebViewWidgetCreationParams.fromPlatformInAppWebViewWidgetCreationParams(
          PlatformInAppWebViewWidgetCreationParams(
            pullToRefreshController: ptr,
            findInteractionController: fic,
          ),
        ),
      );
    });

    test('defaults both to null', () {
      expectNoControllers(AndroidInAppWebViewWidgetCreationParams());
    });
  });

  group('AndroidWebMessageListenerCreationParams.allowedOriginRules', () {
    test('returns the set it was given', () {
      final rules = {'https://example.com'};
      expect(
        AndroidWebMessageListenerCreationParams(
          jsObjectName: 'obj',
          allowedOriginRules: rules,
        ).allowedOriginRules,
        same(rules),
      );
    });

    test('the conversion turns a missing set into {"*"}', () {
      expect(
        AndroidWebMessageListenerCreationParams.fromPlatformWebMessageListenerCreationParams(
          const PlatformWebMessageListenerCreationParams(jsObjectName: 'obj'),
        ).allowedOriginRules,
        {'*'},
      );
    });
  });
}
