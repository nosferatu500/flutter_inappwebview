import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/in_app_webview.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runtime coverage for the per-WebView channel's events on `InAppWebViewFlutterApi` (W4, §214):
/// the 35 fire-and-forget events, each delivered as a real Pigeon message through the generated
/// codec on its real channel name, the way Kotlin sends it.
///
/// This pins the Dart half: the controller registers under `inappwebview_<id>`, each typed
/// argument lands in the right field of the right callback (every value differs, so a crossed wire
/// fails), the handler is unregistered on dispose but not on a keep-alive dispose, and a throwing
/// callback answers an error envelope instead of escaping. The Kotlin half, that each event is sent
/// with its real values, is pinned on the device (§213).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = InAppWebViewFlutterApi.pigeonChannelCodec;
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  String channel(String method, String suffix) =>
      'dev.flutter.pigeon.flutter_inappwebview_android.InAppWebViewFlutterApi'
      '.$method.$suffix';

  /// Delivers one event the way Kotlin does and returns the raw reply: an encoded envelope when a
  /// handler is registered, null when none is.
  Future<ByteData?> deliver(
    String method,
    List<Object?> args, {
    String suffix = 'inappwebview_5',
  }) {
    late final Future<ByteData?> reply;
    reply = messenger.handlePlatformMessage(
      channel(method, suffix),
      codec.encodeMessage(args),
      (_) {},
    );
    return reply;
  }

  final navigation = <String, Object?>{
    'id': 7,
    'pageId': 3,
    'url': 'https://example.com/nav',
    'wasInitiatedByPage': true,
    'isSameDocument': false,
    'isReload': false,
    'isHistory': false,
    'isBack': false,
    'isForward': false,
    'isRestore': false,
    'didCommit': true,
    'didCommitErrorPage': false,
    'statusCode': 200,
    'webResourceError': null,
  };
  Map<String, Object?> page(int id) => {
    'id': id,
    'url': 'https://example.com/page$id',
  };

  test('every event reaches its own callback with its own values', () async {
    final got = <String>[];
    final controller = AndroidInAppWebViewController(
      AndroidInAppWebViewControllerCreationParams(
        id: 5,
        webviewParams: AndroidHeadlessInAppWebViewCreationParams(
          onLoadStart: (_, url) => got.add('loadStart $url'),
          onLoadStop: (_, url) => got.add('loadStop $url'),
          onReceivedError: (_, request, error) =>
              got.add('error ${request.url} ${error.description}'),
          onReceivedHttpError: (_, request, response) =>
              got.add('httpError ${request.url} ${response.statusCode}'),
          onProgressChanged: (_, progress) => got.add('progress $progress'),
          onConsoleMessage: (_, message) => got.add(
            'console ${message.message} ${message.messageLevel.toNativeValue()}',
          ),
          onScrollChanged: (_, x, y) => got.add('scroll $x $y'),
          onOverScrolled: (_, x, y, clampedX, clampedY) =>
              got.add('overScrolled $x $y $clampedX $clampedY'),
          onDownloadStarting: (_, request) => got.add(
            'download ${request.url} ${request.mimeType} ${request.contentLength}',
          ),
          onCloseWindow: (_) => got.add('closeWindow'),
          onTitleChanged: (_, title) => got.add('title $title'),
          onGeolocationPermissionsHidePrompt: (_) => got.add('geolocationHide'),
          onReceivedTouchIconUrl: (_, url, precomposed) =>
              got.add('touchIcon $url $precomposed'),
          onPermissionRequestCanceled: (_, request) => got.add(
            'permissionCanceled ${request.origin} ${request.resources.map((r) => r.toNativeValue()).toList()}',
          ),
          onUpdateVisitedHistory: (_, url, isReload) =>
              got.add('history $url $isReload'),
          onZoomScaleChanged: (_, oldScale, newScale) =>
              got.add('zoom $oldScale $newScale'),
          onPageCommitVisible: (_, url) => got.add('commitVisible $url'),
          onLongPressHitTestResult: (_, result) => got.add(
            'longPress ${result.type?.toNativeValue()} ${result.extra}',
          ),
          onEnterFullscreen: (_) => got.add('enterFullscreen'),
          onExitFullscreen: (_) => got.add('exitFullscreen'),
          onRequestFocus: (_) => got.add('requestFocus'),
          onRenderProcessGone: (_, detail) => got.add(
            'renderGone ${detail.didCrash} ${detail.rendererPriorityAtExit?.toNativeValue()}',
          ),
          onReceivedLoginRequest: (_, request) => got.add(
            'login ${request.realm} ${request.account} ${request.args}',
          ),
          onNavigationStarted: (_, n) => got.add('navStarted ${n.id}'),
          onNavigationRedirected: (_, n) => got.add('navRedirected ${n.id}'),
          onNavigationCompleted: (_, n) =>
              got.add('navCompleted ${n.id} ${n.statusCode}'),
          onPageLoadEvent: (_, p) => got.add('pageLoad ${p.id}'),
          onPageDomContentLoadedEvent: (_, p) => got.add('domLoaded ${p.id}'),
          onPageDeleted: (_, p) => got.add('pageDeleted ${p.id}'),
          onFirstContentfulPaintMillis: (_, p, millis) =>
              got.add('fcp ${p.id} $millis'),
          onLargestContentfulPaintMillis: (_, p, millis) =>
              got.add('lcp ${p.id} $millis'),
          onPerformanceMarkMillis: (_, p, name, millis) =>
              got.add('mark ${p.id} $name $millis'),
          contextMenu: ContextMenu(
            menuItems: [ContextMenuItem(id: 9, title: 'Nine')],
            onCreateContextMenu: (result) =>
                got.add('createMenu ${result.extra}'),
            onHideContextMenu: () => got.add('hideMenu'),
            onContextMenuActionItemClicked: (item) =>
                got.add('menuClicked ${item.id} ${item.title}'),
          ),
        ),
      ),
    );
    addTearDown(controller.dispose);

    final request = {'url': 'https://example.com/req', 'method': 'GET'};
    final events = <(String, List<Object?>, String)>[
      (
        'onLoadStart',
        ['https://example.com/a'],
        'loadStart https://example.com/a',
      ),
      (
        'onLoadStop',
        ['https://example.com/b'],
        'loadStop https://example.com/b',
      ),
      (
        'onReceivedError',
        [
          request,
          {'type': -2, 'description': 'the-error'},
        ],
        'error https://example.com/req the-error',
      ),
      (
        'onReceivedHttpError',
        [
          request,
          {'statusCode': 404},
        ],
        'httpError https://example.com/req 404',
      ),
      ('onProgressChanged', [42], 'progress 42'),
      ('onConsoleMessage', ['the-message', 3], 'console the-message 3'),
      ('onScrollChanged', [11, 22], 'scroll 11 22'),
      (
        'onOverScrolled',
        [33, 44, false, true],
        'overScrolled 33 44 false true',
      ),
      (
        'onDownloadStarting',
        [
          // `contentLength` is required by `DownloadStartRequest.fromMap`; Kotlin always sends it.
          {
            'url': 'https://example.com/file',
            'mimeType': 'the/mime',
            'contentLength': 1234,
          },
        ],
        'download https://example.com/file the/mime 1234',
      ),
      ('onCloseWindow', [], 'closeWindow'),
      ('onTitleChanged', ['the-title'], 'title the-title'),
      ('onGeolocationPermissionsHidePrompt', [], 'geolocationHide'),
      (
        'onReceivedTouchIconUrl',
        ['https://example.com/icon', true],
        'touchIcon https://example.com/icon true',
      ),
      (
        'onPermissionRequestCanceled',
        [
          'https://example.com/origin',
          ['android.webkit.resource.AUDIO_CAPTURE'],
        ],
        'permissionCanceled https://example.com/origin [android.webkit.resource.AUDIO_CAPTURE]',
      ),
      (
        'onUpdateVisitedHistory',
        ['https://example.com/h', true],
        'history https://example.com/h true',
      ),
      ('onZoomScaleChanged', [1.5, 2.5], 'zoom 1.5 2.5'),
      (
        'onPageCommitVisible',
        ['https://example.com/c'],
        'commitVisible https://example.com/c',
      ),
      (
        'onLongPressHitTestResult',
        [
          {'type': 7, 'extra': 'the-link'},
        ],
        'longPress 7 the-link',
      ),
      (
        'onCreateContextMenu',
        [
          {'type': 0, 'extra': 'the-selection'},
        ],
        'createMenu the-selection',
      ),
      ('onHideContextMenu', [], 'hideMenu'),
      ('onContextMenuActionItemClicked', [9, 'Nine'], 'menuClicked 9 Nine'),
      ('onEnterFullscreen', [], 'enterFullscreen'),
      ('onExitFullscreen', [], 'exitFullscreen'),
      ('onRequestFocus', [], 'requestFocus'),
      ('onRenderProcessGone', [true, 1], 'renderGone true 1'),
      (
        'onReceivedLoginRequest',
        ['the-realm', 'the-account', 'the-args'],
        'login the-realm the-account the-args',
      ),
      ('onNavigationStarted', [navigation], 'navStarted 7'),
      ('onNavigationRedirected', [navigation], 'navRedirected 7'),
      ('onNavigationCompleted', [navigation], 'navCompleted 7 200'),
      ('onPageLoadEvent', [page(1)], 'pageLoad 1'),
      ('onPageDomContentLoadedEvent', [page(2)], 'domLoaded 2'),
      ('onPageDeleted', [page(3)], 'pageDeleted 3'),
      ('onFirstContentfulPaintMillis', [page(4), 120], 'fcp 4 120'),
      ('onLargestContentfulPaintMillis', [page(5), 340], 'lcp 5 340'),
      (
        'onPerformanceMarkMillis',
        [page(6), 'the-mark', 560],
        'mark 6 the-mark 560',
      ),
    ];
    expect(events.length, 35, reason: 'every W4 event, once');

    for (final (method, args, expected) in events) {
      got.clear();
      final reply = await deliver(method, args);
      expect(reply, isNotNull, reason: '$method has no handler');
      expect(
        codec.decodeMessage(reply) as List<Object?>,
        isEmpty,
        reason: '$method answered an error',
      );
      expect(got, [expected], reason: method);
    }
  });

  test(
    'dispose unregisters the handler, and a keep-alive dispose does not',
    () async {
      // Positive control first: the same delivery answers while the controller is alive.
      final controller = AndroidInAppWebViewController(
        AndroidInAppWebViewControllerCreationParams(id: 6),
      );
      expect(
        await deliver('onTitleChanged', ['t'], suffix: 'inappwebview_6'),
        isNotNull,
      );
      controller.dispose();
      expect(
        await deliver('onTitleChanged', ['t'], suffix: 'inappwebview_6'),
        isNull,
        reason: 'a disposed controller must not keep receiving events',
      );

      final keptAlive = AndroidInAppWebViewController(
        AndroidInAppWebViewControllerCreationParams(id: 8),
      );
      keptAlive.dispose(isKeepAlive: true);
      expect(
        await deliver('onTitleChanged', ['t'], suffix: 'inappwebview_8'),
        isNotNull,
        reason:
            'a keep-alive WebView keeps its handler, as it keeps its MethodChannel handler',
      );
      InAppWebViewFlutterApi.setUp(
        null,
        messageChannelSuffix: 'inappwebview_8',
      );
    },
  );

  test(
    'a throwing callback answers an error envelope instead of escaping',
    () async {
      final controller = AndroidInAppWebViewController(
        AndroidInAppWebViewControllerCreationParams(
          id: 9,
          webviewParams: AndroidHeadlessInAppWebViewCreationParams(
            onLoadStop: (_, url) => throw StateError('the callback failed'),
          ),
        ),
      );
      addTearDown(controller.dispose);

      final reply = await deliver('onLoadStop', [
        'https://example.com/',
      ], suffix: 'inappwebview_9');
      final envelope = codec.decodeMessage(reply) as List<Object?>;
      expect(envelope, hasLength(3), reason: 'an error envelope');
      expect(envelope[1], contains('the callback failed'));
    },
  );
}
