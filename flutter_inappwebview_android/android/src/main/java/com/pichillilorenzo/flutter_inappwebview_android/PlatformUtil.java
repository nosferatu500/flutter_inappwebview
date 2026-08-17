package com.pichillilorenzo.flutter_inappwebview_android;

import android.os.Build;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.pichillilorenzo.flutter_inappwebview_android.types.ChannelDelegateImpl;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.TimeZone;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class PlatformUtil extends ChannelDelegateImpl {
  protected static final String LOG_TAG = "PlatformUtil";
  public static final String METHOD_CHANNEL_NAME = "com.pichillilorenzo/flutter_inappwebview_platformutil";

  @Nullable
  public InAppWebViewFlutterPlugin plugin;

  public PlatformUtil(final InAppWebViewFlutterPlugin plugin) {
    super(new MethodChannel(plugin.messenger, METHOD_CHANNEL_NAME));
    this.plugin = plugin;
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull final MethodChannel.Result result) {
    switch (call.method) {
      case "getSystemVersion":
        result.success(String.valueOf(Build.VERSION.SDK_INT));
        break;
      case "formatDate":
        long date = (long) call.argument("date");
        String format = (String) call.argument("format");
        Locale locale = PlatformUtil.getLocaleFromString((String) call.argument("locale"));
        String timezone = (String) call.argument("timezone");
        if (timezone == null) {
          timezone = "UTC";
        }
        result.success(PlatformUtil.formatDate(date, format, locale, TimeZone.getTimeZone(timezone)));
        break;
      default:
        result.notImplemented();
    }
  }

  public static Locale getLocaleFromString(@Nullable String locale) {
    if (locale == null) {
      return Locale.US;
    }
    // Replaces the deprecated Locale(language, country, variant) constructor. Locale.of() is the
    // direct successor but requires API 36, well above our minSdk 30, and Locale.Builder throws
    // IllformedLocaleException on malformed subtags where the old constructor tolerated anything —
    // this value comes straight from the public formatDate(locale: "...") API, so it must stay
    // lenient. Locale.forLanguageTag() is lenient in the same way: it ignores ill-formed subtags
    // rather than throwing. It parses BCP 47 tags, which use '-' where our API uses '_'.
    return Locale.forLanguageTag(locale.replace('_', '-'));
  }

  public static String formatDate(long date, String format, Locale locale, TimeZone timezone) {
    final SimpleDateFormat sdf = new SimpleDateFormat(format, locale);
    sdf.setTimeZone(timezone);
    return sdf.format(new Date(date));
  }

  @Override
  public void dispose() {
    super.dispose();
    plugin = null;
  }
}
