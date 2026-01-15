import 'package:flutter/foundation.dart';
import 'package:app/database/entity/place.dart';

//state store for detailed restaurant place information
class PlaceStateStore extends ChangeNotifier {
  Place? _place;
  String? _summary;

  Place? get place => _place;
  String? get summary => _summary;

  void setPlace(Place place) {
    _place = place;
    notifyListeners();
  }

  void setSummary(String summary) {
    _summary = summary;
    notifyListeners();
  }

  void clearSummary() {
    _summary = null;
    notifyListeners();
  }

  void clear() {
    _place = null;
    _summary = null;
    notifyListeners();
  }
}