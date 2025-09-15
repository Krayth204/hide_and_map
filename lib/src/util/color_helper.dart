import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ColorHelper {
  static BitmapDescriptor hueFromMaterialColor(MaterialColor color) {
    switch (color) {
      case Colors.blue:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case Colors.red:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case Colors.indigo:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
      case Colors.cyan:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
      case Colors.green:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case Colors.purple:
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueMagenta,
        );
      case Colors.orange:
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueOrange,
        );
      case Colors.pink:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose);
      case Colors.deepPurple:
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueViolet,
        );
      case Colors.yellow:
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueYellow,
        );
      default:
        return BitmapDescriptor.defaultMarker;
    }
  }

  static MaterialColor copyMaterialColor(MaterialColor color) {
    return MaterialColor(color.value, {
      50: color[50]!,
      100: color[100]!,
      200: color[200]!,
      300: color[300]!,
      400: color[400]!,
      500: color[500]!,
      600: color[600]!,
      700: color[700]!,
      800: color[800]!,
      900: color[900]!,
    });
  }

  static List<MaterialColor> availableColors = [
    Colors.blue,
    Colors.red,
    Colors.indigo,
    Colors.cyan,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.deepPurple,
    Colors.yellow,
  ];
}
