import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../types/main.dart';
import '../types/print_job_color_mode.dart';
import '../types/print_job_duplex_mode.dart';
import '../types/print_job_media_size.dart';
import '../types/print_job_orientation.dart';
import '../types/print_job_output_type.dart';
import '../types/print_job_rendering_quality.dart';
import '../types/print_job_resolution.dart';
import '../util.dart';
import 'platform_print_job_controller.dart';

part 'print_job_settings.g.dart';

///Class that represents the settings of a [PlatformPrintJobController].
@ExchangeableObject(copyMethod: true)
@SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
class PrintJobSettings_ {
  ///Set this to `true` to handle the [PlatformPrintJobController].
  ///Otherwise, it will be handled and disposed automatically by the system.
  ///The default value is `false`.
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  bool? handledByClient;

  ///The name of the print job.
  ///An application should set this property to a name appropriate to the content being printed.
  ///The default job name is the current webpage title concatenated with the "Document" word at the end.
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  String? jobName;

  ///`true` to animate the display of the sheet, `false` to display the sheet immediately.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  bool? animated;

  ///The orientation of the printed content, portrait or landscape.
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  PrintJobOrientation_? orientation;

  ///The number of pages to render.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  int? numberOfPages;

  ///Force rendering quality.
  @SupportedPlatforms(platforms: [IOSPlatform(available: '14.5')])
  PrintJobRenderingQuality_? forceRenderingQuality;

  ///The margins for each printed page.
  ///Margins define the white space around the content where the left margin defines
  ///the amount of white space on the left of the content and so on.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  EdgeInsets? margins;

  ///The media size.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  PrintJobMediaSize_? mediaSize;

  ///The color mode.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  PrintJobColorMode_? colorMode;

  ///The duplex mode to use for the print job.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(available: "23"),
      IOSPlatform(),
    ],
  )
  PrintJobDuplexMode_? duplexMode;

  ///The kind of printable content.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  PrintJobOutputType_? outputType;

  ///The supported resolution in DPI (dots per inch).
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  PrintJobResolution_? resolution;

  ///A Boolean value that determines whether the printing options include the number of copies.
  ///The default value is `true`.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  bool? showsNumberOfCopies;

  ///A Boolean value that determines whether the paper selection menu displays.
  ///The default value of this property is `false`.
  ///Setting the value to `true` enables a paper selection menu on printers that support different types of paper and have more than one paper type loaded.
  ///On printers where only one paper type is available, no paper selection menu is displayed, regardless of the value of this property.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  bool? showsPaperSelectionForLoadedPapers;

  ///A Boolean value that determines whether the printing options include the paper orientation control when available.
  ///The default value is `true`.
  @SupportedPlatforms(platforms: [IOSPlatform(available: '15.0')])
  bool? showsPaperOrientation;

  ///The height of the page footer.
  ///
  ///The footer is measured in points from the bottom of [printableRect] and is below the content area.
  ///The default footer height is `0.0`.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  double? footerHeight;

  ///The height of the page header.
  ///
  ///The header is measured in points from the top of [printableRect] and is above the content area.
  ///The default header height is `0.0`.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  double? headerHeight;

  ///The maximum height of the content area.
  ///
  ///The Print Formatter uses this value to determine where the content rectangle begins on the first page.
  ///It compares the value of this property with the printing rectangle’s height minus the header and footer heights and
  ///the top inset value; it uses the lower of the two values.
  ///The default value of this property is the maximum float value.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  double? maximumContentHeight;

  ///The maximum width of the content area.
  ///
  ///The Print Formatter uses this value to determine the maximum width of the content rectangle.
  ///It compares the value of this property with the printing rectangle’s width minus the left and right inset values and uses the lower of the two.
  ///The default value of this property is the maximum float value.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  double? maximumContentWidth;

  PrintJobSettings_({
    this.handledByClient = false,
    this.jobName,
    this.animated = true,
    this.orientation,
    this.numberOfPages,
    this.forceRenderingQuality,
    this.margins,
    this.mediaSize,
    this.colorMode,
    this.duplexMode,
    this.outputType,
    this.resolution,
    this.showsNumberOfCopies = true,
    this.showsPaperSelectionForLoadedPapers = false,
    this.showsPaperOrientation = true,
    this.maximumContentHeight,
    this.maximumContentWidth,
    this.footerHeight,
    this.headerHeight,
  });

  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isPropertySupported(
    PrintJobSettingsProperty property, {
    TargetPlatform? platform,
  }) => _PrintJobSettingsPropertySupported.isPropertySupported(
    property,
    platform: platform,
  );
}
