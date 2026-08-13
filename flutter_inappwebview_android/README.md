# flutter\_inappwebview\_android

The Android WebView implementation of [`flutter_inappwebview`](https://pub.dev/packages/flutter_inappwebview).

## Requirements

- [AGP](https://developer.android.com/build/releases/gradle-plugin) `>= 9.0.0` — AGP 8 and lower are
  not supported. The module uses the AGP 9 DSL (`enableKotlin`) and declares no AGP version of its
  own, so it builds with whatever AGP the consuming app applies.
- Gradle `>= 9.1.0`, JDK `>= 17` (both are AGP 9 requirements)
- `minSdk >= 30` in the consuming app: AGP rejects an app whose `minSdk` is below that of a library
  it depends on.

## Usage

This package is [endorsed](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin),
which means you can simply use `flutter_inappwebview`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.