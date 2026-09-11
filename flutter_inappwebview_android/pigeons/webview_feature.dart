// Pigeon schema for the webview-feature channel.
//
// Fourth channel migrated off hand-written MethodChannel dispatch, after find_interaction (§14),
// process_global_config (§157) and proxy (§160). Two methods, both simple predicates.
//
// No `messageChannelSuffix`: both androidx entry points are statics on `WebViewFeature`, so there
// is one channel rather than one per WebView.
//
// **Neither method is `@async`**, and that was checked rather than assumed (the check §160 added to
// the template). `WebViewFeature.isFeatureSupported(String)` and
// `isStartupFeatureSupported(Context, String)` both return `boolean` directly -- no `Executor`, no
// completion callback -- so the synchronous default is correct here.
//
// Regenerate with BOTH steps, from flutter_inappwebview_android/:
//   dart run pigeon --input pigeons/webview_feature.dart
//   dart format lib/src/pigeons/webview_feature.g.dart
//
// The format pass is not optional: Pigeon's Dart output does not satisfy this repo's
// `dart format --set-exit-if-changed` gate.
//
// Do not edit the generated files; edit this schema and regenerate.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/webview_feature.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/dev/nosferatu500/inappwebview/pigeons/WebViewFeature.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dev.nosferatu500.inappwebview.pigeons',
      // Every Pigeon Kotlin output declares its own `FlutterError` by default, and all of this
      // plugin's outputs share one package -- so a second declarer stops the module compiling
      // ("Redeclaration: FlutterError"). `find_interaction` is the designated declarer; every
      // other schema in this package must opt out here. See §157.
      includeErrorClass: false,
    ),
    dartPackageName: 'flutter_inappwebview_android',
  ),
)
/// No data classes: both methods take androidx's own feature string and return a bool.
///
/// The string is `WebViewFeature.toNativeValue()`. It is **not** a Pigeon enum, for the same reason
/// `ProxyRuleData.schemeFilter` is not (§160): the platform interface's `WebViewFeature` is an open
/// `_internal(String)` class rather than a closed enum, and androidx types these parameters as
/// annotated `String`s.
@HostApi()
abstract class WebViewFeatureHostApi {
  /// Whether androidx supports [feature] on the current platform SDK and WebView version.
  ///
  /// **Throws for a declared-but-unregistered feature.** androidx's `isFeatureSupported` raises
  /// `RuntimeException("Unknown feature ...")` rather than answering `false` for the six
  /// `WebViewFeature` constants that are declared but never registered with
  /// `WebViewFeatureInternal` -- the tombstones §36 found. That behaviour is unchanged by this
  /// migration: the hand-written channel let the exception propagate to Flutter's `MethodChannel`,
  /// which wrapped it, and Pigeon's `wrapError` does the same.
  bool isFeatureSupported(String feature);

  /// Whether androidx supports [startupFeature], which is a **different** namespace from
  /// [isFeatureSupported] and must not be called with an ordinary feature.
  ///
  /// 🚨 **This fixes a hang.** The hand-written Kotlin read the *activity*
  /// (`plugin?.activity`) and, when it was null, **returned without calling `result` at all** --
  /// no success, no error, no `notImplemented`. `plugin.activity` is genuinely nullable: it is
  /// null until `onAttachedToActivity` and is set back to null on
  /// `onDetachedFromActivityForConfigChanges`, so any call in those windows left the caller's
  /// `await` pending forever. The Dart side's `?? false` could not help -- it defaults a null
  /// *reply*, not a reply that never comes.
  ///
  /// A synchronous Pigeon method has to return a value, which makes that path unrepresentable. The
  /// fix is not "return false": the manager now passes the plugin's **application** context, which
  /// is `lateinit` and always set from `onAttachedToEngine`. That is the correct argument rather
  /// than merely a non-null one -- androidx documents the parameter as "a Context to access
  /// application assets", and `StartupApiFeature` uses it only for `getPackageManager()` and
  /// `WebViewCompat.getCurrentWebViewPackage(context)`, both package-manager lookups an
  /// application context serves identically to an Activity. Verified in the 1.17.0 sources jar,
  /// not inferred from the signature.
  bool isStartupFeatureSupported(String startupFeature);
}
