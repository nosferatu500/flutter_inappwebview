import 'constants.dart';

abstract class Platform {
  final String? available;
  final String? apiName;
  final String? apiUrl;
  final String? note;
  final String name;
  final String targetPlatformName;

  const Platform({
    this.available,
    this.apiName,
    this.apiUrl,
    this.note,
    this.name = '',
    this.targetPlatformName = '',
  });
}

class AndroidPlatform implements Platform {
  final String? available;
  final String? apiName;
  final String? apiUrl;
  final String? note;
  final String name;
  final String targetPlatformName;

  const AndroidPlatform({
    this.available,
    this.apiName,
    this.apiUrl,
    this.note,
    this.name = kPlatformNameAndroid,
    this.targetPlatformName = kTargetPlatformNameAndroid,
  });
}

class IOSPlatform implements Platform {
  final String? available;
  final String? apiName;
  final String? apiUrl;
  final String? note;
  final String name;
  final String targetPlatformName;

  const IOSPlatform({
    this.available,
    this.apiName,
    this.apiUrl,
    this.note,
    this.name = kPlatformNameIOS,
    this.targetPlatformName = kTargetPlatformNameIOS,
  });
}

class SupportedPlatforms {
  final List<Platform> platforms;
  final bool ignore;
  final List<String> ignorePropertyNames;
  final List<String> ignoreMethodNames;
  final List<String> ignoreParameterNames;

  /// Workaround for @SupportedPlatforms annotation not working
  /// on parameters of a class fields which type is a function.
  /// https://github.com/dart-lang/sdk/issues/59670
  final Map<String, List<Platform>> parameterPlatforms;

  const SupportedPlatforms({
    required this.platforms,
    this.ignore = false,
    this.ignorePropertyNames = const [],
    this.ignoreMethodNames = const [],
    this.ignoreParameterNames = const [],
    this.parameterPlatforms = const {},
  });
}
