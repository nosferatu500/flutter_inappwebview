import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import '../constants.dart';
import '../util.dart';

part 'set_service_worker_client.dart';
part 'should_intercept_request.dart';
part 'include_cookies_on_should_intercept_request.dart';
part 'client_survives_second_controller.dart';
part 'settings_round_trip.dart';
part 'intercept_response.dart';

void main() {
  final shouldSkip = !ServiceWorkerController.isClassSupported();

  skippableGroup('Service Worker Controller', () {
    shouldInterceptRequest();
    clientSurvivesSecondController();
    setServiceWorkerClient();
    serviceWorkerIncludeCookies();
    serviceWorkerSettingsRoundTrip();
    serviceWorkerInterceptResponse();
  }, skip: shouldSkip);
}
