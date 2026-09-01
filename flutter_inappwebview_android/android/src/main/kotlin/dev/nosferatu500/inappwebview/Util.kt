package dev.nosferatu500.inappwebview

import android.content.Context
import android.graphics.BitmapFactory
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.net.http.SslCertificate
import android.os.Handler
import android.os.Looper
import android.text.TextUtils
import android.util.Log
import android.view.WindowInsets
import android.view.WindowManager
import dev.nosferatu500.inappwebview.types.Size2D
import dev.nosferatu500.inappwebview.types.SyncBaseCallbackResultImpl
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.FileInputStream
import java.io.IOException
import java.io.InputStream
import java.lang.reflect.InvocationTargetException
import java.net.HttpURLConnection
import java.net.Inet6Address
import java.net.InetAddress
import java.net.URL
import java.net.UnknownHostException
import java.security.KeyStore
import java.security.PrivateKey
import java.security.cert.CertificateException
import java.security.cert.CertificateFactory
import java.security.cert.X509Certificate
import java.util.Objects
import java.util.concurrent.TimeUnit
import java.util.regex.Pattern
import javax.net.ssl.SSLHandshakeException

// The unchecked casts below are the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode. Suppressed at class level because the whole class is that boundary.
@Suppress("UNCHECKED_CAST")
object Util {

  const val LOG_TAG = "Util"
  const val ANDROID_ASSET_URL = "file:///android_asset/"

  @JvmStatic
  @Throws(IOException::class)
  fun getUrlAsset(plugin: InAppWebViewFlutterPlugin, assetFilePath: String): String {
    val key = plugin.flutterAssets.getAssetFilePathByName(assetFilePath)
    var inputStream: InputStream? = null
    var e: IOException? = null

    try {
      inputStream = getFileAsset(plugin, assetFilePath)
    } catch (ex: IOException) {
      e = ex
    } finally {
      if (inputStream != null) {
        try {
          inputStream.close()
        } catch (ex: IOException) {
          e = ex
        }
      }
    }
    if (e != null) {
      throw e
    }

    return ANDROID_ASSET_URL + key
  }

  @JvmStatic
  @Throws(IOException::class)
  fun getFileAsset(plugin: InAppWebViewFlutterPlugin, assetFilePath: String): InputStream {
    val key = plugin.flutterAssets.getAssetFilePathByName(assetFilePath)
    return plugin.applicationContext.resources.assets.open(key)
  }

  /**
   * How long [invokeMethodAndWaitResult] waits for the Dart side before giving up, unless the
   * WebView's `InAppWebViewSettings.syncCallbackTimeoutMillis` raises it (see
   * [resolveSyncCallbackTimeoutMillis]).
   *
   * These calls block a WebView worker thread, so an answer that never arrives used to stall
   * that thread for the rest of the WebView's life. Ten seconds is far longer than a correct
   * handler needs and short enough to recover from: on expiry the caller takes its existing
   * "not handled" path -- the resource just loads normally -- which is what it already did when
   * the wait was interrupted.
   *
   * It also remains the fixed bound for the two blocking waits that cannot read a WebView's
   * settings: a custom `WebViewAssetLoader` `PathHandler` (built from the settings map and holding
   * no reference back to it) and `ServiceWorkerClient.shouldInterceptRequest` (a process-wide
   * controller with no WebView at all).
   */
  const val SYNC_CALLBACK_TIMEOUT_MILLIS = 10_000L

  /**
   * The timeout for a sync callback on a WebView whose settings carry [settingMillis].
   *
   * A null value means the setting was not sent. **A non-positive one is ignored rather than
   * honoured**: `latch.await(0)` returns immediately, so obeying a mistaken `0` would silently turn
   * every synchronous callback into a no-op -- the resource would always load unintercepted, which
   * is the one failure this whole path exists to avoid. There is deliberately no upper bound: a
   * caller that knows its handler is slow is entitled to wait, and the cost is documented.
   */
  @JvmStatic
  fun resolveSyncCallbackTimeoutMillis(settingMillis: Int?): Long =
    if (settingMillis != null && settingMillis > 0) {
      settingMillis.toLong()
    } else {
      SYNC_CALLBACK_TIMEOUT_MILLIS
    }

