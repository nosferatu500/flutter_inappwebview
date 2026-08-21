import 'package:build_test/build_test.dart';
import 'package:generators/src/exchangeable_object_generator.dart';
import 'package:logging/logging.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

/// Regression test for the `Map<String, T>` emitters in [ExchangeableObjectGenerator].
///
/// A field typed `Map<String, SomeEnum_>` used to generate a bare
/// `.cast<String, SomeEnum_>()` in `fromMap` — a raw cast of the native value straight to the enum
/// type, which throws — and *nothing at all* in `toMap`, so enum instances were handed to
/// `StandardMessageCodec`, which cannot encode them. Both directions were broken, and neither the
/// compiler nor `flutter analyze` could see it; only reading the generated file did.
///
/// No production type currently uses an enum-valued map — the one that would have,
/// `WebViewMediaIntegrityApiStatusConfig.overrideRules`, was modelled as a list to dodge the bug —
/// so without this test the fix has nothing exercising it and could regress unnoticed.
Future<String> _generate(String model) async {
  final result = await testBuilder(
    SharedPartBuilder([ExchangeableObjectGenerator()], 'exchangeable_object'),
    {
      // The generator matches its annotation by package
      // (`TypeChecker.typeNamedLiterally(..., inPackage: ...)`), so a same-named local class does
      // not satisfy it. Supplying the annotation library as a test asset under the real package
      // name is enough, and keeps the test independent of the annotations package's own contents.
      'flutter_inappwebview_internal_annotations|lib/flutter_inappwebview_internal_annotations.dart':
          '''
class ExchangeableObject {
  final bool toMapMethod;
  final bool toJsonMethod;
  final bool fromMapFactory;
  final bool fromMapForceAllInline;
  final bool nullableFromMapFactory;
  final bool toStringMethod;
  final bool copyMethod;
  const ExchangeableObject({
    this.toMapMethod = true,
    this.toJsonMethod = true,
    this.fromMapFactory = true,
    this.fromMapForceAllInline = false,
    this.nullableFromMapFactory = true,
    this.toStringMethod = true,
    this.copyMethod = false,
  });
}
''',
      'a|lib/status.dart': '''
class Status_ {
  final int _value;
  const Status_._internal(this._value);
  static const OFF = Status_._internal(0);
  int toNativeValue() => _value;
  static Status_? fromNativeValue(int? value) => OFF;
}
''',
      'a|lib/input.dart': model,
    },
    generateFor: {'a|lib/input.dart'},
    // Swallow the builder's INFO chatter, but surface anything that would mean the build failed —
    // otherwise a broken test asset shows up only as "no output generated", which is a slow thing
    // to debug.
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

void main() {
  group('Map field emitters', () {
    test('an enum-valued map converts every value, both directions', () async {
      final output = await _generate('''
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'status.dart';

@ExchangeableObject()
class Model_ {
  Map<String, Status_>? byOrigin;
  Model_({this.byOrigin});
}
''');

      // fromMap: per-entry conversion, with the trailing underscore stripped from the type name.
      expect(output, contains('Map<String, Status>.fromEntries('));
      expect(output, contains('Status.fromNativeValue('));
      expect(
        output,
        isNot(contains('cast<String, Status_>')),
        reason: 'the raw cast to the source type was the original bug',
      );

      // toMap: per-entry conversion instead of handing enum instances to the codec.
      expect(output, contains('MapEntry(k,'));
      expect(output, contains('toNativeValue()'));
    });

    test('a core-valued map still uses the plain cast', () async {
      final output = await _generate('''
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

@ExchangeableObject()
class Model_ {
  Map<String, String>? headers;
  Model_({this.headers});
}
''');

      expect(output, contains('cast<String, String>()'));
      expect(
        output,
        isNot(contains('fromEntries')),
        reason: 'core-typed values need no per-entry conversion',
      );
    });
  });
}
