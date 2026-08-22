package dev.nosferatu500.inappwebview.content_blocker

import android.os.Handler
import android.os.Looper
import android.text.TextUtils
import android.util.Log
import android.webkit.WebResourceResponse
import dev.nosferatu500.inappwebview.Util
import dev.nosferatu500.inappwebview.plugin_scripts_js.JavaScriptBridgeJS
import dev.nosferatu500.inappwebview.types.WebResourceRequestExt
import dev.nosferatu500.inappwebview.webview.in_app_webview.InAppWebView
import java.io.ByteArrayInputStream
import java.net.MalformedURLException
import java.net.URI
import java.net.URISyntaxException
import java.net.URL
import java.util.concurrent.CopyOnWriteArrayList
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicReference
import javax.net.ssl.SSLHandshakeException

class ContentBlockerHandler(ruleList: MutableList<ContentBlocker>) {

  // Mutable: callers clear it and add to it in place when settings change.
  var ruleList: MutableList<ContentBlocker> = ruleList

  constructor() : this(ArrayList())

  @Throws(URISyntaxException::class, InterruptedException::class, MalformedURLException::class)
  fun checkUrl(
    webView: InAppWebView,
    request: WebResourceRequestExt,
    responseResourceType: ContentBlockerTriggerResourceType
  ): WebResourceResponse? {
    if (webView.customSettings.contentBlockers == null) {
      return null
    }

    val url = request.url

    val u: URI = try {
      URI(url)
    } catch (e: URISyntaxException) {
      val scheme = url.split(":").toTypedArray()[0]
      val tempUrl = URL(url.replace(scheme, "https"))
      URI(
        scheme, tempUrl.userInfo, tempUrl.host, tempUrl.port, tempUrl.path, tempUrl.query,
        tempUrl.ref
      )
    }
    val host = u.host
    val port = u.port
    val scheme = u.scheme
    // thread safe copy list
    val ruleListCopy = CopyOnWriteArrayList(ruleList)

    for (contentBlocker in ruleListCopy) {
      val trigger = contentBlocker.trigger
      val resourceTypes = trigger.resourceType
      if (resourceTypes.contains(ContentBlockerTriggerResourceType.IMAGE) &&
        !resourceTypes.contains(ContentBlockerTriggerResourceType.SVG_DOCUMENT)
      ) {
        resourceTypes.add(ContentBlockerTriggerResourceType.SVG_DOCUMENT)
      }

      val action = contentBlocker.action

      if (!trigger.urlFilterPatternCompiled.matcher(url).matches()) {
        continue
      }

      if (resourceTypes.isNotEmpty() && !resourceTypes.contains(responseResourceType)) {
        return null
      }
      if (trigger.ifDomain.isNotEmpty()) {
        var matchFound = false
        for (domain in trigger.ifDomain) {
          if ((domain.startsWith("*") && host.endsWith(domain.replace("*", ""))) ||
            domain == host
          ) {
            matchFound = true
            break
          }
        }
        if (!matchFound) return null
      }
      if (trigger.unlessDomain.isNotEmpty()) {
        for (domain in trigger.unlessDomain) {
          if ((domain.startsWith("*") && host.endsWith(domain.replace("*", ""))) ||
            domain == host
          ) {
            return null
          }
        }
      }

      // AtomicReference rather than a one-element array: on the timeout path below there is no
      // latch to establish a happens-before with the posted write, so the read needs to be safe
      // on its own.
      val webViewUrl = AtomicReference<String?>(null)
      if (trigger.loadType.isNotEmpty() || trigger.ifTopUrl.isNotEmpty() ||
        trigger.unlessTopUrl.isNotEmpty()
      ) {
        val webViewLooper = webView.getWebViewLooper()
        if (Looper.myLooper() == webViewLooper) {
          // Already on the WebView's thread. Posting and then waiting would queue the read
          // behind this very method and deadlock outright.
          webViewUrl.set(webView.url)
        } else {
          val latch = CountDownLatch(1)
          Handler(webViewLooper).post {
            webViewUrl.set(webView.url)
            latch.countDown()
          }
          // Bounded: if that thread is blocked or the WebView is being torn down, the posted
          // read never runs. Giving up leaves the URL null, which the triggers below already
          // handle -- they are simply skipped, as when the URL could not be determined.
          if (!latch.await(Util.SYNC_CALLBACK_TIMEOUT_MILLIS, TimeUnit.MILLISECONDS)) {
            Log.w(
              LOG_TAG,
              "Timed out reading the WebView URL while evaluating a content blocker trigger; " +
                "skipping the load-type and top-URL conditions for $url"
            )
          }
        }
      }

      val currentUrl = webViewUrl.get()
      if (currentUrl != null) {
        if (trigger.loadType.isNotEmpty()) {
          val cUrl = URI(currentUrl)
          val cHost = cUrl.host
          val cPort = cUrl.port
          val cScheme = cUrl.scheme

          if ((
              trigger.loadType.contains("first-party") && cHost != null &&
                !(cScheme == scheme && cHost == host && cPort == port)
              ) ||
            (trigger.loadType.contains("third-party") && cHost != null && cHost == host)
          ) {
            return null
          }
        }
        if (trigger.ifTopUrl.isNotEmpty()) {
          if (trigger.ifTopUrl.none { currentUrl.startsWith(it) }) {
            return null
          }
        }
        if (trigger.unlessTopUrl.isNotEmpty()) {
          if (trigger.unlessTopUrl.any { currentUrl.startsWith(it) }) {
            return null
          }
        }
      }

      when (action.type) {
        ContentBlockerActionType.BLOCK -> return WebResourceResponse("", "", null)

        ContentBlockerActionType.CSS_DISPLAY_NONE -> {
          val cssSelector = action.selector
          val jsScript = "(function(d) { " +
            "   function hide () { " +
            "       if (d.body != null && !d.getElementById('" + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() + "-css-display-none-style')) { " +
            "           var c = d.createElement('style'); " +
            "           c.id = '" + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() + "-css-display-none-style'; " +
            "           c.innerHTML = '" + cssSelector + " { display: none !important; }'; " +
            "           d.body.appendChild(c); " +
            "       }" +
            "       d.querySelectorAll('" + cssSelector + "').forEach(function (item, index) { " +
            "           item.setAttribute('style', 'display: none !important;'); " +
            "       }); " +
            "   }; " +
            "   hide(); " +
            "   d.addEventListener('DOMContentLoaded', function(event) { hide(); }); " +
            "})(document);"

          Handler(webView.getWebViewLooper()).postDelayed(
            { webView.evaluateJavascript(jsScript, null) },
            800
          )
        }

        ContentBlockerActionType.MAKE_HTTPS -> {
          if (scheme == "http" && (port == -1 || port == 80)) {
            val urlHttps = url.replace("http://", "https://")

            val urlConnection =
              Util.makeHttpRequest(urlHttps, request.method!!, request.headers)
            if (urlConnection != null) {
              try {
                val dataBytes = Util.readAllBytes(urlConnection.inputStream) ?: return null
                val dataStream = ByteArrayInputStream(dataBytes)

                var encoding = urlConnection.contentEncoding
                var contentType = urlConnection.contentType
                if (contentType == null) {
                  contentType = "text/plain"
                } else {
                  val contentTypeSplit = contentType.split(";").toTypedArray()
                  contentType = contentTypeSplit[0].trim()
                  if (encoding == null) {
                    encoding = if (contentTypeSplit.size > 1 &&
                      contentTypeSplit[1].contains("charset=")
                    ) {
                      contentTypeSplit[1].replace("charset=", "").trim()
                    } else {
                      "utf-8"
                    }
                  }
                }

                val reasonPhrase = urlConnection.responseMessage
                return if (reasonPhrase != null) {
                  val responseHeaders = HashMap<String, String>()
                  for ((name, values) in urlConnection.headerFields) {
                    responseHeaders[name] = TextUtils.join(",", values)
                  }
                  WebResourceResponse(
                    contentType, encoding, urlConnection.responseCode, reasonPhrase,
                    responseHeaders, dataStream
                  )
                } else {
                  WebResourceResponse(contentType, encoding, dataStream)
                }
              } catch (e: Exception) {
                if (e !is SSLHandshakeException) {
                  Log.e(LOG_TAG, "", e)
                }
              } finally {
                urlConnection.disconnect()
              }
            }
          }
        }
      }
    }
    return null
  }

