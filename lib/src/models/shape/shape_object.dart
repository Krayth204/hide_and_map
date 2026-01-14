import 'package:google_maps_flutter/google_maps_flutter.dart';

class ShapeObject {
  final Circle? circle;
  final Polyline? polyline;
  final List<Polygon> polygons;
  final Marker? marker;

  const ShapeObject({this.circle, this.polyline, this.polygons = const [], this.marker});

  bool get isEmpty => circle == null && polyline == null && polygons.isEmpty && marker == null;
}