import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_ios/flutter_inappwebview_ios.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards `WebMessageListener.contentWorld` (`WKUserContentController`, §128).
///
/// The device test in `example/integration_test` proves the *isolation*; what it cannot see is
/// the wire, and the wire is where this can fail silently. `WebMessageListener.fromMap` on the
/// Swift side reads `map["contentWorld"]` and hands it to `WKContentWorld.fromMap`, which does
/// `map["name"] as! String` — so an omitted key gives the page world (correct) but a key carrying
/// anything other than a `{"name": …}` map crashes in Swift, and a *misspelled* key is a listener
/// that silently lands in the page world where the caller asked for isolation. Nothing in this
/// repo compiles Swift and Dart together, so only an assertion here sees either.
///
/// The property is deliberately iOS-only; the last group pins that, because "Android ignores it"
/// is a decision recorded in the dartdoc rather than something the type system enforces.
void main() {
  // `IOSWebMessageListener`'s constructor opens a `MethodChannel`, which needs a binary
  // messenger.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('IOSWebMessageListener.toMap contentWorld', () {
    IOSWebMessageListener listener({ContentWorld? contentWorld}) =>
        IOSWebMessageListener(
          IOSWebMessageListenerCreationParams(
            jsObjectName: 'obj',
            allowedOriginRules: {'*'},
            contentWorld: contentWorld,
          ),
        );

    test(
      'sends the key the Swift fromMap reads, shaped as WKContentWorld wants',
      () {
        // Swift: WKContentWorld.fromMap(map: map["contentWorld"] as? [String:Any?], ...)
        //        -> map["name"] as! String
        final map = listener(
          contentWorld: ContentWorld.world(name: 'myWorld'),
        ).toMap();

        expect(map.containsKey('contentWorld'), isTrue);
        expect(map['contentWorld'], {'name': 'myWorld'});
      },
    );

    test(
      'omitting the world sends null, not an empty map or the string "page"',
      () {
        // `as? [String:Any?]` on a null yields nil, which is what makes the Swift side default to
        // `.page`. An empty map would instead reach `map["name"] as! String` and crash.
        expect(listener().toMap()['contentWorld'], isNull);
      },
    );

    test('ContentWorld.PAGE travels as a named world, not as null', () {
      // Passing PAGE explicitly must not be silently rewritten to "no world": on the Swift side
      // "page" is the name WKContentWorld.fromMap special-cases to leave windowId unset, and
      // collapsing it here would lose that distinction for a `window.open` child.
      expect(
        listener(contentWorld: ContentWorld.PAGE).toMap()['contentWorld'],
        {'name': 'page'},
      );
    });

    test('the world survives the params round trip from the base class', () {
      // The facade builds a PlatformWebMessageListenerCreationParams; the iOS params are derived
      // from it by a factory that has to copy every field by hand. A field added to the base and
      // forgotten in that factory analyzes clean and is silently dropped.
      final derived =
          IOSWebMessageListenerCreationParams.fromPlatformWebMessageListenerCreationParams(
            PlatformWebMessageListenerCreationParams(
              jsObjectName: 'obj',
              contentWorld: ContentWorld.world(name: 'carried'),
            ),
          );
      expect(derived.contentWorld?.name, 'carried');
    });
  });

  group('contentWorld support is iOS-only', () {
    test('reported supported on iOS and unsupported on Android', () {
      const property =
          PlatformWebMessageListenerCreationParamsProperty.contentWorld;
      final params = PlatformWebMessageListenerCreationParams(
        jsObjectName: 'obj',
      );

      expect(
        params.isPropertySupported(property, platform: TargetPlatform.iOS),
        isTrue,
      );
      expect(
        params.isPropertySupported(property, platform: TargetPlatform.android),
        isFalse,
        reason:
            'Android deliberately ignores contentWorld — androidx isolated worlds are a '
            'different mechanism from the <iframe> emulation ContentWorld means there',
      );
    });
  });
}
