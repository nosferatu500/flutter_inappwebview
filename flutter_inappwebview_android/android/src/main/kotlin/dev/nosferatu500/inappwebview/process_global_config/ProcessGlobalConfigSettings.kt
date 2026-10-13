package dev.nosferatu500.inappwebview.process_global_config

import android.content.Context
import androidx.webkit.ProcessGlobalConfig
import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.ISettings
import java.io.File

// The unchecked cast below is the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode.
@Suppress("UNCHECKED_CAST")
class ProcessGlobalConfigSettings : ISettings<ProcessGlobalConfig> {

  @JvmField
  var dataDirectorySuffix: String? = null

  @JvmField
  var directoryBasePaths: DirectoryBasePaths? = null

  override fun parse(settings: Map<String, Any?>): ProcessGlobalConfigSettings {
    for ((key, value) in settings) {
      if (value == null) {
        continue
      }
      when (key) {
        "dataDirectorySuffix" -> dataDirectorySuffix = value as String
        "directoryBasePaths" ->
          directoryBasePaths = DirectoryBasePaths().parse(value as Map<String, Any?>)
      }
    }
    return this
  }

  fun toProcessGlobalConfig(context: Context): ProcessGlobalConfig {
    val config = ProcessGlobalConfig()
    val suffix = dataDirectorySuffix
    if (suffix != null && WebViewFeature.isStartupFeatureSupported(
        context, WebViewFeature.STARTUP_FEATURE_SET_DATA_DIRECTORY_SUFFIX
      )
    ) {
      config.setDataDirectorySuffix(context, suffix)
    }
    val basePaths = directoryBasePaths
    if (basePaths != null && WebViewFeature.isStartupFeatureSupported(
        context, WebViewFeature.STARTUP_FEATURE_SET_DIRECTORY_BASE_PATHS
      )
    ) {
      applyDirectoryBasePaths(config, context, basePaths)
    }
    return config
  }

  override fun toMap(): MutableMap<String, Any?> = hashMapOf(
    "dataDirectorySuffix" to dataDirectorySuffix
  )

  override fun getRealSettings(obj: ProcessGlobalConfig): MutableMap<String, Any?> = toMap()

  class DirectoryBasePaths : ISettings<Any> {
    @JvmField
    var cacheDirectoryBasePath: String? = null

    @JvmField
    var dataDirectoryBasePath: String? = null

    override fun parse(settings: Map<String, Any?>): DirectoryBasePaths {
      for ((key, value) in settings) {
        if (value == null) {
          continue
        }
        when (key) {
          "cacheDirectoryBasePath" -> cacheDirectoryBasePath = value as String
          "dataDirectoryBasePath" -> dataDirectoryBasePath = value as String
        }
      }
      return this
    }

    override fun toMap(): MutableMap<String, Any?> = hashMapOf(
      "cacheDirectoryBasePath" to cacheDirectoryBasePath,
      "dataDirectoryBasePath" to dataDirectoryBasePath
    )

    override fun getRealSettings(obj: Any): MutableMap<String, Any?> = toMap()

    companion object {
      const val LOG_TAG = "ProcessGlobalConfigSettings"
    }
  }

  companion object {
    const val LOG_TAG = "ProcessGlobalConfigSettings"

    // ProcessGlobalConfig.setDirectoryBasePaths is deprecated in androidx.webkit 1.17.0 but has no
    // successor: verified by javap over the 1.17.0 AAR, the class stores mDataDirectoryBasePath and
    // mCacheDirectoryBasePath yet exposes no other public setter for them, and none of the
    // 1.13-1.17 release notes mention it. It is not marked for removal. Removing it would drop a
    // capability with no alternative, so it is kept. Re-check on the next androidx.webkit bump.
    @Suppress("DEPRECATION")
    private fun applyDirectoryBasePaths(
      config: ProcessGlobalConfig,
      context: Context,
      basePaths: DirectoryBasePaths
    ) {
      config.setDirectoryBasePaths(
        context,
        File(basePaths.dataDirectoryBasePath!!),
        File(basePaths.cacheDirectoryBasePath!!)
      )
    }
  }
}
