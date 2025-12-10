import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/weather_model.dart';
import '../models/hourly_weather_model.dart';
import '../models/forecast_model.dart';

class WeatherService {
  final String unit;
  final String lang;

  WeatherService({this.unit = 'metric', this.lang = 'en'});

  Future<Map<String, dynamic>?> _getAqiData(double lat, double lon) async {
    try {
      final url = ApiConfig.buildUrl('/air_pollution', {'lat': lat.toString(), 'lon': lon.toString()});
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['list'][0];
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<WeatherModel> getCurrentWeather(String city) async {
    final url = ApiConfig.buildUrl(ApiConfig.currentWeather, {'q': city, 'units': unit, 'lang': lang});
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var weather = WeatherModel.fromJson(json.decode(response.body));
      
      // An toàn: Chỉ gọi AQI nếu có tọa độ
      if (weather.lat != null && weather.lon != null) {
        final aqiData = await _getAqiData(weather.lat!, weather.lon!);
        if (aqiData != null) {
          weather = weather.copyWith(
            aqi: (aqiData['main']['aqi'] as num?)?.toInt(),
            pm2_5: (aqiData['components']['pm2_5'] as num?)?.toDouble(),
          );
        }
      }
      return weather;
    }
    throw Exception('Failed to load weather: ${response.statusCode}');
  }

  Future<WeatherModel> getCurrentWeatherByCoords(double lat, double lon) async {
    final url = ApiConfig.buildUrl(ApiConfig.currentWeather, {
      'lat': lat.toString(), 'lon': lon.toString(), 'units': unit, 'lang': lang
    });
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var weather = WeatherModel.fromJson(json.decode(response.body));
      
      final aqiData = await _getAqiData(lat, lon);
      if (aqiData != null) {
        weather = weather.copyWith(
          aqi: (aqiData['main']['aqi'] as num?)?.toInt(),
          pm2_5: (aqiData['components']['pm2_5'] as num?)?.toDouble(),
        );
      }
      return weather;
    }
    throw Exception('Failed to load weather: ${response.statusCode}');
  }

  Future<List<HourlyWeatherModel>> getHourlyForecast(String city) async {
    final url = ApiConfig.buildUrl(ApiConfig.forecast, {'q': city, 'units': unit, 'lang': lang});
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['list'] as List).map((e) => HourlyWeatherModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<ForecastModel>> getDailyForecast(String city) async {
    final url = ApiConfig.buildUrl(ApiConfig.forecast, {'q': city, 'units': unit, 'lang': lang});
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final list = data['list'] as List;
      Map<String, List<dynamic>> dailyMap = {};
      for (var item in list) {
        DateTime date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
        String dayKey = "${date.year}-${date.month}-${date.day}";
        if (!dailyMap.containsKey(dayKey)) dailyMap[dayKey] = [];
        dailyMap[dayKey]!.add(item);
      }
      List<ForecastModel> forecasts = [];
      dailyMap.forEach((key, items) {
        double min = 1000; double max = -1000;
        String icon = items[0]['weather'][0]['icon']; String desc = items[0]['weather'][0]['description'];
        for (var item in items) {
          double tempMin = (item['main']['temp_min'] as num).toDouble();
          double tempMax = (item['main']['temp_max'] as num).toDouble();
          if (tempMin < min) min = tempMin; if (tempMax > max) max = tempMax;
          DateTime d = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
          if (d.hour >= 11 && d.hour <= 14) { icon = item['weather'][0]['icon']; desc = item['weather'][0]['description']; }
        }
        forecasts.add(ForecastModel(
          dateTime: DateTime.fromMillisecondsSinceEpoch(items[0]['dt'] * 1000),
          tempMin: min, tempMax: max, description: desc, icon: icon,
          precipitationProb: (items[0]['pop'] != null) ? (items[0]['pop'] * 100).round() : 0,
        ));
      });
      return forecasts.take(5).toList(); 
    }
    return []; 
  }
}