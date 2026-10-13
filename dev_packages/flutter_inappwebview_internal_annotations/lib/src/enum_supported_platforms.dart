import 'constants.dart';
import 'supported_platforms.dart';

abstract class EnumPlatform implements Platform {
  final String? available;
  final String? apiName;
  final String? apiUrl;
  final String? note;
  final String name;
  final String targetPlatformName;
  final dynamic value;

  const EnumPlatform({
    this.available,
    this.apiName,
    this.apiUrl,
    this.note,
    this.name = '',
    this.targetPlatformName = '',
    this.value,
  });
}

class EnumAndroidPlatform implements EnumPlatform, AndroidPlatform {
  final String? available;
  final String? apiName;
  final String? apiUrl;
  final String? note;
  final String name;
  final String targetPlatformName;
  final dynamic value;

  const EnumAndroidPlatform({
    this.available,
    this.apiName,
    this.apiUrl,
    this.note,
    this.name = kPlatformNameAndroid,
    this.targetPlatformName = kTargetPlatformNameAndroid,
    this.value,
  });
}

class EnumIOSPlatform implements EnumPlatform, IOSPlatform {
  final String? available;
  final String? apiName;
  final String? apiUrl;
  final String? note;
  final String name;
  final String targetPlatformName;
  final dynamic value;

  const EnumIOSPlatform({
    this.available,
    this.apiName,
    this.apiUrl,
    this.note,
    this.name = kPlatformNameIOS,
    this.targetPlatformName = kTargetPlatformNameIOS,
    this.value,
  });
}

class EnumSupportedPlatforms {
  final List<EnumPlatform> platforms;
  final dynamic defaultValue;

  const EnumSupportedPlatforms({required this.platforms, this.defaultValue});
}
