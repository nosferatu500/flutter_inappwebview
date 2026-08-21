package dev.nosferatu500.inappwebview.in_app_browser

import dev.nosferatu500.inappwebview.ISettings
import dev.nosferatu500.inappwebview.R

class InAppBrowserSettings : ISettings<InAppBrowserActivity> {

  @JvmField var hidden: Boolean = false
  @JvmField var hideToolbarTop: Boolean = false
  @JvmField var toolbarTopBackgroundColor: String? = null
  @JvmField var toolbarTopFixedTitle: String? = null
  @JvmField var hideUrlBar: Boolean = false
  @JvmField var hideProgressBar: Boolean = false

  @JvmField var hideTitleBar: Boolean = false
  @JvmField var closeOnCannotGoBack: Boolean = true
  @JvmField var allowGoBackWithBackButton: Boolean = true
  @JvmField var shouldCloseOnBackButtonPressed: Boolean = false
  @JvmField var hideDefaultMenuItems: Boolean = false

  override fun parse(settings: Map<String, Any?>): InAppBrowserSettings {
    for ((key, value) in settings) {
      if (value == null) {
        continue
      }
      when (key) {
        "hidden" -> hidden = value as Boolean
        "hideToolbarTop" -> hideToolbarTop = value as Boolean
        "toolbarTopBackgroundColor" -> toolbarTopBackgroundColor = value as String
        "toolbarTopFixedTitle" -> toolbarTopFixedTitle = value as String
        "hideUrlBar" -> hideUrlBar = value as Boolean
        "hideTitleBar" -> hideTitleBar = value as Boolean
        "closeOnCannotGoBack" -> closeOnCannotGoBack = value as Boolean
        "hideProgressBar" -> hideProgressBar = value as Boolean
        "allowGoBackWithBackButton" -> allowGoBackWithBackButton = value as Boolean
        "shouldCloseOnBackButtonPressed" -> shouldCloseOnBackButtonPressed = value as Boolean
        "hideDefaultMenuItems" -> hideDefaultMenuItems = value as Boolean
      }
    }
    return this
  }

  override fun toMap(): MutableMap<String, Any?> = hashMapOf(
    "hidden" to hidden,
    "hideToolbarTop" to hideToolbarTop,
    "toolbarTopBackgroundColor" to toolbarTopBackgroundColor,
    "toolbarTopFixedTitle" to toolbarTopFixedTitle,
    "hideUrlBar" to hideUrlBar,
    "hideTitleBar" to hideTitleBar,
    "closeOnCannotGoBack" to closeOnCannotGoBack,
    "hideProgressBar" to hideProgressBar,
    "allowGoBackWithBackButton" to allowGoBackWithBackButton,
    "shouldCloseOnBackButtonPressed" to shouldCloseOnBackButtonPressed,
    "hideDefaultMenuItems" to hideDefaultMenuItems
  )

  override fun getRealSettings(obj: InAppBrowserActivity): MutableMap<String, Any?> {
    val realSettings = toMap()
    realSettings["hidden"] = obj.isHidden
    realSettings["hideToolbarTop"] = obj.actionBar?.isShowing != true
    realSettings["hideUrlBar"] =
      obj.menu?.findItem(R.id.menu_search)?.isVisible != true
    realSettings["hideProgressBar"] = obj.progressBar.let { it == null || it.max == 0 }
    return realSettings
  }

  companion object {
    const val LOG_TAG = "InAppBrowserSettings"
  }
}
