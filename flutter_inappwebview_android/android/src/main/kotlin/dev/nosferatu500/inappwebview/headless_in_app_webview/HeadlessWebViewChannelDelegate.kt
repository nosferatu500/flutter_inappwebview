package dev.nosferatu500.inappwebview.headless_in_app_webview

import dev.nosferatu500.inappwebview.pigeons.HeadlessWebViewFlutterApi
import dev.nosferatu500.inappwebview.pigeons.HeadlessWebViewHostApi
import dev.nosferatu500.inappwebview.pigeons.Size2DData
import dev.nosferatu500.inappwebview.types.Size2D
import io.flutter.plugin.common.BinaryMessenger

/**
 * Transport is Pigeon-generated ([HeadlessWebViewHostApi] / [HeadlessWebViewFlutterApi]) rather than
 * a hand-written `MethodChannel`; the fourteenth channel migrated, and one of the smallest at
 * **three host methods plus one event**.
 *
 * **Per-instance**: the `messageChannelSuffix` is the headless webview id, threaded from
 * [HeadlessInAppWebView] into both `setUp` and the FlutterApi constructor so the halves cannot
 * drift. Both halves are covered by the `HeadlessInAppWebView` integration group — the host methods
 * by `set and get custom size`, the event by `run and dispose`, which awaits the controller that
 * [onWebViewCreated] delivers and so hangs for 60s if that half is wrong. That is the first time
 * both directions of a suffix have had test coverage on the same channel: §177 could only cover the
 * host half, and §179 covered the event half separately.
 *
 * **None of the three host methods is `@async`**: each answers inline, so Pigeon's own `try`/`catch`
 * around the synchronous handlers is the only error path and §172's `replyingOnThrow` has nothing to
 * wrap. Re-verified by reading the generated output rather than assumed.
 *
 * The class-level `@Suppress("UNCHECKED_CAST")` is **gone**, as it was on §179. It existed for the
 * single `call.argument<Map<String, Any?>>("size")` read at the codec boundary; [Size2DData] is
 * typed, so the cast and the suppression both disappear.
 *
 * 🚨 **This class deliberately does not extend `ChannelDelegateImpl`, and its teardown is called
 * [disposeDelegate]** — §177's collision, landing for the second time. The channel has a method
 * named `dispose`, so the generated interface contributes `fun dispose(): Boolean`, which cannot
 * coexist with `Disposable.dispose(): Unit` (same name, different return type).
 *
 * That much is a compile error and so is self-announcing. The part that is **not** is the call site:
 * [HeadlessInAppWebView.dispose] used to call `channelDelegate?.dispose()`, and after this migration
 * that name resolves to the *host* method below, which calls `webView.dispose()` straight back —
 * an infinite recursion that compiles cleanly and would only show up as a device-test stack
 * overflow. Hence [disposeDelegate], and hence the updated call site.
 */
class HeadlessWebViewChannelDelegate(
  headlessWebView: HeadlessInAppWebView,
  messenger: BinaryMessenger,
  private val suffix: String
) : HeadlessWebViewHostApi {

  private var headlessWebView: HeadlessInAppWebView? = headlessWebView

  private var messenger: BinaryMessenger? = messenger

  private var flutterApi: HeadlessWebViewFlutterApi? =
    HeadlessWebViewFlutterApi(messenger, suffix)

  init {
    HeadlessWebViewHostApi.setUp(messenger, this, suffix)
  }

  /**
   * `false` means the webview had already gone away — not that disposal failed. Preserved from the
   * hand-written channel, which the Dart side has never bound. See the schema, checklist item 9.
   *
   * 🚨 This is the *host* method. The teardown is [disposeDelegate]; calling this one from
   * [HeadlessInAppWebView.dispose] recurses forever.
   */
  override fun dispose(): Boolean {
    val webView = headlessWebView ?: return false
    webView.dispose()
    return true
  }

  /**
   * The hand-written channel ran the incoming map through `Size2D.fromMap` and applied nothing when
   * it came back null, while still answering `true`. Typed transport removes that arm entirely: a
   * malformed size can no longer reach this method.
   */
  override fun setSize(size: Size2DData): Boolean {
    val webView = headlessWebView ?: return false
    webView.setSize(size.toNative())
    return true
  }

  override fun getSize(): Size2DData? = headlessWebView?.getSize()?.toPigeon()

  /**
   * Fire-and-forget, as the hand-written `channel.invokeMethod` was: Pigeon's generated FlutterApi
   * reports delivery through a callback, and discarding it keeps the previous behaviour rather than
   * inventing error handling for an event nothing awaits. Same shape as §165, §177 and §179.
   */
  fun onWebViewCreated() {
    flutterApi?.onWebViewCreated {}
  }

  /**
   * Releases this delegate's channel registration. **Not** called `dispose` — see the class doc:
   * that name belongs to the host method above, and reusing it here recurses.
   */
  fun disposeDelegate() {
    // Unregisters the generated handler for *this suffix*. Skipping it would leave a disposed
    // webview's handler bound to the messenger for the life of the engine.
    messenger?.let { HeadlessWebViewHostApi.setUp(it, null, suffix) }
    messenger = null
    flutterApi = null
    headlessWebView = null
  }
}

// --- Size2D <-> Pigeon ---------------------------------------------------------------------------
//
// Kept local rather than added to `types/`, as §177 and §179 did: `Size2D` also serves
// `Util.getFullscreenSize` and the manager's `initialSize`, neither of which is a Pigeon concern
// yet. When the manager migrates it will want these two in a shared place — the schema records that
// as a prediction along with the type itself.
//
// No widening or narrowing in either direction: a size is two `Double`s on both sides, so §162's
// `[WrongConstant]` trap has nothing to fire on.

private fun Size2DData.toNative(): Size2D = Size2D(width, height)

private fun Size2D.toPigeon(): Size2DData = Size2DData(width = width, height = height)
