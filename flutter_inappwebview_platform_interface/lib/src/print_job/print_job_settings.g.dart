// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_job_settings.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the settings of a [PlatformPrintJobController].
///
///**Officially Supported Platforms/Implementations**:
///- Android WebView
///- iOS WKWebView
class PrintJobSettings {
  ///`true` to animate the display of the sheet, `false` to display the sheet immediately.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  bool? animated;

  ///The color mode.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  PrintJobColorMode? colorMode;

  ///The duplex mode to use for the print job.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 23+
  ///- iOS WKWebView
  PrintJobDuplexMode? duplexMode;

  ///The height of the page footer.
  ///
  ///The footer is measured in points from the bottom of [printableRect] and is below the content area.
  ///The default footer height is `0.0`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  double? footerHeight;

  ///Force rendering quality.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 14.5+
  PrintJobRenderingQuality? forceRenderingQuality;

  ///Set this to `true` to handle the [PlatformPrintJobController].
  ///Otherwise, it will be handled and disposed automatically by the system.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  bool? handledByClient;

  ///The height of the page header.
  ///
  ///The header is measured in points from the top of [printableRect] and is above the content area.
  ///The default header height is `0.0`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  double? headerHeight;

  ///The name of the print job.
  ///An application should set this property to a name appropriate to the content being printed.
  ///The default job name is the current webpage title concatenated with the "Document" word at the end.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  String? jobName;

  ///The margins for each printed page.
  ///Margins define the white space around the content where the left margin defines
  ///the amount of white space on the left of the content and so on.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  EdgeInsets? margins;

  ///The maximum height of the content area.
  ///
  ///The Print Formatter uses this value to determine where the content rectangle begins on the first page.
  ///It compares the value of this property with the printing rectangle’s height minus the header and footer heights and
  ///the top inset value; it uses the lower of the two values.
  ///The default value of this property is the maximum float value.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  double? maximumContentHeight;

  ///The maximum width of the content area.
  ///
  ///The Print Formatter uses this value to determine the maximum width of the content rectangle.
  ///It compares the value of this property with the printing rectangle’s width minus the left and right inset values and uses the lower of the two.
  ///The default value of this property is the maximum float value.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  double? maximumContentWidth;

  ///The media size.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  PrintJobMediaSize? mediaSize;

  ///The number of pages to render.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  int? numberOfPages;

  ///The orientation of the printed content, portrait or landscape.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  PrintJobOrientation? orientation;

  ///The kind of printable content.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  PrintJobOutputType? outputType;

  ///The supported resolution in DPI (dots per inch).
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  PrintJobResolution? resolution;

  ///A Boolean value that determines whether the printing options include the number of copies.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  bool? showsNumberOfCopies;

  ///A Boolean value that determines whether the printing options include the paper orientation control when available.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.0+
  bool? showsPaperOrientation;

  ///A Boolean value that determines whether the paper selection menu displays.
  ///The default value of this property is `false`.
  ///Setting the value to `true` enables a paper selection menu on printers that support different types of paper and have more than one paper type loaded.
  ///On printers where only one paper type is available, no paper selection menu is displayed, regardless of the value of this property.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  bool? showsPaperSelectionForLoadedPapers;

  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  PrintJobSettings({
    this.animated = true,
    this.colorMode,
    this.duplexMode,
    this.footerHeight,
    this.forceRenderingQuality,
    this.handledByClient = false,
    this.headerHeight,
    this.jobName,
    this.margins,
    this.maximumContentHeight,
    this.maximumContentWidth,
    this.mediaSize,
    this.numberOfPages,
    this.orientation,
    this.outputType,
    this.resolution,
    this.showsNumberOfCopies = true,
    this.showsPaperOrientation = true,
    this.showsPaperSelectionForLoadedPapers = false,
  });

