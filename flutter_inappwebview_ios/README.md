# flutter\_inappwebview\_ios

The Apple iOS WKWebView implementation of [`flutter_inappwebview`](https://pub.dev/packages/flutter_inappwebview).

## Requirements

- iOS 15.0+ — declared in both `ios/flutter_inappwebview_ios.podspec` (`s.platform`) and
  `ios/flutter_inappwebview_ios/Package.swift` (`platforms`). The consuming app's
  `IPHONEOS_DEPLOYMENT_TARGET` (and `platform :ios` in its `Podfile`, if it uses CocoaPods) must be
  15.0 or higher.
- Xcode `>= 15.0` (Swift 5.9)

## Usage

This package is [endorsed](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin),
which means you can simply use `flutter_inappwebview`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.