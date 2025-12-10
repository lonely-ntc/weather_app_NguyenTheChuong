import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(provider.getTrans('settings_title')),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(provider.getTrans('language')),
            subtitle: Text(provider.language == 'en' ? 'English' : 'Tiếng Việt'),
            trailing: DropdownButton<String>(
              value: provider.language,
              underline: const SizedBox(), 
              items: const [
                DropdownMenuItem(value: 'en', child: Text("English")),
                DropdownMenuItem(value: 'vi', child: Text("Tiếng Việt")),
              ],
              onChanged: (val) {
                if (val != null) {
                  provider.updateSettings(language: val);
                }
              },
            ),
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.thermostat),
            title: Text(provider.getTrans('temp_unit')),
            subtitle: Text(provider.isCelsius 
                ? provider.getTrans('celsius') 
                : provider.getTrans('fahrenheit')),
            trailing: Switch(
              value: provider.isCelsius,
              onChanged: (val) {
                provider.updateSettings(tempUnit: val ? 'metric' : 'imperial');
              },
            ),
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.air),
            title: Text(provider.getTrans('wind_unit')),
            subtitle: Text(provider.windUnit),
            trailing: DropdownButton<String>(
              value: provider.windUnit,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'm/s', child: Text("m/s")),
                DropdownMenuItem(value: 'km/h', child: Text("km/h")),
                DropdownMenuItem(value: 'mph', child: Text("mph")),
              ],
              onChanged: (val) {
                if (val != null) {
                  provider.updateSettings(windUnit: val);
                }
              },
            ),
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.access_time),
            title: Text(provider.getTrans('time_format')),
            subtitle: Text(provider.is24Hour 
                ? provider.getTrans('24_hour') 
                : provider.getTrans('12_hour')),
            trailing: Switch(
              value: provider.is24Hour,
              onChanged: (val) {
                provider.updateSettings(is24Hour: val);
              },
            ),
          ),
        ],
      ),
    );
  }
}