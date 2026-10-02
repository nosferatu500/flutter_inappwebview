import 'package:build_test/build_test.dart';
import 'package:generators/src/supported_platforms_generator.dart';
import 'package:logging/logging.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

/// [SupportedPlatformsGenerator] emits a private `_<Class>ClassSupported` extension for every class
/// that declares `isClassSupported`. Some classes answer through their creation params instead and
/// never call it, but it still carries the `supported_platforms` doc template that other docs
/// `{@macro}`. So it gets `// ignore: unused_element`, but **only** when the hand-written library
/// never calls it (§220). An ignore on every extension would have hidden the bug §220 found:
/// `ServiceWorkerClient` answered from another class's extension, and its own went unused.
Future<String> _generate(String model) async {
  final result = await testBuilder(
    SharedPartBuilder([SupportedPlatformsGenerator()], 'supported_platforms'),
    {
      // Matched by package (`TypeChecker.typeNamedLiterally(..., inPackage: ...)`), so the
      // annotations are supplied under the real package name, in the shapes the generator reads.
      'flutter_inappwebview_internal_annotations|lib/flutter_inappwebview_internal_annotations.dart':
          '''
abstract class Platform {
  final String? available;
  final String? apiName;
  final String? apiUrl;
  final String? note;
  final String name;
  final String targetPlatformName;
  const Platform({this.available, this.apiName, this.apiUrl, this.note, this.name = '',
      this.targetPlatformName = ''});
}

class AndroidPlatform implements Platform {
  final String? available;
  final String? apiName;
  final String? apiUrl;
  final String? note;
  final String name;
  final String targetPlatformName;
  const AndroidPlatform({this.available, this.apiName, this.apiUrl, this.note,
      this.name = 'Android WebView', this.targetPlatformName = 'android'});
}

class SupportedPlatforms {
  final List<Platform> platforms;
  final bool ignore;
  final List<String> ignorePropertyNames;
  final List<String> ignoreMethodNames;
  final List<String> ignoreParameterNames;
  final Map<String, List<Platform>> parameterPlatforms;
  const SupportedPlatforms({required this.platforms, this.ignore = false,
      this.ignorePropertyNames = const [], this.ignoreMethodNames = const [],
      this.ignoreParameterNames = const [], this.parameterPlatforms = const {}});
}
''',
      'a|lib/input.dart': model,
    },
    generateFor: {'a|lib/input.dart'},
    onLog: (l) {
      if (l.level >= Level.SEVERE) {
        fail('builder logged ${l.level.name}: ${l.message}${l.error ?? ''}');
      }
    },
  );

  final generated = result.readerWriter.testing.assets
      .where((id) => id.path.endsWith('.g.part'))
      .toList();
  expect(
    generated,
    hasLength(1),
    reason: 'expected exactly one generated part',
  );
  return result.readerWriter.testing.readString(generated.single);
}

/// The text of `extension _<name>ClassSupported …` up to its closing brace.
String _extension(String output, String name) {
  final start = output.indexOf('extension _${name}ClassSupported');
  expect(start, isNot(-1), reason: 'no extension emitted for $name');
  final end = output.indexOf('\n}', start);
  return output.substring(start, end);
}

void main() {
  test(
    'the ignore goes on exactly the extension its library never calls',
    () async {
      final output = await _generate('''
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

@SupportedPlatforms(platforms: [AndroidPlatform()])
class Calls {
  Calls();
  static bool isClassSupported() => _CallsClassSupported.isClassSupported();
}

@SupportedPlatforms(platforms: [AndroidPlatform()])
class Delegates {
  Delegates();
  bool isClassSupported() => true;
}
''');

      expect(
        _extension(output, 'Calls'),
        isNot(contains('// ignore: unused_element')),
        reason: 'a called extension must stay checked',
      );
      final delegates = _extension(output, 'Delegates');
      expect(delegates, contains('// ignore: unused_element'));
      // The doc template it is kept for is still emitted.
      expect(
        delegates,
        contains('{@template a.Delegates.supported_platforms}'),
      );
      expect(
        RegExp('// ignore: unused_element').allMatches(output),
        hasLength(1),
      );
    },
  );
}
