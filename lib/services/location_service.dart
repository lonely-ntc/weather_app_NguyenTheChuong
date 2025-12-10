import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/location_model.dart';

class LocationService {
  Future<LocationModel> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    Position? position = await Geolocator.getLastKnownPosition();

    if (position == null) {
      print("Cache GPS trống, đang thử lấy vị trí thực...");
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5), 
      );
    }

    String cityName = 'Unknown';
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        cityName = placemarks[0].locality ?? 
                   placemarks[0].administrativeArea ?? 
                   'Unknown';
      }
    } catch (e) {
      print("Lỗi lấy tên thành phố: $e");
    }

    return LocationModel(
      latitude: position.latitude,
      longitude: position.longitude,
      cityName: cityName,
    );
  }
}