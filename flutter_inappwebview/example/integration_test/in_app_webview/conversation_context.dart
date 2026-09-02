part of 'main.dart';

void conversationContext() {
  // `isMethodSupported` answers about the *platform*, not the OS version — it is `true` on any iOS,
  // including 17.5 where `WKWebView.conversationContext` does not exist. The first iOS 17.5 baseline
  // failed both round-trip tests for exactly that reason, so the version gate is separate and
  // explicit, as it is in `screen_time.dart` and `obscured_content_insets.dart`.
  final shouldSkip =
      !InAppWebViewController.isMethodSupported(
        PlatformInAppWebViewControllerMethod.setConversationContext,
      ) ||
      defaultTargetPlatform != TargetPlatform.iOS;
  final belowIOS26 = (_iosMajorVersion() ?? 0) < 26;

  final url = TEST_CROSS_PLATFORM_URL_1;

  Future<InAppWebViewController> openWebView(WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: url),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            if (!pageLoaded.isCompleted) {
              pageLoaded.complete();
            }
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    final controller = await controllerCompleter.future;
    await pageLoaded.future;
    return controller;
  }

  final sentDate = DateTime.fromMillisecondsSinceEpoch(1735689600000);

  // The whole type family in one round trip: a nested list of entries, two sets, and a map whose
  // values are themselves exchangeable objects. That last one is the reason this test matters more
  // than its size suggests — `participantNameByIdentifier` is the repo's first
  // `Map<String, ExchangeableObject>` field, and it exposed a generator defect that made `fromMap`
  // throw at runtime while `flutter analyze` stayed clean.
  skippableTestWidgets('conversationContext round-trips', (
    WidgetTester tester,
  ) async {
    final controller = await openWebView(tester);

    await controller.setConversationContext(
      conversationContext: ConversationContext(
        threadIdentifier: 'thread-1',
        selfIdentifiers: {'me'},
        responsePrimaryRecipientIdentifiers: {'them'},
        participantNameByIdentifier: {
          'them': PersonNameComponents(givenName: 'Alex', familyName: 'Kim'),
        },
        entries: [
          ConversationEntry(
            text: 'Are we still on for lunch?',
            senderIdentifier: 'them',
            sentDate: sentDate,
            entryIdentifier: 'e1',
            primaryRecipientIdentifiers: {'me'},
          ),
        ],
      ),
    );

    final back = await controller.getConversationContext();
    expect(back, isNotNull);
    expect(back!.threadIdentifier, 'thread-1');
    expect(back.selfIdentifiers, {'me'});
    expect(back.responsePrimaryRecipientIdentifiers, {'them'});

    expect(back.entries, hasLength(1));
    final entry = back.entries!.first;
    expect(entry.text, 'Are we still on for lunch?');
    expect(entry.senderIdentifier, 'them');
    expect(entry.entryIdentifier, 'e1');
    expect(entry.primaryRecipientIdentifiers, {'me'});
    // Milliseconds out, seconds in, milliseconds back. A missed /1000 or *1000 anywhere on that
    // path lands the message tens of thousands of years away and nothing errors.
    expect(entry.sentDate, sentDate);

    final name = back.participantNameByIdentifier?['them'];
    expect(name, isNotNull, reason: 'the map-of-objects field must survive');
    expect(name!.givenName, 'Alex');
    expect(name.familyName, 'Kim');
  }, skip: shouldSkip || belowIOS26);

  // The native drop rule, which Dart cannot observe any other way: `UIConversationContext.Entry`
  // declares text/senderIdentifier/sentDate/entryIdentifier non-null, so an entry missing any of
  // them is refused by the Swift `guard` rather than sent half-built. Two entries go in, one comes
  // back — and the survivor is the complete one, not merely "a" one.
  skippableTestWidgets(
    'an incomplete conversation entry is dropped natively',
    (WidgetTester tester) async {
      final controller = await openWebView(tester);

      await controller.setConversationContext(
        conversationContext: ConversationContext(
          threadIdentifier: 'thread-2',
          entries: [
            ConversationEntry(
              text: 'complete',
              senderIdentifier: 'them',
              sentDate: sentDate,
              entryIdentifier: 'ok',
            ),
            // No senderIdentifier and no sentDate.
            ConversationEntry(text: 'incomplete', entryIdentifier: 'bad'),
          ],
        ),
      );

      final back = await controller.getConversationContext();
      expect(back, isNotNull);
      expect(
        back!.entries,
        hasLength(1),
        reason: 'the entry missing required fields must not survive',
      );
      expect(back.entries!.first.entryIdentifier, 'ok');
    },
    skip: shouldSkip || belowIOS26,
  );

  // Below iOS 26 the property does not exist, and `null` says so — distinct from an empty context,
  // exactly as `isBlockedByScreenTime` distinguishes "cannot answer" from "no".
  skippableTestWidgets('getConversationContext is null below iOS 26', (
    WidgetTester tester,
  ) async {
    final controller = await openWebView(tester);
    expect(await controller.getConversationContext(), isNull);
  }, skip: shouldSkip || !belowIOS26);
}
