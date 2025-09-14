import 'dart:math' as Math;

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'play_area.dart';

class CirclePlayArea extends PlayArea {
  final LatLng center;
  final double radiusMeters;

  CirclePlayArea(this.center, this.radiusMeters);

  @override
  List<LatLng> getBoundary() {
    // Approximate circle with 64 points
    final points = <LatLng>[];
    const steps = 64;
    for (var i = 0; i < steps; i++) {
      final theta = (i / steps) * (2 * Math.pi);
      final latOffset = radiusMeters / 111320.0 * Math.cos(theta);
      final lngOffset = radiusMeters / (111320.0 * Math.cos(center.latitude * Math.pi / 180)) * Math.sin(theta);
      points.add(LatLng(center.latitude + latOffset, center.longitude + lngOffset));
    }
    return points;
  }
}
