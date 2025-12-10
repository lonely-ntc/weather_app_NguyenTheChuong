import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';
import 'providers/weather_provider.dart';
import 'providers/location_provider.dart';
import 'services/weather_service.dart';
import 'services/location_service.dart';
import 'services/storage_service.dart';
import 'services/connectivity_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => WeatherService()),
        Provider(create: (_) => LocationService()),
        Provider(create: (_) => StorageService()),
        Provider(create: (_) => ConnectivityService()),
        
        ChangeNotifierProvider(
          create: (context) => LocationProvider(context.read<LocationService>()),
        ),
        
        ChangeNotifierProxyProvider<LocationProvider, WeatherProvider>(
          create: (context) => WeatherProvider(
            context.read<WeatherService>(),
            context.read<StorageService>(),
            context.read<ConnectivityService>(),
            context.read<LocationProvider>(),
          ),
          update: (context, locationProvider, previous) {
            final provider = previous!;
            provider.locationProvider = locationProvider; 
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Weather App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Roboto',
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}