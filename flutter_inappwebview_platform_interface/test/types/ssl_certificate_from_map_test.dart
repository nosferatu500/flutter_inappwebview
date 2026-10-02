import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins `SslCertificate.fromMap`'s fallback when `x509Certificate` can't be decoded (§223).
///
/// The two `print`s in the generated `fromMap` moved into a helper, `_printDecodeError`, because
/// the generator drops comments, so an `// ignore: avoid_print` could not survive into
/// `ssl_certificate.g.dart`. These tests prove the generated code still reaches it: both lines are
/// printed, the certificate is left null, and the rest of the map is still decoded.
void main() {
  List<String> printsOf(void Function() body) {
    final lines = <String>[];
    runZoned(
      body,
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) => lines.add(line),
      ),
    );
    return lines;
  }

  final issuedBy = {'CName': 'issuer'};

  test('bytes that are not a certificate: logs the error and its stack', () {
    SslCertificate? cert;
    final lines = printsOf(() {
      cert = SslCertificate.fromMap({
        'x509Certificate': Uint8List.fromList([1, 2, 3]),
        'issuedBy': issuedBy,
      });
    });

    expect(cert, isNotNull);
    expect(cert!.x509Certificate, isNull);
    expect(cert!.issuedBy?.CName, 'issuer');
    expect(lines, hasLength(2));
    expect(lines[1], contains('#0'), reason: 'the second line is the stack');
  });

  test('no x509Certificate key at all: the same fallback, and it logs too', () {
    SslCertificate? cert;
    final lines = printsOf(() {
      cert = SslCertificate.fromMap({'issuedBy': issuedBy});
    });

    expect(cert!.x509Certificate, isNull);
    expect(cert!.issuedBy?.CName, 'issuer');
    expect(lines, hasLength(2));
    expect(
      lines[0],
      contains("type 'Null' is not a subtype of type 'Uint8List'"),
    );
  });
}
