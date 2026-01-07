import 'package:app/database/entity/place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

typedef MarkerBuilder = void Function(LatLng position);

class MapMarkers {
  static List<Marker> getPlaceMarkers<T>(
    List<T> items,
    LatLng Function(T item) getPosition,
    void Function(T item) onMarkerTap,
    BuildContext context
  ) {
    return items.map((item) {
      final position = getPosition(item);
      return Marker(
        width: MediaQuery.of(context).size.width * 0.30,
        height: MediaQuery.of(context).size.height * 0.08,
        point: position,
        child: GestureDetector(
          onTap: () => onMarkerTap(item),
          child: Column(
            children: [
                  Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 115, 0),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.all(10),
                child: Row(
                  spacing: 4,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if ((item as Place).type == 'restaurant') 
                      const Icon(Icons.restaurant, size: 14, color: Colors.white),
                    if ((item as Place).type == 'cafe') 
                      const Icon(Icons.local_cafe, size: 14, color: Colors.white),
                    if ((item as Place).type == "pub")
                      const Icon(Icons.local_bar, size: 14, color: Colors.white),
                    Text(
                      (item as Place).placeName,
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, size: 18, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                      "${(item as Place).googleRating}",
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ],
          )
        ),
      );
    }).toList();
  }
}