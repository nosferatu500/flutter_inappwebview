part of 'main.dart';

void apply() {
  final shouldSkip = !ProcessGlobalConfig.isMethodSupported(
    PlatformProcessGlobalConfigMethod.apply,
  );

  skippableTestWidgets('apply', (WidgetTester tester) async {
    await expectLater(
      ProcessGlobalConfig.instance().apply(
        settings: ProcessGlobalConfigSettings(
          dataDirectorySuffix:
              (await WebViewFeature.isStartupFeatureSupported(
                WebViewFeature.STARTUP_FEATURE_SET_DATA_DIRECTORY_SUFFIX,
              ))
              ? 'suffix_inappwebviewexample'
              : null,
          directoryBasePaths:
              (await WebViewFeature.isStartupFeatureSupported(
                WebViewFeature.STARTUP_FEATURE_SET_DIRECTORY_BASE_PATHS,
              ))
              ? ProcessGlobalConfigDirectoryBasePaths(
                  cacheDirectoryBasePath:
                      '${(await getApplicationDocumentsDirectory()).absolute.path}/inappwebviewexample/cache',
                  dataDirectoryBasePath:
                      '${(await getApplicationDocumentsDirectory()).absolute.path}/inappwebviewexample/data',
                )
              : null,
        ),
      ),
      completes,
    );
  }, skip: shouldSkip);

  // The two feature checks read separate androidx lists, so each throws on the other's features
  // rather than returning false, as their docs now say (measured §290). The controls return.
  // After `apply`: a feature check may initialise WebView, after which `apply` can't run.
  skippableTest(
    "isFeatureSupported and isStartupFeatureSupported throw on each other's features",
    () async {
      final unknownFeature = isA<PlatformException>()
          .having((e) => e.code, 'code', 'RuntimeException')
          .having((e) => e.message, 'message', contains('Unknown feature'));
      await expectLater(
        WebViewFeature.isFeatureSupported(
          WebViewFeature.STARTUP_FEATURE_SET_DATA_DIRECTORY_SUFFIX,
        ),
        throwsA(unknownFeature),
      );
      await expectLater(
        WebViewFeature.isStartupFeatureSupported(WebViewFeature.SAVE_STATE),
        throwsA(unknownFeature),
      );
      // The controls: each answers for its own kind of feature.
      expect(
        await WebViewFeature.isFeatureSupported(WebViewFeature.SAVE_STATE),
        isA<bool>(),
      );
      expect(
        await WebViewFeature.isStartupFeatureSupported(
          WebViewFeature.STARTUP_FEATURE_SET_DATA_DIRECTORY_SUFFIX,
        ),
        isA<bool>(),
      );
    },
    skip: defaultTargetPlatform != TargetPlatform.android,
  );
}
