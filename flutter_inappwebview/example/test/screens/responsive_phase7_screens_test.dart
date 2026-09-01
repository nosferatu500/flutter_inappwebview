import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_example/providers/event_log_provider.dart';
import 'package:flutter_inappwebview_example/screens/advanced/service_controllers_screen.dart';
import 'package:flutter_inappwebview_example/screens/storage/cookie_manager_screen.dart';
import 'package:flutter_inappwebview_example/screens/support_matrix/platform_comparison_screen.dart';
import 'package:flutter_inappwebview_example/screens/support_matrix/support_matrix_screen.dart';

import '../test_helpers/mock_inappwebview_platform.dart';
import '../test_helpers/test_provider_wrapper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    MockInAppWebViewPlatform.initialize();
  });

  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    MockInAppWebViewPlatform.initialize();
    await tester.pumpWidget(screen);
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> clearScreen(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('test_all_screens_mobile_no_overflow', (tester) async {
    final previousOnError = FlutterError.onError;
    // Ignore the two known-spurious semantics errors, and **forward everything else to the
    // binding** rather than collecting it. Collecting was the bug: the binding decides a test
    // failed by looking at its own `_pendingExceptionDetails`, so a handler that swallows errors
    // leaves that null, and the next async error to reach the zone trips
    // `'_pendingExceptionDetails != null'` inside `_runTest` -- which does not fail the test, it
    // stops the run making progress. Forwarding keeps the binding's bookkeeping intact.
    FlutterError.onError = (details) {
      final message = details.exceptionAsString();
      final stack = details.stack?.toString() ?? '';
      if (stack.contains('RenderViewportBase.visitChildrenForSemantics') ||
          message.contains('semantics.parentDataDirty')) {
        return;
      }
      previousOnError?.call(details);
    };

    // `takeException()` is how a test consumes what the binding recorded. Restoring the handler
    // *before* failing matters: `fail()` throws, and unwinding with the override still installed
    // is the other half of the original hang.
    void assertNoErrors(String label) {
      final error = tester.takeException();
      if (error == null) {
        return;
      }
      FlutterError.onError = previousOnError;
      fail('Unexpected Flutter error detected in $label:\n$error');
    }

    addTearDown(() async {
      FlutterError.onError = previousOnError;
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    const size = Size(360, 700);
    tester.binding.window.physicalSizeTestValue = size;
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await pumpScreen(tester, const MaterialApp(home: SupportMatrixScreen()));
    assertNoErrors('SupportMatrixScreen');
    await clearScreen(tester);

    await pumpScreen(
      tester,
      const MaterialApp(home: PlatformComparisonScreen()),
    );
    assertNoErrors('PlatformComparisonScreen');
    await clearScreen(tester);

    await pumpScreen(tester, const MaterialApp(home: CookieManagerScreen()));
    assertNoErrors('CookieManagerScreen');
    await clearScreen(tester);

    await pumpScreen(
      tester,
      MaterialApp(
        home: TestProviderWrapper(
          eventLogProvider: EventLogProvider(),
          child: const ServiceControllersScreen(),
        ),
      ),
    );
    assertNoErrors('ServiceControllersScreen');
    await clearScreen(tester);

    FlutterError.onError = previousOnError;
    expect(tester.takeException(), isNull, reason: 'mobile layout');
  });

  testWidgets('test_all_screens_tablet_layout', (tester) async {
    final previousOnError = FlutterError.onError;
    // Same forwarding handler as the test above -- see the note there for why collecting hangs.
    FlutterError.onError = (details) {
      final message = details.exceptionAsString();
      final stack = details.stack?.toString() ?? '';
      if (stack.contains('RenderViewportBase.visitChildrenForSemantics') ||
          message.contains('semantics.parentDataDirty')) {
        return;
      }
      previousOnError?.call(details);
    };

    addTearDown(() async {
      FlutterError.onError = previousOnError;
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    const size = Size(800, 900);
    tester.binding.window.physicalSizeTestValue = size;
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await pumpScreen(tester, const MaterialApp(home: SupportMatrixScreen()));
    expect(find.byKey(const Key('support_matrix_summary_row')), findsOneWidget);
    await clearScreen(tester);

    await pumpScreen(
      tester,
      const MaterialApp(home: PlatformComparisonScreen()),
    );
    expect(
      find.byKey(const Key('platform_comparison_selectors_row')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('platform_comparison_stats_row')),
      findsOneWidget,
    );
    await clearScreen(tester);

    await pumpScreen(tester, const MaterialApp(home: CookieManagerScreen()));
    expect(find.byKey(const Key('cookie_manager_url_row')), findsOneWidget);
    await clearScreen(tester);

    await pumpScreen(
      tester,
      MaterialApp(
        home: TestProviderWrapper(
          eventLogProvider: EventLogProvider(),
          child: const ServiceControllersScreen(),
        ),
      ),
    );
    await tester.ensureVisible(
      find.widgetWithText(ExpansionTile, 'ProxyController'),
    );
    await tester.tap(find.widgetWithText(ExpansionTile, 'ProxyController'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      find.byKey(const Key('service_controllers_proxy_row')),
      findsOneWidget,
    );
    await clearScreen(tester);

    FlutterError.onError = previousOnError;
    expect(tester.takeException(), isNull, reason: 'tablet layout');
  });
}
