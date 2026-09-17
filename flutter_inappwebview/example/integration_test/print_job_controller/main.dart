import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import '../constants.dart';
import '../util.dart';

part 'controller_lifecycle.dart';

void main() {
  final shouldSkip = defaultTargetPlatform != TargetPlatform.android;

  skippableGroup('Print Job Controller', () {
    controllerLifecycle();
  }, skip: shouldSkip);
}
