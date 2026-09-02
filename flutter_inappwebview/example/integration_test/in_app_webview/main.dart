import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import '../util.dart';
import '../constants.dart';
import '../env.dart';

part 'supported.dart';
part 'apple_pay_api.dart';
part 'audio_playback_policy.dart';
part 'clear_all_cache.dart';
part 'clear_client_cert_preferences.dart';
part 'clear_focus.dart';
part 'clear_ssl_preferences.dart';
part 'content_blocker.dart';
part 'create_pdf.dart';
part 'get_certificate.dart';
part 'get_content_height.dart';
part 'post_visual_state_callback.dart';
part 'document_has_images.dart';
part 'fling_scroll.dart';
part 'get_current_web_view_package.dart';
part 'get_default_user_agent.dart';
part 'get_favicons.dart';
part 'get_html.dart';
part 'get_meta_tags.dart';
part 'get_meta_theme_color.dart';
part 'get_original_url.dart';
part 'get_progress.dart';
part 'get_title.dart';
part 'handles_url_scheme.dart';
part 'http_auth_credential_database.dart';
part 'initial_url_request.dart';
part 'inject_css.dart';
part 'inject_javascript_file.dart';
part 'intercept_ajax_request.dart';
part 'intercept_fetch_request.dart';
part 'is_loading.dart';
part 'is_secure_context.dart';
part 'javascript_code_evaluation.dart';
part 'javascript_dialogs.dart';
part 'javascript_handler.dart';
part 'javascript_handler_error.dart';
part 'load_data.dart';
part 'load_file.dart';
part 'load_file_url.dart';
part 'load_url.dart';
part 'on_console_message.dart';
part 'on_content_size_changed.dart';
part 'on_download_starting.dart';
part 'on_js_before_unload.dart';
part 'on_received_error.dart';
part 'on_received_http_error.dart';
part 'on_load_resource.dart';
part 'on_load_resource_with_custom_scheme.dart';
part 'on_navigation_response.dart';
part 'on_page_commit_visible.dart';
part 'on_permission_request.dart';
part 'on_print_request.dart';
part 'on_progress_changed.dart';
part 'on_received_touch_icon_url.dart';
part 'safe_browsing.dart';
part 'on_scroll_changed.dart';
part 'on_title_changed.dart';
part 'on_update_visited_history.dart';
part 'on_window_blur.dart';
part 'on_window_focus.dart';
part 'page_down_up.dart';
part 'pause_resume.dart';
part 'programmatic_zoom_scale.dart';
part 'pause_resume_timers.dart';
part 'post_requests.dart';
part 'print_current_page.dart';
part 'programmatic_scroll.dart';
part 'pull_to_refresh.dart';
part 'reload.dart';
part 'request_focus_node_href.dart';
part 'request_image_ref.dart';
part 'resize_webview.dart';
part 'web_archive.dart';
part 'set_custom_useragent.dart';
part 'conversation_context.dart';
part 'obscured_content_insets.dart';
part 'screen_time.dart';
part 'set_get_settings.dart';
part 'set_web_contents_debugging_enabled.dart';
part 'should_intercept_request.dart';
part 'should_override_url_loading.dart';
part 'ssl_request.dart';
part 'stop_loading.dart';
part 't_rex_runner_game.dart';
part 'take_screenshot.dart';
part 'user_scripts.dart';
part 'video_playback_policy.dart';
part 'web_history.dart';
part 'web_message.dart';
part 'webview_asset_loader.dart';
part 'webview_windows.dart';
part 'keep_alive.dart';

void main() {
  final shouldSkip = !InAppWebViewController.isClassSupported();

  skippableGroup('InAppWebView', () {
    setUpAll(() async {
      if (InAppWebViewController.isMethodSupported(
        PlatformInAppWebViewControllerMethod.setWebContentsDebuggingEnabled,
      )) {
        await InAppWebViewController.setWebContentsDebuggingEnabled(true);
      }
    });

    supported();
    initialUrlRequest();
    setGetSettings();
    javascriptCodeEvaluation();
    loadUrl();
    loadFileUrl();
    javascriptHandler();
    javascriptHandlerError();
    resizeWebView();
    setCustomUserAgent();
    videoPlaybackPolicy();
    audioPlaybackPolicy();
    getTitle();
    programmaticScroll();
    shouldOverrideUrlLoading();
    onReceivedError();
    webViewWindows();
    interceptAjaxRequest();
    interceptFetchRequest();
    contentBlocker();
    httpAuthCredentialDatabase();
    onConsoleMessage();
    onDownloadStarting();
    javascriptDialogs();
    onReceivedHttpError();
    onLoadResourceWithCustomScheme();
    onLoadResource();
    onUpdateVisitedHistory();
    onProgressChanged();
    safeBrowsing();
    onScrollChanged();
    sslRequest();
    onWindowFocus();
    onWindowBlur();
    onPageCommitVisible();
    onTitleChanged();
    programmaticZoomScale();
    onPermissionRequest();
    shouldInterceptRequest();
    onReceivedTouchIconUrl();
    onJsBeforeUnload();
    onNavigationResponse();
    postRequests();
    loadData();
    loadFile();
    reload();
    webHistory();
    getProgress();
    getHtml();
    getFavicons();
    isLoading();
    stopLoading();
    injectJavascriptFile();
    injectCSS();
    takeScreenshot();
    clearAllCache();
    tRexRunnerGame();
    pauseResumeTimers();
    getContentHeight();
    postVisualStateCallback();
    documentHasImages();
    flingScroll();
    clearFocus();
    requestFocusNodeHref();
    requestImageRef();
    getMetaTags();
    getMetaThemeColor();
    getCertificate();
    userScripts();
    webArchive();
    isSecureContext();
    getDefaultUserAgent();
    pullToRefresh();
    webMessage();
    clearSslPreferences();
    pauseResume();
    getOriginalUrl();
    pageDownUp();
    clearClientCertPreferences();
    getCurrentWebViewPackage();
    setWebContentsDebuggingEnabled();
    createPdf();
    applePayAPI();
    handlesURLScheme();
    webViewAssetLoader();
    onContentSizeChanged();
    screenTime();
    obscuredContentInsets();
    conversationContext();
    keepAlive();

    // `printCurrentPage` MUST BE LAST, and must stay last.
    //
    // It raises the platform's modal print UI, and nothing in the plugin API can dismiss it again —
    // `PrintJobController.dispose()` maps to Android's `PrintJob.cancel()`, and that is a no-op
    // while the job is still in CREATED state, which is exactly the state it is in while the dialog
    // is open (verified on API 37). That is correct behaviour: `printCurrentPage()` is an explicit
    // request to print, so there is nothing to decline.
    //
    // On Android 17 / API 37 the dialog then sits on top as
    // `com.android.printspooler/.ui.PrintActivity` and every test after it times out at 60s
    // waiting for a UI it can never reach: measured three times, ~60 tests lost and the app
    // finally ANR-killed. API 33 and both iOS versions do not block, but the ordering is the only
    // thing that makes the group safe everywhere.
    //
    // `onPrintRequest` no longer belongs to that set: since 7.0.0 Dart is asked *before* the job is
    // created, and the test returns `true`, so no dialog is raised at all. It is kept next to
    // `printCurrentPage` only because they are the same subject.
    onPrintRequest();
    printCurrentPage();
  }, skip: shouldSkip);
}
