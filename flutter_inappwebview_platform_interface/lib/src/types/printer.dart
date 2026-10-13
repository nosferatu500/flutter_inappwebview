import 'package:nosferatu500_inappwebview_internal_annotations/nosferatu500_inappwebview_internal_annotations.dart';

import '../print_job/main.dart';
import 'enum_method.dart';

part 'printer.g.dart';

///Class representing the printer used by a [PlatformPrintJobController].
@ExchangeableObject()
class Printer_ {
  ///The unique id of the printer.
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  String? id;

  Printer_({this.id});
}
