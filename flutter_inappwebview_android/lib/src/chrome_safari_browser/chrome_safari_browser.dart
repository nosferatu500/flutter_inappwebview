import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../pigeons/chrome_custom_tabs.g.dart';

/// Object specifying creation parameters for creating a [AndroidChromeSafariBrowser].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformChromeSafariBrowserCreationParams] for
/// more information.
@immutable
class AndroidChromeSafariBrowserCreationParams
    extends PlatformChromeSafariBrowserCreationParams {
  /// Creates a new [AndroidChromeSafariBrowserCreationParams] instance.
  const AndroidChromeSafariBrowserCreationParams();

  /// Creates a [AndroidChromeSafariBrowserCreationParams] instance based on [PlatformChromeSafariBrowserCreationParams].
  factory AndroidChromeSafariBrowserCreationParams.fromPlatformChromeSafariBrowserCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformChromeSafariBrowserCreationParams params,
  ) {
    return AndroidChromeSafariBrowserCreationParams();
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser}
/// Receives [ChromeCustomTabsFlutterApi] events and forwards them to the browser.
///
/// 🚨 **A separate class, and here the collision §14 predicted is unavoidable rather than merely
/// awkward.** `PlatformChromeSafariBrowserEvents` declares eleven of these thirteen names as
/// **methods taking domain types** — `onNavigationEvent(CustomTabsNavigationEventType?)`,
/// `onRelationshipValidationResult(CustomTabsRelationType?, WebUri?, bool)` — and users override
/// them. Pigeon generates methods of the same names taking wire types (`int`, `String`). One class
/// cannot inherit both sets, so the browser cannot implement the generated API directly.
///
/// That makes this forwarder the place where wire values become domain values: every
/// `fromNativeValue` and `WebUri` construction that used to live in the `_handleMethod` switch lives
/// here now, with the types checked by the compiler instead of by a cast.
///
/// Third time for §14's prediction after find_interaction and print_job (§177), and the largest.
class _ChromeCustomTabsFlutterApiImpl implements ChromeCustomTabsFlutterApi {
  _ChromeCustomTabsFlutterApiImpl(this._browser);

  final AndroidChromeSafariBrowser _browser;

  @override
  void onServiceConnected() {
    _browser._debugLog('onServiceConnected', {});
    _browser.eventHandler?.onServiceConnected();
  }

  @override
  void onOpened() {
    _browser._debugLog('onOpened', {});
    _browser.eventHandler?.onOpened();
  }

  @override
  void onCompletedInitialLoad() {
    _browser._debugLog('onCompletedInitialLoad', {});
    // `null` on purpose: Android has never sent `didLoadSuccessfully` — the Kotlin passed an empty
    // map and the old Dart read a key that was not there. See the schema.
    _browser.eventHandler?.onCompletedInitialLoad(null);
  }

  @override
  void onNavigationEvent(int navigationEvent) {
    _browser._debugLog('onNavigationEvent', {
      'navigationEvent': navigationEvent,
    });
    _browser.eventHandler?.onNavigationEvent(
      CustomTabsNavigationEventType.fromNativeValue(navigationEvent),
    );
  }

  @override
  void onClosed() {
    _browser._debugLog('onClosed', {});
    _browser._handleClosed();
  }

  @override
  void onItemActionPerform(int id, String? url, String? title) {
    _browser._debugLog('onItemActionPerform', {
      'id': id,
      'url': url,
      'title': title,
    });
    // `!` preserves the old behaviour exactly: the previous code read these into non-nullable
    // `String`s, so a null from the platform threw there too. Not silently fixed here — whether the
    // platform can send null is a contract question, not a transport one. See the schema.
    _browser._dispatchItemAction(id, url!, title!);
  }

  @override
  void onSecondaryItemActionPerform(String? name, String? url) {
    _browser._debugLog('onSecondaryItemActionPerform', {
      'name': name,
      'url': url,
    });
    _browser._dispatchSecondaryItemAction(
      name,
      url != null ? WebUri(url) : null,
    );
  }

