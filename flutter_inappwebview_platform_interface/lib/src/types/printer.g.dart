// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'printer.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class representing the printer used by a [PlatformPrintJobController].
class Printer {
  ///The unique id of the printer.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  String? id;
  Printer({this.id});

  ///Gets a possible [Printer] instance from a [Map] value.
  static Printer? fromMap(Map<String, dynamic>? map, {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = Printer(id: map['id']);
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {"id": id};
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'Printer{id: $id}';
  }
}
