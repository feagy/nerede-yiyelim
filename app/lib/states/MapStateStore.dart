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

  LatLng? get userLocation => _userLocation;

  void setUserLocation(LatLng latLng) {
    _userLocation = latLng;
    notifyListeners();
  }

  Future<void> startTracking(LocationService locationService) async {
    if (_locationStream != null) return;

    _locationStream =
        await locationService.startUpdateUserCurrentLocation(
      onLocationChanged: (pos) {
        _userLocation = LatLng(pos.latitude, pos.longitude);
        notifyListeners();
      },
    );
  }

  void stopTracking() {
    _locationStream?.cancel();
    _locationStream = null;
  }
}
