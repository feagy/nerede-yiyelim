import 'package:flutter/foundation.dart';
import 'package:app/database/entity/place.dart';

//state store for detailed restaurant place information
class PlaceStateStore extends ChangeNotifier {
  Place? _place;

  Place? get place => _place;

  void setPlace(Place place) {
    _place = place;
    notifyListeners();
  }

  void clear() {
    _place = null;
    notifyListeners();
  }
}