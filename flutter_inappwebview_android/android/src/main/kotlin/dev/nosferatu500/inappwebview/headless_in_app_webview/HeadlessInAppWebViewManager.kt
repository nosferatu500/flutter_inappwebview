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
import dev.nosferatu500.inappwebview.types.ChannelDelegateImpl
import dev.nosferatu500.inappwebview.webview.in_app_webview.FlutterWebView
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

// The unchecked cast below is the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode.
@Suppress("UNCHECKED_CAST")
class HeadlessInAppWebViewManager(plugin: InAppWebViewFlutterPlugin) :
  ChannelDelegateImpl(MethodChannel(plugin.messenger, METHOD_CHANNEL_NAME)) {

  // Values go null rather than being removed: HeadlessInAppWebView.dispose() nulls its own slot.
  @JvmField
  val webViews: MutableMap<String, HeadlessInAppWebView?> = HashMap()

  @JvmField
  var plugin: InAppWebViewFlutterPlugin? = plugin

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    val id = call.argument<String>("id")

    when (call.method) {
      "run" -> {
        run(id!!, call.argument<HashMap<String, Any?>>("params")!!)
        result.success(true)
      }

      else -> result.notImplemented()
    }
  }

  fun run(id: String, params: HashMap<String, Any?>) {
    val currentPlugin = plugin ?: return
    val context = currentPlugin.activity ?: currentPlugin.applicationContext
    val flutterWebView = FlutterWebView(currentPlugin, context, id, params)
    val headlessInAppWebView = HeadlessInAppWebView(currentPlugin, id, flutterWebView)
    webViews[id] = headlessInAppWebView

    headlessInAppWebView.prepare(params)
    headlessInAppWebView.onWebViewCreated()
    flutterWebView.makeInitialLoad(params)
  }

  override fun dispose() {
    super.dispose()
    for (headlessInAppWebView in webViews.values) {
      headlessInAppWebView?.dispose()
    }
    webViews.clear()
    plugin = null
  }

  companion object {
    protected const val LOG_TAG = "HeadlessInAppWebViewManager"
    const val METHOD_CHANNEL_NAME = "dev.nosferatu500.inappwebview/headless_inappwebview"
  }
}
