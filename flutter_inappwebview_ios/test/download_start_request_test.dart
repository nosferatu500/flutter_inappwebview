import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the iOS 18.2 additions to [DownloadStartRequest]: `isUserInitiated` and
/// `originatingFrame`.
///
/// The interesting property is not the values but the **three-state** meaning of `null`, because
/// `onDownloadStarting` has three producers on the iOS side and only two of them can fill these
/// fields:
///
/// 1. `download(_:decideDestinationUsing:suggestedFilename:completionHandler:)` — has a `WKDownload`
/// 2. `webView(_:navigationResponse:didBecome:)` — has a `WKDownload`
/// 3. `webView(_:decidePolicyFor:decisionHandler:)` on the navigation response — **synthesises** the
///    event and cancels before WebKit creates a download object, so there is nothing to ask
///
/// So `null` means "below iOS 18.2 **or** raised from producer 3", and `false` means WebKit actively
/// reported a non-user-initiated download. Collapsing those would turn "we could not tell" into
/// "the user did not ask for this", which is exactly backwards for a caller using the field to
/// decide whether to block a drive-by download.
void main() {
  group('DownloadStartRequest iOS 18.2 fields', () {
    test(
      'decode from the map the Swift side sends when WebKit reported them',
      () {
        final request = DownloadStartRequest.fromMap({
          'url': 'https://example.com/a.zip',
          'contentLength': 1024,
          // Swift: downloadStartRequest.apply(download:) fills these two.
          'isUserInitiated': true,
          'originatingFrame': {
            'isMainFrame': true,
            'request': {'url': 'https://example.com/'},
          },
        })!;

        expect(request.isUserInitiated, isTrue);
        expect(request.originatingFrame, isNotNull);
        expect(request.originatingFrame!.isMainFrame, isTrue);
      },
    );

    test('null is distinct from false', () {
      // Producer 3, or any iOS below 18.2: the keys are absent entirely.
      final unreported = DownloadStartRequest.fromMap({
        'url': 'https://example.com/a.zip',
        'contentLength': 1024,
      })!;
      expect(unreported.isUserInitiated, isNull);
      expect(unreported.originatingFrame, isNull);

      // WebKit said "not user initiated" -- a drive-by download.
      final driveBy = DownloadStartRequest.fromMap({
        'url': 'https://example.com/a.zip',
        'contentLength': 1024,
        'isUserInitiated': false,
      })!;
      expect(driveBy.isUserInitiated, isFalse);
      expect(driveBy.isUserInitiated, isNot(isNull));
    });

    test('the pre-existing fields are unaffected', () {
      // The two new fields were appended to an event that already ships; this asserts the older
      // payload still decodes unchanged, since all three producers still populate it.
      final request = DownloadStartRequest.fromMap({
        'url': 'https://example.com/a.zip',
        'mimeType': 'application/zip',
        'contentLength': 2048,
        'suggestedFilename': 'a.zip',
        'textEncodingName': 'utf-8',
      })!;

      expect(request.url.toString(), 'https://example.com/a.zip');
      expect(request.mimeType, 'application/zip');
      expect(request.contentLength, 2048);
      expect(request.suggestedFilename, 'a.zip');
      expect(request.textEncodingName, 'utf-8');
    });

    test('toMap round-trips both new fields', () {
      final map = DownloadStartRequest(
        url: WebUri('https://example.com/a.zip'),
        contentLength: 1,
        isUserInitiated: false,
      ).toMap();

      expect(map['isUserInitiated'], false);
      expect(map['originatingFrame'], isNull);
      expect(DownloadStartRequest.fromMap(map)!.isUserInitiated, isFalse);
    });
  });
}
