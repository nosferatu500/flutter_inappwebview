package dev.nosferatu500.inappwebview

import android.util.Log
import android.webkit.CookieManager
import androidx.webkit.CookieManagerCompat
import androidx.webkit.ProfileStore
import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.pigeons.CookieData
import dev.nosferatu500.inappwebview.pigeons.CookieManagerHostApi
import dev.nosferatu500.inappwebview.pigeons.CookieToSetData
import dev.nosferatu500.inappwebview.types.Disposable
import io.flutter.plugin.common.BinaryMessenger
import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone

/**
 * Transport is Pigeon-generated ([CookieManagerHostApi]) rather than a hand-written `MethodChannel`;
 * the eighth channel migrated, after find_interaction (§14), process_global_config (§157),
 * proxy (§160), webview_feature (§161), tracing_controller (§162), credential_database (§163) and
 * both web_message channels (§165).
 *
 * There is no `messageChannelSuffix`: `android.webkit.CookieManager` is process-global, so there is
 * one channel rather than one per WebView.
 *
 * **Five of the twelve methods are `@async`** — the ones whose completion arrives on a
 * `ValueCallback`. [deleteCookies] is the odd one out and is deliberately synchronous; see its
 * KDoc. Every method but [isFileSchemeCookiesAllowed] takes a `profileName`, and §167's device tests
 * cover both the resolution and the null-manager branch.
 */
class MyCookieManager(plugin: InAppWebViewFlutterPlugin) : Disposable, CookieManagerHostApi {

  @JvmField
  var plugin: InAppWebViewFlutterPlugin? = plugin

  private var messenger: BinaryMessenger? = plugin.messenger

  init {
    CookieManagerHostApi.setUp(plugin.messenger, this)
  }

  override fun setCookie(
    cookie: CookieToSetData,
    profileName: String?,
    callback: (Result<Boolean>) -> Unit
  ) {
    val manager = getCookieManager(profileName)
    if (manager == null) {
      callback(Result.success(false))
      return
    }

    manager.setCookie(cookie.url, buildCookieValue(cookie)) { successful ->
      callback(Result.success(successful))
    }
    manager.flush()
  }

  /**
   * Sets several cookies from one channel call.
   *
   * The framework has no batch API, so this loops — the saving is the single channel round trip,
   * which was measured to be ~94% of the cost of doing this from Dart one call at a time.
   *
   * Two details that are not incidental. **[CookieManager.setCookie]'s callback is asynchronous**,
   * so the results are written into a fixed-size array by index and the reply is sent only once
   * the last one lands; collecting them by append order would scramble the mapping the Dart side
   * documents. And **[CookieManager.flush] is called once at the end** rather than once per
   * cookie, which the singular path cannot do.
   *
   * The empty case is also short-circuited on the Dart side, so it never reaches here; the guard
   * stays because this interface is reachable from anything that speaks the channel.
   */
  override fun setCookies(
    cookies: List<CookieToSetData>,
    profileName: String?,
    callback: (Result<List<Boolean>>) -> Unit
  ) {
    val manager = getCookieManager(profileName)
    if (manager == null) {
      callback(Result.success(List(cookies.size) { false }))
      return
    }
    if (cookies.isEmpty()) {
      callback(Result.success(emptyList()))
      return
    }

    val outcomes = arrayOfNulls<Boolean>(cookies.size)
    var remaining = cookies.size

    for ((index, cookie) in cookies.withIndex()) {
      manager.setCookie(cookie.url, buildCookieValue(cookie)) { successful ->
        outcomes[index] = successful
        remaining--
        if (remaining == 0) {
          manager.flush()
          callback(Result.success(outcomes.map { it == true }))
        }
      }
    }
  }

