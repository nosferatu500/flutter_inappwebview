// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webview_navigation.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///A snapshot of a single navigation, delivered to
///[PlatformWebViewCreationParams.onNavigationStarted],
///[PlatformWebViewCreationParams.onNavigationRedirected] and
///[PlatformWebViewCreationParams.onNavigationCompleted].
///
///**Every field is a snapshot taken at the moment the event fired, not a live view.** The platform
///reuses one navigation object across the whole `started -> redirected -> completed` sequence and
///mutates it in place — [url], [didCommit] and [statusCode] all change value between the
///callbacks — so a snapshot is the only thing that can cross the channel intact. Use [id] to tie
///the snapshots of one navigation together; it is stable for the whole sequence and is not reused
///afterwards.
///
///Requires [InAppWebViewSettings.useNavigationListener] to be `true`, and on Android also requires
///[WebViewFeature.NAVIGATION_LISTENER].
class WebViewNavigation {
  ///Whether the navigation has committed, i.e. the `WebView` has begun replacing the old document
  ///with the new one.
  ///
  ///This is `false` at [PlatformWebViewCreationParams.onNavigationStarted] and at
  ///[PlatformWebViewCreationParams.onNavigationRedirected]. At
  ///[PlatformWebViewCreationParams.onNavigationCompleted] it distinguishes a navigation that
  ///actually happened from one that was cancelled, superseded, or answered with a download.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  bool didCommit;

  ///Whether the navigation committed an error page rather than the content that was asked for.
  ///
  ///When this is `true`, [didCommit] is `true` as well — an error page is still a committed
  ///document — so test this one first if you are deciding whether a navigation succeeded.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  bool didCommitErrorPage;

  ///An identifier for this navigation, stable across
  ///[PlatformWebViewCreationParams.onNavigationStarted],
  ///[PlatformWebViewCreationParams.onNavigationRedirected] and
  ///[PlatformWebViewCreationParams.onNavigationCompleted].
  ///
  ///This is **synthesised by the plugin**, not a platform value: the platform identifies a
  ///navigation by object identity, which cannot cross a method channel. Ids are unique within a
  ///`WebView` and are released once the navigation completes, so do not persist one or compare it
  ///against an id from a different `WebView`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  int id;

  ///Whether this navigation goes back exactly one entry in the back/forward list.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  bool isBack;

  ///Whether this navigation goes forward exactly one entry in the back/forward list.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  bool isForward;

  ///Whether this navigation traverses the back/forward list, in either direction.
  ///
  ///[isBack] and [isForward] say which way; both are `false` for a history navigation that moves
  ///by more than one entry.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  bool isHistory;

  ///Whether this navigation is a reload.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  bool isReload;

  ///Whether this navigation is restoring a previously saved session entry.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  bool isRestore;

  ///Whether this navigation stays within the same document, as a fragment navigation or a
  ///`history.pushState` does.
  ///
  ///A same-document navigation does not load a new document, so no new page is created and no load
  ///events fire for it.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  bool isSameDocument;

  ///The identifier of the page this navigation belongs to, or `null` when the platform reports no
  ///page for it — which is the normal case before a navigation has committed.
  ///
  ///Like [id] this is synthesised by the plugin. Unlike [id] it outlives the navigation: several
  ///navigations can share one page (a same-document navigation does not create a new page), and a
  ///page id stays valid until the page is deleted.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  int? pageId;

  ///The HTTP status code of this navigation, or `null` when the platform has no status to report.
  ///
  ///**This is the only way to see the status code of a navigation that succeeded.**
  ///`PlatformWebViewCreationParams.onReceivedHttpError` fires only for error responses, so before
  ///this event a `200` was indistinguishable from no response at all.
  ///
  ///It is `null` until the navigation commits — so on
  ///[PlatformWebViewCreationParams.onNavigationStarted] and
  ///[PlatformWebViewCreationParams.onNavigationRedirected] — and `null` for a navigation that
  ///completes without committing.
  ///
  ///It is also `null` whenever there was no HTTP response to have a status: a same-document
  ///navigation, or a URL that carries no status at all such as `data:` or `file:`. Note that a
  ///same-document navigation **does** commit, so [didCommit] is not a reliable test for whether
  ///this is set — check this field for `null` instead. The platform reports `0` in those cases and
  ///the plugin maps it to `null`, because `0` is not a valid HTTP status and would quietly pass a
  ///`statusCode >= 400` check.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  int? statusCode;

