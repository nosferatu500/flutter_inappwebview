// Pigeon schema for the find-interaction channel.
//
// This is the pilot for migrating the plugin's Dart<->Kotlin boundary off hand-written
// MethodChannel dispatch. find_interaction was chosen because it is small (6 methods, 1 event) yet
// exercises all three mechanisms the rest of the migration depends on:
//
//   * HostApi              -- Dart calling into Kotlin
//   * FlutterApi           -- Kotlin calling back into Dart (onFindResultReceived)
//   * messageChannelSuffix -- one channel per WebView instance, which every per-instance delegate
//                             in this plugin needs
//
// The generated types are transport only. The public API stays the platform-interface types
// (PlatformFindInteractionController, and its FindSession), so the implementation converts at the
// boundary. That conversion is the standing cost of adopting Pigeon here and is why this schema
// does not try to re-export generated types.
//
// Regenerate with BOTH steps, from flutter_inappwebview_android/:
//   dart run pigeon --input pigeons/find_interaction.dart
//   dart format lib/src/pigeons/find_interaction.g.dart
//
// The format pass is not optional: Pigeon's Dart output does not satisfy this repo's
// `dart format --set-exit-if-changed` gate. Generate-then-format is idempotent (verified), so the
// formatted file is stable across regenerations and produces no diff churn.
//
// Do not edit the generated files; edit this schema and regenerate.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/find_interaction.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/dev/nosferatu500/inappwebview/pigeons/FindInteraction.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dev.nosferatu500.inappwebview.pigeons',
    ),
    dartPackageName: 'flutter_inappwebview_android',
  ),
)
/// Mirrors the platform interface's `FindSession`.
///
/// Deliberately a separate type: the platform interface's version is the public API and is shared
/// with iOS, so it cannot be Pigeon-generated without coupling every platform to this schema.
class FindSessionData {
  FindSessionData({
    required this.resultCount,
    required this.highlightedResultIndex,
    required this.searchResultDisplayStyle,
  });

  final int resultCount;
  final int highlightedResultIndex;

  /// Always null on Android; the field exists so the shape matches the platform interface's
  /// `FindSession`, which carries it for iOS.
  final int? searchResultDisplayStyle;
}

@HostApi()
abstract class FindInteractionHostApi {
  void findAll(String? find);

  void findNext(bool forward);

  void clearMatches();

  void setSearchText(String? searchText);

  /// Returns the current search text.
  ///
  /// The hand-written channel this replaces returned `false` (a bool) when the controller had gone
  /// away, and the String otherwise, so the Dart side received a value it could not type. Pigeon
  /// makes that unrepresentable: a missing controller is simply null.
  String? getSearchText();

  FindSessionData? getActiveFindSession();
}

@FlutterApi()
abstract class FindInteractionFlutterApi {
  void onFindResultReceived(
    int activeMatchOrdinal,
    int numberOfMatches,
    bool isDoneCounting,
  );
}
