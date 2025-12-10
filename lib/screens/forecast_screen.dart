import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart'; 
import '../providers/weather_provider.dart';
import '../utils/constants.dart';
import '../utils/weather_icons.dart';
import '../utils/date_formatter.dart'; 

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    final forecasts = provider.dailyForecast;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        centerTitle: true,
        title: Text(
          provider.getTrans('daily_title'), 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: provider.currentWeather != null 
            ? AppColors.getGradient(provider.currentWeather!.mainCondition)
            : AppColors.getGradient('default'),
        ),
        child: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: forecasts.length,
            itemBuilder: (context, index) {
              final item = forecasts[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormatter.formatDayName(item.dateTime, provider.language),
                            style: const TextStyle(
                              color: Colors.white, 
                              fontWeight: FontWeight.bold, 
                              fontSize: 16
                            )
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd/MM').format(item.dateTime),
                            style: const TextStyle(color: Colors.white70, fontSize: 14)
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          CachedNetworkImage(
                            imageUrl: WeatherIconsHelper.getIconUrl(item.icon),
                            height: 40,
                          ),
                          if (item.precipitationProb > 0)
                            Text(
                              "💧 ${item.precipitationProb}%",
                              style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                    
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "${item.tempMax.round()}°", 
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "${item.tempMin.round()}°", 
                            style: const TextStyle(color: Colors.white70, fontSize: 18)
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}