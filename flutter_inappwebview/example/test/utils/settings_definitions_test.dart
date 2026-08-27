import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/models/setting_definition.dart';
import 'package:flutter_inappwebview_example/utils/settings_definitions.dart';

void main() {
  test('getSettingDefinitions returns expected categories', () {
    final definitions = getSettingDefinitions();

    expect(definitions, isNotEmpty);
    expect(definitions.keys, containsAll(['General', 'Security', 'Cache']));
  });

  test('definitions contain expected types', () {
    final definitions = getSettingDefinitions();
    final general = definitions['General'];

    expect(general, isNotNull);
    expect(general!.first.type, SettingType.boolean);
  });

  test('enum-like setting definitions use enum values lists', () {
    final definitions = getSettingDefinitions();
    final security = definitions['Security'];
    final cache = definitions['Cache'];

    expect(security, isNotNull);
    expect(cache, isNotNull);

    final mixedContent = security!.firstWhere(
      (definition) =>
          definition.property == InAppWebViewSettingsProperty.mixedContentMode,
    );
    final cacheMode = cache!.firstWhere(
      (definition) =>
          definition.property == InAppWebViewSettingsProperty.cacheMode,
    );

    expect(mixedContent.enumValues, unorderedEquals(MixedContentMode.values));
    expect(cacheMode.enumValues, unorderedEquals(CacheMode.values));
  });
}
