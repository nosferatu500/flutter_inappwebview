import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards for `ClientCertResponse`'s constructor assert (§133).
///
/// The assert used to read `action == PROCEED && !Util.isWindows`. §9 dropped Windows, so
/// `Util.isWindows` is unconditionally `false` on every platform this fork supports and the
/// second operand was dead; §133 removed it along with the four unreferenced `Util` getters.
///
/// These pin the behaviour that removal had to preserve. Nothing else covers this constructor —
/// it had no tests at all — so without them the simplification would have rested on reading the
/// expression rather than on running it.
void main() {
  group('ClientCertResponse constructor assert', () {
    test('PROCEED with an empty certificatePath asserts', () {
      // The live half of the old condition. If the simplification had inverted or dropped the
      // guard this is the assertion that would stop firing.
      expect(
        () => ClientCertResponse(
          action: ClientCertResponseAction.PROCEED,
          certificatePath: "",
        ),
        throwsAssertionError,
      );
    });

    test('PROCEED with a non-empty certificatePath is accepted', () {
      expect(
        ClientCertResponse(
          action: ClientCertResponseAction.PROCEED,
          certificatePath: "assets/cert.p12",
        ).certificatePath,
        "assets/cert.p12",
      );
    });

    test('CANCEL with an empty certificatePath is accepted', () {
      // The guard is scoped to PROCEED, and the default action is CANCEL — so the common
      // "refuse the challenge" construction must stay legal with no certificate at all.
      expect(
        ClientCertResponse(
          action: ClientCertResponseAction.CANCEL,
          certificatePath: "",
        ).certificatePath,
        "",
      );
    });

    test('the default construction is CANCEL and needs no certificate', () {
      final response = ClientCertResponse();
      expect(response.action, ClientCertResponseAction.CANCEL);
      expect(response.certificatePath, "");
    });
  });
}
