import 'dart:convert'; // Bắt buộc để dùng jsonEncode
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart'; 
import '../models/weather_model.dart';
import '../models/hourly_weather_model.dart';
import '../models/forecast_model.dart';
import '../services/weather_service.dart';
import '../services/storage_service.dart';
import '../services/connectivity_service.dart';
import 'location_provider.dart';

enum WeatherState { initial, loading, loaded, error }

class WeatherProvider extends ChangeNotifier {
  WeatherService _weatherService;
  final StorageService _storageService;
  final ConnectivityService _connectivityService;
  LocationProvider? _locationProvider;
  WeatherModel? _currentWeather;
  List<HourlyWeatherModel> _hourlyForecast = [];
  List<ForecastModel> _dailyForecast = [];
  List<String> _favorites = [];
  WeatherState _state = WeatherState.initial;
  String _errorMessage = '';
  String _tempUnit = 'metric';
  String _windUnit = 'm/s';
  bool _is24Hour = true;
  String _language = 'en';
  bool _isUsingCachedData = false;
  bool _isCacheOutdated = false;
  bool _isDisposed = false;

  final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'aqi': 'Air Quality', 'pm25': 'PM2.5',
      'search_hint': 'Enter city name...', 'search_compare': 'Search City...',
      'comparing_with': 'Comparing with:', 'compare_instruction': 'Search another city above\nto start comparing',
      'recent': 'Recent', 'favorites': 'Favorites (Max 5)',
      'hourly_title': 'Hourly Forecast (24h)', 'daily_title': '5-Day Forecast', 'view_5_days': 'View 5-Days >',
      'offline_outdated': 'Offline: Outdated', 'offline_cached': 'Offline Mode',
      'feels_like': 'Feels like', 'humidity': 'Humidity', 'wind': 'Wind', 'pressure': 'Pressure', 'visibility': 'Visibility', 'sunrise': 'Sunrise', 'sunset': 'Sunset', 
      'alert_heat': '⚠️ Extreme Heat Warning!',
      'alert_cold': '❄️ Freezing Weather Alert!',
      'alert_wind': '💨 High Wind Warning!',
      'alert_storm': '⚡ Thunderstorm Alert!',
      'alert_rain_wind': '🌧️ Heavy Rain & Wind!',
      'alert_aqi': '😷 Poor Air Quality!',
      'aqi_1': 'Good', 'aqi_2': 'Fair', 'aqi_3': 'Moderate', 'aqi_4': 'Poor', 'aqi_5': 'Very Poor', 'aqi_unknown': 'Unknown',
      'map_radar': 'Radar View',
      'map_temp': 'Temperature Map',
      'map_precip': 'Precipitation Map',
      'settings_title': 'Settings',
      'language': 'Language',
      'temp_unit': 'Temperature Unit',
      'wind_unit': 'Wind Speed Unit',
      'time_format': 'Time Format',
      'celsius': 'Celsius (°C)',
      'fahrenheit': 'Fahrenheit (°F)',
      '24_hour': '24 Hour (14:00)',
      '12_hour': '12 Hour (2:00 PM)',
      'enter_city': 'Enter city name...',
    },
    'vi': {
      'aqi': 'Chất lượng KK', 'pm25': 'Bụi mịn',
      'search_hint': 'Nhập tên thành phố...', 'search_compare': 'Tìm thành phố...',
      'comparing_with': 'Đang so sánh với:', 'compare_instruction': 'Tìm thành phố khác ở trên\nđể bắt đầu so sánh',
      'recent': 'Gần đây', 'favorites': 'Yêu thích (Tối đa 5)',
      'hourly_title': 'Dự báo theo giờ (24h)', 'daily_title': 'Dự báo 5 ngày', 'view_5_days': 'Xem 5 ngày tới >',
      'offline_outdated': 'Dữ liệu cũ', 'offline_cached': 'Chế độ Offline',
      'feels_like': 'Cảm giác', 'humidity': 'Độ ẩm', 'wind': 'Gió', 'pressure': 'Áp suất', 'visibility': 'Tầm nhìn', 'sunrise': 'Bình minh', 'sunset': 'Hoàng hôn',
      'alert_heat': '⚠️ Nắng nóng gay gắt!',
      'alert_cold': '❄️ Trời rất lạnh!',
      'alert_wind': '💨 Cảnh báo gió mạnh!',
      'alert_storm': '⚡ Cảnh báo dông bão!',
      'alert_rain_wind': '🌧️ Mưa to gió lớn!',
      'alert_aqi': '😷 Không khí ô nhiễm!',
      'aqi_1': 'Tốt', 'aqi_2': 'Khá', 'aqi_3': 'Trung bình', 'aqi_4': 'Kém', 'aqi_5': 'Nguy hại', 'aqi_unknown': 'Không xác định',
      'map_radar': 'Chế độ Radar',
      'map_temp': 'Bản đồ Nhiệt độ',
      'map_precip': 'Bản đồ Lượng mưa',
      'settings_title': 'Cài đặt',
      'language': 'Ngôn ngữ',
      'temp_unit': 'Đơn vị nhiệt độ',
      'wind_unit': 'Đơn vị gió',
      'time_format': 'Định dạng giờ',
      'celsius': 'Độ C (°C)',
      'fahrenheit': 'Độ F (°F)',
      '24_hour': '24 Giờ (14:00)',
      '12_hour': '12 Giờ (2:00 CH)',
      'enter_city': 'Nhập tên thành phố...',
    },
  };

  WeatherProvider(this._weatherService, this._storageService, this._connectivityService, this._locationProvider) {
    _initApp();
  }

  set locationProvider(LocationProvider? value) {
    if (_locationProvider != value) _locationProvider = value;
  }

  WeatherModel? get currentWeather => _currentWeather;
  List<HourlyWeatherModel> get hourlyForecast => _hourlyForecast;
  List<ForecastModel> get dailyForecast => _dailyForecast;
  List<HourlyWeatherModel> get forecast => _hourlyForecast; 
  List<String> get favorites => _favorites;
  WeatherState get state => _state;
  String get errorMessage => _errorMessage;
  
  bool get isCelsius => _tempUnit == 'metric';
  String get windUnit => _windUnit;
  bool get is24Hour => _is24Hour;
  String get language => _language;
  bool get isUsingCachedData => _isUsingCachedData;
  bool get isCacheOutdated => _isCacheOutdated;

  String getTrans(String key) => _localizedValues[_language]?[key] ?? key;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_isDisposed) notifyListeners();
  }

  Future<void> _initApp() async {
    await _loadSettings();
    await _loadFavorites();
  }

  Future<void> _loadSettings() async {
    final settings = await _storageService.getSettings();
    _tempUnit = settings['tempUnit'];
    _windUnit = settings['windUnit'];
    _is24Hour = settings['is24Hour'];
    _language = settings['language'];
    _weatherService = WeatherService(unit: _tempUnit, lang: _language);
    _safeNotify();
  }

  Future<void> _loadFavorites() async {
    _favorites = await _storageService.getFavorites();
    _safeNotify();
  }

  Future<void> updateSettings({String? tempUnit, String? windUnit, bool? is24Hour, String? language}) async {
    if (tempUnit != null) _tempUnit = tempUnit;
    if (windUnit != null) _windUnit = windUnit;
    if (is24Hour != null) _is24Hour = is24Hour;
    if (language != null) _language = language;

    await _storageService.saveSettings(tempUnit: _tempUnit, windUnit: _windUnit, is24Hour: _is24Hour, language: _language);
    _weatherService = WeatherService(unit: _tempUnit, lang: _language);

    if ((tempUnit != null || language != null) && _currentWeather != null) {
      await fetchWeatherByCity(_currentWeather!.cityName);
    }
    _safeNotify();
  }

  Future<void> toggleFavorite(String city) async {
    await _storageService.toggleFavorite(city);
    await _loadFavorites();
  }

  bool isFavorite(String city) {
    return _favorites.any((element) => element.toLowerCase() == city.toLowerCase());
  }

  Future<void> _updateWidget() async {
    if (_currentWeather == null) return;
    try {
      print("Starting Widget Update...");

      await HomeWidget.saveWidgetData<String>('city', _currentWeather!.cityName);
      await HomeWidget.saveWidgetData<String>('temp', "${_currentWeather!.temperature.round()}°");
      await HomeWidget.saveWidgetData<String>('desc', _currentWeather!.description);
      
      List<Map<String, String>> hourlyData = [];
      if (_hourlyForecast.isNotEmpty) {
        for (var i = 0; i < 3 && i < _hourlyForecast.length; i++) {
          final item = _hourlyForecast[i];
          final time = "${item.dateTime.hour}:00"; 
          final temp = "${item.temperature.round()}°";
          hourlyData.add({'time': time, 'temp': temp});
        }
      }
      
      final jsonString = jsonEncode(hourlyData);
      await HomeWidget.saveWidgetData<String>('hourly_json', jsonString);
      
      await HomeWidget.updateWidget(
        name: 'WeatherWidgetProvider', 
        iOSName: 'WeatherWidget',
      );
      
      print("Widget Updated: ${_currentWeather!.cityName} with $jsonString");
    } catch (e) {
      print("Widget Update Error: $e");
    }
  }
  Future<void> fetchWeatherByLocation() async {
    _state = WeatherState.loading;
    _safeNotify();

    if (await _connectivityService.isConnected()) {
      _isUsingCachedData = false;
      try {
        if (_locationProvider?.currentLocation != null) {
          final loc = _locationProvider!.currentLocation!;
          await _fetchDataByCoords(loc.latitude, loc.longitude);
        } else {
           print("GPS null, load default: Ho Chi Minh City");
           await fetchWeatherByCity("Ho Chi Minh City");
        }
      } catch (e) {
        await _loadCache(force: true);
      }
    } else {
      await _loadCache(force: true);
    }
    _safeNotify();
  }

  Future<void> fetchWeatherByCity(String city) async {
    _state = WeatherState.loading;
    _safeNotify();
    
    if (await _connectivityService.isConnected()) {
      _isUsingCachedData = false;
      try {
        _currentWeather = await _weatherService.getCurrentWeather(city);
        
        await _storageService.saveWeather(_currentWeather!);
        await _storageService.addToHistory(city);
        await _fetchForecasts(city); 
        await _updateWidget();

        _state = WeatherState.loaded;
      } catch (e) {
        _state = WeatherState.error;
        _errorMessage = "Could not find city '$city'.";
      }
    } else {
      _errorMessage = "No internet connection.";
      _state = WeatherState.error;
    }
    _safeNotify();
  }

  Future<void> _fetchDataByCoords(double lat, double lon) async {
    try {
      _currentWeather = await _weatherService.getCurrentWeatherByCoords(lat, lon);
      
      if (_isDisposed) return;

      await _storageService.saveWeather(_currentWeather!);
      await _fetchForecasts(_currentWeather!.cityName);
      await _updateWidget();

      _state = WeatherState.loaded;
    } catch (e) {
      throw e;
    }
  }

  Future<void> _fetchForecasts(String city) async {
    if (_isDisposed) return;
    try {
      _hourlyForecast = await _weatherService.getHourlyForecast(city);
      _dailyForecast = await _weatherService.getDailyForecast(city);
    } catch (e) {
      print("Fetch Forecast Error: $e");
    }
  }

  Future<WeatherModel?> searchWeatherForComparison(String city) async {
    try {
      if (await _connectivityService.isConnected()) {
        return await _weatherService.getCurrentWeather(city);
      }
    } catch (_) {}
    return null;
  }

  // 6. Load Cache
  Future<void> _loadCache({bool force = false}) async {
    final cached = await _storageService.getCachedWeather();
    final timestamp = await _storageService.getCacheTimestamp();
    
    if (cached != null) {
      _currentWeather = cached;
      _state = WeatherState.loaded;
      _isUsingCachedData = true;
      if (timestamp != null) {
        final diff = DateTime.now().millisecondsSinceEpoch - timestamp;
        if (diff > 30 * 60 * 1000) _isCacheOutdated = true;
      }
    } else if (force) {
      _state = WeatherState.error;
      _errorMessage = "No internet and no cached data available.";
    }
  }
}