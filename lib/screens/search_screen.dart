import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import '../providers/weather_provider.dart';
import '../services/storage_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _submit(String value) {
    if (value.isNotEmpty) {
      context.read<WeatherProvider>().fetchWeatherByCity(value);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: provider.getTrans('enter_city'), 
            hintStyle: const TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
          onSubmitted: _submit,
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () => _submit(_controller.text))
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            // 3. Dịch các Tab
            Tab(text: provider.getTrans('recent')),
            Tab(text: provider.getTrans('favorites')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FutureBuilder<List<String>>(
            future: context.read<StorageService>().getHistory(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("No history"));
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) => _buildItem(snapshot.data![index]),
              );
            },
          ),
          Consumer<WeatherProvider>(
            builder: (context, provider, _) {
              if (provider.favorites.isEmpty) return const Center(child: Text("No favorites"));
              return ListView.builder(
                itemCount: provider.favorites.length,
                itemBuilder: (context, index) => _buildItem(provider.favorites[index]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String city) {
    return ListTile(
      leading: const Icon(Icons.location_city),
      title: Text(city),
      onTap: () {
        context.read<WeatherProvider>().fetchWeatherByCity(city);
        Navigator.pop(context);
      },
    );
  }
}