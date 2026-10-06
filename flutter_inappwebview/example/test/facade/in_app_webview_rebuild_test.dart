import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins what the facade `InAppWebView` tells its platform widget across a rebuild (§269).
///
/// A rebuild constructs a new `InAppWebView`, and with it a new platform widget object, but keeps
/// the `State`. The platform implementations keep their controller on the platform widget, so the
/// new one has to be handed the old one before `dispose` runs on it. The device tests
/// (`widget_rebuild.dart`) check the iOS and Android implementations; this checks the call itself.
class _RecordingWidget extends PlatformInAppWebViewWidget {
  _RecordingWidget(this.name, this.log)
    : super.implementation(PlatformInAppWebViewWidgetCreationParams());

  final String name;
  final List<String> log;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();

  @override
  T controllerFromPlatform<T>(PlatformInAppWebViewController controller) =>
      throw UnimplementedError();

  @override
  void didUpdateWidget(covariant _RecordingWidget oldWidget) =>
      log.add('$name.didUpdateWidget(${oldWidget.name})');

  @override
  void dispose() => log.add('$name.dispose');
}

/// Overrides nothing but what it must, so it runs the interface's own `didUpdateWidget`.
class _PlainWidget extends PlatformInAppWebViewWidget {
  _PlainWidget()
    : super.implementation(PlatformInAppWebViewWidgetCreationParams());

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();

  @override
  T controllerFromPlatform<T>(PlatformInAppWebViewController controller) =>
      throw UnimplementedError();

  @override
  void dispose() {}
}

void main() {
  const key = ValueKey('webview');

  testWidgets(
    'a rebuild hands the old platform widget to the new one, then dispose',
    (tester) async {
      final log = <String>[];
      final a = _RecordingWidget('a', log);
      final b = _RecordingWidget('b', log);
      await tester.pumpWidget(InAppWebView.fromPlatform(key: key, platform: a));
      expect(log, isEmpty);
      await tester.pumpWidget(InAppWebView.fromPlatform(key: key, platform: b));
      expect(log, ['b.didUpdateWidget(a)']);
      await tester.pumpWidget(const SizedBox());
      expect(log, ['b.didUpdateWidget(a)', 'b.dispose']);
    },
  );

  testWidgets(
    'a rebuild around the same platform widget passes it as its own old widget',
    (tester) async {
      final log = <String>[];
      final a = _RecordingWidget('a', log);
      await tester.pumpWidget(InAppWebView.fromPlatform(key: key, platform: a));
      // A new InAppWebView instance, so the framework calls didUpdateWidget.
      await tester.pumpWidget(InAppWebView.fromPlatform(key: key, platform: a));
      expect(log, ['a.didUpdateWidget(a)']);
    },
  );

  testWidgets('the interface default does nothing', (tester) async {
    await tester.pumpWidget(
      InAppWebView.fromPlatform(key: key, platform: _PlainWidget()),
    );
    await tester.pumpWidget(
      InAppWebView.fromPlatform(key: key, platform: _PlainWidget()),
    );
    expect(tester.takeException(), isNull);
  });
}
