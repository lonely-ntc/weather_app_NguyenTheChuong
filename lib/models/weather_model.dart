class WeatherModel {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final String description;
  final String icon;
  final String mainCondition;
  final DateTime dateTime;
  final int? visibility;
  final int? cloudiness;
  final int? sunrise;
  final int? sunset;
  final double? lat;
  final double? lon;
  final int? aqi;
  final double? pm2_5;

  WeatherModel({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.description,
    required this.icon,
    required this.mainCondition,
    required this.dateTime,
    this.visibility,
    this.cloudiness,
    this.sunrise,
    this.sunset,
    this.lat,
    this.lon,
    this.aqi,
    this.pm2_5,
  });

String? get alertMessage {
    if (temperature > 38) return "alert_heat";
    if (temperature < 10) return "alert_cold";
    if (windSpeed > 15) return "alert_wind";
    if (mainCondition.toLowerCase().contains('storm')) return "alert_storm";
    if (mainCondition.toLowerCase().contains('rain') && windSpeed > 10) return "alert_rain_wind";
    if ((aqi ?? 0) >= 4) return "alert_aqi";
    return null;
  }

  String get aqiStatus {
    switch (aqi) {
      case 1: return "aqi_1"; 
      case 2: return "aqi_2";
      case 3: return "aqi_3";
      case 4: return "aqi_4";
      case 5: return "aqi_5";
      default: return "aqi_unknown";
    }
  }
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic val) => (val as num?)?.toDouble() ?? 0.0;
    int toInt(dynamic val) => (val as num?)?.toInt() ?? 0;

    return WeatherModel(
      cityName: json['name'] ?? '',
      country: json['sys']?['country'] ?? '',
      temperature: toDouble(json['main']?['temp']),
      feelsLike: toDouble(json['main']?['feels_like']),
      humidity: toInt(json['main']?['humidity']),
      windSpeed: toDouble(json['wind']?['speed']),
      pressure: toInt(json['main']?['pressure']),
      description: json['weather']?[0]['description'] ?? '',
      icon: json['weather']?[0]['icon'] ?? '',
      mainCondition: json['weather']?[0]['main'] ?? '',
      dateTime: DateTime.fromMillisecondsSinceEpoch(toInt(json['dt']) * 1000),
      visibility: toInt(json['visibility']),
      cloudiness: toInt(json['clouds']?['all']),
      sunrise: toInt(json['sys']?['sunrise']),
      sunset: toInt(json['sys']?['sunset']),
      lat: toDouble(json['coord']?['lat']),
      lon: toDouble(json['coord']?['lon']),
      aqi: json['aqi'], 
      pm2_5: toDouble(json['pm2_5']),
    );
  }

  WeatherModel copyWith({int? aqi, double? pm2_5}) {
    return WeatherModel(
      cityName: cityName, country: country, temperature: temperature,
      feelsLike: feelsLike, humidity: humidity, windSpeed: windSpeed,
      pressure: pressure, description: description, icon: icon,
      mainCondition: mainCondition, dateTime: dateTime,
      visibility: visibility, cloudiness: cloudiness,
      sunrise: sunrise, sunset: sunset, lat: lat, lon: lon,
      aqi: aqi ?? this.aqi,
      pm2_5: pm2_5 ?? this.pm2_5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': cityName,
      'sys': {'country': country, 'sunrise': sunrise, 'sunset': sunset},
      'main': {'temp': temperature, 'feels_like': feelsLike, 'humidity': humidity, 'pressure': pressure},
      'wind': {'speed': windSpeed},
      'weather': [{'description': description, 'icon': icon, 'main': mainCondition}],
      'dt': dateTime.millisecondsSinceEpoch ~/ 1000,
      'coord': {'lat': lat, 'lon': lon},
      'visibility': visibility,
      'clouds': {'all': cloudiness},
      'aqi': aqi,
      'pm2_5': pm2_5,
    };
  }
}