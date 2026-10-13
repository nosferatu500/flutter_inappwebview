import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview_example/models/test_configuration.dart';
import 'package:flutter_inappwebview_example/screens/test_automation/test_configuration_screen.dart';
import 'package:flutter_inappwebview_example/utils/constants.dart';

void main() {
  group('TestConfigurationScreen', () {
    Widget createWidget() {
      return ChangeNotifierProvider(
        create: (_) => TestConfigurationManager(),
        child: const MaterialApp(home: TestConfigurationScreen()),
      );
    }

    testWidgets('renders app bar and tabs', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Test Configuration'), findsOneWidget);
      expect(find.text('Custom Steps'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Import/Export'), findsOneWidget);
    });

    // §242 moved the WebView-type radios under a RadioGroup and the steps list from the
    // deprecated onReorder to onReorderItem. These pin both paths.
    Widget createWidgetWith(TestConfigurationManager manager) {
      return ChangeNotifierProvider.value(
        value: manager,
        child: const MaterialApp(home: TestConfigurationScreen()),
      );
    }

    testWidgets('WebView type radios select through their RadioGroup', (
      tester,
    ) async {
      final manager = TestConfigurationManager();
      await tester.pumpWidget(createWidgetWith(manager));
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      RadioGroup<TestWebViewType> group() =>
          tester.widget(find.byType(RadioGroup<TestWebViewType>));
      expect(group().groupValue, manager.currentConfig.webViewType);
      expect(
        manager.currentConfig.webViewType,
        isNot(TestWebViewType.headless),
      );

      await tester.tap(find.text('Headless WebView'));
      await tester.pumpAndSettle();

      expect(manager.currentConfig.webViewType, TestWebViewType.headless);
      expect(group().groupValue, TestWebViewType.headless);
    });

    testWidgets(
      'reordering hands the after-move index straight to the manager',
      (tester) async {
        final manager = TestConfigurationManager();
        for (final name in ['a', 'b', 'c']) {
          manager.addCustomStep(
            CustomTestStep(
              id: name,
              name: name,
              description: '',
              category: TestCategory.navigation,
              action: CustomTestAction.loadUrl('https://example.com'),
            ),
          );
        }
        await tester.pumpWidget(createWidgetWith(manager));
        await tester.pumpAndSettle();

        List<String> names() =>
            manager.currentConfig.customSteps.map((s) => s.name).toList();
        final list = tester.widget<ReorderableListView>(
          find.byType(ReorderableListView),
        );

        // onReorderItem reports the index after the move: 'a' to the end.
        list.onReorderItem!(0, 2);
        expect(names(), ['b', 'c', 'a']);
        expect(manager.currentConfig.customSteps.map((s) => s.order), [
          0,
          1,
          2,
        ]);

        list.onReorderItem!(2, 0);
        expect(names(), ['a', 'b', 'c']);
      },
    );
  });
}
