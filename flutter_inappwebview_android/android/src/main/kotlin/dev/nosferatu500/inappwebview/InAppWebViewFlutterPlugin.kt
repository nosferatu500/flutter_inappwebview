package dev.nosferatu500.inappwebview

import android.app.Activity
import android.content.Context
import dev.nosferatu500.inappwebview.chrome_custom_tabs.ChromeSafariBrowserManager
import dev.nosferatu500.inappwebview.chrome_custom_tabs.NoHistoryCustomTabsActivityCallbacks
import dev.nosferatu500.inappwebview.credential_database.CredentialDatabaseHandler
import dev.nosferatu500.inappwebview.headless_in_app_webview.HeadlessInAppWebViewManager
import dev.nosferatu500.inappwebview.in_app_browser.InAppBrowserManager
import dev.nosferatu500.inappwebview.print_job.PrintJobManager
import dev.nosferatu500.inappwebview.process_global_config.ProcessGlobalConfigManager
import dev.nosferatu500.inappwebview.profile.ProfileStoreManager
import dev.nosferatu500.inappwebview.proxy.ProxyManager
import dev.nosferatu500.inappwebview.service_worker.ServiceWorkerManager
import dev.nosferatu500.inappwebview.tracing.TracingControllerManager
import dev.nosferatu500.inappwebview.webview.FlutterWebViewFactory
import dev.nosferatu500.inappwebview.webview.InAppWebViewManager
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformViewRegistry

class InAppWebViewFlutterPlugin : FlutterPlugin, ActivityAware {

  @JvmField var platformUtil: PlatformUtil? = null
  @JvmField var inAppBrowserManager: InAppBrowserManager? = null
  @JvmField var headlessInAppWebViewManager: HeadlessInAppWebViewManager? = null
  @JvmField var chromeSafariBrowserManager: ChromeSafariBrowserManager? = null
  @JvmField var noHistoryCustomTabsActivityCallbacks: NoHistoryCustomTabsActivityCallbacks? = null
  @JvmField var inAppWebViewManager: InAppWebViewManager? = null
  @JvmField var myCookieManager: MyCookieManager? = null
  @JvmField var credentialDatabaseHandler: CredentialDatabaseHandler? = null
  @JvmField var myWebStorage: MyWebStorage? = null
  @JvmField var serviceWorkerManager: ServiceWorkerManager? = null
  @JvmField var webViewFeatureManager: WebViewFeatureManager? = null
  @JvmField var profileStoreManager: ProfileStoreManager? = null
  @JvmField var proxyManager: ProxyManager? = null
  @JvmField var printJobManager: PrintJobManager? = null
  @JvmField var tracingControllerManager: TracingControllerManager? = null
  @JvmField var processGlobalConfigManager: ProcessGlobalConfigManager? = null

  // No @JvmField: Kotlin already exposes a lateinit property's backing field to Java directly,
  // and the two annotations are mutually exclusive.
  lateinit var flutterWebViewFactory: FlutterWebViewFactory
  lateinit var applicationContext: Context
  lateinit var messenger: BinaryMessenger
  lateinit var flutterAssets: FlutterPlugin.FlutterAssets

  @JvmField var activityPluginBinding: ActivityPluginBinding? = null
  @JvmField var activity: Activity? = null

  // Never assigned anything but null on this platform; kept because it is part of the
  // onAttachedToEngine signature below.
  @JvmField var flutterView: FlutterView? = null

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    flutterAssets = binding.flutterAssets

