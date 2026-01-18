import 'dart:async';
import 'package:app/functions/locationfunc.dart';
import 'package:flutter/foundation.dart';
import 'package:app/database/entity/place.dart';
import 'package:latlong2/latlong.dart';

class MapStateStore extends ChangeNotifier {
  List<Place> _nearbyPlaces = [];
  int _selectedCategoryIndex = 0;

  List<Place> get nearbyPlaces => _nearbyPlaces;
  int get selectedCategoryIndex => _selectedCategoryIndex;

  void setPlaces(List<Place> places) {
    _nearbyPlaces = places;
    notifyListeners();
  }

  void setSelectedCategoryIndex(int i) {
    _selectedCategoryIndex = i;
    notifyListeners();
  }

  void clear() {
    _nearbyPlaces = [];
    notifyListeners();
  }

  LatLng? _userLocation;
  StreamSubscription? _locationStream;
  bool _isTracking = false;

  LatLng? get userLocation => _userLocation;
  bool get isTracking => _isTracking;

  void setUserLocation(LatLng latLng) {
    _userLocation = latLng;
    notifyListeners();
  }

  Future<bool> initializeLocation(LocationService locationService) async {
    try {
      final position = await locationService.getUserCurrentLocation();
      
      if (position != null) {
        _userLocation = LatLng(position.latitude, position.longitude);
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Konum başlatma hatası: $e');
      return false;
    }
  }

  Future<void> startTracking(LocationService locationService) async {
    if (_isTracking || _locationStream != null) {
      debugPrint('Konum takibi zaten aktif');
      return;
    }

    try {
      _locationStream = await locationService.startUpdateUserCurrentLocation(
        onLocationChanged: (pos) {
          _userLocation = LatLng(pos.latitude, pos.longitude);
          notifyListeners();
        },
      );

      if (_locationStream != null) {
        _isTracking = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Konum takibi başlatma hatası: $e');
      _isTracking = false;
    }
  }

  void stopTracking() {
    _locationStream?.cancel();
    _locationStream = null;
    _isTracking = false;
    notifyListeners();
  }

  Future<void> refreshLocation(LocationService locationService) async {
    try {
      final position = await locationService.getUserCurrentLocation();
      
      if (position != null) {
        _userLocation = LatLng(position.latitude, position.longitude);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Konum yenileme hatası: $e');
    }
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}