import 'package:google_maps_flutter/google_maps_flutter.dart';

class ShapeObject {
  final Circle? circle;
  final Polyline? polyline;
  final Polygon? polygon;

  const ShapeObject({this.circle, this.polyline, this.polygon});

  bool get isEmpty => circle == null && polyline == null && polygon == null;
}