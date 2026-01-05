import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

typedef MarkerBuilder = void Function(LatLng position);

class MapMarkers {
  static List<Marker> getPlaceMarkers<T>(
    List<T> items,
    LatLng Function(T item) getPosition,
    void Function(T item) onMarkerTap,
  ) {
    return items.map((item) {
      final position = getPosition(item);
      return Marker(
        width: 40,
        height: 40,
        point: position,
        child: GestureDetector(
          onTap: () => onMarkerTap(item),
          child: Icon(
            Icons.location_pin,
            color: Color.fromARGB(255, 255, 115, 0),
            size: 40,
          ),
        ),
      );
    }).toList();
  }
}