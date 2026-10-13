package dev.nosferatu500.inappwebview.chrome_custom_tabs

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.browser.customtabs.CustomTabsService
import dev.nosferatu500.inappwebview.pigeons.AndroidResourceData
import dev.nosferatu500.inappwebview.pigeons.ChromeCustomTabsFlutterApi
import dev.nosferatu500.inappwebview.pigeons.ChromeCustomTabsHostApi
import dev.nosferatu500.inappwebview.pigeons.CustomTabsSecondaryToolbarData
import dev.nosferatu500.inappwebview.types.AndroidResource
import dev.nosferatu500.inappwebview.types.CustomTabsSecondaryToolbar
import dev.nosferatu500.inappwebview.types.Disposable
import io.flutter.plugin.common.BinaryMessenger

/**
 * Transport is Pigeon-generated ([ChromeCustomTabsHostApi] / [ChromeCustomTabsFlutterApi]) rather
 * than a hand-written `MethodChannel`; the thirteenth channel migrated, and the largest so far at
 * **nine host methods plus thirteen events**.
 *
 * **Per-instance**: the `messageChannelSuffix` is the view id, threaded from
 * [ChromeCustomTabsActivity] into both `setUp` and the FlutterApi constructor so the halves cannot
 * drift.
 *
 * 🚨 **A mismatch is asymmetric, and both halves are now measured** — §177 could only test one,
 * because print_job's single event is unreachable from a test. This channel's thirteen events
 * closed the other half:
 *
 * | direction | a wrong suffix produces |
 * |---|---|
 * | HostApi | `PlatformException(channel-error, …)` in ~2s, naming the full channel (§177) |
 * | FlutterApi | a **60-second timeout and no error at all** (measured here) |
 *
 * The caller of a host method is awaiting a reply, so Pigeon turns the missing handler into a named
 * error. An event has nothing awaiting it, so it simply never arrives — which is the silent mode
 * §165 originally saw, now explained rather than just recorded. With thirteen events on this
 * channel, that silent half is the larger risk.
 *
 * **None of the nine host methods is `@async`**: each answers inline, so Pigeon's own `try`/`catch`
 * around the synchronous handlers is the only error path and §172's `replyingOnThrow` has nothing to
 * wrap.
 *
 * The class-level `@Suppress("UNCHECKED_CAST")` is **gone**. It existed because every structured
 * read was a `Map<String, Any?>` cast at the codec boundary; the generated types are typed, so the
 * casts and the suppression both disappear. That is the clearest win this migration buys.
 */
