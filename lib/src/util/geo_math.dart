import 'dart:math' as math;
import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class GeoMath {
   static const double _earthRadius = 6371000;

  /// Returns distance between [a] and [b] in metres
  static double distanceInMeters(LatLng a, LatLng b) {
    final lat1 = _degToRad(a.latitude);
    final lon1 = _degToRad(a.longitude);
    final lat2 = _degToRad(b.latitude);
    final lon2 = _degToRad(b.longitude);

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final hav = pow(sin(dLat / 2), 2) +
        cos(lat1) * cos(lat2) * pow(sin(dLon / 2), 2);

    final c = 2 * atan2(sqrt(hav), sqrt(1 - hav));
    return _earthRadius * c;
  }

  static double _degToRad(double deg) => deg * pi / 180.0;

  static List<LatLng> pointsOfCircle(LatLng center, double radiusMeters) {
    final points = <LatLng>[];
    const steps = 64;
    for (var i = 0; i < steps; i++) {
      final theta = (i / steps) * (2 * math.pi);
      final latOffset = radiusMeters / 111320.0 * math.cos(theta);
      final lngOffset =
          radiusMeters /
          (111320.0 * math.cos(center.latitude * math.pi / 180)) *
          math.sin(theta);
      points.add(
        LatLng(center.latitude + latOffset, center.longitude + lngOffset),
      );
    }
    return points;
  }
}
