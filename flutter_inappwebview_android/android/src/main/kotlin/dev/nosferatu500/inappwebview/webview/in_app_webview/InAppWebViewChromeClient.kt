package dev.nosferatu500.inappwebview.webview.in_app_webview

import android.Manifest
import android.app.Activity
import android.content.DialogInterface
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.net.Uri
import android.os.Environment
import android.os.Message
import android.os.Parcelable
import android.provider.MediaStore
import android.util.Log
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.webkit.ConsoleMessage
import android.webkit.GeolocationPermissions
import android.webkit.JsPromptResult
import android.webkit.JsResult
import android.webkit.MimeTypeMap
import android.webkit.PermissionRequest
import android.webkit.ValueCallback
import android.webkit.WebChromeClient
import android.webkit.WebView
import android.widget.EditText
import android.widget.FrameLayout
import android.widget.LinearLayout
import androidx.appcompat.app.AlertDialog
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import androidx.core.view.ViewCompat
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import dev.nosferatu500.inappwebview.InAppWebViewFileProvider
import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import dev.nosferatu500.inappwebview.in_app_browser.ActivityResultListener
import dev.nosferatu500.inappwebview.in_app_browser.InAppBrowserDelegate
import dev.nosferatu500.inappwebview.types.CreateWindowAction
import dev.nosferatu500.inappwebview.types.GeolocationPermissionShowPromptResponse
import dev.nosferatu500.inappwebview.types.JsAlertResponse
import dev.nosferatu500.inappwebview.types.JsBeforeUnloadResponse
import dev.nosferatu500.inappwebview.types.JsConfirmResponse
import dev.nosferatu500.inappwebview.types.JsPromptResponse
import dev.nosferatu500.inappwebview.types.PermissionResponse
import dev.nosferatu500.inappwebview.types.ShowFileChooserRequest
import dev.nosferatu500.inappwebview.types.ShowFileChooserResponse
import dev.nosferatu500.inappwebview.types.URLRequest
import dev.nosferatu500.inappwebview.webview.WebViewChannelDelegate
import io.flutter.plugin.common.PluginRegistry
import java.io.File
import java.io.IOException
import java.util.Locale