class ChromeCustomTabsChannelDelegate(
  chromeCustomTabsActivity: ChromeCustomTabsActivity,
  messenger: BinaryMessenger,
  private val suffix: String
) : Disposable, ChromeCustomTabsHostApi {

  private var chromeCustomTabsActivity: ChromeCustomTabsActivity? =
    chromeCustomTabsActivity

  private var messenger: BinaryMessenger? = messenger

  private var flutterApi: ChromeCustomTabsFlutterApi? =
    ChromeCustomTabsFlutterApi(messenger, suffix)

  init {
    ChromeCustomTabsHostApi.setUp(messenger, this, suffix)
  }

  override fun launchUrl(
    url: String,
    headers: Map<String, String>?,
    referrer: String?,
    otherLikelyURLs: List<String>?
  ): Boolean {
    val activity = chromeCustomTabsActivity ?: return false
    activity.launchUrl(url, headers, referrer, otherLikelyURLs)
    return true
  }

  override fun mayLaunchUrl(url: String?, otherLikelyURLs: List<String>?): Boolean {
    val activity = chromeCustomTabsActivity ?: return false
    return activity.mayLaunchUrl(url, otherLikelyURLs)
  }

  override fun updateActionButton(icon: ByteArray, description: String): Boolean {
    val activity = chromeCustomTabsActivity ?: return false
    activity.updateActionButton(icon, description)
    return true
  }

  /**
   * 🚨 **The one inbound narrowing on this channel, and §162's lint trap does *not* fire on it.**
   * Pigeon hands a `Long`, androidx's `validateRelationship(@Relation int, Uri, Bundle)` wants an
   * `Int`, and `@Relation` is an `@IntDef` — the shape that made §162's `.toInt()` compile cleanly
   * and then fail `lintDebug` with `[WrongConstant]`.
   *
   * Measured at the lint gate rather than predicted: **0 errors, no `WrongConstant`.** So §162's
   * finding is narrower than "any narrowed int reaching an androidx `@IntDef`" — its case was a
   * `@IntDef(flag = true)` varargs array built from a list, where lint could see a collection it
   * could not verify. A single narrowed value passes.
   */
  override fun validateRelationship(relation: Long, origin: String): Boolean {
    val session = chromeCustomTabsActivity?.customTabsSession ?: return false
    return session.validateRelationship(relation.toInt(), Uri.parse(origin), null)
  }

  /**
   * ⚠️ **No test covers this payload.** `add and update secondary toolbar` asserts only that the
   * call does not throw: a mutant replacing `secondaryToolbar.toNative()` with `null` — dropping the
   * layout and every clickable id — **passes it**. So the conversion below, which is the most
   * intricate part of this schema, has transport coverage and no payload coverage.
   *
   * Verifying it would mean asserting that a remote view rendered inside a Custom Tab, or tapping
   * one to make `onSecondaryItemActionPerform` fire; neither is reachable from `WidgetTester`.
   * Recorded rather than papered over with a test that would measure the same nothing.
   */
  override fun updateSecondaryToolbar(
    secondaryToolbar: CustomTabsSecondaryToolbarData
  ): Boolean {
    val activity = chromeCustomTabsActivity ?: return false
    activity.updateSecondaryToolbar(secondaryToolbar.toNative())
    return true
  }

  override fun requestPostMessageChannel(
    sourceOrigin: String,
    targetOrigin: String?
  ): Boolean {
    val session = chromeCustomTabsActivity?.customTabsSession ?: return false
    return session.requestPostMessageChannel(
      Uri.parse(sourceOrigin),
      targetOrigin?.let { Uri.parse(it) },
      Bundle()
    )
  }

  /**
   * Answers `CustomTabsService`'s own result code. `RESULT_FAILURE_MESSAGING_ERROR` for a missing
   * session is a *value*, not a failure envelope — preserved from the hand-written channel.
   */
  override fun postMessage(message: String): Long {
    val session = chromeCustomTabsActivity?.customTabsSession
      ?: return CustomTabsService.RESULT_FAILURE_MESSAGING_ERROR.toLong()
    return session.postMessage(message, Bundle()).toLong()
  }

  /**
   * The `try`/`catch (Throwable)` is preserved deliberately: the androidx call throws on builds that
   * do not implement the API, and turning "unsupported" into a `PlatformException` would be a
   * behaviour change rather than a migration.
   */
  override fun isEngagementSignalsApiAvailable(): Boolean {
    val session = chromeCustomTabsActivity?.customTabsSession ?: return false
    return try {
      session.isEngagementSignalsApiAvailable(Bundle())
    } catch (e: Throwable) {
      false
    }
  }

  override fun close(): Boolean {
    val activity = chromeCustomTabsActivity ?: return false
    activity.onStop()
    activity.onDestroy()
    activity.close()

    val hostActivity = activity.manager?.plugin?.activity
    if (hostActivity != null) {
      // https://stackoverflow.com/a/41596629/4637638
      val myIntent = Intent(hostActivity, hostActivity.javaClass)
      myIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
      myIntent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
      hostActivity.startActivity(myIntent)
    }
    activity.dispose()
    return true
  }

  // --- events -----------------------------------------------------------------------------------
  //
  // Fire-and-forget, as the hand-written `channel.invokeMethod` calls were: Pigeon's generated
  // FlutterApi reports delivery through a callback and discarding it keeps the previous behaviour
  // rather than inventing error handling for events nothing awaits. Same shape as §165 and §177.

  fun onServiceConnected() {
    flutterApi?.onServiceConnected {}
  }

  fun onOpened() {
    flutterApi?.onOpened {}
  }

  fun onCompletedInitialLoad() {
    flutterApi?.onCompletedInitialLoad {}
  }

  fun onNavigationEvent(navigationEvent: Int) {
    flutterApi?.onNavigationEvent(navigationEvent.toLong()) {}
  }

  fun onClosed() {
    flutterApi?.onClosed {}
  }

  fun onItemActionPerform(id: Int, url: String?, title: String?) {
    flutterApi?.onItemActionPerform(id.toLong(), url, title) {}
  }

  fun onSecondaryItemActionPerform(name: String?, url: String?) {
    flutterApi?.onSecondaryItemActionPerform(name, url) {}
  }

  fun onRelationshipValidationResult(relation: Int, requestedOrigin: Uri, result: Boolean) {
    flutterApi?.onRelationshipValidationResult(
      relation.toLong(),
      requestedOrigin.toString(),
      result
    ) {}
  }

  fun onMessageChannelReady() {
    flutterApi?.onMessageChannelReady {}
  }

  fun onPostMessage(message: String) {
    flutterApi?.onPostMessage(message) {}
  }

  fun onVerticalScrollEvent(isDirectionUp: Boolean) {
    flutterApi?.onVerticalScrollEvent(isDirectionUp) {}
  }

  fun onGreatestScrollPercentageIncreased(scrollPercentage: Int) {
    flutterApi?.onGreatestScrollPercentageIncreased(scrollPercentage.toLong()) {}
  }

  fun onSessionEnded(didUserInteract: Boolean) {
    flutterApi?.onSessionEnded(didUserInteract) {}
  }

  override fun dispose() {
    // Unregisters the generated handler for *this suffix*. Skipping it would leave a closed tab's
    // handler bound to the messenger for the life of the engine.
    //
    // Safe to call `dispose`, unlike §177's delegate: this channel's teardown method is `close`, so
    // there is no collision with `Disposable.dispose()` and no recursion to design around.
    messenger?.let { ChromeCustomTabsHostApi.setUp(it, null, suffix) }
    messenger = null
    flutterApi = null
    chromeCustomTabsActivity = null
  }
}

// --- Pigeon -> native ---------------------------------------------------------------------------
//
// Kept local rather than added to `types/`, as §177 did: `AndroidResource` and
// `CustomTabsSecondaryToolbar` also serve the settings path and the InAppBrowser menu, and this
// conversion is inbound-only for this one channel.

private fun AndroidResourceData.toNative(): AndroidResource =
  AndroidResource(name, defType, defPackage)

/**
 * The public `clickableIDs` is a list of one-key wrappers whose other field (`onClick`) never
 * crossed the wire; the schema flattens it to the resources themselves, so this rebuild is direct.
 */
private fun CustomTabsSecondaryToolbarData.toNative(): CustomTabsSecondaryToolbar =
  CustomTabsSecondaryToolbar(layout.toNative(), clickableIDs.map { it.toNative() })
