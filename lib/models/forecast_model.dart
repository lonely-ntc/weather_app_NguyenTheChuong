class ForecastModel {
  final DateTime dateTime;
  final double tempMin;
  final double tempMax;
  final String description;
  final String icon;
  final int precipitationProb;

  ForecastModel({
    required this.dateTime,
    required this.tempMin,
    required this.tempMax,
    required this.description,
    required this.icon,
    this.precipitationProb = 0,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    return ForecastModel(
      dateTime: DateTime.fromMillisecondsSinceEpoch((json['dt'] ?? 0) * 1000),
      tempMin: (json['main']['temp_min'] as num).toDouble(),
      tempMax: (json['main']['temp_max'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      icon: json['weather'][0]['icon'] ?? '',
      precipitationProb: (json['pop'] != null) ? (json['pop'] * 100).round() : 0,
    );
  }
}