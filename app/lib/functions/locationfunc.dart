import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  StreamSubscription<Position>? _streamSubscription;

  Future<bool> _checkPermissions() async {
    try {
      var reqStatus = await Permission.locationWhenInUse.status;

      if (reqStatus.isDenied) {
        reqStatus = await Permission.locationWhenInUse.request();
        if (reqStatus.isDenied) {
          return false;
        }
      } else if (reqStatus.isPermanentlyDenied) {
        return false;
      }

      LocationPermission locationPermission = await Geolocator.checkPermission();
      if (locationPermission == LocationPermission.denied) {
        locationPermission = await Geolocator.requestPermission();
        if (locationPermission == LocationPermission.denied) {
          return false;
        }
      }
      if (locationPermission == LocationPermission.deniedForever) {
        return false;
      }

      return true;
    } catch (e) {
      print('İzin kontrolü hatası: $e');
      return false;
    }
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LatLng?> getCurrentLocation() async {
    try {
      final hasPermission = await _checkPermissions();
      if (!hasPermission) return null;

      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Konum alınamadı: $e');
      return null;
    }
  }

  Future<Position?> getUserCurrentLocation() async {
    try {
      final hasPermission = await _checkPermissions();
      if (!hasPermission) return null;

      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      final userCurrentLocation = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      );

      return userCurrentLocation;
    } catch (e) {
      print('Konum alınamadı: $e');
      return null;
    }
  }

  Stream<LatLng> getLocationStream() async* {
    final hasPermission = await _checkPermissions();
    if (!hasPermission) return;

    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) return;

    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).map((position) => LatLng(position.latitude, position.longitude));
  }

  Future<StreamSubscription<Position>?> startUpdateUserCurrentLocation({
    required void Function(Position) onLocationChanged,
  }) async {
    try {
      final hasPermission = await _checkPermissions();
      if (!hasPermission) return null;

      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      await _streamSubscription?.cancel();

      final stream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      _streamSubscription = stream.listen(
        (Position pos) {
          onLocationChanged(pos);
        },
        onError: (error) {
          print('Konum stream hatası: $error');
        },
      );

      return _streamSubscription;
    } catch (e) {
      print('Konum stream başlatma hatası: $e');
      return null;
    }
  }

  Future<void> stopUserLocationUpdates() async {
    try {
      await _streamSubscription?.cancel();
      _streamSubscription = null;
    } catch (e) {
      print('Konum stream durdurma hatası: $e');
    }
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }

  void dispose() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
  }
}