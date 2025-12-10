import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../utils/constants.dart';
import '../providers/weather_provider.dart';

class WeatherDetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const WeatherDetailItem({super.key, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 28),
        const SizedBox(height: 8),
        Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.label),
      ],
    );
  }
}

class WeatherDetailsGrid extends StatelessWidget {
  final WeatherModel weather;
  const WeatherDetailsGrid({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    final is24Hour = provider.is24Hour;
    
    String windDisplay = "";
    double speed = weather.windSpeed; 
    
    if (provider.isCelsius) {
      switch (provider.windUnit) {
        case 'km/h': windDisplay = "${(speed * 3.6).toStringAsFixed(1)} km/h"; break;
        case 'mph': windDisplay = "${(speed * 2.237).toStringAsFixed(1)} mph"; break;
        default: windDisplay = "$speed m/s";
      }
    } else {
      windDisplay = "$speed mph";
    }

    String formatSunTime(int? timestamp) {
      if (timestamp == null) return "--:--";
      final dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      return is24Hour ? DateFormat('HH:mm').format(dt) : DateFormat('h:mm a').format(dt);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                WeatherDetailItem(icon: Icons.water_drop_outlined, label: provider.getTrans('humidity'), value: "${weather.humidity}%"),
                WeatherDetailItem(icon: Icons.air, label: provider.getTrans('wind'), value: windDisplay),
                WeatherDetailItem(icon: Icons.speed, label: provider.getTrans('pressure'), value: "${weather.pressure} hPa"),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                 WeatherDetailItem(icon: Icons.visibility, label: provider.getTrans('visibility'), value: "${(weather.visibility ?? 0) / 1000} km"),
                 WeatherDetailItem(icon: Icons.wb_twilight, label: provider.getTrans('sunrise'), value: formatSunTime(weather.sunrise)),
                 WeatherDetailItem(icon: Icons.nights_stay_outlined, label: provider.getTrans('sunset'), value: formatSunTime(weather.sunset)),
              ],
            )
          ],
        ),
      ),
    );
  }
}