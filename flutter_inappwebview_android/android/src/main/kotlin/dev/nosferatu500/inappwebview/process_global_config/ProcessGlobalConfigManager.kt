package dev.nosferatu500.inappwebview.process_global_config

import androidx.webkit.ProcessGlobalConfig
import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import dev.nosferatu500.inappwebview.pigeons.ProcessGlobalConfigHostApi
import dev.nosferatu500.inappwebview.pigeons.ProcessGlobalConfigSettingsData
import dev.nosferatu500.inappwebview.types.Disposable
import io.flutter.plugin.common.BinaryMessenger

/**
 * Transport is Pigeon-generated ([ProcessGlobalConfigHostApi]) rather than a hand-written
 * `MethodChannel`; this is the second channel migrated, after find_interaction (§14).
 *
 * There is no `messageChannelSuffix`: `ProcessGlobalConfig.apply` is process-global and androidx
 * permits it only once per process, so there is one channel rather than one per WebView.
 *
 * The `Map<String, Any?>` parse step is gone with the hand-written channel. That removes the
 * class's whole reason for the `@Suppress("UNCHECKED_CAST")` it used to carry: the generated
 * [ProcessGlobalConfigSettingsData] arrives typed, so a wrong shape is now a codec error at the
 * boundary rather than a `ClassCastException` deep inside `parse`.
 */
class ProcessGlobalConfigManager(plugin: InAppWebViewFlutterPlugin) :
  Disposable, ProcessGlobalConfigHostApi {

  @JvmField
  var plugin: InAppWebViewFlutterPlugin? = plugin

  private var messenger: BinaryMessenger? = plugin.messenger

  init {
    ProcessGlobalConfigHostApi.setUp(plugin.messenger, this)
  }

  /**
   * Returns false when there is no activity to apply the config against, and throws when androidx
   * rejects it — most often because it has already been applied once in this process.
   *
   * The `false` case matches the hand-written channel exactly. The throwing case does not, and it
   * is an improvement rather than a regression: the old branch was
   * `result.error(LOG_TAG, "", e)` with `e` a raw `Exception`, and `StandardMessageCodec.writeValue`
   * throws `IllegalArgumentException("Unsupported value: …")` for any type it does not know — so
   * that error envelope could never be encoded and the error never reached Dart as written.
   * Pigeon's `wrapError` stringifies instead, so the failure is now actually delivered.
   */
  override fun apply(settings: ProcessGlobalConfigSettingsData): Boolean {
    val activity = plugin?.activity ?: return false
    val parsed = ProcessGlobalConfigSettings().apply {
      dataDirectorySuffix = settings.dataDirectorySuffix
      directoryBasePaths = settings.directoryBasePaths?.let {
        ProcessGlobalConfigSettings.DirectoryBasePaths().apply {
          dataDirectoryBasePath = it.dataDirectoryBasePath
          cacheDirectoryBasePath = it.cacheDirectoryBasePath
        }
      }
    }
    ProcessGlobalConfig.apply(parsed.toProcessGlobalConfig(activity))
    return true
  }

  override fun dispose() {
    // Unregisters the generated handler. Skipping it would leave it bound to a disposed manager
    // for the life of the messenger.
    messenger?.let { ProcessGlobalConfigHostApi.setUp(it, null) }
    messenger = null
    plugin = null
  }
}
