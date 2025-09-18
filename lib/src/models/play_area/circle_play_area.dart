import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../util/geo_math.dart';
import 'play_area.dart';

class CirclePlayArea extends PlayArea {
  final LatLng center;
  final double radiusMeters;

  CirclePlayArea(this.center, this.radiusMeters);

  @override
  List<LatLng> getBoundary() {
    return GeoMath.pointsOfCircle(center, radiusMeters);
  }

  @override
  LatLng getCenter() => center;

  @override
  Map<String, dynamic> toJson() {
    return {
      't': 'c',
      'cen': {
        'lat': double.parse(center.latitude.toStringAsFixed(5)),
        'lng': double.parse(center.longitude.toStringAsFixed(5)),
      },
      'rad': radiusMeters,
    };
  }
}
