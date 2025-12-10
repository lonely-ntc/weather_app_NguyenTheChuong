import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';

class StorageService {
  static const String _keyWeather = 'cached_weather';
  static const String _keyTimestamp = 'cached_timestamp';
  static const String _keyFavorites = 'weather_favorites'; 
  static const String _keyHistory = 'weather_history';    
  static const String _keySettings = 'app_settings';

  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyFavorites) ?? [];
  }

  Future<void> toggleFavorite(String city) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_keyFavorites) ?? [];
    
    String cityClean = city; 
    
    int index = favorites.indexWhere((item) => item.toLowerCase() == city.toLowerCase());

    if (index >= 0) {
      favorites.removeAt(index); 
    } else {
      if (favorites.length >= 5) return; 
      favorites.add(cityClean); 
    }
    
    await prefs.setStringList(_keyFavorites, favorites);
  }

  Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyHistory) ?? [];
  }

  Future<void> addToHistory(String city) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_keyHistory) ?? [];

    history.removeWhere((item) => item.toLowerCase() == city.toLowerCase());
    
    history.insert(0, city);

    if (history.length > 10) {
      history = history.sublist(0, 10);
    }

    await prefs.setStringList(_keyHistory, history);
  }

  Future<void> saveWeather(WeatherModel weather) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(weather.toJson());
    await prefs.setString(_keyWeather, jsonString);
    await prefs.setInt(_keyTimestamp, DateTime.now().millisecondsSinceEpoch);
  }

  Future<WeatherModel?> getCachedWeather() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(_keyWeather);
    if (jsonString == null) return null;
    try {
      return WeatherModel.fromJson(jsonDecode(jsonString));
    } catch (_) {
      return null;
    }
  }

  Future<int?> getCacheTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTimestamp);
  }

  Future<void> saveSettings({
    required String tempUnit,
    required String windUnit,
    required bool is24Hour,
    required String language,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'tempUnit': tempUnit,
      'windUnit': windUnit,
      'is24Hour': is24Hour,
      'language': language,
    };
    await prefs.setString(_keySettings, jsonEncode(data));
  }

  Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString(_keySettings);
    if (data != null) {
      return jsonDecode(data);
    }
    return {
      'tempUnit': 'metric',
      'windUnit': 'm/s',
      'is24Hour': true,
      'language': 'en',
    };
  }
}