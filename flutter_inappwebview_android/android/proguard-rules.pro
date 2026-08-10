# Consumer keep rules shipped to apps that depend on this plugin.
#
# NOTE: this file must not contain global options such as -dontoptimize or
# -dontobfuscate. Since AGP 9, publishing an Android library whose consumer keep
# rules contain them fails the build
# (android.r8.globalOptionsInConsumerRules.disallowed).

# WebView JavaScript bridge.
# @JavascriptInterface is a runtime-visible annotation, so the annotation
# attributes have to survive for the keepclassmembers rule below to match.
-keepattributes *Annotation*
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# WebViewClient callbacks invoked by the framework.
-keepclassmembers class * extends android.webkit.WebViewClient {
    public void *(android.webkit.WebView, java.lang.String, android.graphics.Bitmap);
    public boolean *(android.webkit.WebView, java.lang.String);
    public void *(android.webkit.WebView, java.lang.String);
}

-keepclassmembers class com.pichillilorenzo.flutter_inappwebview_android.webview.JavaScriptBridgeInterface {
     <fields>;
     <methods>;
     public *;
     private *;
}

-keep class com.pichillilorenzo.flutter_inappwebview_android.** { *; }

-dontwarn android.window.BackEvent
