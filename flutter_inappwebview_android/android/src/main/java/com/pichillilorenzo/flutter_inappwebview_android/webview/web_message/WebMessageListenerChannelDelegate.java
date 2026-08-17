package com.pichillilorenzo.flutter_inappwebview_android.webview.web_message;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.pichillilorenzo.flutter_inappwebview_android.types.ChannelDelegateImpl;
import com.pichillilorenzo.flutter_inappwebview_android.types.WebMessageCompatExt;
import com.pichillilorenzo.flutter_inappwebview_android.webview.in_app_webview.InAppWebView;

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
public class WebMessageListenerChannelDelegate extends ChannelDelegateImpl {
  @Nullable
  private WebMessageListener webMessageListener;

  public WebMessageListenerChannelDelegate(@NonNull WebMessageListener webMessageListener, @NonNull MethodChannel channel) {
    super(channel);
    this.webMessageListener = webMessageListener;
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    switch (call.method) {
      case "postMessage":
        if (webMessageListener != null && webMessageListener.webView instanceof InAppWebView) {
          WebMessageCompatExt message = WebMessageCompatExt.fromMap((Map<String, Object>) call.argument("message"));
          webMessageListener.postMessageForInAppWebView(message, result);
        } else {
          result.success(false); 
        }
        break;
      default:
        result.notImplemented();
    }
  }

  public void onPostMessage(@Nullable WebMessageCompatExt message, String sourceOrigin, boolean isMainFrame) {
    MethodChannel channel = getChannel();
    if (channel == null) return;
    Map<String, Object> obj = new HashMap<>();
    obj.put("message", message != null ? message.toMap() : null);
    obj.put("sourceOrigin", sourceOrigin);
    obj.put("isMainFrame", isMainFrame);
    channel.invokeMethod("onPostMessage", obj);
  }

  @Override
  public void dispose() {
    super.dispose();
    webMessageListener = null;
  }
}
