import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/in_app_webview.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runtime coverage for the per-WebView channel's value-returning events (W5, §216): the 19 events
/// and the two blocking waits on `InAppWebViewFlutterApi`, each delivered as a real Pigeon message
/// through the generated codec on its real channel name, the way Kotlin sends it.
///
/// This pins the Dart half: each argument lands in the right field of the right callback, each
/// callback's answer goes back in the success envelope exactly as the MethodChannel replied it, no
/// callback answers null, and a throw answers an error envelope. The Kotlin half (what the platform
/// does with each answer) is pinned on the device (§215).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = InAppWebViewFlutterApi.pigeonChannelCodec;
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  String channel(String method, String suffix) =>
      'dev.flutter.pigeon.flutter_inappwebview_android.InAppWebViewFlutterApi'
      '.$method.$suffix';

  Future<ByteData?> deliver(
    String method,
    List<Object?> args, {
    required String suffix,
  }) => messenger.handlePlatformMessage(
    channel(method, suffix),
    codec.encodeMessage(args),
    (_) {},
  );

  // Payloads in the shapes Kotlin's `toMap()`s send.
  final urlRequest = {'url': 'https://example.com/req', 'method': 'GET'};
  final protectionSpace = {
    'host': 'auth.example.com',
    'protocol': 'http',
    'realm': 'the-realm',
    'port': 8081,
  };
  final webResourceRequest = WebResourceRequestData(
    url: 'https://example.com/resource',
    headers: {'X-Req': 'req-value'},
    isRedirect: true,
    hasGesture: false,
    isForMainFrame: true,
    method: 'POST',
  );

  // Every answer differs from the others and from the platform default.
  final alert = JsAlertResponse(
    message: 'alert-answer',
    handledByClient: true,
    action: JsAlertResponseAction.CONFIRM,
  );
  final confirm = JsConfirmResponse(
    message: 'confirm-answer',
    handledByClient: true,
    action: JsConfirmResponseAction.CANCEL,
  );
  final prompt = JsPromptResponse(
    value: 'prompt-value',
    handledByClient: true,
    action: JsPromptResponseAction.CONFIRM,
  );
  final beforeUnload = JsBeforeUnloadResponse(
    message: 'unload-answer',
    handledByClient: true,
    action: JsBeforeUnloadResponseAction.CONFIRM,
  );
  final geolocation = GeolocationPermissionShowPromptResponse(
    origin: 'https://geo.example.com',
    allow: true,
    retain: true,
  );
  final permission = PermissionResponse(
    resources: [PermissionResourceType.PROTECTED_MEDIA_ID],
    action: PermissionResponseAction.GRANT,
  );
  final httpAuth = HttpAuthResponse(
    username: 'the-user',
    password: 'the-password',
    permanentPersistence: true,
    action: HttpAuthResponseAction.PROCEED,
  );
  final serverTrust = ServerTrustAuthResponse(
    action: ServerTrustAuthResponseAction.PROCEED,
  );
  final clientCert = ClientCertResponse(
    certificatePath: 'the/cert.pfx',
    certificatePassword: 'cert-password',
    keyStoreType: 'PKCS12',
    action: ClientCertResponseAction.IGNORE,
  );
  final safeBrowsing = SafeBrowsingResponse(
    report: false,
    action: SafeBrowsingResponseAction.PROCEED,
  );
  final fileChooser = ShowFileChooserResponse(
    handledByClient: true,
    filePaths: ['file:///data/a.txt', 'file:///data/b.txt'],
  );
  final intercepted = WebResourceResponse(
    contentType: 'text/plain',
    contentEncoding: 'ISO-8859-1',
    statusCode: 202,
    reasonPhrase: 'Accepted Here',
    headers: {'X-Res': 'res-value'},
    data: Uint8List.fromList([4, 5, 6]),
    cookies: ['answer=cookie'],
  );
  final customScheme = CustomSchemeResponse(
    data: Uint8List.fromList([7, 8, 9]),
    contentType: 'image/svg+xml',
    contentEncoding: 'utf-16',
  );

  test('every event reaches its callback, and its answer reaches Kotlin', () async {
    final got = <String>[];
    final controller = AndroidInAppWebViewController(
      AndroidInAppWebViewControllerCreationParams(
        id: 15,
        webviewParams: AndroidInAppWebViewWidgetCreationParams(
          onJsAlert: (_, r) async {
            got.add('alert ${r.url} ${r.message} ${r.isMainFrame}');
            return alert;
          },
          onJsConfirm: (_, r) async {
            got.add('confirm ${r.url} ${r.message} ${r.isMainFrame}');
            return confirm;
          },
          onJsPrompt: (_, r) async {
            got.add(
              'prompt ${r.url} ${r.message} ${r.defaultValue} ${r.isMainFrame}',
            );
            return prompt;
          },
          onJsBeforeUnload: (_, r) async {
            got.add('beforeUnload ${r.url} ${r.message}');
            return beforeUnload;
          },
          onCreateWindow: (_, a) async {
            got.add(
              'createWindow ${a.request.url} ${a.windowId} ${a.isDialog}',
            );
            return true;
          },
          onGeolocationPermissionsShowPrompt: (_, origin) async {
            got.add('geolocation $origin');
            return geolocation;
          },
          onPermissionRequest: (_, r) async {
            got.add(
              'permission ${r.origin} ${r.resources.map((e) => e.toNativeValue()).toList()}',
            );
            return permission;
          },
          shouldOverrideUrlLoading: (_, a) async {
            got.add(
              'override ${a.request.url} ${a.isForMainFrame} ${a.isRedirect}',
            );
            return NavigationActionPolicy.ALLOW;
          },
          onReceivedHttpAuthRequest: (_, c) async {
            got.add(
              'httpAuth ${c.protectionSpace.host} ${c.protectionSpace.realm} ${c.previousFailureCount}',
            );
            return httpAuth;
          },
          onReceivedServerTrustAuthRequest: (_, c) async {
            got.add('serverTrust ${c.protectionSpace.port}');
            return serverTrust;
          },
          onReceivedClientCertRequest: (_, c) async {
            got.add('clientCert ${c.principals} ${c.keyTypes}');
            return clientCert;
          },
          onSafeBrowsingHit: (_, url, threat) async {
            got.add('safeBrowsing $url ${threat?.toNativeValue()}');
            return safeBrowsing;
          },
          onFormResubmission: (_, url) async {
            got.add('form $url');
            return FormResubmissionAction.RESEND;
          },
          onRenderProcessUnresponsive: (_, url) async {
            got.add('unresponsive $url');
            return WebViewRenderProcessAction.TERMINATE;
          },
          onRenderProcessResponsive: (_, url) async {
            got.add('responsive $url');
            return WebViewRenderProcessAction.TERMINATE;
          },
          onPrintRequest: (_, url) async {
            got.add('print $url');
            return true;
          },
          onRequestVisitedHistory: (_) {
            got.add('visited');
            return [
              WebUri('https://example.com/v1'),
              WebUri('https://example.com/v2'),
            ];
          },
          onShowFileChooser: (_, r) async {
            got.add(
              'fileChooser ${r.mode.toNativeValue()} ${r.acceptTypes} ${r.isCaptureEnabled}',
            );
            return fileChooser;
          },
          shouldInterceptRequest: (_, r) async {
            got.add(
              'intercept ${r.url} ${r.headers} ${r.isRedirect} ${r.hasGesture} '
              '${r.isForMainFrame} ${r.method}',
            );
            return intercepted;
          },
          onLoadResourceWithCustomScheme: (_, r) async {
            got.add('customScheme ${r.url} ${r.method}');
            return customScheme;
          },
        ),
      ),
    );
    addTearDown(controller.dispose);
    controller.addJavaScriptHandler(
      handlerName: 'probe',
      callback: (data) {
        got.add('jsHandler ${data.origin} ${data.isMainFrame} ${data.args}');
        return {'echo': data.args};
      },
    );

    final events = <(String, List<Object?>, String, Object?)>[
      (
        'onJsAlert',
        ['https://example.com/a', 'alert-message', true],
        'alert https://example.com/a alert-message true',
        alert.toMap(),
      ),
      (
        'onJsConfirm',
        ['https://example.com/c', 'confirm-message', false],
        'confirm https://example.com/c confirm-message false',
        confirm.toMap(),
      ),
      (
        'onJsPrompt',
        ['https://example.com/p', 'prompt-message', 'the-default', null],
        'prompt https://example.com/p prompt-message the-default null',
        prompt.toMap(),
      ),
      (
        'onJsBeforeUnload',
        ['https://example.com/u', 'unload-message'],
        'beforeUnload https://example.com/u unload-message',
        beforeUnload.toMap(),
      ),
      (
        'onCreateWindow',
        [
          {
            'request': urlRequest,
            'isForMainFrame': true,
            'hasGesture': true,
            'isRedirect': false,
            'windowId': 4,
            'isDialog': true,
          },
        ],
        'createWindow https://example.com/req 4 true',
        true,
      ),
      (
        'onGeolocationPermissionsShowPrompt',
        ['https://geo.example.com/'],
        'geolocation https://geo.example.com/',
        geolocation.toMap(),
      ),
      (
        'onPermissionRequest',
        [
          'https://perm.example.com/',
          ['android.webkit.resource.PROTECTED_MEDIA_ID'],
          null,
        ],
        'permission https://perm.example.com/ [android.webkit.resource.PROTECTED_MEDIA_ID]',
        permission.toMap(),
      ),
      (
        'shouldOverrideUrlLoading',
        [
          {
            'request': urlRequest,
            'isForMainFrame': false,
            'hasGesture': true,
            'isRedirect': true,
          },
        ],
        'override https://example.com/req false true',
        NavigationActionPolicy.ALLOW.toNativeValue(),
      ),
      (
        'onReceivedHttpAuthRequest',
        [
          {
            'protectionSpace': protectionSpace,
            'previousFailureCount': 2,
            'proposedCredential': null,
          },
        ],
        'httpAuth auth.example.com the-realm 2',
        httpAuth.toMap(),
      ),
      (
        'onReceivedServerTrustAuthRequest',
        [
          {'protectionSpace': protectionSpace},
        ],
        'serverTrust 8081',
        serverTrust.toMap(),
      ),
      (
        'onReceivedClientCertRequest',
        [
          {
            'protectionSpace': protectionSpace,
            'principals': ['CN=principal'],
            'keyTypes': ['RSA'],
          },
        ],
        'clientCert [CN=principal] [RSA]',
        clientCert.toMap(),
      ),
      (
        'onSafeBrowsingHit',
        ['https://bad.example.com/', 2],
        'safeBrowsing https://bad.example.com/ 2',
        safeBrowsing.toMap(),
      ),
      (
        'onFormResubmission',
        ['https://example.com/form'],
        'form https://example.com/form',
        FormResubmissionAction.RESEND.toNativeValue(),
      ),
      (
        'onRenderProcessUnresponsive',
        ['https://example.com/slow'],
        'unresponsive https://example.com/slow',
        WebViewRenderProcessAction.TERMINATE.toNativeValue(),
      ),
      (
        'onRenderProcessResponsive',
        ['https://example.com/fast'],
        'responsive https://example.com/fast',
        WebViewRenderProcessAction.TERMINATE.toNativeValue(),
      ),
      (
        'onCallJsHandler',
        [
          'probe',
          {
            'origin': 'https://js.example.com',
            'requestUrl': 'https://js.example.com/page',
            'isMainFrame': true,
            'args': '[1,"two"]',
          },
        ],
        'jsHandler https://js.example.com true [1, two]',
        '{"echo":[1,"two"]}',
      ),
      (
        'onPrintRequest',
        ['https://example.com/print'],
        'print https://example.com/print',
        true,
      ),
      (
        'onRequestVisitedHistory',
        [],
        'visited',
        ['https://example.com/v1', 'https://example.com/v2'],
      ),
      (
        'onShowFileChooser',
        [
          {
            'mode': 1,
            'acceptTypes': ['image/*'],
            'isCaptureEnabled': true,
            'title': null,
            'filenameHint': null,
          },
        ],
        'fileChooser 1 [image/*] true',
        fileChooser.toMap(),
      ),
      (
        'onLoadResourceWithCustomScheme',
        [webResourceRequest],
        'customScheme https://example.com/resource POST',
        customScheme.toMap(),
      ),
    ];
    expect(
      events.length,
      20,
      reason: 'every W5 event but shouldInterceptRequest, once',
    );

    for (final (method, args, expected, answer) in events) {
      got.clear();
      final reply = await deliver(method, args, suffix: 'inappwebview_15');
      expect(reply, isNotNull, reason: '$method has no handler');
      final envelope = codec.decodeMessage(reply) as List<Object?>;
      expect(
        envelope,
        hasLength(1),
        reason: '$method answered an error: $envelope',
      );
      expect(got, [expected], reason: method);
      expect(
        envelope.single,
        answer,
        reason: '$method answered the wrong value',
      );
    }

    // The typed answer, field by field.
    got.clear();
    final reply = await deliver('shouldInterceptRequest', [
      webResourceRequest,
    ], suffix: 'inappwebview_15');
    expect(got, [
      'intercept https://example.com/resource {X-Req: req-value} true false true POST',
    ]);
    final data =
        (codec.decodeMessage(reply) as List<Object?>).single
            as WebResourceResponseData;
    expect(data.contentType, 'text/plain');
    expect(data.contentEncoding, 'ISO-8859-1');
    expect(data.statusCode, 202);
    expect(data.reasonPhrase, 'Accepted Here');
    expect(data.headers, {'X-Res': 'res-value'});
    expect(data.data, [4, 5, 6]);
    expect(data.cookies, ['answer=cookie']);
  });

  test(
    'with no callback set, every event answers null, the "no answer" Kotlin defaults on',
    () async {
      final controller = AndroidInAppWebViewController(
        AndroidInAppWebViewControllerCreationParams(
          id: 16,
          webviewParams: AndroidInAppWebViewWidgetCreationParams(),
        ),
      );
      addTearDown(controller.dispose);

      final events = <(String, List<Object?>)>[
        ('onJsAlert', ['u', 'm', null]),
        ('onJsConfirm', ['u', 'm', null]),
        ('onJsPrompt', ['u', 'm', 'd', null]),
        ('onJsBeforeUnload', ['u', 'm']),
        (
          'onCreateWindow',
          [
            {'request': urlRequest, 'windowId': 1, 'isForMainFrame': true},
          ],
        ),
        ('onGeolocationPermissionsShowPrompt', ['https://geo.example.com/']),
        (
          'onPermissionRequest',
          ['https://perm.example.com/', <String>[], null],
        ),
        (
          'shouldOverrideUrlLoading',
          [
            {'request': urlRequest, 'isForMainFrame': true},
          ],
        ),
        (
          'onReceivedHttpAuthRequest',
          [
            {'protectionSpace': protectionSpace, 'previousFailureCount': 0},
          ],
        ),
        (
          'onReceivedServerTrustAuthRequest',
          [
            {'protectionSpace': protectionSpace},
          ],
        ),
        (
          'onReceivedClientCertRequest',
          [
            {'protectionSpace': protectionSpace},
          ],
        ),
        ('onSafeBrowsingHit', ['https://bad.example.com/', 1]),
        ('onFormResubmission', ['u']),
        ('onRenderProcessUnresponsive', ['u']),
        ('onRenderProcessResponsive', ['u']),
        (
          'onCallJsHandler',
          [
            'unregistered',
            {
              'origin': 'o',
              'requestUrl': 'r',
              'isMainFrame': true,
              'args': '[]',
            },
          ],
        ),
        ('onPrintRequest', ['u']),
        ('onRequestVisitedHistory', []),
        (
          'onShowFileChooser',
          [
            {'mode': 0, 'acceptTypes': <String>[], 'isCaptureEnabled': false},
          ],
        ),
        ('shouldInterceptRequest', [webResourceRequest]),
        ('onLoadResourceWithCustomScheme', [webResourceRequest]),
      ];
      expect(events.length, 21, reason: 'every W5 event, once');

      for (final (method, args) in events) {
        final reply = await deliver(method, args, suffix: 'inappwebview_16');
        expect(reply, isNotNull, reason: '$method has no handler');
        expect(
          codec.decodeMessage(reply) as List<Object?>,
          [null],
          reason: '$method did not answer null',
        );
      }
    },
  );

  test(
    'a throwing callback answers an error envelope, which Kotlin hands to the callback\'s error',
    () async {
      final controller = AndroidInAppWebViewController(
        AndroidInAppWebViewControllerCreationParams(
          id: 17,
          webviewParams: AndroidInAppWebViewWidgetCreationParams(
            onJsConfirm: (_, r) async => throw StateError('confirm failed'),
          ),
        ),
      );
      addTearDown(controller.dispose);

      final reply = await deliver('onJsConfirm', [
        'u',
        'm',
        null,
      ], suffix: 'inappwebview_17');
      final envelope = codec.decodeMessage(reply) as List<Object?>;
      expect(envelope, hasLength(3), reason: 'an error envelope');
      expect(envelope[0], 'error');
      expect(envelope[1], contains('confirm failed'));
    },
  );

  // The exception to the test above (D1, §309): an error would reach Kotlin's `error`, which
  // allows, so a throwing `shouldOverrideUrlLoading` answers CANCEL instead.
  test(
    'a throwing shouldOverrideUrlLoading answers CANCEL, not an error',
    () async {
      final controller = AndroidInAppWebViewController(
        AndroidInAppWebViewControllerCreationParams(
          id: 18,
          webviewParams: AndroidInAppWebViewWidgetCreationParams(
            shouldOverrideUrlLoading: (_, a) async =>
                throw StateError('an allow-list bug'),
          ),
        ),
      );
      addTearDown(controller.dispose);

      final reply = await deliver('shouldOverrideUrlLoading', [
        {'request': urlRequest, 'isForMainFrame': true},
      ], suffix: 'inappwebview_18');
      expect(codec.decodeMessage(reply), [
        NavigationActionPolicy.CANCEL.toNativeValue(),
      ], reason: 'a success envelope carrying CANCEL');
    },
  );
}