  /**
   * Invokes [method] on [channel] from the main thread and blocks the calling thread until Dart
   * answers or [timeoutMillis] elapses.
   *
   * Returns `null` on timeout. The caller cannot distinguish that from Dart legitimately
   * answering `null`, and does not need to: both mean "no response to substitute".
   */
  @JvmStatic
  @Throws(InterruptedException::class)
  fun <T> invokeMethodAndWaitResult(
    channel: MethodChannel,
    method: String,
    arguments: Any?,
    callback: SyncBaseCallbackResultImpl<T>,
    timeoutMillis: Long = SYNC_CALLBACK_TIMEOUT_MILLIS
  ): T? {
    Handler(Looper.getMainLooper()).post { channel.invokeMethod(method, arguments, callback) }
    if (!callback.latch.await(timeoutMillis, TimeUnit.MILLISECONDS)) {
      Log.w(
        LOG_TAG,
        "Timed out after ${timeoutMillis}ms waiting for the Dart side to answer \"$method\"; " +
          "continuing as if it had returned null. Check that the corresponding handler returns " +
          "on every path and does not throw."
      )
      return null
    }
    return callback.result
  }

  @JvmStatic
  fun loadPrivateKeyAndCertificate(
    plugin: InAppWebViewFlutterPlugin,
    certificatePath: String,
    certificatePassword: String?,
    keyStoreType: String
  ): PrivateKeyAndCertificates? {
    var privateKeyAndCertificates: PrivateKeyAndCertificates? = null
    var certificateFileStream: InputStream? = null

    try {
      certificateFileStream = getFileAsset(plugin, certificatePath)
    } catch (ignored: IOException) {
    }

    try {
      if (certificateFileStream == null) {
        certificateFileStream = FileInputStream(certificatePath)
      }
      val keyStore = KeyStore.getInstance(keyStoreType)
      val password = (certificatePassword ?: "").toCharArray()
      keyStore.load(certificateFileStream, password)

      val alias = keyStore.aliases().nextElement()

      val key = keyStore.getKey(alias, password)
      if (key is PrivateKey) {
        val cert = keyStore.getCertificate(alias)
        privateKeyAndCertificates =
          PrivateKeyAndCertificates(key, arrayOf(cert as X509Certificate))
      }
      certificateFileStream.close()
    } catch (e: Exception) {
      Log.e(LOG_TAG, "", e)
    } finally {
      if (certificateFileStream != null) {
        try {
          certificateFileStream.close()
        } catch (ex: IOException) {
          Log.e(LOG_TAG, "", ex)
        }
      }
    }

    return privateKeyAndCertificates
  }

  class PrivateKeyAndCertificates(
    @JvmField var privateKey: PrivateKey,
    @JvmField var certificates: Array<X509Certificate>
  )

  @JvmStatic
  fun makeHttpRequest(
    urlString: String,
    method: String,
    headers: Map<String, String>?
  ): HttpURLConnection? {
    var urlConnection: HttpURLConnection? = null
    try {
      urlConnection = URL(urlString).openConnection() as HttpURLConnection
      urlConnection.requestMethod = method
      headers?.forEach { (name, value) -> urlConnection.setRequestProperty(name, value) }
      urlConnection.connectTimeout = 15000 // 15 seconds
      urlConnection.readTimeout = 15000 // 15 seconds
      urlConnection.doInput = true
      urlConnection.instanceFollowRedirects = true
      if ("GET".equals(method, ignoreCase = true)) {
        urlConnection.doOutput = false
      }
      urlConnection.connect()
      return urlConnection
    } catch (e: Exception) {
      if (e !is SSLHandshakeException) {
        Log.e(LOG_TAG, "", e)
      }
      urlConnection?.disconnect()
    }
    return null
  }

  /**
   * SslCertificate class does not has a public getter for the underlying
   * X509Certificate, we can only do this by hack. This only works for Android 4.0+
   * https://groups.google.com/forum/#!topic/android-developers/eAPJ6b7mrmg
   */
  @JvmStatic
  fun getX509CertFromSslCertHack(sslCert: SslCertificate): X509Certificate? {
    val bytes = SslCertificate.saveState(sslCert).getByteArray("x509-certificate") ?: return null
    return try {
      CertificateFactory.getInstance("X.509")
        .generateCertificate(ByteArrayInputStream(bytes)) as X509Certificate
    } catch (e: CertificateException) {
      null
    }
  }

