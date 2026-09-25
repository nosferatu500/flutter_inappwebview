import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/chrome_custom_tabs.g.dart';
import 'package:flutter_test/flutter_test.dart';

/// Boundary coverage for the chrome-custom-tabs channel's **event unregistration** (§184), which
/// had no test at any level. §179 migrated thirteen events onto one `ChromeCustomTabsFlutterApi`,
/// registered by a single `setUp` in `open()` and removed by a single `setUp(null)` in `dispose`.
///
/// Because one call registers and removes all thirteen together, one event is enough to observe
/// whether the handler set is registered. `onServiceConnected` is used because it takes no
/// arguments and has no side effect; **`onClosed` is not a usable probe**, because its handler calls
/// `dispose()` itself — which is also the production path by which a closed tab unregisters, so it
/// gets its own test.
///
/// "Unregistered" is observed through the **platform reply** — an encoded envelope from a registered
/// Pigeon handler, null from none. §183 measured two other assertions blind against a
/// delete-the-unregister mutant (an outbound-mock check, and "the callback stayed silent").
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = ChromeCustomTabsHostApi.pigeonChannelCodec;
  const staticChannel = MethodChannel(
    'dev.nosferatu500.inappwebview/chromesafaribrowser',
  );
  const eventBase =
      'dev.flutter.pigeon.flutter_inappwebview_android.ChromeCustomTabsFlutterApi';

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late AndroidChromeSafariBrowser browser;

  /// Delivers one argument-less event and returns the raw platform reply.
  Future<ByteData?> deliver(String event) {
    final reply = Completer<ByteData?>();
    messenger.handlePlatformMessage(
      '$eventBase.$event.${browser.id}',
      codec.encodeMessage(<Object?>[]),
      reply.complete,
    );
    return reply.future;
  }

  setUp(() async {
    // `open` registers the per-instance handlers and then calls the static manager channel, which
    // is still hand-written; answering it is what lets `open` complete.
    messenger.setMockMethodCallHandler(staticChannel, (call) async => null);
    browser = AndroidChromeSafariBrowser(
      AndroidChromeSafariBrowserCreationParams(),
    );
    await browser.open();
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(staticChannel, null);
  });

  test('dispose unregisters the event handlers for this id', () async {
    // Positive control first, so a null below cannot just mean a misspelt channel.
    expect(await deliver('onServiceConnected'), isNotNull);
    browser.dispose();
    expect(await deliver('onServiceConnected'), isNull);
  });

  test('onClosed from the platform unregisters them too', () async {
    // The production path: the tab closes, the platform reports it, and `_handleClosed` disposes.
    expect(await deliver('onServiceConnected'), isNotNull);
    await deliver('onClosed');
    expect(browser.isOpened(), isFalse);
    expect(await deliver('onServiceConnected'), isNull);
  });
}
