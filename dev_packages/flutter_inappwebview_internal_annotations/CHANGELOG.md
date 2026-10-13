## 7.0.0

- **BREAKING: the package is renamed `nosferatu500_inappwebview_internal_annotations`** (was
  `flutter_inappwebview_internal_annotations`). Import
  `package:nosferatu500_inappwebview_internal_annotations/nosferatu500_inappwebview_internal_annotations.dart`.
  The version goes from 1.3.0 to 7.0.0 so that all five `nosferatu500_inappwebview*` packages ship at
  one number; the entries below 7.0.0 are upstream's, published under the old name.
- **BREAKING: the macOS, Windows, Linux and Web annotations are removed** with those platforms:
  `MacOSPlatform`, `WindowsPlatform`, `LinuxPlatform`, `WebPlatform`, their `Enum…Platform`
  counterparts, and the `kPlatformName…` / `kTargetPlatformName…` constants for the four platforms
  (16 declarations; none added). `kPlatformNameValues` and `kTargetPlatformNameValues` list Android and
  iOS only. Compared against upstream's published 1.3.0.

## 1.3.0

- Updated linux platform name

## 1.2.0

- Updated `ExchangeableEnum` and `ExchangeableObjectProperty`.

## 1.1.1

- Added `ExchangeableObject.fromMapForceAllInline`.

## 1.1.0

- Added `ExchangeableObject.copyMethod`.

## 1.0.0

Initial release.