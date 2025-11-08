import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  StreamSubscription<Position>? _streamSubscription;

  Future<void> _checkPermissions() async {
    try {
      var reqStatus = await Permission.locationWhenInUse.status;

      if (reqStatus.isDenied) {
        reqStatus = await Permission.locationWhenInUse.request();
        if (reqStatus.isDenied) {
          openAppSettings();
        }
      } else if (reqStatus.isPermanentlyDenied) {
        openAppSettings();
      }
    } catch (e) {
      return;
    }
  }

  Future<Position?> getUserCurrentLocation() async {
    try {
      await _checkPermissions();

      LocationPermission locationPermission = await Geolocator.checkPermission();
      if (locationPermission == LocationPermission.denied) {
        locationPermission = await Geolocator.requestPermission();
      }
      if (locationPermission == LocationPermission.deniedForever) {
        openAppSettings();
      }

      final userCurrentLocation = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 5,
        ),
      );

      return userCurrentLocation;
    } catch (e) {
      return null;
    }
  }

  Future<StreamSubscription<dynamic>?> startUpdateUserCurrentLocation({
    required void Function(Position) onLocationChanged,
  }) async {
    try {
      await _checkPermissions();

      final stream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 5,
        ),
      );

      _streamSubscription = stream.listen((Position pos) {
        onLocationChanged(pos);
      });
    } catch (e) {
      return null;
    }
  }

  Future<void> stopUserLocationUpdates() async {
    try {
      await _streamSubscription?.cancel();
      _streamSubscription = null;
    } catch (e) {
      return;
    }
  }
}
