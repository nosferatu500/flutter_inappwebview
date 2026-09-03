import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../in_app_webview/platform_webview.dart';
import '../in_app_webview/in_app_webview_settings.dart';
import '../web_uri.dart';
import 'web_resource_error.dart';
import 'enum_method.dart';

part 'webview_navigation.g.dart';

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
@ExchangeableObject()
class WebViewNavigation_ {
  ///An identifier for this navigation, stable across
  ///[PlatformWebViewCreationParams.onNavigationStarted],
  ///[PlatformWebViewCreationParams.onNavigationRedirected] and
  ///[PlatformWebViewCreationParams.onNavigationCompleted].
  ///
  ///This is **synthesised by the plugin**, not a platform value: the platform identifies a
  ///navigation by object identity, which cannot cross a method channel. Ids are unique within a
  ///`WebView` and are released once the navigation completes, so do not persist one or compare it
  ///against an id from a different `WebView`.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  int id;

  ///The identifier of the page this navigation belongs to, or `null` when the platform reports no
  ///page for it — which is the normal case before a navigation has committed.
  ///
  ///Like [id] this is synthesised by the plugin. Unlike [id] it outlives the navigation: several
  ///navigations can share one page (a same-document navigation does not create a new page), and a
  ///page id stays valid until the page is deleted.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  int? pageId;

  ///The URL this navigation is currently for.
  ///
  ///This **changes across the sequence**: a redirected navigation reports the original URL at
  ///[PlatformWebViewCreationParams.onNavigationStarted] and the new one at each
  ///[PlatformWebViewCreationParams.onNavigationRedirected].
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  WebUri? url;

  ///Whether the page itself started this navigation — a link click, a form submission or a
  ///`location` assignment — rather than the app calling something like
  ///`PlatformInAppWebViewController.loadUrl`.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  bool wasInitiatedByPage;

  ///Whether this navigation stays within the same document, as a fragment navigation or a
  ///`history.pushState` does.
  ///
  ///A same-document navigation does not load a new document, so no new page is created and no load
  ///events fire for it.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  bool isSameDocument;

  ///Whether this navigation is a reload.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  bool isReload;

  ///Whether this navigation traverses the back/forward list, in either direction.
  ///
  ///[isBack] and [isForward] say which way; both are `false` for a history navigation that moves
  ///by more than one entry.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  bool isHistory;

  ///Whether this navigation goes back exactly one entry in the back/forward list.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  bool isBack;

  ///Whether this navigation goes forward exactly one entry in the back/forward list.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  bool isForward;

  ///Whether this navigation is restoring a previously saved session entry.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  bool isRestore;

  ///Whether the navigation has committed, i.e. the `WebView` has begun replacing the old document
  ///with the new one.
  ///
  ///This is `false` at [PlatformWebViewCreationParams.onNavigationStarted] and at
  ///[PlatformWebViewCreationParams.onNavigationRedirected]. At
  ///[PlatformWebViewCreationParams.onNavigationCompleted] it distinguishes a navigation that
  ///actually happened from one that was cancelled, superseded, or answered with a download.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  bool didCommit;

  ///Whether the navigation committed an error page rather than the content that was asked for.
  ///
  ///When this is `true`, [didCommit] is `true` as well — an error page is still a committed
  ///document — so test this one first if you are deciding whether a navigation succeeded.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  bool didCommitErrorPage;

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
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  int? statusCode;

  ///The error that stopped this navigation, or `null` if it was not stopped by one.
  ///
  ///Only ever set on [PlatformWebViewCreationParams.onNavigationCompleted], and only when the
  ///platform reports the navigation as failed rather than merely uncommitted.
  ///
  ///**On Android this needs a second feature check of its own**,
  ///[WebViewFeature.NAVIGATION_GET_WEB_RESOURCE_ERROR], which is finer-grained than the
  ///[WebViewFeature.NAVIGATION_LISTENER] that gates the events themselves. Where that is
  ///unsupported this is always `null` while every other field is still reported.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  WebResourceError_? webResourceError;

  WebViewNavigation_({
    required this.id,
    this.pageId,
    this.url,
    this.wasInitiatedByPage = false,
    this.isSameDocument = false,
    this.isReload = false,
    this.isHistory = false,
    this.isBack = false,
    this.isForward = false,
    this.isRestore = false,
    this.didCommit = false,
    this.didCommitErrorPage = false,
    this.statusCode,
    this.webResourceError,
  });
}
