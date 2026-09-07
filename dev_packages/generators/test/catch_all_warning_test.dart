import 'package:build_test/build_test.dart';
import 'package:generators/src/exchangeable_object_generator.dart';
import 'package:logging/logging.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

/// Guards the bare-`!` warning on non-nullable enum fields (§136).
///
/// A non-nullable enum field decodes to `Enum.fromNativeValue(v)`, which is nullable, so the
/// generator must close it. Where the enum has a catch-all constant it emits `?? Enum.UNKNOWN`;
/// where it has none it emits `!`, and an unmapped native value then throws **inside the channel
/// handler**, so the callback never reaches app code at all (§72's bug class).
///
/// The `!` emission is legitimate — all 16 production sites were audited and found unreachable
/// (§86) — but it used to be *silent*, which is how §73 deleted a catch-all and re-armed the bug
/// with nothing noticing. The generator now logs each one.
///
/// **The catch-all is matched by name and cannot be matched by annotation**:
/// `flutter_inappwebview_internal_annotations` is published, 238 shipped sources import it, and a
/// consuming app resolves it from pub.dev — so new annotation surface breaks every consumer build
/// until that package is republished (trap 14). Name matching therefore has two failure modes, and
/// both are covered below: a missing constant, and a **near miss** like `UNKNOWN_TYPE`, which reads
/// like a catch-all but is not one of the accepted spellings.
Future<({String output, List<String> warnings})> _generate(String model) async {
  final warnings = <String>[];
  final result = await testBuilder(
    SharedPartBuilder([ExchangeableObjectGenerator()], 'exchangeable_object'),
    {
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
      // No catch-all constant at all.
      'a|lib/bare.dart': '''
class Bare_ {
  final int _value;
  const Bare_._internal(this._value);
  static const OFF = Bare_._internal(0);
  int toNativeValue() => _value;
  static Bare_? fromNativeValue(int? value) => OFF;
}
''',
      // An accepted catch-all spelling.
      'a|lib/known.dart': '''
class Known_ {
  final int _value;
  const Known_._internal(this._value);
  static const OFF = Known_._internal(0);
  static const UNKNOWN = Known_._internal(-1);
  int toNativeValue() => _value;
  static Known_? fromNativeValue(int? value) => OFF;
}
''',
      // A near miss: reads like a catch-all, is not one of the accepted names.
      'a|lib/nearmiss.dart': '''
class NearMiss_ {
  final int _value;
  const NearMiss_._internal(this._value);
  static const OFF = NearMiss_._internal(0);
  static const UNKNOWN_TYPE = NearMiss_._internal(-1);
  int toNativeValue() => _value;
  static NearMiss_? fromNativeValue(int? value) => OFF;
}
''',
      'a|lib/input.dart': model,
    },
    generateFor: {'a|lib/input.dart'},
    onLog: (l) {
      if (l.level == Level.WARNING) {
        warnings.add(l.message);
      }
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
  return (
    output: result.readerWriter.testing.readString(generated.single),
    warnings: warnings,
  );
}

void main() {
  group('bare `!` warning on non-nullable enum fields', () {
    test('an enum with no catch-all emits `!` and warns', () async {
      final r = await _generate('''
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'bare.dart';

@ExchangeableObject()
class Model_ {
  Bare_ status;
  Model_({required this.status});
}
''');

      expect(r.output, contains('Bare.fromNativeValue('));
      expect(
        r.output,
        isNot(contains('?? Bare.')),
        reason: 'there is no catch-all to degrade to',
      );
      expect(
        r.warnings.where((w) => w.contains('has no catch-all constant')),
        hasLength(1),
        reason: 'the `!` must not be emitted silently',
      );
      expect(r.warnings.single, contains('Bare'));
      expect(
        r.warnings.single,
        isNot(contains('reads like a catch-all')),
        reason: 'no near-miss constant exists on this enum',
      );
    });

    test('an enum with UNKNOWN degrades instead, and does not warn', () async {
      // The negative control. Without it a warning that fired unconditionally would pass the
      // test above while telling the reader nothing.
      final r = await _generate('''
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'known.dart';

@ExchangeableObject()
class Model_ {
  Known_ status;
  Model_({required this.status});
}
''');

      expect(r.output, contains('?? Known.UNKNOWN'));
      expect(
        r.warnings.where((w) => w.contains('has no catch-all constant')),
        isEmpty,
      );
    });

    test('a near-miss constant name is called out by name', () async {
      // `UNKNOWN_TYPE` is a catch-all in every sense except the spelling, so the generator
      // cannot see it and silently emits `!`. This is the failure mode that needs no deletion
      // to occur — it is one constant name away at all times.
      final r = await _generate('''
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'nearmiss.dart';

@ExchangeableObject()
class Model_ {
  NearMiss_ status;
  Model_({required this.status});
}
''');

      expect(
        r.output,
        isNot(contains('?? NearMiss.')),
        reason: 'the near-miss constant is NOT matched — that is the point',
      );
      final warning = r.warnings.singleWhere(
        (w) => w.contains('has no catch-all constant'),
      );
      expect(warning, contains('UNKNOWN_TYPE'));
      expect(warning, contains('reads like a catch-all'));
    });
  });
}
