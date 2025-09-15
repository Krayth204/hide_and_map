import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum ShapeType { circle, line, polygon }

class ExtraShape {
  final String id;
  final ShapeType type;
  MaterialColor color;
  final LatLng? center;
  final double? radius;
  final List<LatLng>? points;

  ExtraShape.circle(this.id, this.color, this.center, this.radius)
    : type = ShapeType.circle,
      points = null;

  ExtraShape.line(this.id, this.color, this.points)
    : type = ShapeType.line,
      center = null,
      radius = null;

  ExtraShape.polygon(this.id, this.color, this.points)
    : type = ShapeType.polygon,
      center = null,
      radius = null;
}
