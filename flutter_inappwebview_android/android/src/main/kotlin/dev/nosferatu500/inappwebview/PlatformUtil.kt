package dev.nosferatu500.inappwebview

import android.os.Build
import dev.nosferatu500.inappwebview.types.ChannelDelegateImpl
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone

class PlatformUtil(plugin: InAppWebViewFlutterPlugin) :
  ChannelDelegateImpl(MethodChannel(plugin.messenger, METHOD_CHANNEL_NAME)) {

  @JvmField
  var plugin: InAppWebViewFlutterPlugin? = plugin

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "getSystemVersion" -> result.success(Build.VERSION.SDK_INT.toString())

      "formatDate" -> {
        val date = call.argument<Long>("date")!!
        val format = call.argument<String>("format")
        val locale = getLocaleFromString(call.argument("locale"))
        val timezone = call.argument<String>("timezone") ?: "UTC"
        result.success(formatDate(date, format, locale, TimeZone.getTimeZone(timezone)))
      }

      else -> result.notImplemented()
    }
  }

  override fun dispose() {
    super.dispose()
    plugin = null
  }

  companion object {
    protected const val LOG_TAG = "PlatformUtil"
    const val METHOD_CHANNEL_NAME = "dev.nosferatu500.inappwebview/inappwebview_platformutil"

    @JvmStatic
    fun getLocaleFromString(locale: String?): Locale {
      if (locale == null) {
        return Locale.US
      }
      // Replaces the deprecated Locale(language, country, variant) constructor. Locale.of() is the
      // direct successor but requires API 36, well above our minSdk 30, and Locale.Builder throws
      // IllformedLocaleException on malformed subtags where the old constructor tolerated anything --
      // this value comes straight from the public formatDate(locale: "...") API, so it must stay
      // lenient. Locale.forLanguageTag() is lenient in the same way: it ignores ill-formed subtags
      // rather than throwing. It parses BCP 47 tags, which use '-' where our API uses '_'.
      return Locale.forLanguageTag(locale.replace('_', '-'))
    }

    @JvmStatic
    fun formatDate(date: Long, format: String?, locale: Locale, timezone: TimeZone): String {
      val sdf = SimpleDateFormat(format, locale)
      sdf.timeZone = timezone
      return sdf.format(Date(date))
    }
  }
}
