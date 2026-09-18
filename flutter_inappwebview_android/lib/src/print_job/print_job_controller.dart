import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show EdgeInsets;
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../pigeons/print_job.g.dart';

/// Object specifying creation parameters for creating a [AndroidPrintJobController].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformPrintJobControllerCreationParams] for
/// more information.
@immutable
class AndroidPrintJobControllerCreationParams
    extends PlatformPrintJobControllerCreationParams {
  /// Creates a new [AndroidPrintJobControllerCreationParams] instance.
  const AndroidPrintJobControllerCreationParams({required super.id});

  /// Creates a [AndroidPrintJobControllerCreationParams] instance based on [PlatformPrintJobControllerCreationParams].
  factory AndroidPrintJobControllerCreationParams.fromPlatformPrintJobControllerCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformPrintJobControllerCreationParams params,
  ) {
    return AndroidPrintJobControllerCreationParams(id: params.id);
  }
}

/// Receives [PrintJobControllerFlutterApi] events and forwards them to the controller.
///
/// 🚨 **A separate class rather than having the controller implement the generated API directly,
/// and this is the collision §14 predicted.** `PlatformPrintJobController` already exposes
/// `onComplete` as a **field** (`PrintJobCompletionHandler? onComplete`), and Pigeon generates a
/// **method** of the same name; Dart rejects a class that would have both as inconsistent
/// inheritance. Exactly the shape §14 hit on `onFindResultReceived`, and the reason P0a item 4 has
/// carried "expect a private forwarding class per event whose name collides" since the pilot.
///
/// §165's two web-message channels escaped this only because `onMessage` and `onPostMessage` happen
/// not to collide with anything.
class _PrintJobControllerFlutterApiImpl
    implements PrintJobControllerFlutterApi {
  _PrintJobControllerFlutterApiImpl(this._controller);

  final AndroidPrintJobController _controller;

  @override
  void onComplete(bool completed, String? error) {
    _controller.onComplete?.call(completed, error);
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController}
///
/// Transport is Pigeon-generated ([PrintJobControllerHostApi] / [PrintJobControllerFlutterApi])
/// rather than a hand-written `MethodChannel`; the twelfth channel migrated. **Per-instance**: the
/// `messageChannelSuffix` is the job id, so both halves must derive it from the same value — §165
/// measured that a mismatch here produces no error, just a 60-second timeout.
class AndroidPrintJobController extends PlatformPrintJobController {
  /// Constructs a [AndroidPrintJobController].
  AndroidPrintJobController(PlatformPrintJobControllerCreationParams params)
    : super.implementation(
        params is AndroidPrintJobControllerCreationParams
            ? params
            : AndroidPrintJobControllerCreationParams.fromPlatformPrintJobControllerCreationParams(
                params,
              ),
      ) {
    _hostApi = PrintJobControllerHostApi(messageChannelSuffix: params.id);
    PrintJobControllerFlutterApi.setUp(
      _PrintJobControllerFlutterApiImpl(this),
      messageChannelSuffix: params.id,
    );
  }

  late final PrintJobControllerHostApi _hostApi;

  static final AndroidPrintJobController _staticValue =
      AndroidPrintJobController(
        AndroidPrintJobControllerCreationParams(id: ''),
      );

  /// Provide static access.
  factory AndroidPrintJobController.static() {
    return _staticValue;
  }

  @override
  Future<void> cancel() async {
    // The host answers whether the controller was still live, and that answer is dropped here
    // because the platform interface declares `Future<void>`. It would not mean "the job was
    // cancelled" in any case — see the schema.
    await _hostApi.cancel();
  }

  @override
  Future<void> restart() async {
    // See cancel for the discarded bool.
    await _hostApi.restart();
  }

  @override
  Future<PrintJobInfo?> getInfo() async {
    final info = await _hostApi.getInfo();
    if (info == null) {
      return null;
    }
    return PrintJobInfo(
      state: PrintJobState.fromNativeValue(info.state),
      copies: info.copies,
      numberOfPages: info.numberOfPages,
      creationTime: info.creationTime,
      label: info.label,
      // Rebuilt unconditionally, including when the id is null: the hand-written channel always sent
      // a `"printer"` map even when the id inside it was null, so `Printer.fromMap` always returned
      // an object. Making this null when the id is null would be a behaviour change.
      printer: Printer(id: info.printerId),
      attributes: _attributesFrom(info.attributes),
      // The eight fields Android never sends. They arrived as absent map keys before, which
      // `fromMap` read as null, so passing null here is exactly what the old path produced. Measured:
      // each has zero occurrences in the Android Kotlin source. See the schema and §176.
      canSpawnSeparateThread: null,
      currentPage: null,
      firstPage: null,
      isCopyingOperation: null,
      lastPage: null,
      preferredRenderingQuality: null,
      showsPrintPanel: null,
      showsProgressPanel: null,
    );
  }

  @override
  Future<void> dispose() async {
    await _hostApi.dispose();
    PrintJobControllerFlutterApi.setUp(null, messageChannelSuffix: params.id);
  }

  /// The six attribute fields Android populates; the other six the public type declares
  /// (`footerHeight`, `headerHeight`, `maximumContentHeight`, `maximumContentWidth`, `paperRect`,
  /// `printableRect`) are iOS-only and were never on the wire. See the schema.
  static PrintJobAttributes? _attributesFrom(PrintJobAttributesData? data) {
    if (data == null) {
      return null;
    }
    final mediaSize = data.mediaSize;
    final resolution = data.resolution;
    final margins = data.margins;
    return PrintJobAttributes(
      colorMode: PrintJobColorMode.fromNativeValue(data.colorMode),
      duplex: PrintJobDuplexMode.fromNativeValue(data.duplex),
      orientation: PrintJobOrientation.fromNativeValue(data.orientation),
      mediaSize: mediaSize == null
          ? null
          : PrintJobMediaSize(
              id: mediaSize.id,
              label: mediaSize.label,
              widthMils: mediaSize.widthMils,
              heightMils: mediaSize.heightMils,
            ),
      resolution: resolution == null
          ? null
          : PrintJobResolution(
              id: resolution.id,
              label: resolution.label,
              verticalDpi: resolution.verticalDpi,
              horizontalDpi: resolution.horizontalDpi,
            ),
      margins: margins == null
          ? null
          : EdgeInsets.only(
              top: margins.top,
              right: margins.right,
              bottom: margins.bottom,
              left: margins.left,
            ),
      footerHeight: null,
      headerHeight: null,
      maximumContentHeight: null,
      maximumContentWidth: null,
      paperRect: null,
      printableRect: null,
    );
  }
}
