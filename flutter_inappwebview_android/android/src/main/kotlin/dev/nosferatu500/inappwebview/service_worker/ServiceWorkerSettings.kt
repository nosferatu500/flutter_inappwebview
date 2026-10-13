package dev.nosferatu500.inappwebview.service_worker

import androidx.webkit.ServiceWorkerWebSettingsCompat
import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.Util

/**
 * The service-worker settings the plugin exposes, over whichever API can reach them.
 *
 * Four of them exist on both APIs. The fifth,
 * `includeCookiesOnShouldInterceptRequestEnabled`, is **androidx-only**: `android.jar`'s
 * `android.webkit.ServiceWorkerWebSettings` declares exactly the other four and nothing else
 * (checked with `javap`, which is what a stub jar *is* authoritative about -- trap 68). So it is
 * unavailable for a named profile, structurally rather than by version, and
 * [FrameworkServiceWorkerSettings] answers null / no-ops for it.
 *
 * Two APIs provide the same four settings and share no supertype, and which one applies is not a
 * choice:
 *  - the **default** profile is reachable through androidx's [ServiceWorkerWebSettingsCompat];
 *  - a **named** profile is only reachable through the framework's
 *    `android.webkit.ServiceWorkerWebSettings`, because `Profile.getServiceWorkerController()`
 *    returns the framework `ServiceWorkerController` and `ServiceWorkerControllerCompat` offers
 *    nothing but `getInstance()` -- there is no compat wrapper for a profile's controller.
 *
 * Availability rules therefore differ per API and live here rather than in the channel delegate, so
 * the delegate stays one branch per method:
 *  - the compat implementation keeps the per-setting `WebViewFeature` gates it has always had, and
 *    reports null / no-ops when the WebView provider lacks them;
 *  - the framework implementation has no gates, because `ServiceWorkerWebSettings` is API 24 and
 *    this module's minSdk is 30. Applying the *compat* feature flags to framework calls would skip
 *    work that would in fact succeed -- those flags describe the support library's surface, not the
 *    framework's.
 *
 * A null getter means "not available"; the matching setter is then a no-op.
 */
internal interface ServiceWorkerSettings {
  fun getAllowContentAccess(): Boolean?

  fun setAllowContentAccess(value: Boolean)

  fun getAllowFileAccess(): Boolean?

  fun setAllowFileAccess(value: Boolean)

  fun getBlockNetworkLoads(): Boolean?

  fun setBlockNetworkLoads(value: Boolean)

  fun getCacheMode(): Int?

  fun setCacheMode(value: Int)

  /** Null when unreachable: feature unsupported, or a named profile (see the class doc). */
  fun getIncludeCookiesOnShouldInterceptRequestEnabled(): Boolean?

  fun setIncludeCookiesOnShouldInterceptRequestEnabled(value: Boolean)
}

/** Backed by androidx, for the default profile. Preserves the pre-existing feature gating. */
internal class CompatServiceWorkerSettings(
  private val settings: ServiceWorkerWebSettingsCompat
) : ServiceWorkerSettings {

  override fun getAllowContentAccess(): Boolean? =
    if (supported(WebViewFeature.SERVICE_WORKER_CONTENT_ACCESS)) {
      settings.allowContentAccess
    } else {
      null
    }

  override fun setAllowContentAccess(value: Boolean) {
    if (supported(WebViewFeature.SERVICE_WORKER_CONTENT_ACCESS)) {
      settings.allowContentAccess = value
    }
  }

  override fun getAllowFileAccess(): Boolean? =
    if (supported(WebViewFeature.SERVICE_WORKER_FILE_ACCESS)) {
      settings.allowFileAccess
    } else {
      null
    }

  override fun setAllowFileAccess(value: Boolean) {
    if (supported(WebViewFeature.SERVICE_WORKER_FILE_ACCESS)) {
      settings.allowFileAccess = value
    }
  }

  override fun getBlockNetworkLoads(): Boolean? =
    if (supported(WebViewFeature.SERVICE_WORKER_BLOCK_NETWORK_LOADS)) {
      settings.blockNetworkLoads
    } else {
      null
    }

  override fun setBlockNetworkLoads(value: Boolean) {
    if (supported(WebViewFeature.SERVICE_WORKER_BLOCK_NETWORK_LOADS)) {
      settings.blockNetworkLoads = value
    }
  }

  override fun getCacheMode(): Int? =
    if (supported(WebViewFeature.SERVICE_WORKER_CACHE_MODE)) settings.cacheMode else null

  override fun setCacheMode(value: Int) {
    if (supported(WebViewFeature.SERVICE_WORKER_CACHE_MODE)) {
      settings.cacheMode = value
    }
  }

  override fun getIncludeCookiesOnShouldInterceptRequestEnabled(): Boolean? =
    if (Util.isCookieInterceptSupported()) {
      settings.isIncludeCookiesOnShouldInterceptRequestEnabled
    } else {
      null
    }

  override fun setIncludeCookiesOnShouldInterceptRequestEnabled(value: Boolean) {
    if (Util.isCookieInterceptSupported()) {
      settings.setIncludeCookiesOnShouldInterceptRequestEnabled(value)
    }
  }

  // COOKIE_INTERCEPT is NOT routed through this helper: androidx omits it from the @StringDef on
  // isFeatureSupported, so lint rejects the call. Util.isCookieInterceptSupported() holds that
  // suppression for the whole module.
  private fun supported(feature: String) = WebViewFeature.isFeatureSupported(feature)
}

/** Backed by the framework, the only way to reach a named profile's service worker settings. */
internal class FrameworkServiceWorkerSettings(
  private val settings: android.webkit.ServiceWorkerWebSettings
) : ServiceWorkerSettings {

  override fun getAllowContentAccess(): Boolean = settings.allowContentAccess

  override fun setAllowContentAccess(value: Boolean) {
    settings.allowContentAccess = value
  }

  override fun getAllowFileAccess(): Boolean = settings.allowFileAccess

  override fun setAllowFileAccess(value: Boolean) {
    settings.allowFileAccess = value
  }

  override fun getBlockNetworkLoads(): Boolean = settings.blockNetworkLoads

  override fun setBlockNetworkLoads(value: Boolean) {
    settings.blockNetworkLoads = value
  }

  override fun getCacheMode(): Int = settings.cacheMode

  override fun setCacheMode(value: Int) {
    settings.cacheMode = value
  }

  /**
   * Always null: the framework `ServiceWorkerWebSettings` has no cookie-intercept method at all.
   * This is not a version gate that a newer device would open -- there is nothing to call.
   */
  override fun getIncludeCookiesOnShouldInterceptRequestEnabled(): Boolean? = null

  /** No-op, per the class doc's "a null getter means the matching setter is a no-op". */
  override fun setIncludeCookiesOnShouldInterceptRequestEnabled(value: Boolean) {
    // Intentionally empty; see getIncludeCookiesOnShouldInterceptRequestEnabled.
  }
}
