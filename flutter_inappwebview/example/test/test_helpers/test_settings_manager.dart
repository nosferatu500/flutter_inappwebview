import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/providers/settings_manager.dart';

/// Lightweight settings manager for widget tests.
class TestSettingsManager extends SettingsManager {
  TestSettingsManager() : super();

  @override
  Future<void> init() async {}

  @override
  InAppWebViewSettings buildSettings() => InAppWebViewSettings();

  @override
  int get settingsRevision => 0;
}
