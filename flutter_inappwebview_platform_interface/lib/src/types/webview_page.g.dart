// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webview_page.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///A snapshot of one document loaded in the `WebView`, delivered to the page-lifecycle and
///Web-Vitals events:
///[PlatformWebViewCreationParams.onPageLoadEvent],
///[PlatformWebViewCreationParams.onPageDomContentLoadedEvent],
///[PlatformWebViewCreationParams.onPageDeleted],
///[PlatformWebViewCreationParams.onFirstContentfulPaintMillis],
///[PlatformWebViewCreationParams.onLargestContentfulPaintMillis] and
///[PlatformWebViewCreationParams.onPerformanceMarkMillis].
///
///A page is **not** the same thing as a navigation. Several navigations can share one page — a
///same-document navigation such as `history.pushState` does not create a new document — and a page
///outlives the navigation that created it, potentially by a long way: a page kept in the
///back/forward cache stays alive, and its events keep arriving, after the `WebView` has navigated
///somewhere else entirely. Use [id] to tell which document an event refers to.
///
///Requires [InAppWebViewSettings.useNavigationListener], and on Android also requires
///[WebViewFeature.NAVIGATION_LISTENER].
class WebViewPage {
  ///An identifier for this page, stable for as long as the document lives and matching
  ///[WebViewNavigation.pageId] on the navigations that belong to it.
  ///
  ///This is **synthesised by the plugin**, not a platform value: the platform identifies a page by
  ///object identity, which cannot cross a method channel. Ids are unique within a `WebView` and are
  ///released when [PlatformWebViewCreationParams.onPageDeleted] reports the document destroyed, so
  ///do not persist one or compare it against an id from a different `WebView`.
  ///
  ///Note that a page id is **not** released at the end of a navigation, unlike
  ///[WebViewNavigation.id]. A page in the back/forward cache can outlive many navigations, and one
  ///that is never evicted keeps its id for the life of the `WebView`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  int id;

  ///The URL of this page.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  WebUri? url;
  WebViewPage({required this.id, this.url});

  ///Gets a possible [WebViewPage] instance from a [Map] value.
  static WebViewPage? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = WebViewPage(
      id: map['id'],
      url: map['url'] != null ? WebUri(map['url']) : null,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {"id": id, "url": url?.toString()};
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'WebViewPage{id: $id, url: $url}';
  }
}
