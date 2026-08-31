import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util.dart';

part 'website_data_types.dart';

void main() {
  final shouldSkip = !WebStorageManager.isClassSupported();

  skippableGroup('Web Storage Manager', () {
    websiteDataTypes();
  }, skip: shouldSkip);
}
