import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_inappwebview_example/models/settings_profile.dart';
import 'package:flutter_inappwebview_example/models/setting_definition.dart';
import 'package:flutter_inappwebview_example/utils/settings_defaults.dart'
    as settings_defaults;
import 'package:flutter_inappwebview_example/utils/settings_definitions.dart'
    as settings_definitions;

/// Settings manager for the testing interface
/// Manages InAppWebViewSettings profiles with save/load functionality
class SettingsManager extends ChangeNotifier {
  static const String _profilesKey = 'settings_profiles';
  static const String _currentProfileKey = 'current_profile_id';
  static const String _modifiedSettingsKey = 'modified_settings';
  SettingsManager();
  SharedPreferences? _prefs;
  List<SettingsProfile> _profiles = [];
  String? _currentProfileId;
  Map<String, dynamic> _currentSettings = {};
  Set<String> _modifiedSettings = {};
  int _settingsRevision = 0;
  bool _isLoading = true;

  /// Get all saved profiles
  List<SettingsProfile> get profiles => List.unmodifiable(_profiles);

  /// Get the current profile ID
  String? get currentProfileId => _currentProfileId;

  /// Get the current settings revision
  int get settingsRevision => _settingsRevision;

  /// Get the current profile
  SettingsProfile? get currentProfile {
    if (_currentProfileId == null) return null;
    try {
      return _profiles.firstWhere((p) => p.id == _currentProfileId);
    } catch (e) {
      return null;
    }
  }

  /// Get the current settings state
  Map<String, dynamic> get currentSettings =>
      Map.unmodifiable(_currentSettings);

  /// Get the set of modified setting keys
  Set<String> get modifiedSettings => Set.unmodifiable(_modifiedSettings);

  /// Check if loading is in progress
  bool get isLoading => _isLoading;

