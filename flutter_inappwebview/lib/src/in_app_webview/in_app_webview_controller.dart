import 'dart:core';

import 'package:flutter/services.dart';
import 'package:nosferatu500_inappwebview_platform_interface/nosferatu500_inappwebview_platform_interface.dart';

import '../print_job/main.dart';
import '../web_message/main.dart';
import '../web_storage/web_storage.dart';

///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController}
///
///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.supported_platforms}
class InAppWebViewController {
  /// Constructs a [InAppWebViewController].
  ///
  /// See [InAppWebViewController.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  InAppWebViewController.fromPlatformCreationParams({
    required PlatformInAppWebViewControllerCreationParams params,
  }) : this.fromPlatform(platform: PlatformInAppWebViewController(params));

  /// Constructs a [InAppWebViewController] from a specific platform implementation.
  InAppWebViewController.fromPlatform({required this.platform});

  /// Implementation of [PlatformInAppWebViewController] for the current platform.
  final PlatformInAppWebViewController platform;

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.webStorage}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.webStorage.supported_platforms}
  WebStorage get webStorage =>
      WebStorage.fromPlatform(platform: platform.webStorage);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getUrl}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getUrl.supported_platforms}
  Future<WebUri?> getUrl() => platform.getUrl();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getTitle}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getTitle.supported_platforms}
  Future<String?> getTitle() => platform.getTitle();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getProgress}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getProgress.supported_platforms}
  Future<int?> getProgress() => platform.getProgress();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getHtml}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getHtml.supported_platforms}
  Future<String?> getHtml() => platform.getHtml();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getFavicons}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getFavicons.supported_platforms}
  Future<List<Favicon>> getFavicons() => platform.getFavicons();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.loadUrl}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.loadUrl.supported_platforms}
  Future<void> loadUrl({
    required URLRequest urlRequest,
    WebUri? allowingReadAccessTo,
  }) => platform.loadUrl(
    urlRequest: urlRequest,
    allowingReadAccessTo: allowingReadAccessTo,
  );

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.postUrl}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.postUrl.supported_platforms}
  Future<void> postUrl({required WebUri url, required Uint8List postData}) =>
      platform.postUrl(url: url, postData: postData);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.loadData}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.loadData.supported_platforms}
  Future<void> loadData({
    required String data,
    String mimeType = "text/html",
    String encoding = "utf8",
    WebUri? baseUrl,
    WebUri? historyUrl,
    WebUri? allowingReadAccessTo,
  }) => platform.loadData(
    data: data,
    mimeType: mimeType,
    encoding: encoding,
    baseUrl: baseUrl,
    historyUrl: historyUrl,
    allowingReadAccessTo: allowingReadAccessTo,
  );

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.loadFile}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.loadFile.supported_platforms}
  Future<void> loadFile({required String assetFilePath}) =>
      platform.loadFile(assetFilePath: assetFilePath);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.reload}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.reload.supported_platforms}
  Future<void> reload() => platform.reload();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.goBack}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.goBack.supported_platforms}
  Future<void> goBack() => platform.goBack();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.canGoBack}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.canGoBack.supported_platforms}
  Future<bool> canGoBack() => platform.canGoBack();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.goForward}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.goForward.supported_platforms}
  Future<void> goForward() => platform.goForward();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.canGoForward}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.canGoForward.supported_platforms}
  Future<bool> canGoForward() => platform.canGoForward();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.goBackOrForward}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.goBackOrForward.supported_platforms}
  Future<void> goBackOrForward({required int steps}) =>
      platform.goBackOrForward(steps: steps);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.canGoBackOrForward}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.canGoBackOrForward.supported_platforms}
  Future<bool> canGoBackOrForward({required int steps}) =>
      platform.canGoBackOrForward(steps: steps);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.goTo}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.goTo.supported_platforms}
  Future<void> goTo({required WebHistoryItem historyItem}) =>
      platform.goTo(historyItem: historyItem);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.isLoading}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.isLoading.supported_platforms}
  Future<bool> isLoading() => platform.isLoading();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.stopLoading}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.stopLoading.supported_platforms}
  Future<void> stopLoading() => platform.stopLoading();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.evaluateJavascript}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.evaluateJavascript.supported_platforms}
  Future<dynamic> evaluateJavascript({
    required String source,
    ContentWorld? contentWorld,
  }) => platform.evaluateJavascript(source: source, contentWorld: contentWorld);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.injectJavascriptFileFromUrl}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.injectJavascriptFileFromUrl.supported_platforms}
  Future<void> injectJavascriptFileFromUrl({
    required WebUri urlFile,
    ScriptHtmlTagAttributes? scriptHtmlTagAttributes,
  }) => platform.injectJavascriptFileFromUrl(
    urlFile: urlFile,
    scriptHtmlTagAttributes: scriptHtmlTagAttributes,
  );

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.injectJavascriptFileFromAsset}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.injectJavascriptFileFromAsset.supported_platforms}
  Future<dynamic> injectJavascriptFileFromAsset({
    required String assetFilePath,
  }) => platform.injectJavascriptFileFromAsset(assetFilePath: assetFilePath);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.injectCSSCode}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.injectCSSCode.supported_platforms}
  Future<void> injectCSSCode({required String source}) =>
      platform.injectCSSCode(source: source);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.injectCSSFileFromUrl}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.injectCSSFileFromUrl.supported_platforms}
  Future<void> injectCSSFileFromUrl({
    required WebUri urlFile,
    CSSLinkHtmlTagAttributes? cssLinkHtmlTagAttributes,
  }) => platform.injectCSSFileFromUrl(
    urlFile: urlFile,
    cssLinkHtmlTagAttributes: cssLinkHtmlTagAttributes,
  );

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.injectCSSFileFromAsset}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.injectCSSFileFromAsset.supported_platforms}
  Future<void> injectCSSFileFromAsset({required String assetFilePath}) =>
      platform.injectCSSFileFromAsset(assetFilePath: assetFilePath);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.addJavaScriptHandler}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.addJavaScriptHandler.supported_platforms}
  void addJavaScriptHandler({
    required String handlerName,
    required Function callback,
  }) => platform.addJavaScriptHandler(
    handlerName: handlerName,
    callback: callback,
  );

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.removeJavaScriptHandler}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.removeJavaScriptHandler.supported_platforms}
  Function? removeJavaScriptHandler({required String handlerName}) =>
      platform.removeJavaScriptHandler(handlerName: handlerName);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.hasJavaScriptHandler}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.hasJavaScriptHandler.supported_platforms}
  bool hasJavaScriptHandler({required String handlerName}) =>
      platform.hasJavaScriptHandler(handlerName: handlerName);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.takeScreenshot}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.takeScreenshot.supported_platforms}
  Future<Uint8List?> takeScreenshot({
    ScreenshotConfiguration? screenshotConfiguration,
  }) =>
      platform.takeScreenshot(screenshotConfiguration: screenshotConfiguration);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.setSettings}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.setSettings.supported_platforms}
  Future<void> setSettings({required InAppWebViewSettings settings}) =>
      platform.setSettings(settings: settings);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getSettings}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getSettings.supported_platforms}
  Future<InAppWebViewSettings?> getSettings() => platform.getSettings();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getCopyBackForwardList}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getCopyBackForwardList.supported_platforms}
  Future<WebHistory?> getCopyBackForwardList() =>
      platform.getCopyBackForwardList();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.scrollTo}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.scrollTo.supported_platforms}
  Future<void> scrollTo({
    required int x,
    required int y,
    bool animated = false,
  }) => platform.scrollTo(x: x, y: y, animated: animated);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.scrollBy}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.scrollBy.supported_platforms}
  Future<void> scrollBy({
    required int x,
    required int y,
    bool animated = false,
  }) => platform.scrollBy(x: x, y: y, animated: animated);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.pauseTimers}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.pauseTimers.supported_platforms}
  Future<void> pauseTimers() => platform.pauseTimers();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.resumeTimers}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.resumeTimers.supported_platforms}
  Future<void> resumeTimers() => platform.resumeTimers();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.printCurrentPage}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.printCurrentPage.supported_platforms}
  Future<PrintJobController?> printCurrentPage({
    PrintJobSettings? settings,
  }) async {
    final printJobControllerPlatform = await platform.printCurrentPage(
      settings: settings,
    );
    if (printJobControllerPlatform == null) {
      return null;
    }
    return PrintJobController.fromPlatform(
      platform: printJobControllerPlatform,
    );
  }

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getContentHeight}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getContentHeight.supported_platforms}
  Future<int?> getContentHeight() => platform.getContentHeight();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getContentWidth}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getContentWidth.supported_platforms}
  Future<int?> getContentWidth() => platform.getContentWidth();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.zoomBy}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.zoomBy.supported_platforms}
  Future<void> zoomBy({required double zoomFactor, bool animated = false}) =>
      platform.zoomBy(zoomFactor: zoomFactor, animated: animated);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getOriginalUrl}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getOriginalUrl.supported_platforms}
  Future<WebUri?> getOriginalUrl() => platform.getOriginalUrl();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getZoomScale}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getZoomScale.supported_platforms}
  Future<double?> getZoomScale() => platform.getZoomScale();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getSelectedText}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getSelectedText.supported_platforms}
  Future<String?> getSelectedText() => platform.getSelectedText();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getHitTestResult}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getHitTestResult.supported_platforms}
  Future<InAppWebViewHitTestResult?> getHitTestResult() =>
      platform.getHitTestResult();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.requestFocus}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.requestFocus.supported_platforms}
  Future<bool?> requestFocus({
    FocusDirection? direction,
    InAppWebViewRect? previouslyFocusedRect,
  }) => platform.requestFocus(
    direction: direction,
    previouslyFocusedRect: previouslyFocusedRect,
  );

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.clearFocus}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.clearFocus.supported_platforms}
  Future<void> clearFocus() => platform.clearFocus();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.setInputMethodEnabled}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.setInputMethodEnabled.supported_platforms}
  Future<void> setInputMethodEnabled(bool enabled) =>
      platform.setInputMethodEnabled(enabled);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.showInputMethod}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.showInputMethod.supported_platforms}
  Future<void> showInputMethod() => platform.showInputMethod();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.setAudioMuted}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.setAudioMuted.supported_platforms}
  Future<void> setAudioMuted(bool muted) => platform.setAudioMuted(muted);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.isAudioMuted}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.isAudioMuted.supported_platforms}
  Future<bool> isAudioMuted() => platform.isAudioMuted();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.prerenderUrl}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.prerenderUrl.supported_platforms}
  Future<bool> prerenderUrl(WebUri url) => platform.prerenderUrl(url);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.hideInputMethod}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.hideInputMethod.supported_platforms}
  Future<void> hideInputMethod() => platform.hideInputMethod();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.setContextMenu}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.setContextMenu.supported_platforms}
  Future<void> setContextMenu(ContextMenu? contextMenu) =>
      platform.setContextMenu(contextMenu);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.requestFocusNodeHref}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.requestFocusNodeHref.supported_platforms}
  Future<RequestFocusNodeHrefResult?> requestFocusNodeHref() =>
      platform.requestFocusNodeHref();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.requestImageRef}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.requestImageRef.supported_platforms}
  Future<RequestImageRefResult?> requestImageRef() =>
      platform.requestImageRef();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getMetaTags}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getMetaTags.supported_platforms}
  Future<List<MetaTag>> getMetaTags() => platform.getMetaTags();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getMetaThemeColor}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getMetaThemeColor.supported_platforms}
  Future<Color?> getMetaThemeColor() => platform.getMetaThemeColor();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getScrollX}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getScrollX.supported_platforms}
  Future<int?> getScrollX() => platform.getScrollX();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getScrollY}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getScrollY.supported_platforms}
  Future<int?> getScrollY() => platform.getScrollY();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getCertificate}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getCertificate.supported_platforms}
  Future<SslCertificate?> getCertificate() => platform.getCertificate();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.addUserScript}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.addUserScript.supported_platforms}
  Future<void> addUserScript({required UserScript userScript}) =>
      platform.addUserScript(userScript: userScript);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.addUserScripts}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.addUserScripts.supported_platforms}
  Future<void> addUserScripts({required List<UserScript> userScripts}) =>
      platform.addUserScripts(userScripts: userScripts);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.removeUserScript}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.removeUserScript.supported_platforms}
  Future<bool> removeUserScript({required UserScript userScript}) =>
      platform.removeUserScript(userScript: userScript);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.removeUserScriptsByGroupName}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.removeUserScriptsByGroupName.supported_platforms}
  Future<void> removeUserScriptsByGroupName({required String groupName}) =>
      platform.removeUserScriptsByGroupName(groupName: groupName);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.removeUserScripts}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.removeUserScripts.supported_platforms}
  Future<void> removeUserScripts({required List<UserScript> userScripts}) =>
      platform.removeUserScripts(userScripts: userScripts);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.removeAllUserScripts}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.removeAllUserScripts.supported_platforms}
  Future<void> removeAllUserScripts() => platform.removeAllUserScripts();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.hasUserScript}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.hasUserScript.supported_platforms}
  bool hasUserScript({required UserScript userScript}) =>
      platform.hasUserScript(userScript: userScript);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.callAsyncJavaScript}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.callAsyncJavaScript.supported_platforms}
  Future<CallAsyncJavaScriptResult?> callAsyncJavaScript({
    required String functionBody,
    Map<String, dynamic> arguments = const <String, dynamic>{},
    ContentWorld? contentWorld,
  }) => platform.callAsyncJavaScript(
    functionBody: functionBody,
    arguments: arguments,
    contentWorld: contentWorld,
  );

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.saveWebArchive}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.saveWebArchive.supported_platforms}
  Future<String?> saveWebArchive({
    required String filePath,
    bool autoname = false,
  }) => platform.saveWebArchive(filePath: filePath, autoname: autoname);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.isSecureContext}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.isSecureContext.supported_platforms}
  Future<bool> isSecureContext() => platform.isSecureContext();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.createWebMessageChannel}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.createWebMessageChannel.supported_platforms}
  Future<WebMessageChannel?> createWebMessageChannel() async {
    final webMessagePlatform = await platform.createWebMessageChannel();
    if (webMessagePlatform == null) {
      return null;
    }
    return WebMessageChannel.fromPlatform(platform: webMessagePlatform);
  }

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.postWebMessage}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.postWebMessage.supported_platforms}
  Future<void> postWebMessage({
    required WebMessage message,
    WebUri? targetOrigin,
  }) => platform.postWebMessage(message: message, targetOrigin: targetOrigin);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.addWebMessageListener}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.addWebMessageListener.supported_platforms}
  Future<void> addWebMessageListener(WebMessageListener webMessageListener) =>
      platform.addWebMessageListener(webMessageListener.platform);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.hasWebMessageListener}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.hasWebMessageListener.supported_platforms}
  bool hasWebMessageListener(WebMessageListener webMessageListener) =>
      platform.hasWebMessageListener(webMessageListener.platform);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.canScrollVertically}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.canScrollVertically.supported_platforms}
  Future<bool> canScrollVertically() => platform.canScrollVertically();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.canScrollHorizontally}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.canScrollHorizontally.supported_platforms}
  Future<bool> canScrollHorizontally() => platform.canScrollHorizontally();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.clearSslPreferences}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.clearSslPreferences.supported_platforms}
  Future<void> clearSslPreferences() => platform.clearSslPreferences();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.pause}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.pause.supported_platforms}
  Future<void> pause() => platform.pause();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.resume}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.resume.supported_platforms}
  Future<void> resume() => platform.resume();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.flingScroll}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.flingScroll.supported_platforms}
  Future<void> flingScroll({required int velocityX, required int velocityY}) =>
      platform.flingScroll(velocityX: velocityX, velocityY: velocityY);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.documentHasImages}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.documentHasImages.supported_platforms}
  Future<bool> documentHasImages() => platform.documentHasImages();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.postVisualStateCallback}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.postVisualStateCallback.supported_platforms}
  Future<void> postVisualStateCallback() => platform.postVisualStateCallback();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.pageDown}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.pageDown.supported_platforms}
  Future<bool> pageDown({required bool bottom}) =>
      platform.pageDown(bottom: bottom);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.pageUp}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.pageUp.supported_platforms}
  Future<bool> pageUp({required bool top}) => platform.pageUp(top: top);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.zoomIn}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.zoomIn.supported_platforms}
  Future<bool> zoomIn() => platform.zoomIn();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.zoomOut}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.zoomOut.supported_platforms}
  Future<bool> zoomOut() => platform.zoomOut();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.clearHistory}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.clearHistory.supported_platforms}
  Future<void> clearHistory() => platform.clearHistory();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.reloadFromOrigin}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.reloadFromOrigin.supported_platforms}
  Future<void> reloadFromOrigin() => platform.reloadFromOrigin();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.createPdf}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.createPdf.supported_platforms}
  Future<Uint8List?> createPdf({PDFConfiguration? pdfConfiguration}) =>
      platform.createPdf(pdfConfiguration: pdfConfiguration);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.createWebArchiveData}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.createWebArchiveData.supported_platforms}
  Future<Uint8List?> createWebArchiveData() => platform.createWebArchiveData();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.hasOnlySecureContent}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.hasOnlySecureContent.supported_platforms}
  Future<bool> hasOnlySecureContent() => platform.hasOnlySecureContent();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.isBlockedByScreenTime}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.isBlockedByScreenTime.supported_platforms}
  Future<bool?> isBlockedByScreenTime() => platform.isBlockedByScreenTime();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.setConversationContext}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.setConversationContext.supported_platforms}
  Future<void> setConversationContext({
    required ConversationContext conversationContext,
  }) =>
      platform.setConversationContext(conversationContext: conversationContext);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getConversationContext}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getConversationContext.supported_platforms}
  Future<ConversationContext?> getConversationContext() =>
      platform.getConversationContext();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.pauseAllMediaPlayback}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.pauseAllMediaPlayback.supported_platforms}
  Future<void> pauseAllMediaPlayback() => platform.pauseAllMediaPlayback();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.setAllMediaPlaybackSuspended}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.setAllMediaPlaybackSuspended.supported_platforms}
  Future<void> setAllMediaPlaybackSuspended({required bool suspended}) =>
      platform.setAllMediaPlaybackSuspended(suspended: suspended);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.closeAllMediaPresentations}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.closeAllMediaPresentations.supported_platforms}
  Future<void> closeAllMediaPresentations() =>
      platform.closeAllMediaPresentations();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.requestMediaPlaybackState}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.requestMediaPlaybackState.supported_platforms}
  Future<MediaPlaybackState?> requestMediaPlaybackState() =>
      platform.requestMediaPlaybackState();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.isInFullscreen}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.isInFullscreen.supported_platforms}
  Future<bool> isInFullscreen() => platform.isInFullscreen();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.clearFormData}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.clearFormData.supported_platforms}
  Future<void> clearFormData() => platform.clearFormData();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getCameraCaptureState}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getCameraCaptureState.supported_platforms}
  Future<MediaCaptureState?> getCameraCaptureState() =>
      platform.getCameraCaptureState();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.setCameraCaptureState}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.setCameraCaptureState.supported_platforms}
  Future<void> setCameraCaptureState({required MediaCaptureState state}) =>
      platform.setCameraCaptureState(state: state);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getMicrophoneCaptureState}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getMicrophoneCaptureState.supported_platforms}
  Future<MediaCaptureState?> getMicrophoneCaptureState() =>
      platform.getMicrophoneCaptureState();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.setMicrophoneCaptureState}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.setMicrophoneCaptureState.supported_platforms}
  Future<void> setMicrophoneCaptureState({required MediaCaptureState state}) =>
      platform.setMicrophoneCaptureState(state: state);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.loadSimulatedRequest}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.loadSimulatedRequest.supported_platforms}
  Future<void> loadSimulatedRequest({
    required URLRequest urlRequest,
    required Uint8List data,
    URLResponse? urlResponse,
  }) => platform.loadSimulatedRequest(urlRequest: urlRequest, data: data);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.saveState}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.saveState.supported_platforms}
  Future<Uint8List?> saveState({int? maxSize, bool? includeForwardState}) =>
      platform.saveState(
        maxSize: maxSize,
        includeForwardState: includeForwardState,
      );

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.restoreState}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.restoreState.supported_platforms}
  Future<bool> restoreState(Uint8List state) => platform.restoreState(state);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getDefaultUserAgent}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getDefaultUserAgent.supported_platforms}
  static Future<String> getDefaultUserAgent() =>
      PlatformInAppWebViewController.static().getDefaultUserAgent();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.clearClientCertPreferences}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.clearClientCertPreferences.supported_platforms}
  static Future<void> clearClientCertPreferences() =>
      PlatformInAppWebViewController.static().clearClientCertPreferences();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getSafeBrowsingPrivacyPolicyUrl}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getSafeBrowsingPrivacyPolicyUrl.supported_platforms}
  static Future<WebUri?> getSafeBrowsingPrivacyPolicyUrl() =>
      PlatformInAppWebViewController.static().getSafeBrowsingPrivacyPolicyUrl();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.setSafeBrowsingAllowlist}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.setSafeBrowsingAllowlist.supported_platforms}
  static Future<bool> setSafeBrowsingAllowlist({required List<String> hosts}) =>
      PlatformInAppWebViewController.static().setSafeBrowsingAllowlist(
        hosts: hosts,
      );

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getCurrentWebViewPackage}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getCurrentWebViewPackage.supported_platforms}
  static Future<WebViewPackageInfo?> getCurrentWebViewPackage() =>
      PlatformInAppWebViewController.static().getCurrentWebViewPackage();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.setWebContentsDebuggingEnabled}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.setWebContentsDebuggingEnabled.supported_platforms}
  static Future<void> setWebContentsDebuggingEnabled(bool debuggingEnabled) =>
      PlatformInAppWebViewController.static().setWebContentsDebuggingEnabled(
        debuggingEnabled,
      );

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getVariationsHeader}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getVariationsHeader.supported_platforms}
  static Future<String?> getVariationsHeader() =>
      PlatformInAppWebViewController.static().getVariationsHeader();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.isMultiProcessEnabled}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.isMultiProcessEnabled.supported_platforms}
  static Future<bool> isMultiProcessEnabled() =>
      PlatformInAppWebViewController.static().isMultiProcessEnabled();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.setDefaultTrafficStatsTag}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.setDefaultTrafficStatsTag.supported_platforms}
  static Future<bool> setDefaultTrafficStatsTag(int tag) =>
      PlatformInAppWebViewController.static().setDefaultTrafficStatsTag(tag);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.disableWebView}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.disableWebView.supported_platforms}
  static Future<void> disableWebView() =>
      PlatformInAppWebViewController.static().disableWebView();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.handlesURLScheme}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.handlesURLScheme.supported_platforms}
  static Future<bool> handlesURLScheme(String urlScheme) =>
      PlatformInAppWebViewController.static().handlesURLScheme(urlScheme);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.disposeKeepAlive}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.disposeKeepAlive.supported_platforms}
  static Future<void> disposeKeepAlive(InAppWebViewKeepAlive keepAlive) =>
      PlatformInAppWebViewController.static().disposeKeepAlive(keepAlive);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.clearAllCache}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.clearAllCache.supported_platforms}
  static Future<void> clearAllCache({bool includeDiskFiles = true}) =>
      PlatformInAppWebViewController.static().clearAllCache(
        includeDiskFiles: includeDiskFiles,
      );

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.enableSlowWholeDocumentDraw}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.enableSlowWholeDocumentDraw.supported_platforms}
  static Future<void> enableSlowWholeDocumentDraw() =>
      PlatformInAppWebViewController.static().enableSlowWholeDocumentDraw();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.setJavaScriptBridgeName}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.setJavaScriptBridgeName.supported_platforms}
  static Future<void> setJavaScriptBridgeName(String bridgeName) =>
      PlatformInAppWebViewController.static().setJavaScriptBridgeName(
        bridgeName,
      );

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getJavaScriptBridgeName}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getJavaScriptBridgeName.supported_platforms}
  static Future<String> getJavaScriptBridgeName() =>
      PlatformInAppWebViewController.static().getJavaScriptBridgeName();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.tRexRunnerHtml}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.tRexRunnerHtml.supported_platforms}
  static Future<String> get tRexRunnerHtml =>
      PlatformInAppWebViewController.static().tRexRunnerHtml;

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.tRexRunnerCss}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.tRexRunnerCss.supported_platforms}
  static Future<String> get tRexRunnerCss =>
      PlatformInAppWebViewController.static().tRexRunnerCss;

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformInAppWebViewController.static().isClassSupported(
        platform: platform,
      );

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.isPropertySupported}
  static bool isPropertySupported(
    PlatformInAppWebViewControllerProperty property, {
    TargetPlatform? platform,
  }) => PlatformInAppWebViewController.static().isPropertySupported(
    property,
    platform: platform,
  );

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.isMethodSupported}
  static bool isMethodSupported(
    PlatformInAppWebViewControllerMethod method, {
    TargetPlatform? platform,
  }) => PlatformInAppWebViewController.static().isMethodSupported(
    method,
    platform: platform,
  );

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getViewId}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.getViewId.supported_platforms}
  dynamic getViewId() => platform.getViewId();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.dispose}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppWebViewController.dispose.supported_platforms}
  void dispose({bool isKeepAlive = false}) =>
      platform.dispose(isKeepAlive: isKeepAlive);
}