  ///Gets a possible [PrintJobSettings] instance from a [Map] value.
  static PrintJobSettings? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = PrintJobSettings(
      colorMode: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => PrintJobColorMode.fromNativeValue(
          map['colorMode'],
        ),
        EnumMethod.value => PrintJobColorMode.fromValue(map['colorMode']),
        EnumMethod.name => PrintJobColorMode.byName(map['colorMode']),
      },
      duplexMode: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => PrintJobDuplexMode.fromNativeValue(
          map['duplexMode'],
        ),
        EnumMethod.value => PrintJobDuplexMode.fromValue(map['duplexMode']),
        EnumMethod.name => PrintJobDuplexMode.byName(map['duplexMode']),
      },
      footerHeight: map['footerHeight'],
      forceRenderingQuality: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => PrintJobRenderingQuality.fromNativeValue(
          map['forceRenderingQuality'],
        ),
        EnumMethod.value => PrintJobRenderingQuality.fromValue(
          map['forceRenderingQuality'],
        ),
        EnumMethod.name => PrintJobRenderingQuality.byName(
          map['forceRenderingQuality'],
        ),
      },
      headerHeight: map['headerHeight'],
      jobName: map['jobName'],
      margins: MapEdgeInsets.fromMap(map['margins']?.cast<String, dynamic>()),
      maximumContentHeight: map['maximumContentHeight'],
      maximumContentWidth: map['maximumContentWidth'],
      mediaSize: PrintJobMediaSize.fromMap(
        map['mediaSize']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
      numberOfPages: map['numberOfPages'],
      orientation: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => PrintJobOrientation.fromNativeValue(
          map['orientation'],
        ),
        EnumMethod.value => PrintJobOrientation.fromValue(map['orientation']),
        EnumMethod.name => PrintJobOrientation.byName(map['orientation']),
      },
      outputType: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => PrintJobOutputType.fromNativeValue(
          map['outputType'],
        ),
        EnumMethod.value => PrintJobOutputType.fromValue(map['outputType']),
        EnumMethod.name => PrintJobOutputType.byName(map['outputType']),
      },
      resolution: PrintJobResolution.fromMap(
        map['resolution']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
    );
    instance.animated = map['animated'];
    instance.handledByClient = map['handledByClient'];
    instance.showsNumberOfCopies = map['showsNumberOfCopies'];
    instance.showsPaperOrientation = map['showsPaperOrientation'];
    instance.showsPaperSelectionForLoadedPapers =
        map['showsPaperSelectionForLoadedPapers'];
    return instance;
  }

  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isPropertySupported(
    PrintJobSettingsProperty property, {
    TargetPlatform? platform,
  }) => _PrintJobSettingsPropertySupported.isPropertySupported(
    property,
    platform: platform,
  );

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "animated": animated,
      "colorMode": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => colorMode?.toNativeValue(),
        EnumMethod.value => colorMode?.toValue(),
        EnumMethod.name => colorMode?.name(),
      },
      "duplexMode": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => duplexMode?.toNativeValue(),
        EnumMethod.value => duplexMode?.toValue(),
        EnumMethod.name => duplexMode?.name(),
      },
      "footerHeight": footerHeight,
      "forceRenderingQuality": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => forceRenderingQuality?.toNativeValue(),
        EnumMethod.value => forceRenderingQuality?.toValue(),
        EnumMethod.name => forceRenderingQuality?.name(),
      },
      "handledByClient": handledByClient,
      "headerHeight": headerHeight,
      "jobName": jobName,
      "margins": margins?.toMap(),
      "maximumContentHeight": maximumContentHeight,
      "maximumContentWidth": maximumContentWidth,
      "mediaSize": mediaSize?.toMap(enumMethod: enumMethod),
      "numberOfPages": numberOfPages,
      "orientation": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => orientation?.toNativeValue(),
        EnumMethod.value => orientation?.toValue(),
        EnumMethod.name => orientation?.name(),
      },
      "outputType": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => outputType?.toNativeValue(),
        EnumMethod.value => outputType?.toValue(),
        EnumMethod.name => outputType?.name(),
      },
      "resolution": resolution?.toMap(enumMethod: enumMethod),
      "showsNumberOfCopies": showsNumberOfCopies,
      "showsPaperOrientation": showsPaperOrientation,
      "showsPaperSelectionForLoadedPapers": showsPaperSelectionForLoadedPapers,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  ///Returns a copy of PrintJobSettings.
  PrintJobSettings copy() {
    return PrintJobSettings.fromMap(toMap()) ?? PrintJobSettings();
  }

  @override
  String toString() {
    return 'PrintJobSettings{animated: $animated, colorMode: $colorMode, duplexMode: $duplexMode, footerHeight: $footerHeight, forceRenderingQuality: $forceRenderingQuality, handledByClient: $handledByClient, headerHeight: $headerHeight, jobName: $jobName, margins: $margins, maximumContentHeight: $maximumContentHeight, maximumContentWidth: $maximumContentWidth, mediaSize: $mediaSize, numberOfPages: $numberOfPages, orientation: $orientation, outputType: $outputType, resolution: $resolution, showsNumberOfCopies: $showsNumberOfCopies, showsPaperOrientation: $showsPaperOrientation, showsPaperSelectionForLoadedPapers: $showsPaperSelectionForLoadedPapers}';
  }
}

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

