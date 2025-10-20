import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../util/geo_math.dart';
import 'play_area.dart';

class CirclePlayArea extends PlayArea {
  final LatLng center;
  final double radiusMeters;

  List<LatLng>? _boundary;

  CirclePlayArea(this.center, this.radiusMeters);

  @override
  List<LatLng> getBoundary() {
    _boundary ??= GeoMath.pointsOfCircle(center, radiusMeters);
    return _boundary!;
  }

  @override
  LatLng getCenter() => center;

  @override
  LatLngBounds getLatLngBounds() {
    final boundary = getBoundary();
    if (boundary.isEmpty) {
      return LatLngBounds(southwest: center, northeast: center);
    }

    double minLat = boundary.first.latitude;
    double maxLat = boundary.first.latitude;
    double minLng = boundary.first.longitude;
    double maxLng = boundary.first.longitude;

    for (final v in boundary) {
      if (v.latitude < minLat) minLat = v.latitude;
      if (v.latitude > maxLat) maxLat = v.latitude;
      if (v.longitude < minLng) minLng = v.longitude;
      if (v.longitude > maxLng) maxLng = v.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

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