  /// Initialize the settings manager
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadProfiles();
    await _loadModifiedSettings();
    _isLoading = false;
    notifyListeners();
  }

  /// Load profiles from shared preferences
  Future<void> _loadProfiles() async {
    final profilesJson = _prefs?.getStringList(_profilesKey);
    if (profilesJson != null) {
      _profiles = profilesJson
          .map((json) => SettingsProfile.fromJsonString(json))
          .toList();
    }
    _currentProfileId = _prefs?.getString(_currentProfileKey);

    // Load current profile settings or use defaults
    final profile = currentProfile;
    if (profile != null) {
      _currentSettings = Map<String, dynamic>.from(profile.settings);
    } else {
      _currentSettings = _getDefaultSettings();
    }
  }

  /// Load modified settings tracking from shared preferences
  Future<void> _loadModifiedSettings() async {
    final modifiedJson = _prefs?.getStringList(_modifiedSettingsKey);
    if (modifiedJson != null) {
      _modifiedSettings = modifiedJson.toSet();
    }
  }

  /// Save profiles to shared preferences
  Future<void> _saveProfiles() async {
    final profilesJson = _profiles.map((p) => p.toJsonString()).toList();
    await _prefs?.setStringList(_profilesKey, profilesJson);
    if (_currentProfileId != null) {
      await _prefs?.setString(_currentProfileKey, _currentProfileId!);
    } else {
      await _prefs?.remove(_currentProfileKey);
    }
  }

  /// Save modified settings tracking to shared preferences
  Future<void> _saveModifiedSettings() async {
    await _prefs?.setStringList(
      _modifiedSettingsKey,
      _modifiedSettings.toList(),
    );
  }

  /// Create a new settings profile
  Future<SettingsProfile> createProfile(
    String name, {
    Map<String, dynamic>? settings,
  }) async {
    final profile = SettingsProfile.create(
      name: name,
      settings: settings ?? Map<String, dynamic>.from(_currentSettings),
    );
    _profiles.add(profile);
    await _saveProfiles();
    notifyListeners();
    return profile;
  }

  /// Update an existing profile
  Future<void> updateProfile(
    String profileId, {
    String? name,
    Map<String, dynamic>? settings,
  }) async {
    final index = _profiles.indexWhere((p) => p.id == profileId);
    if (index != -1) {
      _profiles[index] = _profiles[index].copyWith(
        name: name,
        settings: settings,
      );
      await _saveProfiles();
      notifyListeners();
    }
  }

  /// Delete a profile
  Future<void> deleteProfile(String profileId) async {
    _profiles.removeWhere((p) => p.id == profileId);
    if (_currentProfileId == profileId) {
      _currentProfileId = null;
    }
    await _saveProfiles();
    notifyListeners();
  }

  /// Load a profile as the current settings
  Future<void> loadProfile(String profileId) async {
    final profile = _profiles.firstWhere(
      (p) => p.id == profileId,
      orElse: () => throw Exception('Profile not found'),
    );
    _currentProfileId = profileId;
    _currentSettings = Map<String, dynamic>.from(profile.settings);
    _modifiedSettings.clear();
    _settingsRevision++;
    await _saveProfiles();
    await _saveModifiedSettings();
    notifyListeners();
  }

  /// Save current settings to the current profile or create a new one
  Future<SettingsProfile> saveCurrentSettings(String name) async {
    if (_currentProfileId != null) {
      await updateProfile(_currentProfileId!, settings: _currentSettings);
      _modifiedSettings.clear();
      await _saveModifiedSettings();
      return currentProfile!;
    } else {
      final profile = await createProfile(name, settings: _currentSettings);
      _currentProfileId = profile.id;
      _modifiedSettings.clear();
      await _saveProfiles();
      await _saveModifiedSettings();
      notifyListeners();
      return profile;
    }
  }

  /// Update a single setting value
  void updateSetting(String key, dynamic value) {
    final defaultSettings = _getDefaultSettings();
    final defaultValue = defaultSettings[key];

    if (value == defaultValue) {
      _currentSettings.remove(key);
      _modifiedSettings.remove(key);
    } else {
      _currentSettings[key] = value;
      _modifiedSettings.add(key);
    }
    _settingsRevision++;
    notifyListeners();
  }

  /// Get a setting value with fallback to default
  dynamic getSetting(String key) {
    if (_currentSettings.containsKey(key)) {
      return _currentSettings[key];
    }
    return _getDefaultSettings()[key];
  }

  /// Check if a setting has been modified from default
  bool isSettingModified(String key) {
    return _modifiedSettings.contains(key);
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    _currentSettings = _getDefaultSettings();
    _modifiedSettings.clear();
    _currentProfileId = null;
    _settingsRevision++;
    await _saveProfiles();
    await _saveModifiedSettings();
    notifyListeners();
  }

  /// Reset a single setting to default
  void resetSetting(String key) {
    final defaultValue = _getDefaultSettings()[key];
    _currentSettings[key] = defaultValue;
    _modifiedSettings.remove(key);
    _settingsRevision++;
    notifyListeners();
  }

  /// Export settings as JSON string
  String exportSettingsAsJson() {
    final exportData = {
      'exportedAt': DateTime.now().toIso8601String(),
      'settings': _currentSettings,
    };
    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  /// Import settings from JSON string
  Future<bool> importSettingsFromJson(String json) async {
    try {
      final importData = jsonDecode(json) as Map<String, dynamic>;
      if (importData.containsKey('settings')) {
        final settings = importData['settings'] as Map<String, dynamic>;
        _currentSettings = Map<String, dynamic>.from(settings);
        _modifiedSettings = settings.keys.toSet();
        _currentProfileId = null;
        _settingsRevision++;
        await _saveModifiedSettings();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error importing settings: $e');
      return false;
    }
  }

  /// Build InAppWebViewSettings from current settings
  InAppWebViewSettings buildSettings() {
    final defaults = _getDefaultSettings();
    final merged = Map<String, dynamic>.from(defaults)
      ..addAll(_currentSettings);

    return InAppWebViewSettings.fromMap(
          merged,
          enumMethod: EnumMethod.nativeValue,
        ) ??
        InAppWebViewSettings();
  }

  /// Get default settings map
  Map<String, dynamic> _getDefaultSettings() {
    return settings_defaults.defaultInAppWebViewSettings().toMap(
      enumMethod: EnumMethod.nativeValue,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Get all setting definitions organized by category
  static Map<String, List<SettingDefinition>> getSettingDefinitions() {
    return settings_definitions.getSettingDefinitions();
  }
}