  override fun getCookies(url: String, profileName: String?): List<CookieData> {
    val manager = getCookieManager(profileName) ?: return emptyList()

    val hasCookieInfo = WebViewFeature.isFeatureSupported(WebViewFeature.GET_COOKIE_INFO)
    val cookies: List<String> = if (hasCookieInfo) {
      CookieManagerCompat.getCookieInfo(manager, url)
    } else {
      manager.getCookie(url)?.split(";") ?: emptyList()
    }

    val result = mutableListOf<CookieData>()
    for (cookie in cookies) {
      val cookieParams = cookie.split(";").toTypedArray()
      if (cookieParams.isEmpty()) continue

      val nameValue = cookieParams[0].split("=".toRegex(), 2).toTypedArray()
      val name = nameValue[0].trim()
      val value = if (nameValue.size > 1) nameValue[1].trim() else ""

      if (!hasCookieInfo) {
        // Without GET_COOKIE_INFO the platform returns a bare `name=value` list, so there are no
        // attributes to parse and every other field stays null.
        result.add(CookieData(name = name, value = value))
        continue
      }

      var expiresDate: Long? = null
      var domain: String? = null
      var sameSite: String? = null
      var isSecure = false
      var isHttpOnly = false
      var path: String? = null

      for (i in 1 until cookieParams.size) {
        val paramNameValue = cookieParams[i].split("=".toRegex(), 2).toTypedArray()
        val paramName = paramNameValue[0].trim()
        val paramValue = if (paramNameValue.size > 1) paramNameValue[1].trim() else ""

        when {
          paramName.equals("Expires", ignoreCase = true) -> {
            try {
              val sdf = SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss z", Locale.US)
              sdf.parse(paramValue)?.let { expiresDate = it.time }
            } catch (e: ParseException) {
              Log.e(LOG_TAG, "", e)
            }
          }

          paramName.equals("Max-Age", ignoreCase = true) -> {
            try {
              expiresDate = System.currentTimeMillis() + paramValue.toLong()
            } catch (e: NumberFormatException) {
              Log.e(LOG_TAG, "", e)
            }
          }

          paramName.equals("Domain", ignoreCase = true) -> domain = paramValue

          paramName.equals("SameSite", ignoreCase = true) -> sameSite = paramValue

          paramName.equals("Secure", ignoreCase = true) -> isSecure = true

          paramName.equals("HttpOnly", ignoreCase = true) -> isHttpOnly = true

          paramName.equals("Path", ignoreCase = true) -> path = paramValue
        }
      }

      result.add(
        CookieData(
          name = name,
          value = value,
          expiresDate = expiresDate,
          domain = domain,
          sameSite = sameSite,
          isSecure = isSecure,
          isHttpOnly = isHttpOnly,
          path = path
        )
      )
    }
    return result
  }

  override fun deleteCookie(
    url: String,
    name: String,
    domain: String?,
    path: String,
    profileName: String?,
    callback: (Result<Boolean>) -> Unit
  ) {
    val manager = getCookieManager(profileName)
    if (manager == null) {
      callback(Result.success(false))
      return
    }

    manager.setCookie(url, expiringCookieValue(name, domain, path)) { successful ->
      callback(Result.success(successful))
    }
    manager.flush()
  }

  /**
   * Synchronous, unlike its singular sibling: the per-cookie writes pass a **null** callback, so
   * nothing signals completion and the reply is a literal `true` meaning "the expiring writes were
   * issued". That is the behaviour the hand-written channel had and it is preserved rather than
   * tightened — turning it into a real per-cookie answer would be a behaviour change, not a
   * migration.
   */
  override fun deleteCookies(
    url: String,
    domain: String?,
    path: String,
    profileName: String?
  ): Boolean {
    val manager = getCookieManager(profileName) ?: return false

    val cookiesString = manager.getCookie(url)
    if (cookiesString != null) {
      for (cookie in cookiesString.split(";")) {
        val name = cookie.split("=".toRegex(), 2).toTypedArray()[0].trim()
        manager.setCookie(url, expiringCookieValue(name, domain, path), null)
      }
      manager.flush()
    }
    return true
  }

  override fun deleteAllCookies(profileName: String?, callback: (Result<Boolean>) -> Unit) {
    val manager = getCookieManager(profileName)
    if (manager == null) {
      callback(Result.success(false))
      return
    }

    manager.removeAllCookies { successful -> callback(Result.success(successful)) }
    manager.flush()
  }

  override fun removeSessionCookies(profileName: String?, callback: (Result<Boolean>) -> Unit) {
    val manager = getCookieManager(profileName)
    if (manager == null) {
      callback(Result.success(false))
      return
    }

    manager.removeSessionCookies { successful -> callback(Result.success(successful)) }
    manager.flush()
  }

  /**
   * Note the reply: without it the channel never answers and the Dart `await flush()` never
   * completes -- a hang rather than an error (P0b.9, §55). Pigeon makes the missing reply
   * unrepresentable, which is the point of this migration for this method in particular.
   */
  override fun flush(profileName: String?): Boolean {
    val manager = getCookieManager(profileName) ?: return false
    manager.flush()
    return true
  }

  /**
   * Store-wide, so it takes no url -- unlike [getCookies], which is per-origin.
   *
   * Sends null rather than false when the store cannot be resolved: "there are no cookies" and
   * "nothing was read" are different answers, and a caller skipping a logout-time clear on the
   * strength of a false would skip it for a store that does hold cookies.
   */
  override fun hasCookies(profileName: String?): Boolean? =
    getCookieManager(profileName)?.hasCookies()