  @JvmStatic
  fun JSONStringify(value: Any?): String = when (value) {
    null -> "null"
    is Map<*, *> -> JSONObject(value as Map<String, Any?>).toString()
    is List<*> -> JSONArray(value as List<Any?>).toString()
    is String -> JSONObject.quote(value)
    // wrap() returns null for a value it cannot represent. The Java threw NPE here; !! keeps
    // that behaviour rather than silently producing the string "null".
    else -> JSONObject.wrap(value)!!.toString()
  }

  @JvmStatic
  fun objEquals(a: Any?, b: Any?): Boolean = Objects.equals(a, b)

  @JvmStatic
  fun replaceAll(s: String, oldString: String, newString: String): String =
    TextUtils.join(newString, s.split(Pattern.quote(oldString).toRegex()).toTypedArray())

  @JvmStatic
  fun log(tag: String, message: String) {
    // Split by line, then ensure each line can fit into Log's maximum length.
    var i = 0
    val length = message.length
    while (i < length) {
      var newline = message.indexOf('\n', i)
      if (newline == -1) {
        newline = length
      }
      do {
        val end = Math.min(newline, i + 4000)
        Log.d(tag, message.substring(i, end))
        i = end
      } while (i < newline)
      i++
    }
  }

  @JvmStatic
  fun getPixelDensity(context: Context): Float = context.resources.displayMetrics.density

  @JvmStatic
  fun getFullscreenSize(context: Context): Size2D {
    val fullscreenSize = Size2D(-1.0, -1.0)
    val wm = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager?
    if (wm != null) {
      val metrics = wm.currentWindowMetrics
      // Gets all excluding insets
      val insets = metrics.windowInsets.getInsetsIgnoringVisibility(
        WindowInsets.Type.navigationBars() or WindowInsets.Type.displayCutout()
      )
      val insetsWidth = insets.right + insets.left
      val insetsHeight = insets.top + insets.bottom
      val bounds = metrics.bounds
      fullscreenSize.width = (bounds.width() - insetsWidth).toDouble()
      fullscreenSize.height = (bounds.height() - insetsHeight).toDouble()
    }
    return fullscreenSize
  }

  @JvmStatic
  fun isClass(className: String): Boolean = try {
    Class.forName(className)
    true
  } catch (e: ClassNotFoundException) {
    false
  }

  /**
   * Strips one layer of `[...]` from an IPv6 literal, if present.
   *
   * `Uri.getHost()` keeps the brackets for an IPv6 authority, so callers may pass either form.
   */
  private fun stripIPv6Brackets(address: String): String =
    if (address.length > 2 && address.startsWith("[") && address.endsWith("]")) {
      address.substring(1, address.length - 1)
    } else {
      address
    }

  /**
   * Whether [address] is an IPv6 **literal**. Purely syntactic: it never touches the network.
   *
   * This used to be `Inet6Address.getByName(address); true`, which answered a different question.
   * `Inet6Address` declares no `getByName`, so that call resolved to the inherited
   * `InetAddress.getByName` — which parses IPv4 literals *and resolves hostnames* — and nothing
   * type-checked the result. So `127.0.0.1` and `example.com` both returned `true`, and every
   * check could cost a DNS lookup on the calling thread.
   *
   * Two guards keep this off the network. A DNS name cannot contain `:`, so requiring one rejects
   * hostnames before `getByName` can try to resolve one; and passing the **bracketed** form makes
   * `getByName` parse literal-only and throw for anything else, rather than falling through to a
   * lookup. The `is Inet6Address` check is what makes the answer mean what the name says.
   */
  @JvmStatic
  fun isIPv6(address: String): Boolean {
    val literal = stripIPv6Brackets(address)
    if (!literal.contains(':')) {
      return false
    }
    return try {
      InetAddress.getByName("[$literal]") is Inet6Address
    } catch (e: UnknownHostException) {
      false
    }
  }

