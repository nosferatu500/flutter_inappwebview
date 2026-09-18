import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import '../constants.dart';
import '../util.dart';

part 'custom_menu_item.dart';
part 'custom_tabs.dart';
part 'open_and_close.dart';
part 'trusted_web_activity.dart';
part 'sf_safari_view_controller.dart';

void main() {
  final shouldSkip = !ChromeSafariBrowser.isClassSupported();

  skippableGroup('ChromeSafariBrowser', () {
    // A Custom Tab left on screen by a failing test covers the Flutter UI, so every test after it
    // times out at 60s against a view it can never reach — §178 measured exactly that cascade, where
    // one real failure took down three tests that pass in isolation. Each test still closes its own
    // browser; this is the net for the ones that fail before they get there.
    tearDown(() async {
      await MyChromeSafariBrowser.closeAllOpen();
    });

    openAndClose();
    customMenuItem();
    customTabs();
    trustedWebActivity();
    sfSafariViewController();
  }, skip: shouldSkip);
}
