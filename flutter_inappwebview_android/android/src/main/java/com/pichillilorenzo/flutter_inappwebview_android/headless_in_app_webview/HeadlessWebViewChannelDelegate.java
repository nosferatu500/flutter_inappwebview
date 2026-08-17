package com.pichillilorenzo.flutter_inappwebview_android.headless_in_app_webview;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.pichillilorenzo.flutter_inappwebview_android.types.ChannelDelegateImpl;
import com.pichillilorenzo.flutter_inappwebview_android.types.Size2D;

import java.util.HashMap;
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
public class HeadlessWebViewChannelDelegate extends ChannelDelegateImpl {
  @Nullable
  private HeadlessInAppWebView headlessWebView;

  public HeadlessWebViewChannelDelegate(@NonNull HeadlessInAppWebView headlessWebView, @NonNull MethodChannel channel) {
    super(channel);
    this.headlessWebView = headlessWebView;
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    switch (call.method) {
      case "dispose":
        if (headlessWebView != null) {
          headlessWebView.dispose();
          result.success(true);
        } else {
          result.success(false);
        }
        break;
      case "setSize":
        if (headlessWebView != null) {
          Map<String, Object> sizeMap = (Map<String, Object>) call.argument("size");
          Size2D size = Size2D.fromMap(sizeMap);
          if (size != null)
            headlessWebView.setSize(size);
          result.success(true);
        } else {
          result.success(false);
        }
      break;
      case "getSize":
        if (headlessWebView != null) {
          Size2D size = headlessWebView.getSize();
          result.success(size != null ? size.toMap() : null);
        } else {
          result.success(null);
        }
      break;
      default:
        result.notImplemented();
    }
  }

  public void onWebViewCreated() {
    MethodChannel channel = getChannel();
    if (channel == null) return;
    Map<String, Object> obj = new HashMap<>();
    channel.invokeMethod("onWebViewCreated", obj);
  }

  @Override
  public void dispose() {
    super.dispose();
    headlessWebView = null;
  }
}
