<div align="center">

# Flutter InAppWebView Plugin

![InAppWebView-logo](https://user-images.githubusercontent.com/5956938/195422744-bdcfed16-73f0-4bc9-94ab-ecf10771a1c4.png)

[![nosferatu500_inappwebview version](https://img.shields.io/pub/v/nosferatu500_inappwebview?include_prereleases)](https://pub.dev/packages/nosferatu500_inappwebview)
[![Pub Points](https://img.shields.io/pub/points/nosferatu500_inappwebview)](https://pub.dev/packages/nosferatu500_inappwebview/score)
[![Pub Popularity](https://img.shields.io/pub/popularity/nosferatu500_inappwebview)](https://pub.dev/packages/nosferatu500_inappwebview/score)
[![Pub Likes](https://img.shields.io/pub/likes/nosferatu500_inappwebview)](https://pub.dev/packages/nosferatu500_inappwebview/score)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](/LICENSE)

###### Supported Platforms

[![nosferatu500_inappwebview_platform_interface version](https://img.shields.io/pub/v/nosferatu500_inappwebview_platform_interface?include_prereleases&label=Platform%20Interface)](https://pub.dev/packages/nosferatu500_inappwebview_platform_interface)
[![nosferatu500_inappwebview_android version](https://img.shields.io/pub/v/nosferatu500_inappwebview_android?include_prereleases&label=Android)](https://pub.dev/packages/nosferatu500_inappwebview_android)
[![nosferatu500_inappwebview_ios version](https://img.shields.io/pub/v/nosferatu500_inappwebview_ios?include_prereleases&label=iOS)](https://pub.dev/packages/nosferatu500_inappwebview_ios)

A Flutter plugin that allows you to add an inline webview, to use an headless webview, and to open an in-app browser window.

</div>

## Resources

- The [API reference](https://pub.dev/documentation/nosferatu500_inappwebview/latest/) on pub.dev.
- The [integration tests](https://github.com/nosferatu500/flutter_inappwebview/blob/master/flutter_inappwebview/example/integration_test/), which exercise most of the API on Android and iOS.

## Requirements

- Dart sdk: "^3.13.0"
- Flutter: ">=3.47.0"
- Android: `minSdk >= 30`, [AGP](https://developer.android.com/build/releases/gradle-plugin) version `>= 9.0.0` (AGP 8 and lower are not supported), Gradle `>= 9.1.0`, JDK `>= 17`, Kotlin Gradle Plugin `>= 2.2.20` on the app's build classpath (Flutter 3.47's own minimum; AGP 9.3.0 through 9.4.1 bring 2.2.10, so declare it, as Flutter 3.47's app template does: `id("org.jetbrains.kotlin.android") version "2.4.0" apply false` in `settings.gradle(.kts)`) (use [Android Studio - Android Gradle plugin Upgrade Assistant](https://developer.android.com/build/agp-upgrade-assistant) for help)
- iOS 15.0+, **Xcode version `>= 26`** — the iOS module uses `isolated deinit` (SE-0371) and needs a Swift 6.2+ compiler, which is a newer toolchain than Flutter itself requires

## Installation

Add `nosferatu500_inappwebview` as a [dependency in your pubspec.yaml file](https://flutter.io/using-packages/):

```sh
flutter pub add nosferatu500_inappwebview
```

Coming from upstream `flutter_inappwebview` 6.x? Follow the [migration guide](https://github.com/nosferatu500/flutter_inappwebview/blob/master/flutter_inappwebview/MIGRATION.md).

### Platform setup

See [Requirements](#requirements) above. The [migration guide](https://github.com/nosferatu500/flutter_inappwebview/blob/master/flutter_inappwebview/MIGRATION.md) lists the Android and iOS build settings in detail.

## Credits

This is a fork of [`flutter_inappwebview`](https://github.com/pichillilorenzo/flutter_inappwebview) by Lorenzo Pichilli. Thanks to him and to [upstream's contributors](https://github.com/pichillilorenzo/flutter_inappwebview#contributors-), whose work this fork carries.
