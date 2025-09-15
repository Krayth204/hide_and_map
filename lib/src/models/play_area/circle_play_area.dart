import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../util/geo_math.dart';
import 'play_area.dart';

class CirclePlayArea extends PlayArea {
  final LatLng center;
  final double radiusMeters;

  CirclePlayArea(this.center, this.radiusMeters);

  @override
  List<LatLng> getBoundary() {
    // Approximate circle with 64 points
    List<LatLng> points = GeoMath.pointsOfCircle(center, radiusMeters);
    return points;
  }

  @override
  LatLng getCenter() => center;
}
