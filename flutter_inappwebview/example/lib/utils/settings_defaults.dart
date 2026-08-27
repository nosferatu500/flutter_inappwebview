import 'package:flutter_inappwebview/flutter_inappwebview.dart';

InAppWebViewSettings defaultInAppWebViewSettings() {
  return InAppWebViewSettings();
}

Map<String, dynamic> defaultInAppWebViewSettingsMap() {
  return defaultInAppWebViewSettings().toMap(
    enumMethod: EnumMethod.nativeValue,
  );
}
