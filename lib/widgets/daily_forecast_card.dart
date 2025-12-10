import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/forecast_model.dart';
import '../utils/weather_icons.dart';
import '../providers/weather_provider.dart';
import '../utils/date_formatter.dart'; 

class DailyForecastCard extends StatelessWidget {
  final List<ForecastModel> forecasts;

  const DailyForecastCard({super.key, required this.forecasts});

  @override
  Widget build(BuildContext context) {
    if (forecasts.isEmpty) return const SizedBox.shrink();

    final provider = context.watch<WeatherProvider>();
    final langCode = provider.language;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            provider.getTrans('daily_title'), 
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: forecasts.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2, 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormatter.formatDayName(item.dateTime, langCode), 
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
                          ),
                          if (item.precipitationProb > 0)
                            Text("💧 ${item.precipitationProb}%", 
                                style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 12)),
                        ],
                      )
                    ),
                    Expanded(
                      flex: 1,
                      child: CachedNetworkImage(imageUrl: WeatherIconsHelper.getIconUrl(item.icon), height: 40),
                    ),
                    Expanded(
                      flex: 2, 
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('${item.tempMax.round()}°', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                          const SizedBox(width: 10),
                          Text('${item.tempMin.round()}°', style: const TextStyle(color: Colors.white70)),
                        ],
                      )
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}