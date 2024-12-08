import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ApiSetting {
  String apiKey;
  String apiEndpoint;

  ApiSetting({
    required this.apiKey,
    required this.apiEndpoint,
  });

  Map<String, dynamic> toJson() {
    return {
      'apiKey': apiKey,
      'apiEndpoint': apiEndpoint,
    };
  }

  factory ApiSetting.fromJson(Map<String, dynamic> json) {
    return ApiSetting(
      apiKey: json['apiKey'] as String,
      apiEndpoint: json['apiEndpoint'] as String,
    );
  }
}

class SettingsProvider extends ChangeNotifier {
  static final SettingsProvider _instance = SettingsProvider._internal();
  factory SettingsProvider() => _instance;
  SettingsProvider._internal();

  Map<String, ApiSetting> _apiSettings = {};

  Map<String, ApiSetting> get apiSettings => _apiSettings;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? settingsJson = prefs.getString('apiSettings');

    if (settingsJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(settingsJson);
      _apiSettings = decoded.map((key, value) =>
          MapEntry(key, ApiSetting.fromJson(value as Map<String, dynamic>)));
    }

    notifyListeners();
  }

  Future<void> updateSettings({
    required Map<String, ApiSetting> apiSettings,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    _apiSettings = apiSettings;

    final encodedSettings =
        apiSettings.map((key, value) => MapEntry(key, value.toJson()));

    await prefs.setString('apiSettings', jsonEncode(encodedSettings));

    notifyListeners();
  }
}
