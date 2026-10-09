# flutter\_inappwebview\_ios

The Apple iOS WKWebView implementation of [`flutter_inappwebview`](https://pub.dev/packages/flutter_inappwebview).

## Requirements

- iOS 15.0+ — declared in `ios/flutter_inappwebview_ios/Package.swift` (`platforms`). The consuming
  app's `IPHONEOS_DEPLOYMENT_TARGET` must be 15.0 or higher.
- **Swift Package Manager.** Since 7.0 the plugin is integrated through Swift Package Manager only;
  it has no podspec. Flutter enables Swift Package Manager by default (the plugin needs Flutter
  3.44 or newer). An app that turned it off, with `flutter config --no-enable-swift-package-manager`
  or with `enable-swift-package-manager: false` under `flutter: config:` in its `pubspec.yaml`, has
  to turn it back on: without it the plugin has no way into the build. The app can still use
  CocoaPods for its other plugins.
- Xcode 26 or newer.

## Usage

This package is [endorsed](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin),
which means you can simply use `flutter_inappwebview`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.