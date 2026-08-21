/*
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
 */

package dev.nosferatu500.inappwebview.in_app_browser

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Parcelable
import android.provider.Browser
import android.util.Log
import android.webkit.MimeTypeMap
import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import dev.nosferatu500.inappwebview.types.ChannelDelegateImpl
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.Serializable
import java.util.UUID

/**
 * InAppBrowserManager
 */
// The unchecked casts below are the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode. Suppressed at class level because the whole class is that boundary.
//
// See ChannelDelegateImpl: `this` is published to a platform-thread-only dispatcher.
@Suppress("UNCHECKED_CAST")
class InAppBrowserManager(plugin: InAppWebViewFlutterPlugin) :
  ChannelDelegateImpl(MethodChannel(plugin.messenger, METHOD_CHANNEL_NAME)) {

  @JvmField
  var plugin: InAppWebViewFlutterPlugin? = plugin

  @JvmField
  var id: String = UUID.randomUUID().toString()

  init {
    shared[id] = this
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    val activity = plugin?.activity

    when (call.method) {
      "open" -> {
        if (activity != null) {
          open(activity, call.arguments<Map<String, Any?>>()!!)
          result.success(true)
        } else {
          result.success(false)
        }
      }

      "openWithSystemBrowser" -> {
        if (activity != null) {
          openWithSystemBrowser(activity, call.argument("url")!!, result)
        } else {
          result.success(false)
        }
      }

      else -> result.notImplemented()
    }
  }

  /**
   * Display a new browser with the specified URL.
   *
   * @param url the url to load.
   */
  fun openWithSystemBrowser(activity: Activity, url: String, result: MethodChannel.Result) {
    try {
      val intent = Intent(Intent.ACTION_VIEW)
      // Omitting the MIME type for file: URLs causes "No Activity found to handle Intent".
      // Adding the MIME type to http: URLs causes them to not be handled by the downloader.
      val uri = Uri.parse(url)
      if ("file" == uri.scheme) {
        intent.setDataAndType(uri, getMimeType(url))
      } else {
        intent.data = uri
      }
      intent.putExtra(Browser.EXTRA_APPLICATION_ID, activity.packageName)
      // CB-10795: Avoid circular loops by preventing it from opening in the current app
      openExternalExcludeCurrentApp(activity, intent)
      result.success(true)
      // not catching FileUriExposedException explicitly because buildtools<24 doesn't know about it
    } catch (e: RuntimeException) {
      Log.d(LOG_TAG, "$url cannot be opened: $e")
      result.error(LOG_TAG, "$url cannot be opened!", null)
    }
  }

  /**
   * Opens the intent, providing a chooser that excludes the current app to avoid
   * circular loops.
   */
  fun openExternalExcludeCurrentApp(activity: Activity, intent: Intent) {
    val currentPackage = activity.packageName
    var hasCurrentPackage = false
    val activities = activity.packageManager.queryIntentActivities(intent, 0)
    val targetIntents = ArrayList<Intent>()
    for (ri in activities) {
      if (currentPackage != ri.activityInfo.packageName) {
        val targetIntent = intent.clone() as Intent
        targetIntent.setPackage(ri.activityInfo.packageName)
        targetIntents.add(targetIntent)
      } else {
        hasCurrentPackage = true
      }
    }
    if (!hasCurrentPackage || targetIntents.isEmpty()) {
      // If the current app package isn't a target for this URL, then use
      // the normal launch behavior
      activity.startActivity(intent)
    } else if (targetIntents.size == 1) {
      // If there's only one possible intent, launch it directly
      activity.startActivity(targetIntents[0])
    } else {
      // Otherwise, show a custom chooser without the current app listed
      val chooser = Intent.createChooser(targetIntents.removeAt(targetIntents.size - 1), null)
      chooser.putExtra(
        Intent.EXTRA_INITIAL_INTENTS, targetIntents.toArray(arrayOf<Parcelable>())
      )
      activity.startActivity(chooser)
    }
  }

  fun open(activity: Activity, arguments: Map<String, Any?>) {
    val windowId = arguments["windowId"] as Int?

    val extras = Bundle()
    extras.putString("fromActivity", activity.javaClass.name)
    extras.putSerializable("initialUrlRequest", arguments["urlRequest"] as Serializable?)
    extras.putString("initialFile", arguments["assetFilePath"] as String?)
    extras.putString("initialData", arguments["data"] as String?)
    extras.putString("initialMimeType", arguments["mimeType"] as String?)
    extras.putString("initialEncoding", arguments["encoding"] as String?)
    extras.putString("initialBaseUrl", arguments["baseUrl"] as String?)
    extras.putString("initialHistoryUrl", arguments["historyUrl"] as String?)
    extras.putString("id", arguments["id"] as String?)
    extras.putString("managerId", id)
    extras.putSerializable("settings", arguments["settings"] as Serializable?)
    extras.putSerializable("contextMenu", arguments["contextMenu"] as Serializable?)
    extras.putInt("windowId", windowId ?: -1)
    extras.putSerializable("initialUserScripts", arguments["initialUserScripts"] as Serializable?)
    extras.putSerializable(
      "pullToRefreshInitialSettings", arguments["pullToRefreshSettings"] as Serializable?
    )
    extras.putSerializable("menuItems", arguments["menuItems"] as Serializable?)
    startInAppBrowserActivity(activity, extras)
  }

  fun startInAppBrowserActivity(activity: Activity, extras: Bundle?) {
    val intent = Intent(activity, InAppBrowserActivity::class.java)
    if (extras != null) {
      intent.putExtras(extras)
    }
    activity.startActivity(intent)
  }

  override fun dispose() {
    super.dispose()
    shared.remove(id)
    plugin = null
  }

  companion object {
    protected const val LOG_TAG = "InAppBrowserManager"
    const val METHOD_CHANNEL_NAME = "dev.nosferatu500.inappwebview/inappbrowser"

    @JvmField
    val shared: MutableMap<String, InAppBrowserManager> = HashMap()

    @JvmStatic
    fun getMimeType(url: String): String? {
      val extension = MimeTypeMap.getFileExtensionFromUrl(url) ?: return null
      return MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension)
    }
  }
}
