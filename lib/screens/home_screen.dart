import 'dart:math'; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart'; 
import '../providers/weather_provider.dart';
import '../providers/location_provider.dart';
import '../models/weather_model.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/hourly_forecast_list.dart';
import '../widgets/daily_forecast_card.dart';
import '../widgets/weather_detail_item.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/error_widget.dart';
import '../utils/constants.dart';
import '../utils/weather_icons.dart';
import '../config/api_config.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

// 1. MAIN HOME SCREEN
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  Future<void> _initData() async {
    try {
      await context.read<LocationProvider>().fetchLocation();
    } catch (_) {}
    
    if (mounted) {
      context.read<WeatherProvider>().fetchWeatherByLocation();
    }
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    final provider = context.read<WeatherProvider>();
    if (index == 0) {
      provider.fetchWeatherByLocation();
    } else {
      provider.fetchWeatherByCity(provider.favorites[index - 1]);
    }
  }

  void _showMap(BuildContext context, double? lat, double? lon) {
    if (lat == null || lon == null) return;

    showDialog(
      context: context,
      builder: (context) => WeatherMapDialog(initialLat: lat, initialLon: lon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        final int totalPages = 1 + provider.favorites.length;

        BoxDecoration bgDecoration = BoxDecoration(
          gradient: provider.currentWeather != null 
            ? AppColors.getGradient(provider.currentWeather!.mainCondition)
            : AppColors.getGradient('default'),
        );

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(totalPages, (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8, height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index ? Colors.white : Colors.white38,
                ),
              )),
            ),
            leading: IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
            ),
            actions: [
              if (provider.currentWeather != null)
                IconButton(
                  icon: const Icon(Icons.map_outlined, color: Colors.white),
                  tooltip: "Map",
                  onPressed: () => _showMap(context, provider.currentWeather!.lat, provider.currentWeather!.lon),
                ),
              if (provider.currentWeather != null)
                IconButton(
                  icon: const Icon(Icons.compare_arrows, color: Colors.white),
                  tooltip: "Compare",
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => CompareScreen(city1: provider.currentWeather!)));
                  },
                ),
              if (provider.currentWeather != null)
                IconButton(
                  icon: Icon(
                    provider.isFavorite(provider.currentWeather!.cityName) ? Icons.favorite : Icons.favorite_border,
                    color: Colors.redAccent,
                  ),
                  onPressed: () => provider.toggleFavorite(provider.currentWeather!.cityName),
                ),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
              ),
            ],
          ),
          body: Container(
            decoration: bgDecoration,
            child: PageView.builder(
              controller: _pageController,
              itemCount: totalPages,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                return _buildBody(provider);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(WeatherProvider provider) {
    if (provider.state == WeatherState.loading || provider.currentWeather == null) {
      return const SafeArea(child: LoadingShimmer());
    }

    if (provider.state == WeatherState.error) {
      return CustomErrorWidget(message: provider.errorMessage, onRetry: _initData);
    }

    final w = provider.currentWeather!;

    return RefreshIndicator(
      onRefresh: () async {
         await provider.fetchWeatherByCity(w.cityName);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 60),
            if (w.alertMessage != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.9), 
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))]
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        provider.getTrans(w.alertMessage!), // Dịch thông báo
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)
                      ),
                    ),
                  ],
                ),
              ),
            const AqiAlertCard(),
            if (provider.isUsingCachedData)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 5),
                color: Colors.orange.withOpacity(0.8),
                child: Text(
                  provider.getTrans('offline_cached'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),

            CurrentWeatherCard(weather: w),
            const SizedBox(height: 20),
            WeatherDetailsGrid(weather: w),
            const SizedBox(height: 30),
            HourlyForecastList(forecasts: provider.hourlyForecast), 
            const SizedBox(height: 15),
        
         
            const SizedBox(height: 5),
            DailyForecastCard(forecasts: provider.dailyForecast), 
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// 2. WIDGET AQI ALERT CARD
class AqiAlertCard extends StatelessWidget {
  const AqiAlertCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    final weather = provider.currentWeather;

    if (weather?.aqi == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: _getAqiColor(weather!.aqi!),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24, width: 1),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(provider.getTrans('aqi'), style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text("${weather.aqi}", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Container(height: 20, width: 1, color: Colors.white54),
                    const SizedBox(width: 8),
                    Text(
                      provider.getTrans(weather.aqiStatus), 
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)
                    ),
                  ],
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(provider.getTrans('pm25'), style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text("${weather.pm2_5?.toStringAsFixed(1)}", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Color _getAqiColor(int index) {
    switch (index) {
      case 1: return const Color(0xFF4CAF50); // Tốt
      case 2: return const Color(0xFFFBC02D); // Khá
      case 3: return const Color(0xFFF57C00); // TB
      case 4: return const Color(0xFFD32F2F); // Kém
      case 5: return const Color(0xFF7B1FA2); // Nguy hại
      default: return Colors.black26;
    }
  }
}

class WeatherMapDialog extends StatefulWidget {
  final double initialLat;
  final double initialLon;

  const WeatherMapDialog({super.key, required this.initialLat, required this.initialLon});

  @override
  State<WeatherMapDialog> createState() => _WeatherMapDialogState();
}

class _WeatherMapDialogState extends State<WeatherMapDialog> {
  String _selectedLayer = 'radar_view';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    final weather = provider.currentWeather;

    final Map<String, String> layers = {
      'radar_view': provider.getTrans('map_radar'),
      'temp_new': provider.getTrans('map_temp'),
      'precipitation_new': provider.getTrans('map_precip'),
    };

    String getApiLayer(String key) {
      if (key == 'radar_view') return 'precipitation_new';
      return key;
    }

    bool isRaining = false;
    if (weather != null) {
      String condition = weather.mainCondition.toLowerCase();
      if (condition.contains('rain') || 
          condition.contains('drizzle') || 
          condition.contains('thunder') || 
          condition.contains('storm')) {
        isRaining = true;
      }
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: double.infinity,
          height: 550,
          child: Column(
            children: [
              AppBar(
                title: Text(layers[_selectedLayer]!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                centerTitle: true,
                leading: const CloseButton(),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
                actions: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.layers, color: Colors.blueAccent),
                    onSelected: (String value) {
                      setState(() {
                        _selectedLayer = value;
                      });
                    },
                    itemBuilder: (BuildContext context) {
                      return layers.entries.map((entry) {
                        return PopupMenuItem<String>(
                          value: entry.key,
                          child: Row(
                            children: [
                              Icon(
                                _selectedLayer == entry.key ? Icons.radio_button_checked : Icons.radio_button_unchecked, 
                                color: Colors.blue, size: 18
                              ),
                              const SizedBox(width: 10),
                              Text(entry.value),
                            ],
                          ),
                        );
                      }).toList();
                    },
                  )
                ],
              ),
              Expanded(
                child: Stack(
                  children: [
                    FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(widget.initialLat, widget.initialLon),
                        initialZoom: 6.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.weather_app',
                        ),
                        
                        Opacity(
                          opacity: 0.7,
                          child: TileLayer(
                            key: ValueKey(_selectedLayer), 
                            urlTemplate: 'https://tile.openweathermap.org/map/${getApiLayer(_selectedLayer)}/{z}/{x}/{y}.png?appid=${ApiConfig.apiKey}',
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                        
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(widget.initialLat, widget.initialLon),
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                            ),
                          ],
                        ),
                      ],
                    ),

                    if (isRaining)
                      const IgnorePointer(
                        child: RainLayer(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 4. RAIN LAYER 
class RainLayer extends StatefulWidget {
  const RainLayer({super.key});

  @override
  State<RainLayer> createState() => _RainLayerState();
}

class _RainLayerState extends State<RainLayer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<RainDrop> _drops = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    for (int i = 0; i < 100; i++) {
      _drops.add(RainDrop(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        length: _random.nextDouble() * 20 + 10,
        speed: _random.nextDouble() * 0.02 + 0.01,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(painter: RainPainter(_drops), size: Size.infinite);
      },
    );
  }
}

class RainDrop {
  double x;
  double y;
  double length;
  double speed;
  RainDrop({required this.x, required this.y, required this.length, required this.speed});
}

class RainPainter extends CustomPainter {
  final List<RainDrop> drops;
  final Paint _paint = Paint()..color = Colors.blueAccent.withOpacity(0.6)..strokeWidth = 1.5..strokeCap = StrokeCap.round;

  RainPainter(this.drops);

  @override
  void paint(Canvas canvas, Size size) {
    for (var drop in drops) {
      drop.y += drop.speed;
      if (drop.y > 1.0) {
        drop.y = -0.1;
        drop.x = Random().nextDouble();
      }
      final startX = drop.x * size.width;
      final startY = drop.y * size.height;
      final endY = startY + drop.length;
      canvas.drawLine(Offset(startX, startY), Offset(startX, endY), _paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
// 5. COMPARE SCREEN
class CompareScreen extends StatefulWidget {
  final WeatherModel city1;

  const CompareScreen({super.key, required this.city1});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  WeatherModel? city2;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String? _errorMsg;

  void _searchCity2(String query) async {
    if (query.isEmpty) return;
    setState(() { _isLoading = true; _errorMsg = null; });

    final result = await context.read<WeatherProvider>().searchWeatherForComparison(query);

    setState(() {
      _isLoading = false;
      if (result != null) {
        city2 = result;
      } else {
        _errorMsg = "Not found: $query";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.getGradient(widget.city1.mainCondition),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Row(
                  children: [
                    const BackButton(color: Colors.white),
                    Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: provider.getTrans('search_compare'),
                            hintStyle: const TextStyle(color: Colors.white60),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.search, color: Colors.white),
                              onPressed: () => _searchCity2(_searchController.text),
                            ),
                          ),
                          onSubmitted: _searchCity2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_isLoading) const LinearProgressIndicator(color: Colors.white),
              if (_errorMsg != null) 
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_errorMsg!, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, backgroundColor: Colors.white)),
                ),

              const SizedBox(height: 10),

              Expanded(
                child: city2 == null 
                  ? _buildPlaceholder(widget.city1, provider) 
                  : _buildComparisonTable(widget.city1, city2!),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(WeatherModel c1, WeatherProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(provider.getTrans('comparing_with'), style: const TextStyle(color: Colors.white70)),
          Text(c1.cityName, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          const Icon(Icons.compare_arrows, size: 80, color: Colors.white30),
          const SizedBox(height: 20),
          Text(
            provider.getTrans('compare_instruction'), 
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTable(WeatherModel c1, WeatherModel c2) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildCityHeader(c1)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.compare_arrows, color: Colors.white54, size: 30),
                ),
                Expanded(child: _buildCityHeader(c2)),
              ],
            ),
            const Divider(color: Colors.white24, height: 30),
            
            _buildRowItem(Icons.thermostat, "Temp", "${c1.temperature.round()}°", "${c2.temperature.round()}°"),
            _buildRowItem(Icons.accessibility_new, "Feels Like", "${c1.feelsLike.round()}°", "${c2.feelsLike.round()}°"),
            _buildRowItem(Icons.water_drop, "Humidity", "${c1.humidity}%", "${c2.humidity}%"),
            _buildRowItem(Icons.air, "Wind", "${c1.windSpeed}", "${c2.windSpeed}"),
            _buildRowItem(Icons.speed, "Pressure", "${c1.pressure}", "${c2.pressure}"),
            _buildRowItem(Icons.visibility, "Visibility", "${(c1.visibility ?? 0)/1000}km", "${(c2.visibility ?? 0)/1000}km"),
            
            if (c1.aqi != null || c2.aqi != null)
              _buildRowItem(Icons.masks, "AQI", "${c1.aqi ?? '-'}", "${c2.aqi ?? '-'}"),
          ],
        ),
      ),
    );
  }

  Widget _buildCityHeader(WeatherModel city) {
    return Column(
      children: [
        Text(city.cityName, 
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
        CachedNetworkImage(
          imageUrl: WeatherIconsHelper.getIconUrl(city.icon),
          height: 70,
        ),
        Text(city.mainCondition, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      ],
    );
  }

  Widget _buildRowItem(IconData icon, String label, String val1, String val2) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(val1, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center)),
          SizedBox(
            width: 80,
            child: Column(
              children: [
                Icon(icon, color: Colors.white70, size: 22),
                const SizedBox(height: 4),
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ),
          Expanded(child: Text(val2, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}