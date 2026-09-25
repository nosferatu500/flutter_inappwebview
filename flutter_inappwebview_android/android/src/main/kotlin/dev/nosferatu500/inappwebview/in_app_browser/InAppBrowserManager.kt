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
import dev.nosferatu500.inappwebview.Util
import dev.nosferatu500.inappwebview.pigeons.FlutterError
import dev.nosferatu500.inappwebview.pigeons.InAppBrowserManagerHostApi
import dev.nosferatu500.inappwebview.pigeons.InAppBrowserOpenRequestData
import io.flutter.plugin.common.BinaryMessenger
import java.io.Serializable
import java.util.UUID

/**
 * Opens in-app browsers, over Pigeon (§197). Implements [InAppBrowserManagerHostApi] directly.
 *
 * The six map-valued fields of [InAppBrowserOpenRequestData] go into the Bundle as the maps Dart
 * sent (§194, decision B): the Activity's `parse(Map)` is still their only reader. Each passes
 * through [Util.normalizeCodecInts] first, because Pigeon delivers their nested ints as `Long`
 * where the parsers cast `as Int` (§197).
 */
class InAppBrowserManager(plugin: InAppWebViewFlutterPlugin) : InAppBrowserManagerHostApi {

  @JvmField
  var plugin: InAppWebViewFlutterPlugin? = plugin

  @JvmField
  var id: String = UUID.randomUUID().toString()

  private var messenger: BinaryMessenger? = plugin.messenger

  init {
    shared[id] = this
    InAppBrowserManagerHostApi.setUp(plugin.messenger, this)
  }

  override fun open(request: InAppBrowserOpenRequestData): Boolean {
    val activity = plugin?.activity ?: return false
    startBrowser(activity, request)
    return true
  }

  override fun openWithSystemBrowser(url: String): Boolean {
    val activity = plugin?.activity ?: return false
    launchSystemBrowser(activity, url)
    return true
  }

  /**
   * Opens [url] in another app. Throws [FlutterError] when none can, with the code, message and
   * details the hand-written channel's `result.error` used, so Dart sees the same
   * `PlatformException` (§196).
   */
  private fun launchSystemBrowser(activity: Activity, url: String) {
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
      // not catching FileUriExposedException explicitly because buildtools<24 doesn't know about it
    } catch (e: RuntimeException) {
      Log.d(LOG_TAG, "$url cannot be opened: $e")
      throw FlutterError(LOG_TAG, "$url cannot be opened!", null)
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

  // Field for Bundle key, one line each, in the order the hand-written reads used. §196 asserts
  // each on a value only the right field produces, so a transposition here fails a device test.
  private fun startBrowser(activity: Activity, request: InAppBrowserOpenRequestData) {
    val extras = Bundle()
    extras.putString("fromActivity", activity.javaClass.name)
    extras.putSerializable(
      "initialUrlRequest", Util.normalizeCodecInts(request.urlRequest) as Serializable?
    )
    extras.putString("initialFile", request.assetFilePath)
    extras.putString("initialData", request.data)
    extras.putString("initialMimeType", request.mimeType)
    extras.putString("initialEncoding", request.encoding)
    extras.putString("initialBaseUrl", request.baseUrl)
    extras.putString("initialHistoryUrl", request.historyUrl)
    extras.putString("id", request.id)
    extras.putString("managerId", id)
    extras.putSerializable("settings", Util.normalizeCodecInts(request.settings) as Serializable)
    extras.putSerializable(
      "contextMenu", Util.normalizeCodecInts(request.contextMenu) as Serializable
    )
    extras.putInt("windowId", request.windowId?.toInt() ?: -1)
    extras.putSerializable(
      "initialUserScripts", Util.normalizeCodecInts(request.initialUserScripts) as Serializable
    )
    extras.putSerializable(
      "pullToRefreshInitialSettings",
      Util.normalizeCodecInts(request.pullToRefreshSettings) as Serializable
    )
    extras.putSerializable("menuItems", Util.normalizeCodecInts(request.menuItems) as Serializable)
    startInAppBrowserActivity(activity, extras)
  }

  fun startInAppBrowserActivity(activity: Activity, extras: Bundle?) {
    val intent = Intent(activity, InAppBrowserActivity::class.java)
    if (extras != null) {
      intent.putExtras(extras)
    }
    activity.startActivity(intent)
  }

  fun dispose() {
    messenger?.let { InAppBrowserManagerHostApi.setUp(it, null) }
    messenger = null
    shared.remove(id)
    plugin = null
  }

  companion object {
    protected const val LOG_TAG = "InAppBrowserManager"

    @JvmField
    val shared: MutableMap<String, InAppBrowserManager> = HashMap()

    @JvmStatic
    fun getMimeType(url: String): String? {
      val extension = MimeTypeMap.getFileExtensionFromUrl(url) ?: return null
      return MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension)
    }
  }
}