// The unchecked casts below are the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode. Suppressed at class level because the whole class is that boundary.
//
// See ChannelDelegateImpl: `this` is published to a platform-thread-only dispatcher.
@Suppress("UNCHECKED_CAST")
class InAppWebViewChromeClient(
  plugin: InAppWebViewFlutterPlugin,
  inAppWebView: InAppWebView,
  inAppBrowserDelegate: InAppBrowserDelegate?
) : WebChromeClient(), PluginRegistry.ActivityResultListener, ActivityResultListener {

  private var inAppBrowserDelegate: InAppBrowserDelegate? = inAppBrowserDelegate

  private val DEFAULT_MIME_TYPES = "*/*"
  private val dialogs: MutableMap<DialogInterface, JsResult> = HashMap()

  private var mCustomView: View? = null
  private var mCustomViewCallback: CustomViewCallback? = null
  private var mOriginalOrientation = 0
  private var mOriginalSystemBarsBehavior = 0
  private var mOriginalSystemBarsVisible = false

  @JvmField
  var plugin: InAppWebViewFlutterPlugin? = plugin

  @JvmField
  var inAppWebView: InAppWebView? = inAppWebView

  private var filePathCallbackLegacy: ValueCallback<Uri?>? = null
  private var filePathCallback: ValueCallback<Array<Uri>?>? = null
  private var videoOutputFileUri: Uri? = null
  private var imageOutputFileUri: Uri? = null

  init {
    inAppBrowserDelegate?.getActivityResultListeners()?.add(this)
    plugin.activityPluginBinding?.addActivityResultListener(this)
  }

  override fun getDefaultVideoPoster(): Bitmap? {
    val data = inAppWebView?.customSettings?.defaultVideoPoster
    if (data != null) {
      val bitmapOptions = BitmapFactory.Options()
      bitmapOptions.inMutable = true
      return BitmapFactory.decodeByteArray(data, 0, data.size, bitmapOptions)
    }
    return Bitmap.createBitmap(50, 50, Bitmap.Config.ARGB_8888)
  }

  override fun onHideCustomView() {
    val activity = getActivity() ?: return

    val decorView = getRootView() ?: return
    mCustomView?.let { decorView.removeView(it) }
    mCustomView = null
    val insetsController = WindowCompat.getInsetsController(activity.window, decorView)
    insetsController.systemBarsBehavior = mOriginalSystemBarsBehavior
    if (mOriginalSystemBarsVisible) {
      insetsController.show(WindowInsetsCompat.Type.systemBars())
    }
    activity.requestedOrientation = mOriginalOrientation
    mCustomViewCallback?.onCustomViewHidden()
    mCustomViewCallback = null
    activity.window.clearFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS)

    inAppWebView?.let { webView ->
      webView.channelDelegate?.onExitFullscreen()
      webView.setInFullscreen(false)
    }
  }

  override fun onShowCustomView(paramView: View?, paramCustomViewCallback: CustomViewCallback?) {
    if (mCustomView != null) {
      onHideCustomView()
      return
    }

    val activity = getActivity() ?: return

    val decorView = getRootView() ?: return
    mCustomView = paramView
    val insetsController = WindowCompat.getInsetsController(activity.window, decorView)
    val rootInsets = ViewCompat.getRootWindowInsets(decorView)
    mOriginalSystemBarsVisible =
      rootInsets == null || rootInsets.isVisible(WindowInsetsCompat.Type.systemBars())
    mOriginalSystemBarsBehavior = insetsController.systemBarsBehavior
    mOriginalOrientation = activity.requestedOrientation
    mCustomViewCallback = paramCustomViewCallback
    mCustomView?.setBackgroundColor(Color.BLACK)

    // Immersive-sticky fullscreen. Replaces the SYSTEM_UI_FLAG_FULLSCREEN | _HIDE_NAVIGATION |
    // _IMMERSIVE | _IMMERSIVE_STICKY bits of the old bitmask. The SYSTEM_UI_FLAG_LAYOUT_* bits it
    // also carried are covered by FLAG_LAYOUT_NO_LIMITS below, which is already set here and
    // cleared in onHideCustomView. The window's decorFitsSystemWindows state is deliberately left
    // untouched: the host activity may legitimately own it (InAppBrowserActivity sets it false for
    // its whole lifetime), and there is no getter to restore a previous value from.
    insetsController.systemBarsBehavior =
      WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
    insetsController.hide(WindowInsetsCompat.Type.systemBars())

    activity.window.setFlags(
      WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
      WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
    )
    decorView.addView(mCustomView, FULLSCREEN_LAYOUT_PARAMS)

    inAppWebView?.let { webView ->
      webView.channelDelegate?.onEnterFullscreen()
      webView.setInFullscreen(true)
    }
  }

  override fun onJsAlert(
    view: WebView,
    url: String?,
    message: String?,
    jsResult: JsResult
  ): Boolean {
    val channelDelegate = inAppWebView?.channelDelegate ?: return false

    channelDelegate.onJsAlert(
      url, message, null,
      object : WebViewChannelDelegate.JsAlertCallback() {
        override fun nonNullSuccess(result: JsAlertResponse): Boolean {
          if (result.isHandledByClient) {
            when (result.action ?: 1) {
              0 -> jsResult.confirm()
              else -> jsResult.cancel()
            }
            return false
          }
          return true
        }

        override fun defaultBehaviour(result: JsAlertResponse?) {
          createAlertDialog(message, jsResult, result?.message, result?.confirmButtonTitle)
        }

        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
          Log.e(LOG_TAG, errorCode + ", " + (errorMessage ?: ""))
          jsResult.cancel()
        }
      }
    )

    return true
  }

  fun createAlertDialog(
    message: String?,
    result: JsResult,
    responseMessage: String?,
    confirmButtonTitle: String?
  ) {
    val alertMessage = if (!responseMessage.isNullOrEmpty()) responseMessage else message

    val clickListener = DialogInterface.OnClickListener { dialog, _ ->
      result.confirm()
      dialog.dismiss()
      dialogs.remove(dialog)
    }

    val activity = getActivity() ?: return

    val alertDialogBuilder =
      AlertDialog.Builder(activity, androidx.appcompat.R.style.Theme_AppCompat_Dialog_Alert)
    alertDialogBuilder.setMessage(alertMessage)
    if (!confirmButtonTitle.isNullOrEmpty()) {
      alertDialogBuilder.setPositiveButton(confirmButtonTitle, clickListener)
    } else {
      alertDialogBuilder.setPositiveButton(android.R.string.ok, clickListener)
    }

    alertDialogBuilder.setOnCancelListener { dialog ->
      result.cancel()
      dialog.dismiss()
      dialogs.remove(dialog)
    }

    val alertDialog = alertDialogBuilder.create()
    dialogs[alertDialog] = result
    alertDialog.show()
  }

  override fun onJsConfirm(
    view: WebView,
    url: String?,
    message: String?,
    jsResult: JsResult
  ): Boolean {
    val channelDelegate = inAppWebView?.channelDelegate ?: return false

    channelDelegate.onJsConfirm(
      url, message, null,
      object : WebViewChannelDelegate.JsConfirmCallback() {
        override fun nonNullSuccess(result: JsConfirmResponse): Boolean {
          if (result.isHandledByClient) {
            when (result.action ?: 1) {
              0 -> jsResult.confirm()
              else -> jsResult.cancel()
            }
            return false
          }
          return true
        }

        override fun defaultBehaviour(result: JsConfirmResponse?) {
          createConfirmDialog(
            message, jsResult, result?.message, result?.confirmButtonTitle,
            result?.cancelButtonTitle
          )
        }

        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
          Log.e(LOG_TAG, errorCode + ", " + (errorMessage ?: ""))
          jsResult.cancel()
        }
      }
    )

    return true
  }

  fun createConfirmDialog(
    message: String?,
    result: JsResult,
    responseMessage: String?,
    confirmButtonTitle: String?,
    cancelButtonTitle: String?
  ) {
    val alertMessage = if (!responseMessage.isNullOrEmpty()) responseMessage else message
    val confirmClickListener = DialogInterface.OnClickListener { dialog, _ ->
      result.confirm()
      dialog.dismiss()
      dialogs.remove(dialog)
    }
    val cancelClickListener = DialogInterface.OnClickListener { dialog, _ ->
      result.cancel()
      dialog.dismiss()
      dialogs.remove(dialog)
    }

    val activity = getActivity() ?: return

    val alertDialogBuilder =
      AlertDialog.Builder(activity, androidx.appcompat.R.style.Theme_AppCompat_Dialog_Alert)
    alertDialogBuilder.setMessage(alertMessage)
    if (!confirmButtonTitle.isNullOrEmpty()) {
      alertDialogBuilder.setPositiveButton(confirmButtonTitle, confirmClickListener)
    } else {
      alertDialogBuilder.setPositiveButton(android.R.string.ok, confirmClickListener)
    }
    if (!cancelButtonTitle.isNullOrEmpty()) {
      alertDialogBuilder.setNegativeButton(cancelButtonTitle, cancelClickListener)
    } else {
      alertDialogBuilder.setNegativeButton(android.R.string.cancel, cancelClickListener)
    }

    alertDialogBuilder.setOnCancelListener { dialog ->
      result.cancel()
      dialog.dismiss()
      dialogs.remove(dialog)
    }

    val alertDialog = alertDialogBuilder.create()
    dialogs[alertDialog] = result
    alertDialog.show()
  }

  override fun onJsPrompt(
    view: WebView,
    url: String?,
    message: String?,
    defaultValue: String?,
    jsResult: JsPromptResult
  ): Boolean {
    val channelDelegate = inAppWebView?.channelDelegate ?: return false

    channelDelegate.onJsPrompt(
      url, message, defaultValue, null,
      object : WebViewChannelDelegate.JsPromptCallback() {
        override fun nonNullSuccess(result: JsPromptResponse): Boolean {
          if (result.isHandledByClient) {
            when (result.action ?: 1) {
              0 -> jsResult.confirm(result.value)
              else -> jsResult.cancel()
            }
            return false
          }
          return true
        }

        override fun defaultBehaviour(result: JsPromptResponse?) {
          createPromptDialog(
            view, message, defaultValue, jsResult, result?.message, result?.defaultValue,
            result?.value, result?.cancelButtonTitle, result?.confirmButtonTitle
          )
        }

        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
          Log.e(LOG_TAG, errorCode + ", " + (errorMessage ?: ""))
          jsResult.cancel()
        }
      }
    )

    return true
  }

  fun createPromptDialog(
    view: WebView,
    message: String?,
    defaultValue: String?,
    result: JsPromptResult,
    responseMessage: String?,
    responseDefaultValue: String?,
    value: String?,
    cancelButtonTitle: String?,
    confirmButtonTitle: String?
  ) {
    val layout = FrameLayout(view.context)

    val input = EditText(view.context)
    input.maxLines = 1
    input.setText(
      if (!responseDefaultValue.isNullOrEmpty()) responseDefaultValue else defaultValue
    )
    input.layoutParams = LinearLayout.LayoutParams(
      LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.MATCH_PARENT
    )

    layout.setPaddingRelative(45, 15, 45, 0)
    layout.addView(input)

    val alertMessage = if (!responseMessage.isNullOrEmpty()) responseMessage else message

    val confirmClickListener = DialogInterface.OnClickListener { dialog, _ ->
      val text = input.text.toString()
      result.confirm(value ?: text)
      dialog.dismiss()
      dialogs.remove(dialog)
    }
    val cancelClickListener = DialogInterface.OnClickListener { dialog, _ ->
      result.cancel()
      dialog.dismiss()
      dialogs.remove(dialog)
    }

    val activity = getActivity() ?: return

    val alertDialogBuilder =
      AlertDialog.Builder(activity, androidx.appcompat.R.style.Theme_AppCompat_Dialog_Alert)
    alertDialogBuilder.setMessage(alertMessage)
    if (!confirmButtonTitle.isNullOrEmpty()) {
      alertDialogBuilder.setPositiveButton(confirmButtonTitle, confirmClickListener)
    } else {
      alertDialogBuilder.setPositiveButton(android.R.string.ok, confirmClickListener)
    }
    if (!cancelButtonTitle.isNullOrEmpty()) {
      alertDialogBuilder.setNegativeButton(cancelButtonTitle, cancelClickListener)
    } else {
      alertDialogBuilder.setNegativeButton(android.R.string.cancel, cancelClickListener)
    }

    alertDialogBuilder.setOnCancelListener { dialog ->
      result.cancel()
      dialog.dismiss()
      dialogs.remove(dialog)
    }

    val alertDialog = alertDialogBuilder.create()
    alertDialog.setView(layout)
    dialogs[alertDialog] = result
    alertDialog.show()
  }

  override fun onJsBeforeUnload(
    view: WebView,
    url: String?,
    message: String?,
    jsResult: JsResult
  ): Boolean {
    val channelDelegate = inAppWebView?.channelDelegate ?: return false

    channelDelegate.onJsBeforeUnload(
      url, message,
      object : WebViewChannelDelegate.JsBeforeUnloadCallback() {
        override fun nonNullSuccess(result: JsBeforeUnloadResponse): Boolean {
          if (result.isHandledByClient) {
            when (result.action ?: 1) {
              0 -> jsResult.confirm()
              else -> jsResult.cancel()
            }
            return false
          }
          return true
        }

        override fun defaultBehaviour(result: JsBeforeUnloadResponse?) {
          createBeforeUnloadDialog(
            message, jsResult, result?.message, result?.confirmButtonTitle,
            result?.cancelButtonTitle
          )
        }

        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
          Log.e(LOG_TAG, errorCode + ", " + (errorMessage ?: ""))
          jsResult.cancel()
        }
      }
    )

    return true
  }

  fun createBeforeUnloadDialog(
    message: String?,
    result: JsResult,
    responseMessage: String?,
    confirmButtonTitle: String?,
    cancelButtonTitle: String?
  ) {
    val alertMessage = if (!responseMessage.isNullOrEmpty()) responseMessage else message
    val confirmClickListener = DialogInterface.OnClickListener { dialog, _ ->
      result.confirm()
      dialog.dismiss()
      dialogs.remove(dialog)
    }
    val cancelClickListener = DialogInterface.OnClickListener { dialog, _ ->
      result.cancel()
      dialog.dismiss()
      dialogs.remove(dialog)
    }

    val activity = getActivity() ?: return

    val alertDialogBuilder =
      AlertDialog.Builder(activity, androidx.appcompat.R.style.Theme_AppCompat_Dialog_Alert)
    alertDialogBuilder.setMessage(alertMessage)
    if (!confirmButtonTitle.isNullOrEmpty()) {
      alertDialogBuilder.setPositiveButton(confirmButtonTitle, confirmClickListener)
    } else {
      alertDialogBuilder.setPositiveButton(android.R.string.ok, confirmClickListener)
    }
    if (!cancelButtonTitle.isNullOrEmpty()) {
      alertDialogBuilder.setNegativeButton(cancelButtonTitle, cancelClickListener)
    } else {
      alertDialogBuilder.setNegativeButton(android.R.string.cancel, cancelClickListener)
    }

    alertDialogBuilder.setOnCancelListener { dialog ->
      result.cancel()
      dialog.dismiss()
      dialogs.remove(dialog)
    }

    val alertDialog = alertDialogBuilder.create()
    dialogs[alertDialog] = result
    alertDialog.show()
  }

  override fun onCreateWindow(
    view: WebView,
    isDialog: Boolean,
    isUserGesture: Boolean,
    resultMsg: Message
  ): Boolean {
    var windowId = 0
    val inAppWebViewManager = plugin?.inAppWebViewManager
    if (inAppWebViewManager != null) {
      inAppWebViewManager.windowAutoincrementId++
      windowId = inAppWebViewManager.windowAutoincrementId
    }

    val hitTestResult = view.hitTestResult
    var url = hitTestResult.extra

    // Ensure that images with hyperlink return the correct URL, not the image source
    if (hitTestResult.type == WebView.HitTestResult.SRC_IMAGE_ANCHOR_TYPE) {
      val href = view.handler.obtainMessage()
      view.requestFocusNodeHref(href)
      val data = href.data
      if (data != null) {
        val imageUrl = data.getString("url")
        if (!imageUrl.isNullOrEmpty()) {
          url = imageUrl
        }
      }
    }

    val request = URLRequest(url, "GET", null, null)
    val createWindowAction =
      CreateWindowAction(request, true, isUserGesture, false, windowId, isDialog)

    inAppWebViewManager?.windowWebViewMessages?.put(windowId, resultMsg)

    val channelDelegate = inAppWebView?.channelDelegate ?: return false

    val finalWindowId = windowId
    channelDelegate.onCreateWindow(
      createWindowAction,
      object : WebViewChannelDelegate.CreateWindowCallback() {
        override fun nonNullSuccess(result: Boolean): Boolean = !result

        override fun defaultBehaviour(result: Boolean?) {
          plugin?.inAppWebViewManager?.windowWebViewMessages?.remove(finalWindowId)
        }

        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
          Log.e(LOG_TAG, errorCode + ", " + (errorMessage ?: ""))
          defaultBehaviour(null)
        }
      }
    )

    return true
  }

  override fun onCloseWindow(window: WebView?) {
    inAppWebView?.channelDelegate?.onCloseWindow()

    super.onCloseWindow(window)
  }

  override fun onGeolocationPermissionsShowPrompt(
    origin: String?,
    callback: GeolocationPermissions.Callback
  ) {
    val resultCallback =
      object : WebViewChannelDelegate.GeolocationPermissionsShowPromptCallback() {
        override fun nonNullSuccess(result: GeolocationPermissionShowPromptResponse): Boolean {
          callback.invoke(result.origin, result.isAllow, result.isRetain)
          return false
        }

        override fun defaultBehaviour(result: GeolocationPermissionShowPromptResponse?) {
          callback.invoke(origin, false, false)
        }

        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
          Log.e(LOG_TAG, errorCode + ", " + (errorMessage ?: ""))
          defaultBehaviour(null)
        }
      }

    val channelDelegate = inAppWebView?.channelDelegate
    if (channelDelegate != null) {
      channelDelegate.onGeolocationPermissionsShowPrompt(origin, resultCallback)
    } else {
      resultCallback.defaultBehaviour(null)
    }
  }

  override fun onGeolocationPermissionsHidePrompt() {
    inAppWebView?.channelDelegate?.onGeolocationPermissionsHidePrompt()
  }

  override fun onConsoleMessage(consoleMessage: ConsoleMessage): Boolean {
    inAppWebView?.channelDelegate?.onConsoleMessage(
      consoleMessage.message(), consoleMessage.messageLevel().ordinal
    )
    return super.onConsoleMessage(consoleMessage)
  }

  override fun onProgressChanged(view: WebView, progress: Int) {
    super.onProgressChanged(view, progress)

    inAppBrowserDelegate?.didChangeProgress(progress)

    val webView = view as InAppWebView

    val compat = webView.inAppWebViewClientCompat
    val client = webView.inAppWebViewClient
    if (compat != null) {
      compat.loadCustomJavaScriptOnPageStarted(view)
    } else if (client != null) {
      client.loadCustomJavaScriptOnPageStarted(view)
    }

    webView.channelDelegate?.onProgressChanged(progress)
  }

  override fun onReceivedTitle(view: WebView, title: String?) {
    super.onReceivedTitle(view, title)

    inAppBrowserDelegate?.didChangeTitle(title)

    val webView = view as InAppWebView

    webView.channelDelegate?.onTitleChanged(title)
  }

  override fun onReceivedTouchIconUrl(view: WebView, url: String?, precomposed: Boolean) {
    super.onReceivedTouchIconUrl(view, url, precomposed)

    val webView = view as InAppWebView
    webView.channelDelegate?.onReceivedTouchIconUrl(url, precomposed)
  }

  private fun getRootView(): ViewGroup? {
    val activity = getActivity() ?: return null
    return activity.findViewById(android.R.id.content)
  }

  private fun onShowFileChooser(
    request: ShowFileChooserRequest,
    filePathsCallback: ValueCallback<*>
  ): Boolean {
    val callback = object : WebViewChannelDelegate.ShowFileChooserCallback() {
      override fun nonNullSuccess(result: ShowFileChooserResponse): Boolean {
        if (result.isHandledByClient) {
          val filePaths = result.filePaths
          val uriArray = filePaths?.map { Uri.parse(it) }?.toTypedArray()
          (filePathsCallback as ValueCallback<Array<Uri>?>).onReceiveValue(uriArray)

          return false
        }
        return true
      }

      override fun defaultBehaviour(result: ShowFileChooserResponse?) {
        val acceptTypes = request.acceptTypes.toTypedArray()
        val captureEnabled = request.isCaptureEnabled
        val allowMultiple = request.mode == FileChooserParams.MODE_OPEN_MULTIPLE
        startPickerIntent(
          filePathsCallback as ValueCallback<Array<Uri>?>, acceptTypes, allowMultiple,
          captureEnabled
        )
      }

      override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        Log.e(LOG_TAG, errorCode + ", " + (errorMessage ?: ""))
        defaultBehaviour(null)
      }
    }

    val webView = inAppWebView
    val channelDelegate = webView?.channelDelegate
    if (channelDelegate != null && webView.customSettings.useOnShowFileChooser) {
      channelDelegate.onShowFileChooser(request, callback)
    } else {
      callback.defaultBehaviour(null)
    }

    return true
  }

  // The three openFileChooser overloads are the pre-API-21 file input entry points; the framework
  // still reaches them reflectively on some WebView builds.
  protected fun openFileChooser(filePathCallback: ValueCallback<Uri?>, acceptType: String) {
    onShowFileChooser(
      ShowFileChooserRequest(0, listOf(acceptType), false, null, null), filePathCallback
    )
  }

  protected fun openFileChooser(filePathCallback: ValueCallback<Uri?>) {
    onShowFileChooser(
      ShowFileChooserRequest(0, listOf(""), false, null, null), filePathCallback
    )
  }

  protected fun openFileChooser(
    filePathCallback: ValueCallback<Uri?>,
    acceptType: String,
    capture: String
  ) {
    onShowFileChooser(
      ShowFileChooserRequest(0, listOf(acceptType), true, null, null), filePathCallback
    )
  }

  override fun onShowFileChooser(
    webView: WebView,
    filePathCallback: ValueCallback<Array<Uri>>,
    fileChooserParams: FileChooserParams
  ): Boolean = onShowFileChooser(
    ShowFileChooserRequest.fromFileChooserParams(fileChooserParams), filePathCallback
  )

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    if (filePathCallback == null && filePathCallbackLegacy == null) {
      return true
    }

    // based off of which button was pressed, we get an activity result and a file
    // the camera activity doesn't properly return the filename* (I think?) so we use
    // this filename instead
    when (requestCode) {
      PICKER -> {
        var results: Array<Uri>? = null
        if (resultCode == Activity.RESULT_OK) {
          results = getSelectedFiles(data, resultCode)
        }

        filePathCallback?.onReceiveValue(results)
      }

      PICKER_LEGACY -> {
        var result: Uri? = null
        if (resultCode == Activity.RESULT_OK) {
          result = data?.data ?: getCapturedMediaFile()
        }
        filePathCallbackLegacy?.onReceiveValue(result)
      }
    }

    filePathCallback = null
    filePathCallbackLegacy = null
    imageOutputFileUri = null
    videoOutputFileUri = null

    return true
  }

  private fun getSelectedFiles(data: Intent?, resultCode: Int): Array<Uri>? {
    // we have one file selected
    if (data?.data != null) {
      return if (resultCode == Activity.RESULT_OK) {
        FileChooserParams.parseResult(resultCode, data)
      } else {
        null
      }
    }

    // we have multiple files selected
    val clipData = data?.clipData
    if (clipData != null) {
      return Array(clipData.itemCount) { clipData.getItemAt(it).uri }
    }

    // we have a captured image or video file
    val mediaUri = getCapturedMediaFile()
    if (mediaUri != null) {
      return arrayOf(mediaUri)
    }

    return null
  }

  private fun isFileNotEmpty(uri: Uri): Boolean {
    val activity = getActivity() ?: return false

    val length: Long
    try {
      val descriptor = activity.contentResolver.openAssetFileDescriptor(uri, "r")!!
      length = descriptor.length
      descriptor.close()
    } catch (e: IOException) {
      return false
    }

    return length > 0
  }

  private fun getCapturedMediaFile(): Uri? {
    imageOutputFileUri?.let { if (isFileNotEmpty(it)) return it }
    videoOutputFileUri?.let { if (isFileNotEmpty(it)) return it }
    return null
  }

  fun startPickerIntent(
    filePathCallback: ValueCallback<Uri?>,
    acceptType: String,
    captureEnabled: Boolean
  ) {
    filePathCallbackLegacy = filePathCallback

    val images = acceptsImages(acceptType)
    val video = acceptsVideo(acceptType)

    var pickerIntent: Intent? = null

    if (captureEnabled && !needsCameraPermission()) {
      if (images) {
        pickerIntent = getPhotoIntent()
      } else if (video) {
        pickerIntent = getVideoIntent()
      }
    }
    if (pickerIntent == null) {
      pickerIntent = Intent.createChooser(getFileChooserIntent(acceptType), "")

      val extraIntents = ArrayList<Parcelable>()
      if (!needsCameraPermission()) {
        if (images) {
          extraIntents.add(getPhotoIntent())
        }
        if (video) {
          extraIntents.add(getVideoIntent())
        }
      }
      pickerIntent.putExtra(
        Intent.EXTRA_INITIAL_INTENTS, extraIntents.toArray(arrayOf<Parcelable>())
      )
    }

    val activity = getActivity()
    if (activity != null && pickerIntent.resolveActivity(activity.packageManager) != null) {
      activity.startActivityForResult(pickerIntent, PICKER_LEGACY)
    } else {
      Log.d(LOG_TAG, "there is no Activity to handle this Intent")
    }
  }

  fun startPickerIntent(
    callback: ValueCallback<Array<Uri>?>,
    acceptTypes: Array<String>,
    allowMultiple: Boolean,
    captureEnabled: Boolean
  ): Boolean {
    filePathCallback = callback

    val images = acceptsImages(acceptTypes)
    val video = acceptsVideo(acceptTypes)

    var pickerIntent: Intent? = null

    if (captureEnabled && !needsCameraPermission()) {
      if (images) {
        pickerIntent = getPhotoIntent()
      } else if (video) {
        pickerIntent = getVideoIntent()
      }
    }
    if (pickerIntent == null) {
      val extraIntents = ArrayList<Parcelable>()
      if (!needsCameraPermission()) {
        if (images) {
          extraIntents.add(getPhotoIntent())
        }
        if (video) {
          extraIntents.add(getVideoIntent())
        }
      }

      pickerIntent = Intent(Intent.ACTION_CHOOSER)
      pickerIntent.putExtra(
        Intent.EXTRA_INTENT, getFileChooserIntent(acceptTypes, allowMultiple)
      )
      pickerIntent.putExtra(
        Intent.EXTRA_INITIAL_INTENTS, extraIntents.toArray(arrayOf<Parcelable>())
      )
    }

    val activity = getActivity()
    if (activity != null && pickerIntent.resolveActivity(activity.packageManager) != null) {
      activity.startActivityForResult(pickerIntent, PICKER)
    } else {
      Log.d(LOG_TAG, "there is no Activity to handle this Intent")
    }

    return true
  }

  private fun needsCameraPermission(): Boolean {
    var needed = false

    val activity = getActivity() ?: return true
    val packageManager = activity.packageManager
    try {
      val requestedPermissions = packageManager.getPackageInfo(
        activity.applicationContext.packageName, PackageManager.GET_PERMISSIONS
      ).requestedPermissions
      if (requestedPermissions!!.contains(Manifest.permission.CAMERA) &&
        ContextCompat.checkSelfPermission(activity, Manifest.permission.CAMERA) !=
        PackageManager.PERMISSION_GRANTED
      ) {
        needed = true
      }
    } catch (e: PackageManager.NameNotFoundException) {
      needed = true
    }

    return needed
  }

  private fun getPhotoIntent(): Intent {
    val intent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
    imageOutputFileUri = getOutputUri(MediaStore.ACTION_IMAGE_CAPTURE)
    intent.putExtra(MediaStore.EXTRA_OUTPUT, imageOutputFileUri)
    return intent
  }

  private fun getVideoIntent(): Intent {
    val intent = Intent(MediaStore.ACTION_VIDEO_CAPTURE)
    videoOutputFileUri = getOutputUri(MediaStore.ACTION_VIDEO_CAPTURE)
    intent.putExtra(MediaStore.EXTRA_OUTPUT, videoOutputFileUri)
    return intent
  }

  private fun getFileChooserIntent(acceptTypes: String): Intent {
    var resolvedAcceptTypes = acceptTypes
    if (acceptTypes.isEmpty()) {
      resolvedAcceptTypes = DEFAULT_MIME_TYPES
    }
    if (acceptTypes.matches("\\.\\w+".toRegex())) {
      resolvedAcceptTypes = getMimeTypeFromExtension(acceptTypes.replace(".", "")) ?: ""
    }
    val intent = Intent(Intent.ACTION_GET_CONTENT)
    intent.addCategory(Intent.CATEGORY_OPENABLE)
    intent.type = resolvedAcceptTypes
    return intent
  }

  private fun getFileChooserIntent(acceptTypes: Array<String>, allowMultiple: Boolean): Intent {
    val intent = Intent(Intent.ACTION_GET_CONTENT)
    intent.addCategory(Intent.CATEGORY_OPENABLE)
    intent.type = "*/*"
    intent.putExtra(Intent.EXTRA_MIME_TYPES, getAcceptedMimeType(acceptTypes))
    intent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, allowMultiple)
    return intent
  }

  private fun acceptsAny(types: Array<String>): Boolean {
    if (isArrayEmpty(types)) {
      return true
    }
    return types.any { it == "*/*" }
  }

  private fun acceptsImages(types: String): Boolean {
    var mimeType: String? = types
    if (types.matches("\\.\\w+".toRegex())) {
      mimeType = getMimeTypeFromExtension(types.replace(".", ""))
    }
    return mimeType.isNullOrEmpty() || mimeType.lowercase(Locale.ROOT).contains("image")
  }

  private fun acceptsImages(types: Array<String>): Boolean =
    acceptsAny(types) || arrayContainsString(getAcceptedMimeType(types), "image")

  private fun acceptsVideo(types: String): Boolean {
    var mimeType: String? = types
    if (types.matches("\\.\\w+".toRegex())) {
      mimeType = getMimeTypeFromExtension(types.replace(".", ""))
    }
    return mimeType.isNullOrEmpty() || mimeType.lowercase(Locale.ROOT).contains("video")
  }

  private fun acceptsVideo(types: Array<String>): Boolean =
    acceptsAny(types) || arrayContainsString(getAcceptedMimeType(types), "video")

  private fun arrayContainsString(array: Array<String?>, pattern: String): Boolean =
    array.any { it != null && it.contains(pattern) }

  private fun getAcceptedMimeType(types: Array<String>): Array<String?> {
    if (isArrayEmpty(types)) {
      return arrayOf(DEFAULT_MIME_TYPES)
    }
    return Array(types.size) { i ->
      val t = types[i]
      // convert file extensions to mime types
      if (t.matches("\\.\\w+".toRegex())) {
        getMimeTypeFromExtension(t.replace(".", ""))
      } else {
        t
      }
    }
  }

  private fun getMimeTypeFromExtension(extension: String?): String? {
    if (extension == null) {
      return null
    }
    return MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension)
  }

  private fun getOutputUri(intentType: String): Uri? {
    var capturedFile: File? = null
    try {
      capturedFile = getCapturedFile(intentType)
    } catch (e: IOException) {
      Log.e(LOG_TAG, "Error occurred while creating the File", e)
    }
    if (capturedFile == null) {
      return null
    }

    val activity = getActivity() ?: return null
    // for versions 6.0+ (23) we use the FileProvider to avoid runtime permissions
    val fileProviderAuthority = activity.applicationContext.packageName + "." +
      InAppWebViewFileProvider.fileProviderAuthorityExtension
    try {
      return FileProvider.getUriForFile(
        activity.applicationContext, fileProviderAuthority, capturedFile
      )
    } catch (e: Exception) {
      Log.e(LOG_TAG, "", e)
    }
    return null
  }

  @Throws(IOException::class)
  private fun getCapturedFile(intentType: String): File? {
    var prefix = ""
    var suffix = ""

    if (intentType == MediaStore.ACTION_IMAGE_CAPTURE) {
      prefix = "image"
      suffix = ".jpg"
    } else if (intentType == MediaStore.ACTION_VIDEO_CAPTURE) {
      prefix = "video"
      suffix = ".mp4"
    }

    val activity = getActivity() ?: return null
    val storageDir = activity.applicationContext.getExternalFilesDir(null)
    return File.createTempFile(prefix, suffix, storageDir)
  }

  private fun isArrayEmpty(arr: Array<String>): Boolean {
    // when our array returned from getAcceptTypes() has no values set from the webview
    // i.e. <input type="file" />, without any "accept" attr
    // will be an array with one empty string element, afaik
    return arr.isEmpty() || (arr.size == 1 && arr[0].isEmpty())
  }

  override fun onPermissionRequest(request: PermissionRequest) {
    val callback = object : WebViewChannelDelegate.PermissionRequestCallback() {
      override fun nonNullSuccess(result: PermissionResponse): Boolean {
        val action = result.action
        if (action != null) {
          when (action) {
            1 -> request.grant(result.resources.toTypedArray())
            else -> request.deny()
          }
          return false
        }
        return true
      }

      override fun defaultBehaviour(result: PermissionResponse?) {
        request.deny()
      }

      override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        Log.e(LOG_TAG, errorCode + ", " + (errorMessage ?: ""))
        defaultBehaviour(null)
      }
    }

    val channelDelegate = inAppWebView?.channelDelegate
    if (channelDelegate != null) {
      channelDelegate.onPermissionRequest(
        request.origin.toString(), request.resources.toList(), null, callback
      )
    } else {
      callback.defaultBehaviour(null)
    }
  }

  override fun onRequestFocus(view: WebView?) {
    inAppWebView?.channelDelegate?.onRequestFocus()
  }

  override fun onPermissionRequestCanceled(request: PermissionRequest) {
    inAppWebView?.channelDelegate?.onPermissionRequestCanceled(
      request.origin.toString(), request.resources.toList()
    )
  }

  private fun getActivity(): Activity? {
    val delegate = inAppBrowserDelegate
    if (delegate != null) {
      return delegate.getActivity()
    }
    return plugin?.activity
  }

  fun dispose() {
    for ((dialog, result) in dialogs) {
      result.cancel()
      dialog.dismiss()
    }
    dialogs.clear()
    plugin?.activityPluginBinding?.removeActivityResultListener(this)
    inAppBrowserDelegate?.let {
      it.getActivityResultListeners().clear()
      inAppBrowserDelegate = null
    }
    filePathCallbackLegacy = null
    filePathCallback = null
    videoOutputFileUri = null
    imageOutputFileUri = null
    inAppWebView = null
    plugin = null
  }

  companion object {
    protected const val LOG_TAG = "IABWebChromeClient"

    private const val PICKER = 1
    private const val PICKER_LEGACY = 3

    @JvmField
    protected val FULLSCREEN_LAYOUT_PARAMS = FrameLayout.LayoutParams(
      ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT, Gravity.CENTER
    )
  }
}
