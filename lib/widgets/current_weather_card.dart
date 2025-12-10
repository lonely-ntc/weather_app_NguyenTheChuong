import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../utils/constants.dart';
import '../utils/weather_icons.dart';
import '../providers/weather_provider.dart';
import '../utils/date_formatter.dart';

class CurrentWeatherCard extends StatelessWidget {
  final WeatherModel weather;

  const CurrentWeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    final langCode = provider.language; 
    final isCelsius = provider.isCelsius;
    final unit = isCelsius ? 'C' : 'F';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(weather.cityName.toUpperCase(), style: AppTextStyles.header),
            const SizedBox(height: 5),
            Text(
              DateFormatter.formatFullDate(weather.dateTime, langCode), 
              style: AppTextStyles.body
            ),
            
            const SizedBox(height: 20),
            CachedNetworkImage(
              imageUrl: WeatherIconsHelper.getIconUrl(weather.icon),
              height: 150,
              placeholder: (context, url) => const CircularProgressIndicator(color: Colors.white),
              errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
            ),
            Text('${weather.temperature.round()}°', style: AppTextStyles.tempBig),
            Text(
              weather.description.toUpperCase(), 
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text('${provider.getTrans('feels_like')} ${weather.feelsLike.round()}°$unit', style: AppTextStyles.label),
          ],
        ),
      ),
    );
  }
}