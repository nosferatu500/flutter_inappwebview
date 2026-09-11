// Gates the `signature:` strings in `support_checker.dart` against the real
// declarations in the `flutter_inappwebview` facade.
//
// WHY ONLY THE RETURN TYPE. The strings are hand-written *summaries*, not exact
// signatures — 30 of them abbreviate their parameter list with a literal `...`
// (`'Future<void> loadData({required String data, ...})'`). Dart has no runtime
// reflection, so nothing can check them as a whole without either generating
// them or rewriting all 252. But every defect ever found in this field was a
// **return type** that lied: §137 (`flush`), §139 (`deleteCookie`,
// `deleteCookies`, `deleteAllCookies`) and nine more found by this test when it
// was first written. The return type is the part that is both checkable and
// the part that has actually gone wrong, so that is what is pinned here.
//
// The parameter lists remain unchecked free text. That is a known, deliberate
// gap — see the P6 row.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_example/utils/support_checker.dart';

/// A method declaration recovered from the facade source.
class _Declaration {
  final String returnType;
  final bool isStatic;

  const _Declaration(this.returnType, this.isStatic);
}

String _normalize(String s) => s.trim().replaceAll(RegExp(r'\s+'), '');

/// Maps every top-level class in the facade package to its own source region.
///
/// Scoped class-by-class rather than file-by-file: several files declare more
/// than one class, and `WebAuthenticationSession.start` / `HeadlessInAppWebView.isRunning`
/// both have same-named neighbours elsewhere in the package that a whole-file
/// search can pick up instead.
Map<String, String> _classBodies() {
  final facadeLib = Directory('../lib');
  expect(
    facadeLib.existsSync(),
    isTrue,
    reason:
        'Expected the flutter_inappwebview facade sources at ${facadeLib.absolute.path}. '
        'If the layout moved, this gate silently stops checking anything.',
  );

  final bodies = <String, String>{};
  final classStart = RegExp(r'^(?:abstract\s+)?class\s+(\w+)', multiLine: true);

  for (final file
      in facadeLib
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
    final text = file.readAsStringSync();
    final starts = classStart.allMatches(text).toList();
    for (var i = 0; i < starts.length; i++) {
      final name = starts[i].group(1)!;
      // Up to the next top-level class, so one class cannot answer for another.
      final end = i + 1 < starts.length ? starts[i + 1].start : text.length;
      bodies.putIfAbsent(name, () => text.substring(starts[i].start, end));
    }
  }
  return bodies;
}

/// Finds `<returnType> <name>(` inside a class body.
_Declaration? _findDeclaration(String classBody, String methodName) {
  final pattern = RegExp(
    r'(?:^|\n)[ \t]*(static[ \t]+)?([\w<>,\s?.]+?)[ \t]+' +
        RegExp.escape(methodName) +
        r'[ \t]*\(',
  );
  for (final m in pattern.allMatches(classBody)) {
    final type = _normalize(m.group(2)!);
    // A continuation line such as `=> platform.isRunning(` starts with
    // `platform.` and would otherwise be read as a return type.
    if (type.contains('.') && !type.startsWith('Future<')) continue;
    if (type == 'return' || type == 'await') continue;
    return _Declaration(type, m.group(1) != null);
  }
  return null;
}

/// Display class name -> the class that actually declares the methods.
///
/// The support screen groups these methods under `WebStorage`, but `WebStorage`
/// only *holds* a `localStorage` and a `sessionStorage`; the methods themselves
/// are declared on the abstract `Storage` that both extend. The example's own
/// resolver already makes the same hop (it answers `WebStorage`'s methods with
/// `LocalStorage.isMethodSupported`), so this mirrors existing behaviour rather
/// than inventing a mapping.
const _declaringClass = <String, String>{'WebStorage': 'Storage'};

void main() {
  group('ApiMethodDefinition.signature', () {
    late Map<String, String> classBodies;

    setUpAll(() {
      classBodies = _classBodies();
    });

    test('every stated return type matches the declared one', () {
      final lies = <String>[];
      final unresolved = <String>[];
      var checked = 0;

      for (final classDef in SupportChecker.getAllApiDefinitions()) {
        final sourceClass =
            _declaringClass[classDef.className] ?? classDef.className;
        final body = classBodies[sourceClass];
        for (final method in classDef.methods) {
          if (method.signature.isEmpty) continue;

          if (body == null) {
            unresolved.add(
              '${classDef.className} -> $sourceClass (class not found)',
            );
            continue;
          }
          final marker = ' ${method.name}(';
          final idx = method.signature.indexOf(marker);
          if (idx < 0) {
            unresolved.add(
              '${classDef.className}.${method.name} '
              '(signature does not contain "${method.name}("): '
              '${method.signature}',
            );
            continue;
          }
          final decl = _findDeclaration(body, method.name);
          if (decl == null) {
            unresolved.add(
              '${classDef.className}.${method.name} (no declaration found)',
            );
            continue;
          }

          var stated = _normalize(method.signature.substring(0, idx));
          final statedStatic = stated.startsWith('static');
          if (statedStatic) {
            stated = stated.replaceFirst('static', '');
          }

          checked++;
          if (stated != decl.returnType) {
            lies.add(
              '${classDef.className}.${method.name}: '
              'signature says "$stated", source declares "${decl.returnType}"',
            );
          } else if (statedStatic != decl.isStatic) {
            lies.add(
              '${classDef.className}.${method.name}: '
              'signature says static=$statedStatic, source declares '
              'static=${decl.isStatic}',
            );
          }
        }
      }

      expect(
        unresolved,
        isEmpty,
        reason:
            'Every signature must resolve to a declaration. An unresolved entry is not '
            'harmless — it is a signature this gate silently stops checking:\n'
            '${unresolved.join('\n')}',
      );
      expect(
        lies,
        isEmpty,
        reason:
            'A displayed signature that lies is worse than none:\n${lies.join('\n')}',
      );

      // Coverage floor. Without this the test passes just as happily when the
      // facade moves and nothing is checked at all.
      expect(
        checked,
        greaterThanOrEqualTo(250),
        reason:
            'Only $checked signatures were checked; the gate has stopped covering the list.',
      );
    });

    test('the corpus is the size we think it is', () {
      // Guards the numbers the P6 row and the file header quote, so a future
      // reader can tell drift from a miscount.
      final definitions = SupportChecker.getAllApiDefinitions();
      final methods = definitions.expand((d) => d.methods).toList();
      final events = definitions.expand((d) => d.events).toList();
      final withSignature = methods.where((m) => m.signature.isNotEmpty).length;

      expect(withSignature, 252);
      // Events carry no signature at all; only methods do. (91 events.)
      expect(events.where((e) => e.signature.isNotEmpty), isEmpty);
      expect(events, isNotEmpty);
      // And every method carries one — so there is no "some are exempt" case
      // for a new entry to hide in.
      expect(methods.length, withSignature);
    });
  });
}
