import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nosferatu500_inappwebview_platform_interface/nosferatu500_inappwebview_platform_interface.dart';

///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppLocalhostServer}
///
///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppLocalhostServer.supported_platforms}
class InAppLocalhostServer {
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppLocalhostServer}
  InAppLocalhostServer({
    int port = 8080,
    String directoryIndex = 'index.html',
    String documentRoot = './',
    bool shared = false,
    Future<bool> Function(HttpRequest request)? onData,
  }) : this.fromPlatformCreationParams(
         PlatformInAppLocalhostServerCreationParams(
           port: port,
           directoryIndex: directoryIndex,
           documentRoot: documentRoot,
           shared: shared,
           onData: onData,
         ),
       );

  /// Constructs a [InAppLocalhostServer] from creation params for a specific
  /// platform.
  InAppLocalhostServer.fromPlatformCreationParams(
    PlatformInAppLocalhostServerCreationParams params,
  ) : this.fromPlatform(PlatformInAppLocalhostServer(params));

  /// Constructs a [InAppLocalhostServer] from a specific platform
  /// implementation.
  InAppLocalhostServer.fromPlatform(this.platform);

  /// Implementation of [PlatformInAppLocalhostServer] for the current platform.
  final PlatformInAppLocalhostServer platform;

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppLocalhostServer.port}
  int get port => platform.port;

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppLocalhostServer.directoryIndex}
  String get directoryIndex => platform.directoryIndex;

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppLocalhostServer.documentRoot}
  String get documentRoot => platform.documentRoot;

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppLocalhostServer.shared}
  bool get shared => platform.shared;

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppLocalhostServer.onData}
  Future<bool> Function(HttpRequest request)? get onData => platform.onData;

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppLocalhostServer.start}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppLocalhostServer.start.supported_platforms}
  Future<void> start() => platform.start();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppLocalhostServer.close}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppLocalhostServer.close.supported_platforms}
  Future<void> close() => platform.close();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppLocalhostServer.isRunning}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppLocalhostServer.isRunning.supported_platforms}
  bool isRunning() => platform.isRunning();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppLocalhostServerCreationParams.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformInAppLocalhostServer.static().isClassSupported(
        platform: platform,
      );

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformInAppLocalhostServer.isMethodSupported}
  static bool isMethodSupported(
    PlatformInAppLocalhostServerMethod method, {
    TargetPlatform? platform,
  }) => PlatformInAppLocalhostServer.static().isMethodSupported(
    method,
    platform: platform,
  );
}
