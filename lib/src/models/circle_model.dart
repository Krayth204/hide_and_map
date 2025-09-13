import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Simple model storing center and radius in meters.
class CircleModel {
  LatLng? center;
  double radiusMeters;

  CircleModel({this.center, required this.radiusMeters});

  factory CircleModel.empty() => CircleModel(center: null, radiusMeters: 1000);

  void reset() {
    center = null;
    radiusMeters = 1000;
  }
}
