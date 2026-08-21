import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'enum_method.dart';

part 'user_agent_brand_version.g.dart';

///Class that represents one entry of the
///[User-Agent Client Hints](https://developer.mozilla.org/en-US/docs/Web/HTTP/Client_hints#user-agent_client_hints)
///brand list, i.e. one `brand`/`version` pair in `Sec-CH-UA`.
///
///Used by [UserAgentMetadata.brandVersionList].
@ExchangeableObject()
class UserAgentBrandVersion_ {
  ///The brand name, e.g. `My WebView App`.
  String brand;

  ///The major version, sent in the low-entropy `Sec-CH-UA` hint, e.g. `120`.
  String majorVersion;

  ///The full version, sent in the high-entropy `Sec-CH-UA-Full-Version-List` hint,
  ///e.g. `120.0.6099.43`.
  String fullVersion;

  UserAgentBrandVersion_({
    required this.brand,
    required this.majorVersion,
    required this.fullVersion,
  });
}