  @override
  void onRelationshipValidationResult(
    int relation,
    String requestedOrigin,
    bool result,
  ) {
    _browser._debugLog('onRelationshipValidationResult', {
      'relation': relation,
      'requestedOrigin': requestedOrigin,
      'result': result,
    });
    _browser.eventHandler?.onRelationshipValidationResult(
      CustomTabsRelationType.fromNativeValue(relation),
      WebUri(requestedOrigin),
      result,
    );
  }

  @override
  void onMessageChannelReady() {
    _browser._debugLog('onMessageChannelReady', {});
    _browser.eventHandler?.onMessageChannelReady();
  }

  @override
  void onPostMessage(String message) {
    _browser._debugLog('onPostMessage', {'message': message});
    _browser.eventHandler?.onPostMessage(message);
  }

  @override
  void onVerticalScrollEvent(bool isDirectionUp) {
    _browser._debugLog('onVerticalScrollEvent', {
      'isDirectionUp': isDirectionUp,
    });
    _browser.eventHandler?.onVerticalScrollEvent(isDirectionUp);
  }

  @override
  void onGreatestScrollPercentageIncreased(int scrollPercentage) {
    _browser._debugLog('onGreatestScrollPercentageIncreased', {
      'scrollPercentage': scrollPercentage,
    });
    _browser.eventHandler?.onGreatestScrollPercentageIncreased(
      scrollPercentage,
    );
  }

  @override
  void onSessionEnded(bool didUserInteract) {
    _browser._debugLog('onSessionEnded', {'didUserInteract': didUserInteract});
    _browser.eventHandler?.onSessionEnded(didUserInteract);
  }
}

class AndroidChromeSafariBrowser extends PlatformChromeSafariBrowser {
  @override
  final String id = IdGenerator.generate();

  /// Constructs a [AndroidChromeSafariBrowser].
  AndroidChromeSafariBrowser(PlatformChromeSafariBrowserCreationParams params)
    : super.implementation(
        params is AndroidChromeSafariBrowserCreationParams
            ? params
            : AndroidChromeSafariBrowserCreationParams.fromPlatformChromeSafariBrowserCreationParams(
                params,
              ),
      );

  static final AndroidChromeSafariBrowser _staticValue =
      AndroidChromeSafariBrowser(AndroidChromeSafariBrowserCreationParams());

  /// Provide static access.
  factory AndroidChromeSafariBrowser.static() {
    return _staticValue;
  }

  ChromeSafariBrowserActionButton? _actionButton;
  final Map<int, ChromeSafariBrowserMenuItem> _menuItems = HashMap();
  ChromeSafariBrowserSecondaryToolbar? _secondaryToolbar;
  bool _isOpened = false;
  static const MethodChannel _staticChannel = MethodChannel(
    'dev.nosferatu500.inappwebview/chromesafaribrowser',
  );

  /// Per-instance transport. The `messageChannelSuffix` is [id], which is also what the Kotlin
  /// side uses; §177 measured that a disagreement fails fast in the HostApi direction and
  /// **silently** in the event direction, and this channel has thirteen events.
  ChromeCustomTabsHostApi? _hostApi;

  void _init() {
    _hostApi = ChromeCustomTabsHostApi(messageChannelSuffix: id);
    ChromeCustomTabsFlutterApi.setUp(
      _ChromeCustomTabsFlutterApiImpl(this),
      messageChannelSuffix: id,
    );
  }

  void _debugLog(String method, dynamic args) {
    debugLog(
      className: runtimeType.toString(),
      id: id,
      debugLoggingSettings: PlatformChromeSafariBrowser.debugLoggingSettings,
      method: method,
      args: args,
    );
  }

  /// Dispatches one secondary-toolbar click to the `onClick` the caller registered for it.
  ///
  /// The platform reports the *resource full name* it resolved, so this rebuilds each registered
  /// id's full name the same way and matches on that. Unchanged from the hand-written dispatch.
  void _dispatchSecondaryItemAction(String? name, WebUri? url) {
    final clickableIDs = _secondaryToolbar?.clickableIDs;
    if (clickableIDs == null || name == null) {
      return;
    }
    for (final clickable in clickableIDs) {
      var clickableFullname = clickable.id.name;
      if (clickable.id.defType != null && !clickableFullname.contains("/")) {
        clickableFullname = "${clickable.id.defType}/$clickableFullname";
      }
      if (clickable.id.defPackage != null && !clickableFullname.contains(":")) {
        clickableFullname = "${clickable.id.defPackage}:$clickableFullname";
      }
      if (clickableFullname == name) {
        clickable.onClick?.call(url);
        break;
      }
    }
  }