  /**
   * `CookieManager.allowFileSchemeCookies` is a **static** on the framework class, so there is no
   * manager instance to act on and no profile to scope to -- which is why this is the one method
   * here with no `profileName`.
   *
   * It still resolves the manager first, and only as a guard: the static delegates to the WebView
   * provider internally and throws if none is installed, while `getCookieManager()` already wraps
   * exactly that case (MissingWebViewPackageException and the Chromium 559720
   * IllegalArgumentException) and answers null. Reusing it turns a crash into the same null this
   * class's other getters send.
   *
   * The setter, `setAcceptFileSchemeCookies`, is deprecated and deliberately not exposed.
   */
  override fun isFileSchemeCookiesAllowed(): Boolean? {
    if (getCookieManager() == null) {
      return null
    }
    return CookieManager.allowFileSchemeCookies()
  }

  /**
   * The cookie master switch. Unlike every other write here there is nothing to flush: acceptance
   * is a runtime property of the CookieManager, not stored cookie data, and calling `flush()`
   * afterwards would only write out unrelated pending cookies.
   *
   * Reports false rather than throwing when the store cannot be resolved, matching the other
   * write paths on this class.
   */
  override fun setAcceptCookie(accept: Boolean, profileName: String?): Boolean {
    val manager = getCookieManager(profileName) ?: return false
    manager.setAcceptCookie(accept)
    return true
  }

  /**
   * Sends null -- not false -- when the store cannot be resolved. The platform default is `true`,
   * so false would tell the caller cookies are being rejected when nothing was actually read.
   */
  override fun isAcceptCookieEnabled(profileName: String?): Boolean? =
    getCookieManager(profileName)?.acceptCookie()

  override fun dispose() {
    // Unregisters the generated handler. Skipping it would leave it bound to a disposed manager
    // for the life of the messenger.
    messenger?.let { CookieManagerHostApi.setUp(it, null) }
    messenger = null
    plugin = null
  }

  companion object {
    private const val LOG_TAG = "MyCookieManager"

    /**
     * Cached because the *first* `CookieManager.getInstance()` loads Chromium (~100ms). Was a
     * public mutable `@JvmField` alongside a public `init()`; nothing outside this class ever
     * touched either — measured across the whole module — so both are gone, the cache is private
     * and resolution is lazy at the point of use rather than at the top of every dispatch.
     */
    private var cachedCookieManager: CookieManager? = null

    /**
     * The `Set-Cookie`-style string the framework's [CookieManager.setCookie] takes.
     *
     * Takes the wire type directly, so the singular and plural writes cannot drift: they were
     * previously kept in step by a hand-written Dart helper that had to spell `expiresDate` as a
     * String to match the singular call. One typed field removes that hazard rather than managing
     * it — see the schema's [CookieToSetData].
     *
     * [CookieToSetData.maxAge] stays a `Long` here: it is only interpolated into the attribute, so
     * narrowing to `Int` would buy nothing (§162's narrowing was forced by androidx demanding an
     * `int`; nothing does here).
     */
    private fun buildCookieValue(cookie: CookieToSetData): String {
      var value = "${cookie.name}=${cookie.value}; Path=${cookie.path}"

      cookie.domain?.let { value += "; Domain=$it" }
      cookie.expiresDate?.let { value += "; Expires=" + getCookieExpirationDate(it) }
      cookie.maxAge?.let { value += "; Max-Age=$it" }
      if (cookie.isSecure == true) value += "; Secure"
      if (cookie.isHttpOnly == true) value += "; HttpOnly"
      cookie.sameSite?.let { value += "; SameSite=$it" }

      value += ";"

      return value
    }

    /**
     * The `Set-Cookie` string that deletes a cookie: same name, empty value, already expired.
     *
     * Extracted because [deleteCookie] and [deleteCookies] built it with two copies of the same
     * four lines, which is how the singular and plural paths drift apart.
     */
    private fun expiringCookieValue(name: String, domain: String?, path: String): String {
      var value = "$name=; Path=$path; Max-Age=-1"
      if (domain != null) value += "; Domain=$domain"
      value += ";"
      return value
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
      if (cachedCookieManager == null) {
        try {
          cachedCookieManager = CookieManager.getInstance()
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

      return cachedCookieManager
    }

    private fun getCookieExpirationDate(timestamp: Long): String {
      val sdf = SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss z", Locale.US)
      sdf.timeZone = TimeZone.getTimeZone("GMT")
      return sdf.format(Date(timestamp))
    }
  }
}
