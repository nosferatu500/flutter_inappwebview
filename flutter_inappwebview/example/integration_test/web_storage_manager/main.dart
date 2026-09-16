import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../env.dart';
import '../util.dart';

part 'website_data_types.dart';
part 'android_storage.dart';

void main() {
  final shouldSkip = !WebStorageManager.isClassSupported();

  skippableGroup('Web Storage Manager', () {
    websiteDataTypes();
    androidStorage();
  }, skip: shouldSkip);
}
