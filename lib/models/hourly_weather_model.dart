class HourlyWeatherModel {
  final DateTime dateTime;
  final double temperature;
  final String description;
  final String icon;

  HourlyWeatherModel({
    required this.dateTime,
    required this.temperature,
    required this.description,
    required this.icon,
  });

  factory HourlyWeatherModel.fromJson(Map<String, dynamic> json) {
    return HourlyWeatherModel(
      dateTime: DateTime.fromMillisecondsSinceEpoch((json['dt'] ?? 0) * 1000),
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      icon: json['weather'][0]['icon'] ?? '',
    );
  }
}