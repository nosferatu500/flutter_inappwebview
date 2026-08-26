import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards [NavigationAction.isContentRuleListRedirect] (`WKNavigationAction`, iOS 26.0+).
///
/// A plain `bool?` has no enum mapping to fumble, so what is actually worth pinning is the
/// **three-state** meaning of the wire value and the fact that the key travels under exactly the
/// spelling the Swift dictionary literal uses — nothing in this repo compiles Swift and Dart
/// together, so a typo on either side yields a field that is fully wired, analyzes clean, and is
/// permanently `null` on device.
///
/// The two `_redirect` names are deliberately not merged: [NavigationAction.isRedirect] is a
/// *server-side* redirect (Android/Windows), while this one never reached the network at the
/// original URL at all.
void main() {
  group('NavigationAction.isContentRuleListRedirect', () {
    test('decodes the key the Swift toMap sends', () {
      // Swift: "isContentRuleListRedirect": isContentRuleListRedirect
      final redirected = NavigationAction.fromMap({
        'request': {'url': 'https://example.com'},
        'isForMainFrame': true,
        'isContentRuleListRedirect': true,
      })!;

      expect(redirected.isContentRuleListRedirect, isTrue);
    });

    test('null is distinct from false', () {
      // Below iOS 26.0 the Swift side leaves it nil: "this platform did not report it".
      final unreported = NavigationAction.fromMap({
        'request': {'url': 'https://example.com'},
        'isForMainFrame': true,
      })!;
      expect(unreported.isContentRuleListRedirect, isNull);

      // On 26.0+ an ordinary navigation reports false: "reported, and not rule-list driven".
      final ordinary = NavigationAction.fromMap({
        'request': {'url': 'https://example.com'},
        'isForMainFrame': true,
        'isContentRuleListRedirect': false,
      })!;
      expect(ordinary.isContentRuleListRedirect, isFalse);
      expect(ordinary.isContentRuleListRedirect, isNot(isNull));
    });

    test('is independent of isRedirect', () {
      // The server-side redirect flag is Android/Windows only, so on iOS the two never agree by
      // construction. A caller must not read one for the other.
      final action = NavigationAction.fromMap({
        'request': {'url': 'https://example.com'},
        'isForMainFrame': true,
        'isContentRuleListRedirect': true,
      })!;

      expect(action.isContentRuleListRedirect, isTrue);
      expect(action.isRedirect, isNull);
    });

    test('toMap round-trips it', () {
      final map = NavigationAction(
        request: URLRequest(url: WebUri('https://example.com')),
        isForMainFrame: true,
        isContentRuleListRedirect: true,
      ).toMap();

      expect(map['isContentRuleListRedirect'], true);
      expect(NavigationAction.fromMap(map)!.isContentRuleListRedirect, isTrue);
    });

    test('CreateWindowAction inherits it', () {
      // CreateWindowAction.toMap() on the Swift side starts from navigationAction.toMap(), so
      // onCreateWindow carries the field with no extra population site.
      final action = CreateWindowAction.fromMap({
        'request': {'url': 'https://example.com'},
        'isForMainFrame': true,
        'windowId': 1,
        'isContentRuleListRedirect': true,
      })!;

      expect(action.isContentRuleListRedirect, isTrue);
    });
  });
}