  @Throws(URISyntaxException::class, InterruptedException::class, MalformedURLException::class)
  fun checkUrl(webView: InAppWebView, request: WebResourceRequestExt): WebResourceResponse? =
    checkUrl(webView, request, getResourceTypeFromUrl(request))

  @Throws(URISyntaxException::class, InterruptedException::class, MalformedURLException::class)
  fun checkUrl(
    webView: InAppWebView,
    request: WebResourceRequestExt,
    contentType: String
  ): WebResourceResponse? =
    checkUrl(webView, request, getResourceTypeFromContentType(contentType))

  fun getResourceTypeFromUrl(request: WebResourceRequestExt): ContentBlockerTriggerResourceType {
    var responseResourceType = ContentBlockerTriggerResourceType.RAW
    val url = request.url

    if (url.startsWith("http://") || url.startsWith("https://")) {
      // make an HTTP "HEAD" request to the server for that URL. This will not return the full
      // content of the URL.
      val urlConnection = Util.makeHttpRequest(url, "HEAD", request.headers)
      if (urlConnection != null) {
        try {
          val contentType = urlConnection.contentType
          if (contentType != null) {
            responseResourceType =
              getResourceTypeFromContentType(contentType.split(";").toTypedArray()[0].trim())
          }
        } catch (e: Exception) {
          Log.e(LOG_TAG, "", e)
        } finally {
          urlConnection.disconnect()
        }
      }
    }
    return responseResourceType
  }

  fun getResourceTypeFromContentType(contentType: String): ContentBlockerTriggerResourceType {
    // https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types
    return when {
      contentType == "text/css" -> ContentBlockerTriggerResourceType.STYLE_SHEET
      contentType == "image/svg+xml" -> ContentBlockerTriggerResourceType.SVG_DOCUMENT
      contentType.startsWith("image/") -> ContentBlockerTriggerResourceType.IMAGE
      contentType.startsWith("font/") -> ContentBlockerTriggerResourceType.FONT
      contentType.startsWith("audio/") || contentType.startsWith("video/") ||
        contentType == "application/ogg" -> ContentBlockerTriggerResourceType.MEDIA
      contentType.endsWith("javascript") -> ContentBlockerTriggerResourceType.SCRIPT
      contentType.startsWith("text/") -> ContentBlockerTriggerResourceType.DOCUMENT
      else -> ContentBlockerTriggerResourceType.RAW
    }
  }

  companion object {
    protected const val LOG_TAG = "ContentBlockerHandler"
  }
}
