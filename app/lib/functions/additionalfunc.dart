
import 'package:app/detailedrestaurantpage.dart';
import 'package:app/mappage.dart';
import 'package:flutter/material.dart';

class Additionalfunc {
  static void changePage(int index, GlobalKey<NavigatorState> state, String keyAPI) {
    switch (index) {
      case 0:
        state.currentState!.pushReplacement(MaterialPageRoute(builder: (_) => MapPage(keyAPI: keyAPI)));
        break;
      case 1:
        //Navigator.pushReplacementNamed(context, "/profile");
        break;
      case 2:
        //Navigator.pushReplacementNamed(context, "/favorites");
        break;
      case 3:
        state.currentState!.pushReplacement(MaterialPageRoute(builder: (_) => DetailedRestaurantPage()));
        break;
      case 4:
        //Navigator.pushReplacementNamed(context, "/settings");
    }
  }
}
