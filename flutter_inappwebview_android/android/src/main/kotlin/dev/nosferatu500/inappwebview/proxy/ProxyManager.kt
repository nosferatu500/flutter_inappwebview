package dev.nosferatu500.inappwebview.proxy

import androidx.webkit.ProxyConfig
import androidx.webkit.ProxyController
import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import dev.nosferatu500.inappwebview.pigeons.ProxyHostApi
import dev.nosferatu500.inappwebview.pigeons.ProxySettingsData
import dev.nosferatu500.inappwebview.types.Disposable
import dev.nosferatu500.inappwebview.types.replyingOnThrow
import io.flutter.plugin.common.BinaryMessenger
import java.util.concurrent.Executor

/**
 * Transport is Pigeon-generated ([ProxyHostApi]) rather than a hand-written `MethodChannel`; this
 * is the third channel migrated, after find_interaction (§14) and process_global_config (§157).
 *
 * There is no `messageChannelSuffix`: androidx's `ProxyController` is a process-wide singleton, so
 * there is one channel rather than one per WebView.
 *
 * Both methods are `@async` in the schema because the androidx calls are: they take an `Executor`
 * plus a completion callback. A synchronous Pigeon method would have to return before that callback
 * could run, so `await` on the Dart side would resolve while the proxy was not yet in effect.
 *
 * The `Map<String, Any?>` parse step is gone with the hand-written channel, and with it the
 * class-level `@Suppress("UNCHECKED_CAST")` it existed for: [ProxySettingsData] arrives typed, so a
 * wrong shape is a codec error at the boundary rather than a `ClassCastException` inside a parse
 * routine. `ProxySettings` and `ProxyRuleExt` were left with no callers and are deleted.
 */
class ProxyManager(plugin: InAppWebViewFlutterPlugin) : Disposable, ProxyHostApi {

  @JvmField
  var plugin: InAppWebViewFlutterPlugin? = plugin

  private var messenger: BinaryMessenger? = plugin.messenger

  init {
    ProxyHostApi.setUp(plugin.messenger, this)
  }

  /**
   * Answers `false` when androidx does not support `PROXY_OVERRIDE`, matching the hand-written
   * channel exactly. The Dart side discards the bool — see the schema for why it stays on the wire.
   */
  override fun setProxyOverride(
    settings: ProxySettingsData,
    callback: (Result<Boolean>) -> Unit
  ) {
    val controller = proxyController()
    if (controller == null) {
      callback(Result.success(false))
      return
    }

    // 🚨 **A malformed rule raises `IllegalArgumentException` synchronously, and this is an
    // `@async` host method, so it has to be delivered through [callback] rather than thrown.**
    //
    // Pigeon's generated handlers are not symmetric: a *synchronous* one is wrapped in
    // `try { … } catch (Throwable) { wrapError(…) }`, an `@async` one is a bare
    // `api.method(args) { result -> … }` with no `try`/`catch`. A throw escapes into
    // `BasicMessageChannel`, which logs "Failed to handle message" and replies **null**, so the Dart
    // caller sees `PlatformException(channel-error, "Unable to establish connection on channel…")`
    // -- an error naming the transport rather than the rule that caused it. §170 found the same
    // shape in `MyWebStorage.deleteBrowsingDataForSite`.
    //
    // **Where the validation happens was measured, and the obvious reading is wrong.** It is natural
    // to assume `ProxyConfig.Builder.addProxyRule` validates, and to guard only the build -- a guard
    // that catches nothing, because the device stack trace puts the throw in Chromium underneath the
    // *controller* call:
    //
    //     java.lang.IllegalArgumentException: Invalid Proxy URL: ://
    //       at org.chromium.android_webview.AwProxyController.a(…)
    //       at androidx.webkit.internal.ProxyControllerImpl.setProxyOverride(ProxyControllerImpl.java:47)
    //       at dev.nosferatu500.inappwebview.proxy.ProxyManager.setProxyOverride(…)
    //
    // So `controller.setProxyOverride` is inside the guard too. The guard's idempotent `reply`
    // covers the ordering that makes excluding it tempting: `DIRECT_EXECUTOR` runs the completion
    // inline, so a throw *after* androidx has already invoked it would otherwise produce a second
    // reply -- which `AsyncReplyTest` pins.
    //
    // [replyingOnThrow] rather than a local try/catch: it is shared by every `@async` method in this
    // module and unit-tested in `AsyncReplyTest`, which is what makes the guard reviewable where
    // the call site itself cannot produce a throw on demand.
    replyingOnThrow(LOG_TAG, callback) { reply ->
      val builder = ProxyConfig.Builder()
      settings.bypassRules.forEach { builder.addBypassRule(it) }
      settings.directs.forEach { builder.addDirect(it) }
      settings.proxyRules.forEach { rule ->
        val schemeFilter = rule.schemeFilter
        if (schemeFilter != null) {
          builder.addProxyRule(rule.url, schemeFilter)
        } else {
          builder.addProxyRule(rule.url)
        }
      }
      // Builder calls with no inverse, so only `true` may invoke them -- null and false both mean
      // "leave it alone". This is why the two fields stay nullable in the schema.
      if (settings.bypassSimpleHostnames == true) {
        builder.bypassSimpleHostnames()
      }
      if (settings.removeImplicitRules == true) {
        builder.removeImplicitRules()
      }
      // The old code also tested `reverseBypassEnabled != null`. The field is non-null in the schema
      // (the platform interface defaults it to false and Dart could never send null), so that test
      // could not fail and is gone.
      if (WebViewFeature.isFeatureSupported(WebViewFeature.PROXY_OVERRIDE_REVERSE_BYPASS)) {
        builder.setReverseBypassEnabled(settings.reverseBypassEnabled)
      }
      controller.setProxyOverride(builder.build(), DIRECT_EXECUTOR) {
        reply(Result.success(true))
      }
    }
  }

  override fun clearProxyOverride(callback: (Result<Boolean>) -> Unit) {
    val controller = proxyController()
    if (controller == null) {
      callback(Result.success(false))
      return
    }
    replyingOnThrow(LOG_TAG, callback) { reply ->
      controller.clearProxyOverride(DIRECT_EXECUTOR) { reply(Result.success(true)) }
    }
  }

  override fun dispose() {
    // Unregisters the generated handler. Skipping it would leave it bound to a disposed manager
    // for the life of the messenger.
    messenger?.let { ProxyHostApi.setUp(it, null) }
    messenger = null
    plugin = null
  }

  companion object {
    private const val LOG_TAG = "ProxyManager"

    /**
     * Runs the completion callback on the calling thread, which is the behaviour the hand-written
     * channel had.
     */
    private val DIRECT_EXECUTOR = Executor { command -> command.run() }

    private var cachedProxyController: ProxyController? = null

    /**
     * Resolved lazily on first use, as the hand-written channel did by calling `init()` at the top
     * of every dispatch. `ProxyController.getInstance()` throws when the feature is unsupported, so
     * the support check has to come first and a null return is the "unsupported" signal both
     * methods above turn into `false`.
     *
     * Was a public mutable `@JvmField` static plus a public `init()`; nothing outside this class
     * ever touched either, so both are private now.
     */
    private fun proxyController(): ProxyController? {
      if (cachedProxyController == null &&
        WebViewFeature.isFeatureSupported(WebViewFeature.PROXY_OVERRIDE)
      ) {
        cachedProxyController = ProxyController.getInstance()
      }
      return cachedProxyController
    }
  }
}
