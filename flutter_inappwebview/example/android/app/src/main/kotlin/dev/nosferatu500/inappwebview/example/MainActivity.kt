package dev.nosferatu500.inappwebview.example

import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  // Test-harness only: lets integration tests gate on the device's API level (see
  // `androidSdkInt()` in integration_test/util.dart). The plugin itself deliberately exposes no such
  // call, and Dart's `Platform.operatingSystemVersion` reports the kernel, not the SDK.
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "example/device_info")
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "sdkInt" -> result.success(Build.VERSION.SDK_INT)
          else -> result.notImplemented()
        }
      }
  }
}