    // activity could be null or not.
    // It depends on who is called first between onAttachedToEngine event and onAttachedToActivity
    // event.
    //
    // See https://github.com/pichillilorenzo/flutter_inappwebview/issues/390#issuecomment-647039084
    onAttachedToEngine(
      binding.applicationContext,
      binding.binaryMessenger,
      activity,
      binding.platformViewRegistry,
      null
    )
  }

  private fun onAttachedToEngine(
    applicationContext: Context,
    messenger: BinaryMessenger,
    activity: Activity?,
    platformViewRegistry: PlatformViewRegistry,
    flutterView: FlutterView?
  ) {
    this.applicationContext = applicationContext
    this.activity = activity
    this.messenger = messenger
    this.flutterView = flutterView

    inAppBrowserManager = InAppBrowserManager(this)
    headlessInAppWebViewManager = HeadlessInAppWebViewManager(this)
    chromeSafariBrowserManager = ChromeSafariBrowserManager(this)
    noHistoryCustomTabsActivityCallbacks = NoHistoryCustomTabsActivityCallbacks(this)
    flutterWebViewFactory = FlutterWebViewFactory(this)
    platformViewRegistry.registerViewFactory(
      FlutterWebViewFactory.VIEW_TYPE_ID, flutterWebViewFactory
    )

    platformUtil = PlatformUtil(this)
    inAppWebViewManager = InAppWebViewManager(this)
    myCookieManager = MyCookieManager(this)
    myWebStorage = MyWebStorage(this)
    serviceWorkerManager = ServiceWorkerManager(this)

    credentialDatabaseHandler = CredentialDatabaseHandler(this)

    webViewFeatureManager = WebViewFeatureManager(this)
    profileStoreManager = ProfileStoreManager(this)
    proxyManager = ProxyManager(this)
    printJobManager = PrintJobManager(this)

    tracingControllerManager = TracingControllerManager(this)
    processGlobalConfigManager = ProcessGlobalConfigManager(this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    platformUtil?.dispose()
    platformUtil = null
    inAppBrowserManager?.dispose()
    inAppBrowserManager = null
    headlessInAppWebViewManager?.dispose()
    headlessInAppWebViewManager = null
    chromeSafariBrowserManager?.dispose()
    chromeSafariBrowserManager = null
    noHistoryCustomTabsActivityCallbacks?.dispose()
    noHistoryCustomTabsActivityCallbacks = null
    myCookieManager?.dispose()
    myCookieManager = null
    myWebStorage?.dispose()
    myWebStorage = null
    credentialDatabaseHandler?.dispose()
    credentialDatabaseHandler = null
    inAppWebViewManager?.dispose()
    inAppWebViewManager = null
    serviceWorkerManager?.dispose()
    serviceWorkerManager = null
    webViewFeatureManager?.dispose()
    webViewFeatureManager = null
    profileStoreManager?.dispose()
    profileStoreManager = null
    proxyManager?.dispose()
    proxyManager = null
    printJobManager?.dispose()
    printJobManager = null
    tracingControllerManager?.dispose()
    tracingControllerManager = null
    processGlobalConfigManager?.dispose()
    processGlobalConfigManager = null
  }

  override fun onAttachedToActivity(activityPluginBinding: ActivityPluginBinding) {
    this.activityPluginBinding = activityPluginBinding
    activity = activityPluginBinding.activity

    noHistoryCustomTabsActivityCallbacks?.let {
      activity?.application?.registerActivityLifecycleCallbacks(it.activityLifecycleCallbacks)
    }
  }

  override fun onDetachedFromActivityForConfigChanges() {
    noHistoryCustomTabsActivityCallbacks?.let {
      activity?.application?.unregisterActivityLifecycleCallbacks(it.activityLifecycleCallbacks)
    }

    activityPluginBinding = null
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(
    activityPluginBinding: ActivityPluginBinding
  ) {
    this.activityPluginBinding = activityPluginBinding
    activity = activityPluginBinding.activity

    noHistoryCustomTabsActivityCallbacks?.let {
      activity?.application?.registerActivityLifecycleCallbacks(it.activityLifecycleCallbacks)
    }
  }

  override fun onDetachedFromActivity() {
    noHistoryCustomTabsActivityCallbacks?.let {
      activity?.application?.unregisterActivityLifecycleCallbacks(it.activityLifecycleCallbacks)
    }

    activityPluginBinding = null
    activity = null
  }

  companion object {
    protected const val LOG_TAG = "InAppWebViewFlutterPL"
  }
}