  /**
   * The canonical textual form of an IPv6 literal, for comparing two spellings of one address.
   *
   * This used to return `canonicalHostName`, which is a **reverse DNS lookup**: it produced a
   * *hostname* rather than a normalized address (`::1` came back as `"localhost"`), ran on the
   * calling thread, and leaked the host being checked to the resolver. Worse, it made two
   * unrelated addresses compare equal whenever they happened to share a canonical name — and
   * because [isIPv6] accepted anything resolvable, it ran for every origin check rather than only
   * IPv6 ones.
   *
   * `hostAddress` is the field that normalizes, and needs no lookup.
   */
  @JvmStatic
  @Throws(Exception::class)
  fun normalizeIPv6(address: String): String {
    val literal = stripIPv6Brackets(address)
    if (!isIPv6(literal)) {
      throw Exception("Invalid address: $address")
    }
    return InetAddress.getByName("[$literal]").hostAddress
      ?: throw Exception("Invalid address: $address")
  }

  /**
   * Whether a wildcard origin rule's host matches a page host.
   *
   * The rule host is a `*` followed by a suffix — `*.example.com` — and the match is **anchored at
   * the end of the host**. This used to be `host.contains(suffix)`, an unanchored substring test,
   * so a rule of `*.example.com` also matched `foo.example.com.evil.test`: the suffix occurs in the
   * middle of a host whose registrable domain belongs to somebody else. The origin allow-list is
   * the only thing standing between a page and a `WebMessageListener`, so an unanchored match is a
   * way in.
   *
   * Because the suffix of a `*.` rule begins with a dot, anchoring at the end also anchors on a
   * label boundary, which is what makes this "subdomains only": `*.example.com` matches
   * `foo.example.com` and **not** bare `example.com`. That last part is not new — `example.com`
   * does not contain `.example.com` either — and nothing that matched before matches now, because
   * `endsWith(s)` is a subset of `contains(s)` for the same `s`. This is a pure tightening.
   *
   * The dotless spelling `*example.com` is left exactly as it behaved: it still matches
   * `notexample.com`, because its suffix carries no label boundary to anchor on. Rejecting that
   * form was considered and not chosen — it is [assertOriginRulesValid]'s business, not this
   * predicate's, and iOS already refuses it there.
   *
   * This lives in [Util] rather than next to its caller so a JVM unit test can reach it: the caller
   * needs `android.net.Uri`, and this module deliberately leaves `returnDefaultValues` off, so any
   * `android.*` call from a unit test throws `Stub!`.
   *
   * @see dev.nosferatu500.inappwebview.webview.web_message.WebMessageListener.isOriginAllowed
   */
  @JvmStatic
  fun hostMatchesWildcardRule(ruleHost: String, host: String?): Boolean {
    if (host == null || !ruleHost.startsWith("*")) {
      return false
    }
    // Everything between the leading `*` and the next `*`, if any. Deliberately the same extraction
    // the substring test used, so anchoring is the only axis this function changed.
    val suffix = ruleHost.split("\\*".toRegex())[1]
    return host.endsWith(suffix)
  }

  @JvmStatic
  fun <T> getOrDefault(map: Map<String, Any?>, key: String, defaultValue: T): T =
    if (map.containsKey(key)) map[key] as T else defaultValue

  @JvmStatic
  fun readAllBytes(inputStream: InputStream?): ByteArray? {
    if (inputStream == null) {
      return null
    }

    val bufLen = 4 * 0x400 // 4KB
    val buf = ByteArray(bufLen)
    var readLen: Int
    var exception: IOException? = null
    val outputStream = ByteArrayOutputStream()
    var data: ByteArray? = null

    try {
      while (inputStream.read(buf, 0, bufLen).also { readLen = it } != -1) {
        outputStream.write(buf, 0, readLen)
      }
      data = outputStream.toByteArray()
    } catch (e: IOException) {
      exception = e
    } finally {
      try {
        inputStream.close()
      } catch (e: IOException) {
        exception?.addSuppressed(e)
      }
      try {
        outputStream.close()
      } catch (e: IOException) {
        exception?.addSuppressed(e)
      }
    }
    return data
  }

  @JvmStatic
  fun <O : Any> invokeMethodIfExists(o: O, methodName: String, vararg args: Any?): Any? {
    for (method in o.javaClass.methods) {
      if (method.name == methodName) {
        return try {
          method.invoke(o, *args)
        } catch (e: IllegalAccessException) {
          null
        } catch (e: InvocationTargetException) {
          null
        }
      }
    }
    return null
  }

  @JvmStatic
  fun drawableFromBytes(context: Context, data: ByteArray): Drawable =
    BitmapDrawable(context.resources, BitmapFactory.decodeByteArray(data, 0, data.size))
}
