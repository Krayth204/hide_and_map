import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'play_area.dart';

class PolygonPlayArea extends PlayArea {
  final List<LatLng> vertices;

  PolygonPlayArea(this.vertices);

  @override
  List<LatLng> getBoundary() => vertices;
}
