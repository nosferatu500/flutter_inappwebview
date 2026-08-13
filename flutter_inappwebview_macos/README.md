# flutter\_inappwebview\_macos

The Apple macOS WKWebView implementation of [`flutter_inappwebview`](https://pub.dev/packages/flutter_inappwebview).

## Requirements

- macOS 12.0+ — declared in both `macos/flutter_inappwebview_macos.podspec` (`s.platform`) and
  `macos/flutter_inappwebview_macos/Package.swift` (`platforms`). The consuming app's
  `MACOSX_DEPLOYMENT_TARGET` (and `platform :osx` in its `Podfile`, if it uses CocoaPods) must be
  12.0 or higher.
- Xcode `>= 15.0` (Swift 5.9)

## Usage

This package is [endorsed](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin),
which means you can simply use `flutter_inappwebview`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.