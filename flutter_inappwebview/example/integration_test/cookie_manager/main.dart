import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import '../constants.dart';
import '../util.dart';

part 'set_get_delete.dart';
part 'set_cookies.dart';
part 'flush.dart';
part 'accept_cookie.dart';
part 'has_cookies.dart';
part 'file_scheme_cookies.dart';
part 'cookie_store_observer.dart';

void main() {
  final shouldSkip = !CookieManager.isClassSupported();

  skippableGroup('Cookie Manager', () {
    setGetDelete();
    setCookies();
    flush();
    acceptCookie();
    hasCookies();
    fileSchemeCookies();
    cookieStoreObserver();
  }, skip: shouldSkip);
}
