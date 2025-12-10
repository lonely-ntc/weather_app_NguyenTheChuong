import 'package:flutter/material.dart';
import '../models/location_model.dart';
import '../services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService;
  LocationModel? _currentLocation;
  bool _isLoading = false;

  LocationProvider(this._locationService);

  LocationModel? get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;

  Future<void> fetchLocation() async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentLocation = await _locationService.getCurrentLocation();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}