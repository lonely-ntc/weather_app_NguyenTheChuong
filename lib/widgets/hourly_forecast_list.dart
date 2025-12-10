import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/hourly_weather_model.dart';
import '../utils/weather_icons.dart';
import '../providers/weather_provider.dart';

class HourlyForecastList extends StatelessWidget {
  final List<HourlyWeatherModel> forecasts;

  const HourlyForecastList({super.key, required this.forecasts});

  @override
  Widget build(BuildContext context) {
    if (forecasts.isEmpty) return const SizedBox.shrink();
    
    final provider = context.watch<WeatherProvider>();
    final is24Hour = provider.is24Hour;

   return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            provider.getTrans('hourly_title'), 
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: forecasts.take(8).length,
            itemBuilder: (context, index) {
              final item = forecasts[index];
              String timeStr = is24Hour 
                  ? DateFormat('HH:mm').format(item.dateTime)
                  : DateFormat('h a').format(item.dateTime);

              return Container(
                width: 90,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(timeStr, style: const TextStyle(color: Colors.white70)),
                    CachedNetworkImage(
                      imageUrl: WeatherIconsHelper.getIconUrl(item.icon),
                      height: 50,
                    ),
                    Text('${item.temperature.round()}°', 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}