  ///The URL this navigation is currently for.
  ///
  ///This **changes across the sequence**: a redirected navigation reports the original URL at
  ///[PlatformWebViewCreationParams.onNavigationStarted] and the new one at each
  ///[PlatformWebViewCreationParams.onNavigationRedirected].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  WebUri? url;

  ///Whether the page itself started this navigation — a link click, a form submission or a
  ///`location` assignment — rather than the app calling something like
  ///`PlatformInAppWebViewController.loadUrl`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  bool wasInitiatedByPage;

  ///The error that stopped this navigation, or `null` if it was not stopped by one.
  ///
  ///Only ever set on [PlatformWebViewCreationParams.onNavigationCompleted], and only when the
  ///platform reports the navigation as failed rather than merely uncommitted.
  ///
  ///**On Android this needs a second feature check of its own**,
  ///[WebViewFeature.NAVIGATION_GET_WEB_RESOURCE_ERROR], which is finer-grained than the
  ///[WebViewFeature.NAVIGATION_LISTENER] that gates the events themselves. Where that is
  ///unsupported this is always `null` while every other field is still reported.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  WebResourceError? webResourceError;
  WebViewNavigation({
    this.didCommit = false,
    this.didCommitErrorPage = false,
    required this.id,
    this.isBack = false,
    this.isForward = false,
    this.isHistory = false,
    this.isReload = false,
    this.isRestore = false,
    this.isSameDocument = false,
    this.pageId,
    this.statusCode,
    this.url,
    this.wasInitiatedByPage = false,
    this.webResourceError,
  });

  ///Gets a possible [WebViewNavigation] instance from a [Map] value.
  static WebViewNavigation? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = WebViewNavigation(
      id: map['id'],
      pageId: map['pageId'],
      statusCode: map['statusCode'],
      url: map['url'] != null ? WebUri(map['url']) : null,
      webResourceError: WebResourceError.fromMap(
        map['webResourceError']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
    );
    if (map['didCommit'] != null) {
      instance.didCommit = map['didCommit'];
    }
    if (map['didCommitErrorPage'] != null) {
      instance.didCommitErrorPage = map['didCommitErrorPage'];
    }
    if (map['isBack'] != null) {
      instance.isBack = map['isBack'];
    }
    if (map['isForward'] != null) {
      instance.isForward = map['isForward'];
    }
    if (map['isHistory'] != null) {
      instance.isHistory = map['isHistory'];
    }
    if (map['isReload'] != null) {
      instance.isReload = map['isReload'];
    }
    if (map['isRestore'] != null) {
      instance.isRestore = map['isRestore'];
    }
    if (map['isSameDocument'] != null) {
      instance.isSameDocument = map['isSameDocument'];
    }
    if (map['wasInitiatedByPage'] != null) {
      instance.wasInitiatedByPage = map['wasInitiatedByPage'];
    }
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "didCommit": didCommit,
      "didCommitErrorPage": didCommitErrorPage,
      "id": id,
      "isBack": isBack,
      "isForward": isForward,
      "isHistory": isHistory,
      "isReload": isReload,
      "isRestore": isRestore,
      "isSameDocument": isSameDocument,
      "pageId": pageId,
      "statusCode": statusCode,
      "url": url?.toString(),
      "wasInitiatedByPage": wasInitiatedByPage,
      "webResourceError": webResourceError?.toMap(enumMethod: enumMethod),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'WebViewNavigation{didCommit: $didCommit, didCommitErrorPage: $didCommitErrorPage, id: $id, isBack: $isBack, isForward: $isForward, isHistory: $isHistory, isReload: $isReload, isRestore: $isRestore, isSameDocument: $isSameDocument, pageId: $pageId, statusCode: $statusCode, url: $url, wasInitiatedByPage: $wasInitiatedByPage, webResourceError: $webResourceError}';
  }
}
