import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import '../constants.dart';
import '../util.dart';

part 'set_get_delete.dart';
part 'flush.dart';
part 'accept_cookie.dart';
part 'has_cookies.dart';
part 'file_scheme_cookies.dart';

void main() {
  final shouldSkip = !CookieManager.isClassSupported();

  skippableGroup('Cookie Manager', () {
    setGetDelete();
    flush();
    acceptCookie();
    hasCookies();
    fileSchemeCookies();
  }, skip: shouldSkip);
}
