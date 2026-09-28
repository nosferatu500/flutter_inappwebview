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

package dev.nosferatu500.inappwebview.headless_in_app_webview

import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import dev.nosferatu500.inappwebview.Util
import dev.nosferatu500.inappwebview.pigeons.HeadlessInAppWebViewManagerHostApi
import dev.nosferatu500.inappwebview.pigeons.Size2DData
import dev.nosferatu500.inappwebview.types.Size2D
import dev.nosferatu500.inappwebview.webview.in_app_webview.FlutterWebView
import io.flutter.plugin.common.BinaryMessenger

/**
 * Runs headless webviews, over Pigeon (§203). Implements [HeadlessInAppWebViewManagerHostApi]
 * directly, as `InAppBrowserManager` (§197) and `ChromeSafariBrowserManager` (§201) do.
 *
 * `run`'s params map goes whole into [FlutterWebView], the class that also builds every
 * `InAppWebView` widget, so its readers stay the single definition (§194, decision B). It passes
 * through [Util.normalizeCodecInts] first, because Pigeon delivers its nested ints as `Long` where
 * those readers cast `as Int` (§197).
 */
class HeadlessInAppWebViewManager(plugin: InAppWebViewFlutterPlugin) :
  HeadlessInAppWebViewManagerHostApi {

  // Values go null rather than being removed: HeadlessInAppWebView.dispose() nulls its own slot.
  @JvmField
  val webViews: MutableMap<String, HeadlessInAppWebView?> = HashMap()

  @JvmField
  var plugin: InAppWebViewFlutterPlugin? = plugin

  private var messenger: BinaryMessenger? = plugin.messenger

  init {
    HeadlessInAppWebViewManagerHostApi.setUp(plugin.messenger, this)
  }

  // `true` even when the plugin has already detached and nothing ran, as the hand-written channel
  // answered.
  override fun run(id: String, params: Map<String?, Any?>, initialSize: Size2DData): Boolean {
    @Suppress("UNCHECKED_CAST")
    val normalized = Util.normalizeCodecInts(params) as HashMap<String, Any?>
    startHeadless(id, normalized, initialSize.toNative())
    return true
  }

  // Renamed from `run` (rule 7: it shared the host method's name).
  private fun startHeadless(id: String, params: HashMap<String, Any?>, initialSize: Size2D) {
    val currentPlugin = plugin ?: return
    val context = currentPlugin.activity ?: currentPlugin.applicationContext
    val flutterWebView = FlutterWebView(currentPlugin, context, id, params)
    val headlessInAppWebView = HeadlessInAppWebView(currentPlugin, id, flutterWebView)
    webViews[id] = headlessInAppWebView

    headlessInAppWebView.prepare(initialSize)
    headlessInAppWebView.onWebViewCreated()
    flutterWebView.makeInitialLoad(params)
  }

  fun dispose() {
    messenger?.let { HeadlessInAppWebViewManagerHostApi.setUp(it, null) }
    messenger = null
    for (headlessInAppWebView in webViews.values) {
      headlessInAppWebView?.dispose()
    }
    webViews.clear()
    plugin = null
  }

  companion object {
    protected const val LOG_TAG = "HeadlessInAppWebViewManager"
  }
}
