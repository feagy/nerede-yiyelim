import 'package:flutter/foundation.dart';
import 'package:app/database/entity/place.dart';

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
}