  /// Dispatches an action-button or menu-item click to its registered `onClick`.
  void _dispatchItemAction(int id, String url, String title) {
    if (_actionButton?.id == id) {
      _actionButton?.onClick?.call(WebUri(url), title);
    } else if (_menuItems[id] != null) {
      _menuItems[id]?.onClick?.call(WebUri(url), title);
    }
  }

  /// Closes out the browser when the platform reports it gone.
  ///
  /// The ordering is load-bearing and preserved from the hand-written dispatch: the handler is
  /// captured **before** `dispose()`, because disposing clears `eventHandler`.
  void _handleClosed() {
    _isOpened = false;
    final onClosed = eventHandler?.onClosed;
    dispose();
    onClosed?.call();
  }

  @override
  Future<void> open({
    WebUri? url,
    Map<String, String>? headers,
    List<WebUri>? otherLikelyURLs,
    WebUri? referrer,
    ChromeSafariBrowserSettings? settings,
  }) async {
    assert(!_isOpened, 'The browser is already opened.');
    _isOpened = true;

    if (Util.isIOS) {
      assert(url != null, 'The specified URL must not be null on iOS.');
      assert(
        ['http', 'https'].contains(url!.scheme),
        'The specified URL has an unsupported scheme. Only HTTP and HTTPS URLs are supported on iOS.',
      );
    }
    if (url != null) {
      assert(url.toString().isNotEmpty, 'The specified URL must not be empty.');
    }

    _init();

    List<Map<String, dynamic>> menuItemList = [];
    _menuItems.forEach((key, value) {
      menuItemList.add(value.toMap());
    });

    var initialSettings =
        settings?.toMap() ?? ChromeSafariBrowserSettings().toMap();

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('id', () => id);
    args.putIfAbsent('url', () => url?.toString());
    args.putIfAbsent('headers', () => headers);
    args.putIfAbsent(
      'otherLikelyURLs',
      () => otherLikelyURLs?.map((e) => e.toString()).toList(),
    );
    args.putIfAbsent('referrer', () => referrer?.toString());
    args.putIfAbsent('settings', () => initialSettings);
    args.putIfAbsent('actionButton', () => _actionButton?.toMap());
    args.putIfAbsent('secondaryToolbar', () => _secondaryToolbar?.toMap());
    args.putIfAbsent('menuItemList', () => menuItemList);
    await _staticChannel.invokeMethod('open', args);
  }

  @override
  Future<void> launchUrl({
    required WebUri url,
    Map<String, String>? headers,
    List<WebUri>? otherLikelyURLs,
    WebUri? referrer,
  }) async {
    // The host answers whether the activity was still alive; the platform interface declares
    // `Future<void>`, so it is dropped here as it was before.
    await _hostApi?.launchUrl(
      url.toString(),
      headers,
      referrer?.toString(),
      otherLikelyURLs?.map((e) => e.toString()).toList(),
    );
  }

  @override
  Future<bool> mayLaunchUrl({
    WebUri? url,
    List<WebUri>? otherLikelyURLs,
  }) async {
    return await _hostApi?.mayLaunchUrl(
          url?.toString(),
          otherLikelyURLs?.map((e) => e.toString()).toList(),
        ) ??
        false;
  }

  @override
  Future<bool> validateRelationship({
    required CustomTabsRelationType relation,
    required WebUri origin,
  }) async {
    // `true` means only that the request was accepted; the verdict arrives on
    // onRelationshipValidationResult -- which never fires in this fork, because inappwebview.dev's
    // asset links delegate to the upstream package (§178).
    return await _hostApi?.validateRelationship(
          // `!` rather than a fallback: the old channel put this in a dynamic map and the Kotlin
          // read it with `call.argument<Int>("relation")!!`, so a null threw there too. Every
          // CustomTabsRelationType has a native value, so it cannot be null in practice.
          relation.toNativeValue()!,
          origin.toString(),
        ) ??
        false;
  }

