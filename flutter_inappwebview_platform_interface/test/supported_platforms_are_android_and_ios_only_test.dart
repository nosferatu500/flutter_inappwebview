// §9 dropped macOS, Windows and Linux; Web was never implemented. §154 removed
// the annotations for them so a dropped platform cannot be named at all.
//
// This gate exists because the failure is silent. `SupportedPlatformsGenerator`
// maps whatever an annotation names straight to a `TargetPlatform.<name>` arm:
//
//   [${targetPlatforms.map((e) => "TargetPlatform.$e").join(', ')}]
//       .contains(platform ?? defaultTargetPlatform)
//
// so one restored annotation class plus one usage puts a dropped platform back
// into the shipped support tables, with nothing failing to compile and no test
// noticing. The example's support matrix used to be the only place that showed,
// and §151 deleted those columns — so this is now the only check.
//
// NOTE ON WHERE THIS LIVES: it must be in a package that resolves the *local*
// `dev_packages/flutter_inappwebview_internal_annotations`. This one does, via
// `dependency_overrides`. `dev_packages/generators` does NOT — it resolves
// 1.3.0 from pub.dev, so the same assertions there would read the old six-entry
// constants and pass while proving nothing.
import 'dart:io';

import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('annotatable platforms', () {
    test('are exactly Android and iOS', () {
      expect(kTargetPlatformNameValues, ['android', 'iOS']);
      expect(kPlatformNameValues, ['Android WebView', 'iOS WKWebView']);
    });

    test('the annotation classes for dropped platforms do not exist', () {
      // A deleted class cannot be referenced from Dart without breaking the
      // build, so this asserts on the source instead.
      final source = File(
        '../dev_packages/flutter_inappwebview_internal_annotations/lib/src/supported_platforms.dart',
      );
      final enumSource = File(
        '../dev_packages/flutter_inappwebview_internal_annotations/lib/src/enum_supported_platforms.dart',
      );
      expect(
        source.existsSync() && enumSource.existsSync(),
        isTrue,
        reason:
            'Annotation sources not found at ${source.absolute.path} — if the layout '
            'moved this gate silently stops checking anything.',
      );

      final text = source.readAsStringSync() + enumSource.readAsStringSync();
      for (final dropped in ['MacOS', 'Windows', 'Linux', 'Web']) {
        expect(
          text.contains('class ${dropped}Platform'),
          isFalse,
          reason: '${dropped}Platform was reintroduced.',
        );
        expect(
          text.contains('class Enum${dropped}Platform'),
          isFalse,
          reason: 'Enum${dropped}Platform was reintroduced.',
        );
      }
      // Control: the two platforms that DO exist must be found by the same
      // check, otherwise the loop above passes because nothing matches at all.
      expect(text.contains('class AndroidPlatform'), isTrue);
      expect(text.contains('class IOSPlatform'), isTrue);
      expect(text.contains('class EnumAndroidPlatform'), isTrue);
      expect(text.contains('class EnumIOSPlatform'), isTrue);
    });

    test('no generated file names a dropped platform', () {
      // The artefact itself, which is what actually ships.
      final generated = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.g.dart'))
          .toList();
      expect(
        generated.length,
        greaterThan(200),
        reason:
            'Found only ${generated.length} .g.dart files; expected ~237. '
            'The gate is not looking where the generated code is.',
      );

      final offenders = <String>[];
      var sawAndroidOrIOS = 0;
      for (final file in generated) {
        final text = file.readAsStringSync();
        for (final dropped in ['macOS', 'windows', 'linux']) {
          if (text.contains('TargetPlatform.$dropped')) {
            offenders.add('${file.path}: TargetPlatform.$dropped');
          }
        }
        if (text.contains('TargetPlatform.android') ||
            text.contains('TargetPlatform.iOS')) {
          sawAndroidOrIOS++;
        }
      }

      // Control first: if nothing mentions any TargetPlatform, the scan is
      // reading the wrong files and the emptiness below means nothing.
      // Measured at 50 of the ~237 generated files — most are exchangeable
      // objects with no support table at all, so the floor is well under 50
      // rather than a fraction of the file count.
      expect(
        sawAndroidOrIOS,
        greaterThan(40),
        reason:
            'Only $sawAndroidOrIOS generated files mention TargetPlatform.android/iOS; '
            'the scan is not reading the support tables.',
      );
      expect(offenders, isEmpty);
    });
  });
}
