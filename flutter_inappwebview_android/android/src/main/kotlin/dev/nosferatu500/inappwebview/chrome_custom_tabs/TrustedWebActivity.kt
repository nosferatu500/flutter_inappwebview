package dev.nosferatu500.inappwebview.chrome_custom_tabs

import android.content.Intent
import android.graphics.Color
import android.net.Uri
import androidx.browser.customtabs.CustomTabColorSchemeParams
import androidx.browser.customtabs.CustomTabsIntent
import androidx.browser.trusted.TrustedWebActivityIntent
import androidx.browser.trusted.TrustedWebActivityIntentBuilder

open class TrustedWebActivity : ChromeCustomTabsActivity() {

  // Named differently from the inherited `builder`: the Java shadowed the superclass field with a
  // second one of a different type, which Kotlin does not allow.
  @JvmField
  var trustedWebActivityBuilder: TrustedWebActivityIntentBuilder? = null

  override fun launchUrl(
    url: String,
    headers: Map<String, String>?,
    referrer: String?,
    otherLikelyURLs: List<String>?
  ) {
    val session = customTabsSession ?: return
    val uri = Uri.parse(url)

    mayLaunchUrl(url, otherLikelyURLs)
    val intentBuilder = TrustedWebActivityIntentBuilder(uri)
    trustedWebActivityBuilder = intentBuilder
    prepareCustomTabs(intentBuilder)

    val trustedWebActivityIntent = intentBuilder.build(session)
    prepareCustomTabsIntent(trustedWebActivityIntent)

    CustomTabActivityHelper.openTrustedWebActivity(
      this, trustedWebActivityIntent, uri, headers,
      referrer?.let { Uri.parse(it) }, CHROME_CUSTOM_TAB_REQUEST_CODE
    )
  }

  private fun prepareCustomTabs(builder: TrustedWebActivityIntentBuilder) {
    val defaultColorSchemeBuilder = CustomTabColorSchemeParams.Builder()
    customSettings.toolbarBackgroundColor?.takeIf { it.isNotEmpty() }?.let {
      defaultColorSchemeBuilder.setToolbarColor(Color.parseColor(it))
    }
    customSettings.navigationBarColor?.takeIf { it.isNotEmpty() }?.let {
      defaultColorSchemeBuilder.setNavigationBarColor(Color.parseColor(it))
    }
    customSettings.navigationBarDividerColor?.takeIf { it.isNotEmpty() }?.let {
      defaultColorSchemeBuilder.setNavigationBarDividerColor(Color.parseColor(it))
    }
    customSettings.secondaryToolbarColor?.takeIf { it.isNotEmpty() }?.let {
      defaultColorSchemeBuilder.setSecondaryToolbarColor(Color.parseColor(it))
    }
    builder.setDefaultColorSchemeParams(defaultColorSchemeBuilder.build())

    customSettings.additionalTrustedOrigins.takeIf { it.isNotEmpty() }?.let {
      builder.setAdditionalTrustedOrigins(it)
    }

    customSettings.displayMode?.let { builder.setDisplayMode(it) }

    builder.setScreenOrientation(customSettings.screenOrientation)
  }

  private fun prepareCustomTabsIntent(trustedWebActivityIntent: TrustedWebActivityIntent) {
    val intent: Intent = trustedWebActivityIntent.intent
    val packageName = customSettings.packageName
    if (packageName != null) {
      intent.setPackage(packageName)
    } else {
      intent.setPackage(CustomTabsHelper.getPackageNameToUse(this))
    }

    if (customSettings.keepAliveEnabled) {
      CustomTabsHelper.addKeepAliveExtra(this, intent)
    }

    if (customSettings.alwaysUseBrowserUI) {
      CustomTabsIntent.setAlwaysUseBrowserUI(intent)
    }
  }

  companion object {
    protected const val LOG_TAG = "TrustedWebActivity"
  }
}
