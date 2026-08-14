import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'enum_method.dart';
import 'ssl_error_type.dart';

part 'ssl_error.g.dart';

///Class that represents an SSL Error.
@ExchangeableObject()
class SslError_ {
  ///Primary code error associated to the server SSL certificate.
  ///It represents the most severe SSL error.
  SslErrorType_? code;

  ///The message associated to the [code].
  String? message;

  SslError_({this.code, this.message}) {}
}