///List of [PrintJobSettings]'s properties that can be used to check i they are supported or not by the current platform.
enum PrintJobSettingsProperty {
  ///Can be used to check if the [PrintJobSettings.animated] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.animated.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  animated,

  ///Can be used to check if the [PrintJobSettings.colorMode] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.colorMode.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  colorMode,

  ///Can be used to check if the [PrintJobSettings.duplexMode] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.duplexMode.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 23+
  ///- iOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  duplexMode,

  ///Can be used to check if the [PrintJobSettings.footerHeight] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.footerHeight.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  footerHeight,

  ///Can be used to check if the [PrintJobSettings.forceRenderingQuality] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.forceRenderingQuality.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 14.5+
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  forceRenderingQuality,

  ///Can be used to check if the [PrintJobSettings.handledByClient] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.handledByClient.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  handledByClient,

  ///Can be used to check if the [PrintJobSettings.headerHeight] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.headerHeight.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  headerHeight,

  ///Can be used to check if the [PrintJobSettings.jobName] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.jobName.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  jobName,

  ///Can be used to check if the [PrintJobSettings.margins] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.margins.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  margins,

  ///Can be used to check if the [PrintJobSettings.maximumContentHeight] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.maximumContentHeight.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  maximumContentHeight,

  ///Can be used to check if the [PrintJobSettings.maximumContentWidth] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.maximumContentWidth.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  maximumContentWidth,

  ///Can be used to check if the [PrintJobSettings.mediaSize] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.mediaSize.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  mediaSize,

  ///Can be used to check if the [PrintJobSettings.numberOfPages] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.numberOfPages.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  numberOfPages,

  ///Can be used to check if the [PrintJobSettings.orientation] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.orientation.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  orientation,

  ///Can be used to check if the [PrintJobSettings.outputType] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.outputType.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  outputType,

  ///Can be used to check if the [PrintJobSettings.resolution] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.resolution.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  resolution,

  ///Can be used to check if the [PrintJobSettings.showsNumberOfCopies] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.showsNumberOfCopies.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  showsNumberOfCopies,

  ///Can be used to check if the [PrintJobSettings.showsPaperOrientation] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.showsPaperOrientation.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.0+
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  showsPaperOrientation,

  ///Can be used to check if the [PrintJobSettings.showsPaperSelectionForLoadedPapers] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.showsPaperSelectionForLoadedPapers.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  showsPaperSelectionForLoadedPapers,
}

extension _PrintJobSettingsPropertySupported on PrintJobSettings {
  static bool isPropertySupported(
    PrintJobSettingsProperty property, {
    TargetPlatform? platform,
  }) {
    switch (property) {
      case PrintJobSettingsProperty.animated:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.colorMode:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.duplexMode:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.footerHeight:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.forceRenderingQuality:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.handledByClient:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.headerHeight:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.jobName:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.margins:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.maximumContentHeight:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.maximumContentWidth:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.mediaSize:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.numberOfPages:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.orientation:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.outputType:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.resolution:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.showsNumberOfCopies:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.showsPaperOrientation:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.showsPaperSelectionForLoadedPapers:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
    }
  }
}
