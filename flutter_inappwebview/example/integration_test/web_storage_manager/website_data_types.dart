part of 'main.dart';

/// `WebsiteDataType.ALL` and the two iOS data-removal paths that consume it.
///
/// `ALL` is the documented way to clear everything a site stored, and until 7.0.0 it listed only
/// the ten `WKWebsiteDataType*` constants that existed in iOS 9–11.3. The iOS 26.5 SDK declares
/// fifteen, so `removeDataModifiedSince(dataTypes: WebsiteDataType.ALL)` silently left File System
/// (OPFS), MediaKeys, search field history and the deviceId hash salt in place — an incomplete
/// wipe, on the API an app would use to honour a "delete my data" request.
///
/// Two things these tests measure rather than assume:
///
///  * `ALL` now contains constants that do not exist on every supported OS. On iOS 17.5 four of
///    them are unknown to the framework, and WebKit ignores an unrecognised data type rather than
///    rejecting the call — which is what makes shipping the full set safe.
///  * `WKWebsiteDataTypeScreenTime` (iOS 26.0+) is **excluded** from `ALL`, because including it
///    terminates the app on iOS 26.5 from inside WebKit. That is the reason the last test exists.
void websiteDataTypes() {
  // fetchDataRecords / removeDataModifiedSince are @SupportedPlatforms([IOSPlatform()]) — the
  // Android WebStorageManager has no data-record API at all, so these would throw there.
  final shouldSkip =
      !WebStorageManager.isClassSupported() ||
      !WebStorageManager.isMethodSupported(
        PlatformWebStorageManagerMethod.fetchDataRecords,
      );

  skippableGroup('website data types', () {
    skippableTest(
      'ALL covers every removable WKWebsiteDataType in the iOS 26.5 SDK',
      () {
        // Pinned against the SDK header, not against the implementation: if Apple adds a constant,
        // this list is what has to grow, and `ALL` with it.
        const expected = {
          'WKWebsiteDataTypeFetchCache',
          'WKWebsiteDataTypeDiskCache',
          'WKWebsiteDataTypeMemoryCache',
          'WKWebsiteDataTypeOfflineWebApplicationCache',
          'WKWebsiteDataTypeCookies',
          'WKWebsiteDataTypeSessionStorage',
          'WKWebsiteDataTypeLocalStorage',
          'WKWebsiteDataTypeWebSQLDatabases',
          'WKWebsiteDataTypeIndexedDBDatabases',
          'WKWebsiteDataTypeServiceWorkerRegistrations',
          'WKWebsiteDataTypeFileSystem',
          'WKWebsiteDataTypeSearchFieldRecentSearches',
          'WKWebsiteDataTypeMediaKeys',
          'WKWebsiteDataTypeHashSalt',
        };
        expect(
          WebsiteDataType.ALL.map((t) => t.toNativeValue()).toSet(),
          expected,
        );
      },
    );

    skippableTest('ALL excludes ScreenTime, which crashes the removal path', () {
      // Not cosmetic. With this constant in the set, `removeDataModifiedSince` below terminates
      // the app on iOS 26.5:
      //
      //   *** Terminating app due to uncaught exception 'NSGenericException',
      //       reason: 'Start date cannot be later in time than end date!'
      //    2  Foundation  -[_NSConcreteDateInterval initWithStartDate:endDate:]
      //    3  WebKit      ScreenTimeWebsiteDataSupport::removeScreenTimeDataWithInterval(WallTime…)
      //    5  WebKit      -[WKWebsiteDataStore removeDataOfTypes:modifiedSince:completionHandler:]
      //
      // It is an uncaught Objective-C exception thrown inside WebKit, so no Dart try/catch and no
      // plugin guard can contain it. Measured both ways on iOS 26.5: in the set the app dies, out
      // of the set the whole group passes. If a future WebKit fixes this, delete this test and add
      // the constant back to ALL.
      expect(
        WebsiteDataType.ALL.contains(
          WebsiteDataType.WKWebsiteDataTypeScreenTime,
        ),
        isFalse,
        reason:
            'WKWebsiteDataTypeScreenTime in ALL makes removeDataModifiedSince terminate the app '
            'on iOS 26.5',
      );
    });

    skippableTest(
      'fetchDataRecords accepts ALL, including newer-OS types',
      () async {
        // The measurement behind ALL carrying types the running OS may not know: on iOS 17.5 this
        // set contains four strings the framework has never heard of. If WebKit rejected them, this
        // would not complete.
        await expectLater(
          WebStorageManager.instance().fetchDataRecords(
            dataTypes: WebsiteDataType.ALL,
          ),
          completes,
        );
      },
    );

    skippableTest('removeDataModifiedSince accepts ALL', () async {
      await expectLater(
        WebStorageManager.instance().removeDataModifiedSince(
          dataTypes: WebsiteDataType.ALL,
          date: DateTime.now().subtract(const Duration(seconds: 1)),
        ),
        completes,
      );
    });

    skippableTest('every returned record decodes to a known type', () async {
      final records = await WebStorageManager.instance().fetchDataRecords(
        dataTypes: WebsiteDataType.ALL,
      );
      // The iOS implementation drops a data type it cannot map rather than throwing, so an
      // unmapped one shows up here as a record carrying fewer types than WebKit reported —
      // silent, and invisible from the public API. This is the cheap guard against that.
      for (final record in records) {
        expect(record.dataTypes, isNotNull);
        for (final t in record.dataTypes!) {
          expect(
            WebsiteDataType.ALL.contains(t),
            isTrue,
            reason: '${t.toNativeValue()} is not in WebsiteDataType.ALL',
          );
        }
      }
    });
  }, skip: shouldSkip);
}
