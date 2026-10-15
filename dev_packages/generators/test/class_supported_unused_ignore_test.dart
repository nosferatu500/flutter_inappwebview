import 'package:build_test/build_test.dart';
import 'package:generators/src/supported_platforms_generator.dart';
import 'package:logging/logging.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

/// [SupportedPlatformsGenerator] emits a private `_<Class>ClassSupported` extension only for a class
/// whose hand-written library calls it. Some classes answer through their creation params instead and
/// never call it, and an uncalled extension isn't emitted at all (§350), so none needs an
/// `// ignore: unused_element`. An ignore would have hidden the bug §220 found: `ServiceWorkerClient`
/// answered from another class's extension, and its own went unused.
///
/// The class's `supported_platforms` doc template must sit on a public element: dartdoc registers no
/// template from a private element in a part file (§350). It goes on the class's property enum, else
/// its method enum (§345), else a member-less `<Class>SupportedPlatforms` carrier class, which the
/// library's export hides (§350). Parameter names in the generated "Parameters" lists are code spans,
/// not `[links]`: the lists sit on enum values, where dartdoc can't resolve a method's parameter.
Future<String> _generate(String model) async {
  final result = await testBuilder(
    SharedPartBuilder([SupportedPlatformsGenerator()], 'supported_platforms'),
    {
      // Matched by package (`TypeChecker.typeNamedLiterally(..., inPackage: ...)`), so the
      // annotations are supplied under the real package name, in the shapes the generator reads.
      'nosferatu500_inappwebview_internal_annotations|lib/nosferatu500_inappwebview_internal_annotations.dart':
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

/// The doc comment directly above `enum <name> {`.
String _enumDoc(String output, String name) {
  final match = RegExp(r'((?:[ \t]*///.*\n)+)[ \t]*enum ' + name + r' \{')
      .firstMatch(output);
  expect(match, isNotNull, reason: 'no documented enum $name emitted');
  return match!.group(1)!;
}

/// The doc comment above `abstract final class <name>SupportedPlatforms {}`, past any `//` lines.
String _carrierDoc(String output, String name) {
  final match = RegExp(
    r'((?:[ \t]*///.*\n)+)(?:[ \t]*//[^/].*\n)*[ \t]*abstract final class ' +
        name +
        r'SupportedPlatforms \{\}',
  ).firstMatch(output);
  expect(match, isNotNull, reason: 'no documented carrier for $name emitted');
  return match!.group(1)!;
}

void main() {
  test('the extension is emitted only where its library calls it; a class with no enum gets a carrier', () async {
    final output = await _generate('''
import 'package:nosferatu500_inappwebview_internal_annotations/nosferatu500_inappwebview_internal_annotations.dart';

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

    expect(_extension(output, 'Calls'), isNot(contains('{@template')));
    expect(
      output,
      isNot(contains('_DelegatesClassSupported')),
      reason: 'nothing calls it, and it no longer carries the template',
    );
    expect(output, isNot(contains('// ignore: unused_element')));
    for (final name in ['Calls', 'Delegates']) {
      // Public: dartdoc ignores a private element's template in a part file.
      expect(
        _carrierDoc(output, name),
        contains('{@template a.$name.supported_platforms}'),
      );
      expect(
        '{@template a.$name.supported_platforms}'.allMatches(output),
        hasLength(1),
        reason: '$name: one template, defined once',
      );
    }
  });

  test(
    'the class template goes on the public property enum, else the method enum',
    () async {
      final output = await _generate('''
import 'package:nosferatu500_inappwebview_internal_annotations/nosferatu500_inappwebview_internal_annotations.dart';

@SupportedPlatforms(platforms: [AndroidPlatform()])
class Both {
  Both();
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  final int? field = null;
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  void method() {}
  static bool isClassSupported() => _BothClassSupported.isClassSupported();
  bool isPropertySupported(dynamic property) => true;
  bool isMethodSupported(dynamic method) => true;
}

@SupportedPlatforms(platforms: [AndroidPlatform()])
class MethodsOnly {
  MethodsOnly();
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  void method() {}
  static bool isClassSupported() => _MethodsOnlyClassSupported.isClassSupported();
  bool isMethodSupported(dynamic method) => true;
}
''');

      expect(
        _enumDoc(output, 'BothProperty'),
        contains('{@template a.Both.supported_platforms}'),
      );
      expect(
        _enumDoc(output, 'BothMethod'),
        isNot(contains('{@template a.Both.supported_platforms}')),
        reason: 'the property enum already carries it',
      );
      expect(
        _enumDoc(output, 'MethodsOnlyMethod'),
        contains('{@template a.MethodsOnly.supported_platforms}'),
      );
      // Called, so still emitted, but no longer the template's home.
      expect(_extension(output, 'Both'), isNot(contains('{@template')));
      expect(_extension(output, 'MethodsOnly'), isNot(contains('{@template')));
      expect(output, isNot(contains('SupportedPlatforms {}')));
      for (final name in ['Both', 'MethodsOnly']) {
        expect(
          '{@template a.$name.supported_platforms}'.allMatches(output),
          hasLength(1),
          reason: '$name: one template, defined once',
        );
      }
    },
  );

  test('a class with an enum gets no carrier, and no extension unless it calls one', () async {
    final output = await _generate('''
import 'package:nosferatu500_inappwebview_internal_annotations/nosferatu500_inappwebview_internal_annotations.dart';

@SupportedPlatforms(platforms: [AndroidPlatform()])
class DelegatesWithEnum {
  DelegatesWithEnum();
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  void method() {}
  bool isClassSupported() => true;
  bool isMethodSupported(dynamic method) => true;
}
''');

    expect(output, isNot(contains('_DelegatesWithEnumClassSupported')));
    expect(output, isNot(contains('DelegatesWithEnumSupportedPlatforms')));
    expect(
      _enumDoc(output, 'DelegatesWithEnumMethod'),
      contains('{@template a.DelegatesWithEnum.supported_platforms}'),
    );
  });

  test('parameter names in "Parameters" lists are code spans', () async {
    final output = await _generate('''
import 'package:nosferatu500_inappwebview_internal_annotations/nosferatu500_inappwebview_internal_annotations.dart';

@SupportedPlatforms(platforms: [AndroidPlatform()])
class WithParams {
  WithParams();
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  void method(int first, {String? second}) {}
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  final void Function(int callbackArg)? callback = null;
  bool isPropertySupported(dynamic property) => true;
  bool isMethodSupported(dynamic method) => true;
}
''');

    for (final name in ['first', 'second', 'callbackArg']) {
      expect(output, contains('///- `$name`: all platforms'));
      expect(output, isNot(contains('[$name]')));
    }
  });
}
