import 'package:google_maps_flutter/google_maps_flutter.dart';

class SerializablePolygon {
  final List<LatLng> outer;
  final List<List<LatLng>> holes;

  SerializablePolygon({
    required this.outer,
    this.holes = const [],
  });

  bool get isValid => outer.length >= 3;

  Map<String, dynamic> toJson() {
    return {
      'o': outer
          .map((p) => {'lat': p.latitude, 'lng': p.longitude})
          .toList(),
      'h': holes
          .map(
            (ring) => ring
                .map((p) => {'lat': p.latitude, 'lng': p.longitude})
                .toList(),
          )
          .toList(),
    };
  }

  factory SerializablePolygon.fromJson(Map<String, dynamic> json) {
    return SerializablePolygon(
      outer: (json['o'] as List)
          .map((p) => LatLng(p['lat'], p['lng']))
          .toList(),
      holes: (json['h'] as List?)
              ?.map<List<LatLng>>(
                (ring) => (ring as List)
                    .map((p) => LatLng(p['lat'], p['lng']))
                    .toList(),
              )
              .toList() ??
          const [],
    );
  }
}
