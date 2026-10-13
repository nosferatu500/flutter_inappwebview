// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_storage_origin.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that encapsulates information about the amount of quota-managed storage an origin uses.
///An origin comprises the host, scheme and port of a URI. See
///[PlatformWebStorageManager.getOrigins] for which storage counts.
class WebStorageOrigin {
  ///The string representation of this origin.
  String? origin;

  ///The storage quota, in bytes. On Android one global figure, the same for every origin (see
  ///[PlatformWebStorageManager.getQuotaForOrigin]).
  int? quota;

  ///The amount of storage this origin uses, in bytes: IndexedDB, Cache Storage, the origin-private
  ///file system and service worker registrations, not cookies, `localStorage` or `sessionStorage`
  ///(see [PlatformWebStorageManager.getUsageForOrigin]).
  int? usage;
  WebStorageOrigin({this.origin, this.quota, this.usage});

  ///Gets a possible [WebStorageOrigin] instance from a [Map] value.
  static WebStorageOrigin? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = WebStorageOrigin(
      origin: map['origin'],
      quota: map['quota'],
      usage: map['usage'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {"origin": origin, "quota": quota, "usage": usage};
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'WebStorageOrigin{origin: $origin, quota: $quota, usage: $usage}';
  }
}
