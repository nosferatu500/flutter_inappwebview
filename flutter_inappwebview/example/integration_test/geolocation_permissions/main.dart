import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import '../util.dart';

part 'stored_decisions.dart';
part 'profile_scope.dart';

void main() {
  final shouldSkip =
      !GeolocationPermissions.isClassSupported() ||
      defaultTargetPlatform != TargetPlatform.android;

  skippableGroup('Geolocation Permissions', () {
    storedDecisions();
    geolocationProfileScope();
  }, skip: shouldSkip);
}
