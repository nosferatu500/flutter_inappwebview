package dev.nosferatu500.inappwebview

import android.util.Log
import android.webkit.CookieManager
import androidx.webkit.CookieManagerCompat
import androidx.webkit.ProfileStore
import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.types.ChannelDelegateImpl
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone

class MyCookieManager(plugin: InAppWebViewFlutterPlugin) :
  ChannelDelegateImpl(MethodChannel(plugin.messenger, METHOD_CHANNEL_NAME)) {

  @JvmField
  var plugin: InAppWebViewFlutterPlugin? = plugin

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    init()

    // Null unless the caller scoped this single call to a profile; see PlatformCookieManager's
    // class doc for why the scope is per call rather than per manager instance.
    val profileName = call.argument<String>("profileName")

    when (call.method) {
      "setCookie" -> {
        val url = call.argument<String>("url")
        val name = call.argument<String>("name")
        val value = call.argument<String>("value")
        val domain = call.argument<String>("domain")
        val path = call.argument<String>("path")
        val expiresDateString = call.argument<String>("expiresDate")
        val expiresDate = expiresDateString?.toLong()
        val maxAge = call.argument<Int>("maxAge")
        val isSecure = call.argument<Boolean>("isSecure")
        val isHttpOnly = call.argument<Boolean>("isHttpOnly")
        val sameSite = call.argument<String>("sameSite")
        setCookie(
          url, name, value, domain, path, expiresDate, maxAge, isSecure, isHttpOnly, sameSite,
          profileName, result
        )
      }

      "getCookies" -> result.success(getCookies(call.argument("url"), profileName))

      "deleteCookie" -> deleteCookie(
        call.argument("url"), call.argument("name"), call.argument("domain"),
        call.argument("path"), profileName, result
      )

      "deleteCookies" -> deleteCookies(
        call.argument("url"), call.argument("domain"), call.argument("path"), profileName, result
      )

      "deleteAllCookies" -> deleteAllCookies(profileName, result)

      "removeSessionCookies" -> removeSessionCookies(profileName, result)

      "flush" -> flush(profileName, result)

      "setAcceptCookie" -> setAcceptCookie(call.argument("accept"), profileName, result)

      "isAcceptCookieEnabled" -> isAcceptCookieEnabled(profileName, result)

      else -> result.notImplemented()
    }
  }

  fun setCookie(
    url: String?,
    name: String?,
    value: String?,
    domain: String?,
    path: String?,
    expiresDate: Long?,
    maxAge: Int?,
    isSecure: Boolean?,
    isHttpOnly: Boolean?,
    sameSite: String?,
    profileName: String?,
    result: MethodChannel.Result
  ) {
    val manager = getCookieManager(profileName)
    if (manager == null) {
      result.success(false)
      return
    }

    var cookieValue = "$name=$value; Path=$path"

    if (domain != null) cookieValue += "; Domain=$domain"
    if (expiresDate != null) cookieValue += "; Expires=" + getCookieExpirationDate(expiresDate)
    if (maxAge != null) cookieValue += "; Max-Age=$maxAge"
    if (isSecure != null && isSecure) cookieValue += "; Secure"
    if (isHttpOnly != null && isHttpOnly) cookieValue += "; HttpOnly"
    if (sameSite != null) cookieValue += "; SameSite=$sameSite"

    cookieValue += ";"

    manager.setCookie(url, cookieValue) { successful -> result.success(successful) }
    manager.flush()
  }

  fun getCookies(url: String?, profileName: String?): List<Map<String, Any?>> {
    val cookieListMap = mutableListOf<Map<String, Any?>>()

    val manager = getCookieManager(profileName) ?: return cookieListMap

    var cookies: List<String> = emptyList()
    if (WebViewFeature.isFeatureSupported(WebViewFeature.GET_COOKIE_INFO)) {
      cookies = CookieManagerCompat.getCookieInfo(manager, url!!)
    } else {
      manager.getCookie(url)?.let { cookies = it.split(";") }
    }

    for (cookie in cookies) {
      val cookieParams = cookie.split(";").toTypedArray()
      if (cookieParams.isEmpty()) continue

      val nameValue = cookieParams[0].split("=".toRegex(), 2).toTypedArray()
      val name = nameValue[0].trim()
      val value = if (nameValue.size > 1) nameValue[1].trim() else ""

      val cookieMap = hashMapOf<String, Any?>(
        "name" to name,
        "value" to value,
        "expiresDate" to null,
        "isSessionOnly" to null,
        "domain" to null,
        "sameSite" to null,
        "isSecure" to null,
        "isHttpOnly" to null,
        "path" to null
      )

      if (WebViewFeature.isFeatureSupported(WebViewFeature.GET_COOKIE_INFO)) {
        cookieMap["isSecure"] = false
        cookieMap["isHttpOnly"] = false

        for (i in 1 until cookieParams.size) {
          val cookieParamNameValue = cookieParams[i].split("=".toRegex(), 2).toTypedArray()
          val cookieParamName = cookieParamNameValue[0].trim()
          val cookieParamValue =
            if (cookieParamNameValue.size > 1) cookieParamNameValue[1].trim() else ""

          when {
            cookieParamName.equals("Expires", ignoreCase = true) -> {
              try {
                val sdf = SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss z", Locale.US)
                sdf.parse(cookieParamValue)?.let { cookieMap["expiresDate"] = it.time }
              } catch (e: ParseException) {
                Log.e(LOG_TAG, "", e)
              }
            }

            cookieParamName.equals("Max-Age", ignoreCase = true) -> {
              try {
                val maxAge = cookieParamValue.toLong()
                cookieMap["expiresDate"] = System.currentTimeMillis() + maxAge
              } catch (e: NumberFormatException) {
                Log.e(LOG_TAG, "", e)
              }
            }

            cookieParamName.equals("Domain", ignoreCase = true) ->
              cookieMap["domain"] = cookieParamValue

            cookieParamName.equals("SameSite", ignoreCase = true) ->
              cookieMap["sameSite"] = cookieParamValue

            cookieParamName.equals("Secure", ignoreCase = true) ->
              cookieMap["isSecure"] = true

            cookieParamName.equals("HttpOnly", ignoreCase = true) ->
              cookieMap["isHttpOnly"] = true

            cookieParamName.equals("Path", ignoreCase = true) ->
              cookieMap["path"] = cookieParamValue
          }
        }
      }

      cookieListMap.add(cookieMap)
    }
    return cookieListMap
  }

  fun deleteCookie(
    url: String?,
    name: String?,
    domain: String?,
    path: String?,
    profileName: String?,
    result: MethodChannel.Result
  ) {
    val manager = getCookieManager(profileName)
    if (manager == null) {
      result.success(false)
      return
    }

    var cookieValue = "$name=; Path=$path; Max-Age=-1"
    if (domain != null) cookieValue += "; Domain=$domain"
    cookieValue += ";"

    manager.setCookie(url, cookieValue) { successful -> result.success(successful) }
    manager.flush()
  }

  fun deleteCookies(
    url: String?,
    domain: String?,
    path: String?,
    profileName: String?,
    result: MethodChannel.Result
  ) {
    val manager = getCookieManager(profileName)
    if (manager == null) {
      result.success(false)
      return
    }

    val cookiesString = manager.getCookie(url)
    if (cookiesString != null) {
      for (cookie in cookiesString.split(";")) {
        val name = cookie.split("=".toRegex(), 2).toTypedArray()[0].trim()

        var cookieValue = "$name=; Path=$path; Max-Age=-1"
        if (domain != null) cookieValue += "; Domain=$domain"
        cookieValue += ";"

        manager.setCookie(url, cookieValue, null)
      }

      manager.flush()
    }
    result.success(true)
  }

  fun deleteAllCookies(profileName: String?, result: MethodChannel.Result) {
    val manager = getCookieManager(profileName)
    if (manager == null) {
      result.success(false)
      return
    }

    manager.removeAllCookies { successful -> result.success(successful) }
    manager.flush()
  }

  fun removeSessionCookies(profileName: String?, result: MethodChannel.Result) {
    val manager = getCookieManager(profileName)
    if (manager == null) {
      result.success(false)
      return
    }

    manager.removeSessionCookies { successful -> result.success(successful) }
    manager.flush()
  }

  /**
   * Note the reply on the success path: without it the channel never answers and the Dart
   * `await flush()` never completes -- a hang rather than an error, since a MethodChannel has no
   * timeout and nothing supplies a missing reply.
   */
  fun flush(profileName: String?, result: MethodChannel.Result) {
    val manager = getCookieManager(profileName)
    if (manager == null) {
      result.success(false)
      return
    }
    manager.flush()
    result.success(true)
  }

  /**
   * The cookie master switch. Unlike every other write here there is nothing to flush: acceptance
   * is a runtime property of the CookieManager, not stored cookie data, and calling `flush()`
   * afterwards would only write out unrelated pending cookies.
   *
   * Reports false rather than throwing when the store cannot be resolved, matching the other
   * write paths on this class.
   */
  fun setAcceptCookie(accept: Boolean?, profileName: String?, result: MethodChannel.Result) {
    val manager = getCookieManager(profileName)
    if (manager == null || accept == null) {
      result.success(false)
      return
    }

    manager.setAcceptCookie(accept)
    result.success(true)
  }

  /**
   * Sends null -- not false -- when the store cannot be resolved. The platform default is `true`,
   * so false would tell the caller cookies are being rejected when nothing was actually read.
   */
  fun isAcceptCookieEnabled(profileName: String?, result: MethodChannel.Result) {
    val manager = getCookieManager(profileName)
    if (manager == null) {
      result.success(null)
      return
    }

    result.success(manager.acceptCookie())
  }

  override fun dispose() {
    super.dispose()
    plugin = null
  }

  companion object {
    protected const val LOG_TAG = "MyCookieManager"
    const val METHOD_CHANNEL_NAME = "dev.nosferatu500.inappwebview/inappwebview_cookiemanager"

    @JvmField
    var cookieManager: CookieManager? = null

    @JvmStatic
    fun init() {
      if (cookieManager == null) {
        cookieManager = getCookieManager()
      }
    }

    /**
     * Resolves the [CookieManager] a call should act on.
     *
     * A null [profileName] means the default cookie store, which is the cached process-wide
     * singleton below. A non-null one means that profile's own store, and returns null -- so the
     * caller reports failure -- when `MULTI_PROFILE` is unsupported or no such profile exists.
     * It never silently falls back to the default store, because writing a session cookie into the
     * wrong profile is worse than not writing it.
     *
     * Uses `getProfile`, not `getOrCreateProfile`: reading a profile's cookies must not bring the
     * profile into existence, and a profile that does not exist has no cookies. `getProfile` also
     * returns null for a profile deleted by `deleteProfile`, which is what keeps
     * `Profile.getCookieManager()` -- which throws for a deleted profile -- out of reach here.
     *
     * Deliberately not cached per profile. The cache below exists because the *first*
     * `CookieManager.getInstance()` loads Chromium; once that has happened, resolving a profile's
     * manager is a lookup inside androidx. A cache here would also have to be invalidated on
     * profile deletion.
     */
    private fun getCookieManager(profileName: String?): CookieManager? {
      if (profileName == null) {
        return getCookieManager()
      }
      if (!WebViewFeature.isFeatureSupported(WebViewFeature.MULTI_PROFILE)) {
        return null
      }
      return ProfileStore.getInstance().getProfile(profileName)?.cookieManager
    }

    /**
     * Instantiating CookieManager will load the Chromium task taking a 100ish ms so we do it lazily
     * to make sure it's done on a background thread as needed.
     *
     * https://github.com/facebook/react-native/blob/1903f6680d9750e244d97c3cd4a9f755a9a47c61/ReactAndroid/src/main/java/com/facebook/react/modules/network/ForwardingCookieHandler.java#L132
     */
    private fun getCookieManager(): CookieManager? {
      if (cookieManager == null) {
        try {
          cookieManager = CookieManager.getInstance()
        } catch (ex: IllegalArgumentException) {
          // https://bugs.chromium.org/p/chromium/issues/detail?id=559720
          return null
        } catch (exception: Exception) {
          val message = exception.message
          // We cannot catch MissingWebViewPackageException as it is in a private / system API
          // class. This validates the exception's message to ensure we are only handling this
          // specific exception.
          // https://android.googlesource.com/platform/frameworks/base/+/master/core/java/android/webkit/WebViewFactory.java#348
          if (message != null &&
            exception.javaClass.canonicalName ==
            "android.webkit.WebViewFactory.MissingWebViewPackageException"
          ) {
            return null
          } else {
            throw exception
          }
        }
      }

      return cookieManager
    }

    @JvmStatic
    fun getCookieExpirationDate(timestamp: Long): String {
      val sdf = SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss z", Locale.US)
      sdf.timeZone = TimeZone.getTimeZone("GMT")
      return sdf.format(Date(timestamp))
    }
  }
}
