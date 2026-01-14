import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'play_area.dart';

class PolygonPlayArea extends PlayArea {
  final List<LatLng> vertices;

  PolygonPlayArea(this.vertices);

  @override
  List<LatLng> getBoundary() => vertices;

  @override
  LatLng getCenter() {
    double round(double v) => double.parse(v.toStringAsFixed(5));
    double sumLat = 0;
    double sumLng = 0;
    for (var v in vertices) {
      sumLat += v.latitude;
      sumLng += v.longitude;
    }
    return LatLng(round(sumLat / vertices.length), round(sumLng / vertices.length));
  }

  @override
  LatLngBounds getLatLngBounds() {
    if (vertices.isEmpty) {
      return LatLngBounds(southwest: LatLng(0, 0), northeast: LatLng(0, 0));
    }

    double minLat = vertices.first.latitude;
    double maxLat = vertices.first.latitude;
    double minLng = vertices.first.longitude;
    double maxLng = vertices.first.longitude;

    for (final v in vertices) {
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
      't': 'pg',
      'ver': vertices
          .map(
            (v) => {
              'lat': double.parse(v.latitude.toStringAsFixed(5)),
              'lng': double.parse(v.longitude.toStringAsFixed(5)),
            },
          )
          .toList(),
    };
  }
}