  @override
  Future<void> close() async {
    await _hostApi?.close();
  }

  @override
  void setActionButton(ChromeSafariBrowserActionButton actionButton) {
    _actionButton = actionButton;
  }

  @override
  Future<void> updateActionButton({
    required Uint8List icon,
    required String description,
  }) async {
    await _hostApi?.updateActionButton(icon, description);
    _actionButton?.icon = icon;
    _actionButton?.description = description;
  }

  @override
  void setSecondaryToolbar(
    ChromeSafariBrowserSecondaryToolbar secondaryToolbar,
  ) {
    _secondaryToolbar = secondaryToolbar;
  }

  @override
  Future<void> updateSecondaryToolbar(
    ChromeSafariBrowserSecondaryToolbar secondaryToolbar,
  ) async {
    await _hostApi?.updateSecondaryToolbar(
      CustomTabsSecondaryToolbarData(
        layout: _toResourceData(secondaryToolbar.layout),
        // Flattened: the public wrapper's only other field is the `onClick` closure, which stays
        // here -- `_dispatchSecondaryItemAction` is what calls it. See the schema.
        clickableIDs: secondaryToolbar.clickableIDs
            .map((e) => _toResourceData(e.id))
            .toList(),
      ),
    );
    _secondaryToolbar = secondaryToolbar;
  }

  @override
  void addMenuItem(ChromeSafariBrowserMenuItem menuItem) {
    _menuItems[menuItem.id] = menuItem;
  }

  @override
  void addMenuItems(List<ChromeSafariBrowserMenuItem> menuItems) {
    for (var menuItem in menuItems) {
      _menuItems[menuItem.id] = menuItem;
    }
  }

  @override
  Future<bool> requestPostMessageChannel({
    required WebUri sourceOrigin,
    WebUri? targetOrigin,
  }) async {
    // NOTE: `true` does not mean a channel exists -- onMessageChannelReady is what says that.
    // §178 measured this answering `true` while the event never came.
    return await _hostApi?.requestPostMessageChannel(
          sourceOrigin.toString(),
          targetOrigin?.toString(),
        ) ??
        false;
  }

  @override
  Future<CustomTabsPostMessageResultType> postMessage(String message) async {
    // The host answers CustomTabsService's own result code, including
    // RESULT_FAILURE_MESSAGING_ERROR for a missing session -- a value, not an error envelope.
    return CustomTabsPostMessageResultType.fromNativeValue(
          await _hostApi?.postMessage(message),
        ) ??
        CustomTabsPostMessageResultType.FAILURE_MESSAGING_ERROR;
  }

  @override
  Future<bool> isEngagementSignalsApiAvailable() async {
    return await _hostApi?.isEngagementSignalsApiAvailable() ?? false;
  }

  @override
  Future<bool> isAvailable() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _staticChannel.invokeMethod<bool>("isAvailable", args) ??
        false;
  }

  @override
  Future<int> getMaxToolbarItems() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _staticChannel.invokeMethod<int>("getMaxToolbarItems", args) ??
        0;
  }

  @override
  Future<String?> getPackageName({
    List<String>? packages,
    bool ignoreDefault = false,
  }) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("packages", () => packages);
    args.putIfAbsent("ignoreDefault", () => ignoreDefault);
    return await _staticChannel.invokeMethod<String?>("getPackageName", args);
  }

  @override
  bool isOpened() {
    return _isOpened;
  }

  /// Converts a public [AndroidResource] into its wire form.
  static AndroidResourceData _toResourceData(AndroidResource resource) =>
      AndroidResourceData(
        name: resource.name,
        defType: resource.defType,
        defPackage: resource.defPackage,
      );

  @override
  @mustCallSuper
  void dispose() {
    super.dispose();
    // Unregisters this instance's event handler for its own suffix. Skipping it would leave a
    // closed browser's forwarder bound to the messenger for the life of the engine.
    ChromeCustomTabsFlutterApi.setUp(null, messageChannelSuffix: id);
    _hostApi = null;
  }
}
