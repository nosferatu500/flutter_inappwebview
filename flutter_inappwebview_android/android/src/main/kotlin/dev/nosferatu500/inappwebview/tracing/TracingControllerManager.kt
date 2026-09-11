package dev.nosferatu500.inappwebview.tracing

import androidx.webkit.TracingConfig
import androidx.webkit.TracingController
import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import dev.nosferatu500.inappwebview.pigeons.TracingControllerHostApi
import dev.nosferatu500.inappwebview.pigeons.TracingSettingsData
import dev.nosferatu500.inappwebview.types.Disposable
import io.flutter.plugin.common.BinaryMessenger
import java.io.FileNotFoundException
import java.io.FileOutputStream
import java.util.concurrent.Executors

/**
 * Transport is Pigeon-generated ([TracingControllerHostApi]) rather than a hand-written
 * `MethodChannel`; the fifth channel migrated, after find_interaction (§14),
 * process_global_config (§157), proxy (§160) and webview_feature (§161).
 *
 * There is no `messageChannelSuffix`: androidx's `TracingController` is a process-wide singleton,
 * so there is one channel rather than one per WebView.
 *
 * `TracingControllerChannelDelegate` is folded in here — the generated interface *is* the
 * dispatcher, so a separate delegate object had nothing left to do. `TracingSettings` went with it:
 * the `Map<String, Any?>` parse step is replaced by the typed [TracingSettingsData], and its
 * `getRealSettings` had no caller. Both class-level `@Suppress("UNCHECKED_CAST")` annotations are
 * gone with the casts they covered.
 *
 * **No method is `@async`.** All three androidx calls return synchronously; `stop` takes an
 * `Executor` but returns `boolean` immediately and signals completion through no callback at all.
 * See the schema header.
 */
class TracingControllerManager(plugin: InAppWebViewFlutterPlugin) :
  Disposable, TracingControllerHostApi {

  @JvmField
  var plugin: InAppWebViewFlutterPlugin? = plugin

  private var messenger: BinaryMessenger? = plugin.messenger

  init {
    TracingControllerHostApi.setUp(plugin.messenger, this)
  }

  override fun isTracing(): Boolean = tracingController()?.isTracing ?: false

  override fun start(settings: TracingSettingsData): Boolean {
    val controller = supportedTracingController() ?: return false
    controller.start(buildTracingConfig(settings))
    return true
  }

  /**
   * Returns androidx's own answer: false if the framework was not tracing when called.
   *
   * The trace is written *after* this returns, on the executor below, so a true here does not mean
   * the file is complete — see the schema. A [FileNotFoundException] from opening [filePath] is
   * reported as false, which is what the hand-written channel did.
   */
  override fun stop(filePath: String?): Boolean {
    val controller = supportedTracingController() ?: return false
    return try {
      controller.stop(
        if (filePath != null) FileOutputStream(filePath) else null,
        Executors.newSingleThreadExecutor()
      )
    } catch (e: FileNotFoundException) {
      e.printStackTrace()
      false
    }
  }

  override fun dispose() {
    // Unregisters the generated handler. Skipping it would leave it bound to a disposed manager
    // for the life of the messenger.
    messenger?.let { TracingControllerHostApi.setUp(it, null) }
    messenger = null
    plugin = null
  }

  companion object {
    private var cachedTracingController: TracingController? = null

    /**
     * Resolved lazily on first use, as the hand-written channel did by calling `init()` at the top
     * of every dispatch. `TracingController.getInstance()` requires the feature, so the support
     * check has to come first.
     *
     * Was a public mutable `@JvmField` static plus a public `init()`; nothing outside this class
     * ever touched either, so both are private now.
     */
    private fun tracingController(): TracingController? {
      if (cachedTracingController == null &&
        WebViewFeature.isFeatureSupported(WebViewFeature.TRACING_CONTROLLER_BASIC_USAGE)
      ) {
        cachedTracingController = TracingController.getInstance()
      }
      return cachedTracingController
    }

    /**
     * The controller, but only while the feature is still reported as supported.
     *
     * `start` and `stop` re-checked `isFeatureSupported` on every call where `isTracing` did not,
     * and that asymmetry is preserved rather than tidied: the check is cheap and a WebView provider
     * can be swapped underneath a running process, so the mutating calls keep their guard.
     */
    private fun supportedTracingController(): TracingController? {
      val controller = tracingController() ?: return null
      return if (
        WebViewFeature.isFeatureSupported(WebViewFeature.TRACING_CONTROLLER_BASIC_USAGE)
      ) {
        controller
      } else {
        null
      }
    }

    /**
     * Builds the androidx config from the typed settings.
     *
     * The two `addCategories` calls are **different overloads** — `String...` for name patterns,
     * `int...` for the predefined `TracingConfig.CATEGORIES_*` constants. The hand-written path
     * received one heterogeneous `List<Any?>` and sorted the elements out with `is` checks, which
     * silently dropped anything that was neither; the schema's two typed lists make that
     * unrepresentable.
     *
     * **The `Long` -> `Int` narrowing is required, not incidental.** Pigeon maps Dart's `int` to
     * Kotlin `Long`, while androidx's `addCategories(int...)` and `setTracingMode(int)` take
     * `int` -- so the generated `List<Long>` and `Long?` have to be narrowed here. The
     * hand-written channel never met this because `StandardMessageCodec` had already decoded the
     * values to `Integer`. Every value in flight is a `TracingConfig.CATEGORIES_*` constant or a
     * `TracingMode`, all small ints, so the narrowing cannot lose information.
     *
     * **The predefined categories are added one at a time on purpose.** Spreading them into the
     * vararg (`addCategories(*array)`) is what you would write, and it fails `lintDebug` with
     * `WrongConstant`: the parameter is annotated `@TracingConfig.PredefinedCategories`, an
     * `@IntDef`, and lint cannot see that a runtime array holds those constants. The loop is
     * **behaviourally identical** rather than a workaround -- the annotation is declared
     * `@IntDef(flag = true)` and the builder accumulates with
     * `mPredefinedCategories |= categorySet`, so N single-argument calls OR together to exactly
     * what one N-argument call produces. It is also the shape the hand-written channel used, which
     * is why lint was clean before.
     */
    private fun buildTracingConfig(settings: TracingSettingsData): TracingConfig {
      val builder = TracingConfig.Builder()
      if (settings.categoryNames.isNotEmpty()) {
        builder.addCategories(*settings.categoryNames.toTypedArray())
      }
      for (predefinedCategory in settings.predefinedCategories) {
        builder.addCategories(predefinedCategory.toInt())
      }
      settings.tracingMode?.let { builder.setTracingMode(it.toInt()) }
      return builder.build()
    }
  }
}
