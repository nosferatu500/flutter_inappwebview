import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins `operator ==` on the three x509 types no other test reached, after its parameter was
/// renamed from `value` to `other` (§228, `avoid_renaming_method_parameters`).
///
/// The operator is `other == _value`: it hands the comparison to the other side, so an instance
/// equals another instance with the same raw value **and the raw value itself**. That second half is
/// the existing behaviour, asymmetric as it is (`5 == KeyUsage.keyCertSign` is false), and the
/// rename must not change it.
void main() {
  test('KeyUsage', () {
    expect(KeyUsage.keyCertSign == KeyUsage.keyCertSign, isTrue);
    expect(KeyUsage.keyCertSign == KeyUsage.cRLSign, isFalse);
    // ignore: unrelated_type_equality_checks
    expect(KeyUsage.keyCertSign == 5, isTrue);
    expect(KeyUsage.values.contains(KeyUsage.cRLSign), isTrue);
  });

  test('OID', () {
    expect(OID.codeSigning == OID.codeSigning, isTrue);
    expect(OID.codeSigning == OID.timeStamping, isFalse);
    // ignore: unrelated_type_equality_checks
    expect(OID.codeSigning == '1.3.6.1.5.5.7.3.3', isTrue);
  });

  test('ASN1DistinguishedNames', () {
    expect(
      ASN1DistinguishedNames.COMMON_NAME == ASN1DistinguishedNames.COMMON_NAME,
      isTrue,
    );
    expect(
      ASN1DistinguishedNames.COMMON_NAME == ASN1DistinguishedNames.COUNTRY_NAME,
      isFalse,
    );
    // ignore: unrelated_type_equality_checks
    expect(ASN1DistinguishedNames.COMMON_NAME == '2.5.4.3', isTrue);
    expect(
      ASN1DistinguishedNames.values.contains(ASN1DistinguishedNames.EMAIL),
      isTrue,
    );
  });
}
