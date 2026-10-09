import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../web_storage/platform_web_storage_manager.dart';
import 'enum_method.dart';

part 'web_storage_origin.g.dart';

///Class that encapsulates information about the amount of quota-managed storage an origin uses.
///An origin comprises the host, scheme and port of a URI. See
///[PlatformWebStorageManager.getOrigins] for which storage counts.
@ExchangeableObject()
class WebStorageOrigin_ {
  ///The string representation of this origin.
  String? origin;

  ///The storage quota, in bytes. On Android one global figure, the same for every origin (see
  ///[PlatformWebStorageManager.getQuotaForOrigin]).
  int? quota;

  ///The amount of storage this origin uses, in bytes: IndexedDB, Cache Storage, the origin-private
  ///file system and service worker registrations, not cookies, `localStorage` or `sessionStorage`
  ///(see [PlatformWebStorageManager.getUsageForOrigin]).
  int? usage;

  WebStorageOrigin_({this.origin, this.quota, this.usage});
}
