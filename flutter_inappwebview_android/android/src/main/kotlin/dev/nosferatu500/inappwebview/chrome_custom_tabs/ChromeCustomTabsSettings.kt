package dev.nosferatu500.inappwebview.chrome_custom_tabs

import androidx.browser.customtabs.CustomTabsIntent
import androidx.browser.trusted.ScreenOrientation
import androidx.browser.trusted.TrustedWebActivityDisplayMode
import dev.nosferatu500.inappwebview.ISettings
import dev.nosferatu500.inappwebview.types.AndroidResource

// The unchecked casts below are the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode. Suppressed at class level because the whole class is that boundary.
@Suppress("UNCHECKED_CAST")
class ChromeCustomTabsSettings : ISettings<ChromeCustomTabsActivity> {

  @JvmField var shareState: Int = CustomTabsIntent.SHARE_STATE_DEFAULT
  @JvmField var showTitle: Boolean = true
  @JvmField var toolbarBackgroundColor: String? = null
  @JvmField var navigationBarColor: String? = null
  @JvmField var navigationBarDividerColor: String? = null
  @JvmField var secondaryToolbarColor: String? = null
  @JvmField var enableUrlBarHiding: Boolean = false
  @JvmField var instantAppsEnabled: Boolean = false
  @JvmField var packageName: String? = null
  @JvmField var keepAliveEnabled: Boolean = false
  @JvmField var isSingleInstance: Boolean = false
  @JvmField var noHistory: Boolean = false
  @JvmField var isTrustedWebActivity: Boolean = false
  @JvmField var additionalTrustedOrigins: List<String> = ArrayList()
  @JvmField var displayMode: TrustedWebActivityDisplayMode? = null
  @JvmField var screenOrientation: Int = ScreenOrientation.DEFAULT
  @JvmField var startAnimations: MutableList<AndroidResource> = ArrayList()
  @JvmField var exitAnimations: MutableList<AndroidResource> = ArrayList()
  @JvmField var alwaysUseBrowserUI: Boolean = false

  override fun parse(settings: Map<String, Any?>): ChromeCustomTabsSettings {
    for ((key, value) in settings) {
      if (value == null) {
        continue
      }
      when (key) {
        "shareState" -> shareState = value as Int
        "showTitle" -> showTitle = value as Boolean
        "toolbarBackgroundColor" -> toolbarBackgroundColor = value as String
        "navigationBarColor" -> navigationBarColor = value as String
        "navigationBarDividerColor" -> navigationBarDividerColor = value as String
        "secondaryToolbarColor" -> secondaryToolbarColor = value as String
        "enableUrlBarHiding" -> enableUrlBarHiding = value as Boolean
        "instantAppsEnabled" -> instantAppsEnabled = value as Boolean
        "packageName" -> packageName = value as String
        "keepAliveEnabled" -> keepAliveEnabled = value as Boolean
        "isSingleInstance" -> isSingleInstance = value as Boolean
        "noHistory" -> noHistory = value as Boolean
        "isTrustedWebActivity" -> isTrustedWebActivity = value as Boolean
        "additionalTrustedOrigins" -> additionalTrustedOrigins = value as List<String>
        "displayMode" -> {
          val displayModeMap = value as Map<String, Any?>
          when (displayModeMap["type"] as String?) {
            "IMMERSIVE_MODE" -> {
              val isSticky = displayModeMap["isSticky"] as Boolean
              val layoutInDisplayCutoutMode = displayModeMap["displayCutoutMode"] as Int
              displayMode = TrustedWebActivityDisplayMode.ImmersiveMode(
                isSticky, layoutInDisplayCutoutMode
              )
            }

            "DEFAULT_MODE" -> displayMode = TrustedWebActivityDisplayMode.DefaultMode()
          }
        }
        "screenOrientation" -> screenOrientation = value as Int
        "startAnimations" -> {
          for (startAnimation in value as List<Map<String, Any?>>) {
            AndroidResource.fromMap(startAnimation)?.let { startAnimations.add(it) }
          }
        }
        "exitAnimations" -> {
          for (exitAnimation in value as List<Map<String, Any?>>) {
            AndroidResource.fromMap(exitAnimation)?.let { exitAnimations.add(it) }
          }
        }
        "alwaysUseBrowserUI" -> alwaysUseBrowserUI = value as Boolean
      }
    }
    return this
  }

  override fun toMap(): MutableMap<String, Any?> = hashMapOf(
    "showTitle" to showTitle,
    "toolbarBackgroundColor" to toolbarBackgroundColor,
    "navigationBarColor" to navigationBarColor,
    "navigationBarDividerColor" to navigationBarDividerColor,
    "secondaryToolbarColor" to secondaryToolbarColor,
    "enableUrlBarHiding" to enableUrlBarHiding,
    "instantAppsEnabled" to instantAppsEnabled,
    "packageName" to packageName,
    "keepAliveEnabled" to keepAliveEnabled,
    "isSingleInstance" to isSingleInstance,
    "noHistory" to noHistory,
    "isTrustedWebActivity" to isTrustedWebActivity,
    "additionalTrustedOrigins" to additionalTrustedOrigins,
    "screenOrientation" to screenOrientation,
    "alwaysUseBrowserUI" to alwaysUseBrowserUI
  )

  override fun getRealSettings(obj: ChromeCustomTabsActivity): MutableMap<String, Any?> {
    val realOptions = toMap()
    obj.intent?.let { intent ->
      realOptions["packageName"] = intent.getPackage()
      realOptions["keepAliveEnabled"] =
        intent.hasExtra(CustomTabsHelper.EXTRA_CUSTOM_TABS_KEEP_ALIVE)
    }
    return realOptions
  }

  companion object {
    const val LOG_TAG = "ChromeCustomTabsSettings"
  }
}
