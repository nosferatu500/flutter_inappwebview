package com.pichillilorenzo.flutter_inappwebview_android.process_global_config;

import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.webkit.ProcessGlobalConfig;

import com.pichillilorenzo.flutter_inappwebview_android.InAppWebViewFlutterPlugin;
import com.pichillilorenzo.flutter_inappwebview_android.types.ChannelDelegateImpl;

import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

// Unchecked casts below are the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. Java cannot check these; a wrong shape throws ClassCastException at the cast site,
// which is the intended failure mode. Suppressed at class level because the whole class is
// that boundary. NOTE: javac does not enable -Xlint:unchecked by default; these only ever
// appeared under -Xlint:all.
@SuppressWarnings("unchecked")
public class ProcessGlobalConfigManager extends ChannelDelegateImpl {
  protected static final String LOG_TAG = "ProcessGlobalConfigM";
  public static final String METHOD_CHANNEL_NAME = "com.pichillilorenzo/flutter_inappwebview_processglobalconfig";

  @Nullable
  public InAppWebViewFlutterPlugin plugin;

  public ProcessGlobalConfigManager(@NonNull final InAppWebViewFlutterPlugin plugin) {
    super(new MethodChannel(plugin.messenger, METHOD_CHANNEL_NAME));
    this.plugin = plugin;
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    switch (call.method) {
      case "apply":
        if (plugin != null && plugin.activity != null) {
          ProcessGlobalConfigSettings settings = (new ProcessGlobalConfigSettings())
                  .parse((Map<String, Object>) call.argument("settings"));
          try {
            ProcessGlobalConfig.apply(settings.toProcessGlobalConfig(plugin.activity));
            result.success(true);
          } catch (Exception e) {
            result.error(LOG_TAG, "", e);
          }
        } else {
          result.success(false);
        }
        break;
      default:
        result.notImplemented();
    }
  }

  @Override
  public void dispose() {
    super.dispose();
    plugin = null;
  }
}
