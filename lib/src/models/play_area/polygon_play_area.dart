import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'play_area.dart';

class PolygonPlayArea extends PlayArea {
  final List<LatLng> vertices;

  PolygonPlayArea(this.vertices);

  @override
  List<LatLng> getBoundary() => vertices;

  @override
  LatLng getCenter() {
    double sumLat = 0;
    double sumLng = 0;
    for (var v in vertices) {
      sumLat += v.latitude;
      sumLng += v.longitude;
    }
    return LatLng(sumLat / vertices.length, sumLng / vertices.length);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'polygon',
      'vertices': vertices
          .map((v) => {
                'lat': double.parse(v.latitude.toStringAsFixed(5)),
                'lng': double.parse(v.longitude.toStringAsFixed(5)),
              })
          .toList(),
    };
  }
}
