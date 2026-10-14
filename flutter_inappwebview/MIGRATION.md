# Migrating from flutter_inappwebview 6.x to nosferatu500_inappwebview 7.x

This guide is for apps on upstream [`flutter_inappwebview`](https://pub.dev/packages/flutter_inappwebview)
6.x (6.1.5 or 6.2.0-beta.3) moving to this fork. It covers what you must change and what behaves
differently. The full record, including every removed name and the measurements behind each change,
is in [CHANGELOG.md](CHANGELOG.md).

Steps 1–4 are compile-time: the analyzer finds the places for you. Step 5 is behaviour your code may
rely on without the analyzer noticing, so read it even if everything compiles.

## At a glance

| | flutter_inappwebview 6.x | nosferatu500_inappwebview 7.1 |
|---|---|---|
| Package | `flutter_inappwebview` | `nosferatu500_inappwebview` |
| Platforms | Android, iOS, macOS, Windows, Linux, Web | **Android, iOS** |
| Flutter / Dart | 3.x | **3.47 / 3.13** (7.0.0: 3.44 / 3.12) |
| Android | `minSdk` 19, AGP 8 | **`minSdk` 30, `compileSdk` 37, AGP 9, Gradle 9.1, JDK 17, Kotlin Gradle Plugin 2.2.20+** |
| iOS | 12.0, CocoaPods or SwiftPM | **15.0, Xcode 26, Swift Package Manager only** |
| Deprecated API | present | **removed** |

## 1. Change the package

```yaml
# pubspec.yaml
dependencies:
  nosferatu500_inappwebview: ^7.1.0   # was: flutter_inappwebview: ^6.x
```

```dart
// was: import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nosferatu500_inappwebview/nosferatu500_inappwebview.dart';
```

Class, method and setting names don't change with the package. The JavaScript bridge your web pages
call keeps its name, `window.flutter_inappwebview`, so page code needs no change.

If your app talks to the plugin's platform channels directly, their names now start with
`dev.nosferatu500.inappwebview/` (they were `com.pichillilorenzo/…`).

## 2. Update the build

**Flutter.** 7.1 needs Flutter 3.47 or newer. On an older Flutter, pub resolves 7.0.0, which needs
Flutter 3.44.

**Android** (`android/app/build.gradle` and `settings.gradle`):

- `minSdk` 30 or higher. AGP rejects an app whose `minSdk` is below a library's.
- `compileSdk = 37`. Flutter's default is still 36, and the plugin's `androidx.core` dependency makes
  AGP fail the build below 37.
- Android Gradle Plugin 9, Gradle 9.1 or newer, JDK 17 or newer.
- The Kotlin Gradle Plugin 2.2.20 or newer on your build classpath. That is Flutter 3.47's own
  minimum, and AGP 9.3–9.4 bring only 2.2.10, so declare it as Flutter 3.47's app template does:
  ```groovy
  plugins {
      id "org.jetbrains.kotlin.android" version "2.4.0" apply false
  }
  ```
- If you declared the plugin's `FileProvider` in your manifest, replace the whole `<provider>`
  block: `android:name` → `dev.nosferatu500.inappwebview.InAppWebViewFileProvider`,
  `android:authorities` → `${applicationId}.dev.nosferatu500.inappwebview.fileprovider`, and the
  `meta-data` resource → `@xml/inappwebview_provider_paths`. A wrong authority fails silently:
  `<input type="file" capture>` just stops producing a file.

**iOS:**

- Deployment target 15.0 or higher.
- Xcode 26 or newer (the module needs a Swift 6.2 compiler).
- Keep Swift Package Manager enabled; it is Flutter's default. The module has no podspec. If your
  Podfile existed only for this plugin, you can remove CocoaPods from the app (`pod deintegrate`);
  other plugins can keep using CocoaPods.

## 3. Replace removed API

Everything upstream had marked `@Deprecated` is gone, and every replacement already existed in 6.x:

- `*Options` types and parameters → their `*Settings` equivalents; `getOptions` / `setOptions` →
  `getSettings` / `setSettings`.
- `Android…` / `IOS…`-prefixed duplicates of types, events, fields and methods → the unprefixed
  ones.
- macOS-, Windows-, Linux- and Web-only API is removed, with nothing to migrate to. `switch`es over
  `WebResourceErrorType`, `SslErrorType` or `PermissionResourceType` may name constants that no longer
  exist; these are constant classes, not enums, so you get an "undefined name" error, not an
  exhaustiveness warning.
- `onFaviconChanged` is removed: Android no longer delivers the callback behind it.
- `InAppWebViewSettings.selectionGranularity` and `SelectionGranularity` are removed: WebKit has
  ignored the setting since iOS 11.
- A few other settings that did nothing are removed (for example `clearCache` /
  `clearSessionCache`: use `InAppWebViewController.clearAllCache()`). The CHANGELOG lists each one.

## 4. Fix changed signatures

**`onPrintRequest`** lost its third parameter, and returning `true` now stops the system print dialog
from opening (before, the dialog was already up whatever you returned):

```dart
// 6.x
onPrintRequest: (controller, url, printJobController) async { ...; return false; },
// 7.x
onPrintRequest: (controller, url) async { ...; return false; },  // true = don't open the dialog
```

**`onDownloadStarting`** returns `FutureOr<void>`; neither platform ever read the old
`DownloadStartResponse?`. Drop the return value.

**Answers that can now say "unknown"** (they used to return a value that looked real):

```dart
final storage = WebStorageManager.instance();
final quota = await storage.getQuotaForOrigin(origin: origin) ?? 0;   // was int, now int?
final usage = await storage.getUsageForOrigin(origin: origin) ?? 0;   // was int, now int?
final has = await ProfileStore.instance().hasCustomHeader('X-Token') ?? false;  // was bool, now bool?
```

`null` means the store couldn't be reached (a `profileName` that doesn't exist, or the WebView lacks
the feature). `?? 0` and `?? false` keep the old behaviour.

