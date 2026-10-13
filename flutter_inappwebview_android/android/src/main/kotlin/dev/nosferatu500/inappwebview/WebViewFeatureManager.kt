package dev.nosferatu500.inappwebview

import android.content.Context
import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.pigeons.WebViewFeatureHostApi
import dev.nosferatu500.inappwebview.types.Disposable
import io.flutter.plugin.common.BinaryMessenger

/**
 * Transport is Pigeon-generated ([WebViewFeatureHostApi]) rather than a hand-written
 * `MethodChannel`; the fourth channel migrated, after find_interaction (§14),
 * process_global_config (§157) and proxy (§160).
 *
 * Neither method is `@async`: both androidx entry points return `boolean` directly, with no
 * `Executor` and no completion callback. Checked against the androidx sources rather than assumed,
 * which is the step §160 added to the template.
 */
class WebViewFeatureManager(plugin: InAppWebViewFlutterPlugin) :
  Disposable, WebViewFeatureHostApi {

  @JvmField
  var plugin: InAppWebViewFlutterPlugin? = plugin

  private var messenger: BinaryMessenger? = plugin.messenger

  /**
   * The **application** context, captured up front.
   *
   * Held directly rather than read from `plugin` on each call so that
   * [isStartupFeatureSupported] cannot depend on plugin state that may have been torn down, and
   * so the `lateinit` is touched once, during construction, when it is guaranteed to be set.
   */
  private var applicationContext: Context? = plugin.applicationContext

  init {
    WebViewFeatureHostApi.setUp(plugin.messenger, this)
  }

  override fun isFeatureSupported(feature: String): Boolean =
    WebViewFeature.isFeatureSupported(feature)

  /**
   * Answers from the application context.
   *
   * The hand-written channel read `plugin?.activity` and, when that was null, returned **without
   * calling `result`** — leaving the Dart future pending forever rather than failing. The activity
   * is null before `onAttachedToActivity` and again after
   * `onDetachedFromActivityForConfigChanges`, so that path was reachable.
   *
   * The application context is the right argument, not just a non-null one: androidx documents the
   * parameter as "a Context to access application assets", and `StartupApiFeature` uses it only for
   * `getPackageManager()` and `WebViewCompat.getCurrentWebViewPackage(context)` — package-manager
   * lookups that an application context serves exactly as well as an Activity.
   *
   * Returns false only after [dispose], when there is no context left to ask with; a disposed
   * manager should no longer be receiving calls at all, since [dispose] unregisters the handler.
   */
  override fun isStartupFeatureSupported(startupFeature: String): Boolean {
    val context = applicationContext ?: return false
    return WebViewFeature.isStartupFeatureSupported(context, startupFeature)
  }

  override fun dispose() {
    // Unregisters the generated handler. Skipping it would leave it bound to a disposed manager
    // for the life of the messenger.
    messenger?.let { WebViewFeatureHostApi.setUp(it, null) }
    messenger = null
    applicationContext = null
    plugin = null
  }
}
