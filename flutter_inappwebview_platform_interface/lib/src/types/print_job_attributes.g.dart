// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_job_attributes.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class representing the attributes of a [PlatformPrintJobController].
///These attributes describe how the printed content should be laid out.
class PrintJobAttributes {
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
  PrintJobDuplexMode? duplex;

  ///The height of the page footer.
  ///
  ///The footer is measured in points from the bottom of [printableRect] and is below the content area.
  ///The default footer height is `0.0`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  double? footerHeight;

  ///The height of the page header.
  ///
  ///The header is measured in points from the top of [printableRect] and is above the content area.
  ///The default header height is `0.0`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  double? headerHeight;

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

  ///The orientation of the printed content, portrait or landscape.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  PrintJobOrientation? orientation;

  ///The size of the paper used for printing.
  ///
  ///The value of this property is a rectangle that defines the size of paper chosen for the print job.
  ///The origin is always (0,0).
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  InAppWebViewRect? paperRect;

  ///The area in which printing can occur.
  ///
  ///The value of this property is a rectangle that defines the area in which the printer can print content.
  ///Sometimes this is referred to as the imageable area of the paper.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  InAppWebViewRect? printableRect;

  ///The supported resolution in DPI (dots per inch).
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  PrintJobResolution? resolution;
  PrintJobAttributes({
    this.colorMode,
    this.duplex,
    this.footerHeight,
    this.headerHeight,
    this.margins,
    this.maximumContentHeight,
    this.maximumContentWidth,
    this.mediaSize,
    this.orientation,
    this.paperRect,
    this.printableRect,
    this.resolution,
  });

  ///Gets a possible [PrintJobAttributes] instance from a [Map] value.
  static PrintJobAttributes? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = PrintJobAttributes(
      colorMode: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => PrintJobColorMode.fromNativeValue(
          map['colorMode'],
        ),
        EnumMethod.value => PrintJobColorMode.fromValue(map['colorMode']),
        EnumMethod.name => PrintJobColorMode.byName(map['colorMode']),
      },
      duplex: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => PrintJobDuplexMode.fromNativeValue(
          map['duplex'],
        ),
        EnumMethod.value => PrintJobDuplexMode.fromValue(map['duplex']),
        EnumMethod.name => PrintJobDuplexMode.byName(map['duplex']),
      },
      footerHeight: map['footerHeight'],
      headerHeight: map['headerHeight'],
      margins: MapEdgeInsets.fromMap(map['margins']?.cast<String, dynamic>()),
      maximumContentHeight: map['maximumContentHeight'],
      maximumContentWidth: map['maximumContentWidth'],
      mediaSize: PrintJobMediaSize.fromMap(
        map['mediaSize']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
      orientation: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => PrintJobOrientation.fromNativeValue(
          map['orientation'],
        ),
        EnumMethod.value => PrintJobOrientation.fromValue(map['orientation']),
        EnumMethod.name => PrintJobOrientation.byName(map['orientation']),
      },
      paperRect: InAppWebViewRect.fromMap(
        map['paperRect']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
      printableRect: InAppWebViewRect.fromMap(
        map['printableRect']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
      resolution: PrintJobResolution.fromMap(
        map['resolution']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "colorMode": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => colorMode?.toNativeValue(),
        EnumMethod.value => colorMode?.toValue(),
        EnumMethod.name => colorMode?.name(),
      },
      "duplex": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => duplex?.toNativeValue(),
        EnumMethod.value => duplex?.toValue(),
        EnumMethod.name => duplex?.name(),
      },
      "footerHeight": footerHeight,
      "headerHeight": headerHeight,
      "margins": margins?.toMap(),
      "maximumContentHeight": maximumContentHeight,
      "maximumContentWidth": maximumContentWidth,
      "mediaSize": mediaSize?.toMap(enumMethod: enumMethod),
      "orientation": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => orientation?.toNativeValue(),
        EnumMethod.value => orientation?.toValue(),
        EnumMethod.name => orientation?.name(),
      },
      "paperRect": paperRect?.toMap(enumMethod: enumMethod),
      "printableRect": printableRect?.toMap(enumMethod: enumMethod),
      "resolution": resolution?.toMap(enumMethod: enumMethod),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'PrintJobAttributes{colorMode: $colorMode, duplex: $duplex, footerHeight: $footerHeight, headerHeight: $headerHeight, margins: $margins, maximumContentHeight: $maximumContentHeight, maximumContentWidth: $maximumContentWidth, mediaSize: $mediaSize, orientation: $orientation, paperRect: $paperRect, printableRect: $printableRect, resolution: $resolution}';
  }
}