**Methods that now report whether they did anything** (no change needed if you only `await` them):
`WebStorageManager.deleteAllData` / `deleteOrigin`, and `ProfileStore.addCustomHeader` /
`clearCustomHeader` / `clearAllCustomHeaders` return `Future<bool>`. `false` means the store
couldn't be reached and nothing happened.

**New:** `PathHandler.dispose()` unregisters a custom path handler; a request for its path then gets no
handler.

## 5. Check behaviour your code may rely on

These compile unchanged but behave differently.

**Both platforms**

- **`shouldOverrideUrlLoading`:** a `null` answer, or `useShouldOverrideUrlLoading: true` with no
  handler, now **loads** the page (it cancelled; on iOS a missing handler blocked every navigation,
  the first load included). A handler that throws now **cancels** on both platforms. `ALLOW` and
  `CANCEL` are unchanged. If you relied on `null` to block, return `NavigationActionPolicy.CANCEL`.
- **Rebuilt widgets:** after a parent rebuild passes new callbacks to an `InAppWebView`, events go to
  the new callbacks (they kept going to the first build's). What the WebView read at creation is not
  redone: the initial page and settings, and the `use…` settings a callback turns on when present at
  creation (for example `shouldOverrideUrlLoading`), so add such callbacks from the first build.

**iOS**

- **`onLoadStart`, `onPageCommitVisible`, `onLoadStop`** report their own navigation's URL. They could
  carry the URL of a `loadUrl` requested meanwhile, so code that waited for `onLoadStop` with a given
  URL could act before that page had loaded.
- **`onUpdateVisitedHistory`** fires when a load commits, not when it is requested, and a reload is
  now reported. `pushState`, `replaceState` and fragment changes are still reported at once.
- **`contentBlockers` WebKit can't compile:** the WebView now loads nothing and sends
  `onReceivedError` with a description starting `contentBlockers could not be compiled` (it showed a
  blank page with no sign why). `setSettings` with such rules throws a `PlatformException` (code
  `contentBlockers`) and keeps the previous rules in force (it silently removed all blocking).
- **Popups** (`onCreateWindow` → `InAppWebView(windowId:)`) apply their own `contentBlockers`, not
  their opener's, as on Android. If you relied on a popup inheriting them, pass them to the popup.
- **A popup's `setSettings`** now applies a `WKPreferences`-backed setting (`javaScriptEnabled`,
  `javaScriptCanOpenWindowsAutomatically`, `minimumFontSize` and five others) even when the value equals
  the popup's default: it compared against that default and skipped the call while the popup held a
  value inherited from its opener. As before, the opener changes too, since the two share those
  preferences.
- **`ProxyController.setProxyOverride`** throws a `PlatformException` (code `ProxyManager`) when a
  rule can't be parsed, and keeps the override in force. It used to drop such rules silently, so
  traffic could go direct while the app believed it was proxied.
- **`PullToRefreshController.beginRefreshing()`** called before the WebView is on screen is applied
  when it appears (it was lost); `isRefreshing` reports `true` meanwhile.
- **A removed WebView is disposed at once** when its widget is disposed (it could keep running its
  page until another platform view was drawn). A `keepAlive` WebView is unaffected.

**Android (7.1)**

- **The `InAppBrowser` and the JavaScript `alert` / `confirm` / `prompt` dialogs use Material 3** and
  follow the system's light / dark setting. The dialogs were AppCompat's dark dialog, even in light
  mode. The plugin now depends on `com.google.android.material:material` (1.14.0).
- **The unused `InAppWebViewTheme` style is removed.** If your app referenced
  `@style/InAppWebViewTheme`, use your own theme.

## Checklist

- [ ] `nosferatu500_inappwebview` in `pubspec.yaml`; imports updated.
- [ ] Flutter 3.47+ (or stay on 7.0.0 with 3.44).
- [ ] Android: `minSdk` 30, `compileSdk` 37, AGP 9, Kotlin Gradle Plugin 2.2.20+ declared,
      `FileProvider` block replaced if you had one.
- [ ] iOS: deployment target 15.0, Xcode 26, Swift Package Manager enabled.
- [ ] `*Options` → `*Settings`; `Android` / `IOS` prefixes dropped; platform-only API deleted.
- [ ] `onPrintRequest`, `onDownloadStarting`, `getQuotaForOrigin`, `getUsageForOrigin`,
      `hasCustomHeader` call sites updated.
- [ ] `shouldOverrideUrlLoading` handlers return `CANCEL` where they relied on `null`.
- [ ] iOS: `onLoadStop` / `onUpdateVisitedHistory` logic, `contentBlockers` errors, popup content
      blockers and `setProxyOverride` errors reviewed.
