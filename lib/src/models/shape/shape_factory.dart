import 'dart:math' show Random;

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hide_and_map/src/models/play_area/play_area.dart';
import '../../util/color_helper.dart';
import 'circle_shape.dart';
import 'line_shape.dart';
import 'polygon_shape.dart';
import 'shape.dart';

class ShapeFactory {
  static Shape createShape(ShapeType type, PlayArea playArea) {
    int rand = Random().nextInt(1000);
    final id = '${type.name[0]}${DateTime.now().millisecondsSinceEpoch % 1000000}$rand';
    switch (type) {
      case ShapeType.circle:
        return CircleShape(id, playArea.getCenter());
      case ShapeType.line:
        return LineShape(id, List.empty(growable: true));
      case ShapeType.polygon:
        return PolygonShape(id, List.empty(growable: true));
    }
  }

  static Shape copy(Shape shape) {
    if (shape is CircleShape) {
      return CircleShape(
        shape.id,
        shape.center,
        color: shape.color,
        radius: shape.radius,
        inverted: shape.inverted,
      );
    } else if (shape is LineShape) {
      return LineShape(shape.id, [...shape.points], color: shape.color);
    } else if (shape is PolygonShape) {
      return PolygonShape(
        shape.id,
        [...shape.points],
        color: shape.color,
        inverted: shape.inverted,
      );
    } else {
      throw UnsupportedError('No such ShapeType: ${shape.type}');
    }
  }

  static Shape fromJson(Map<String, dynamic> json) {
    final type = ShapeType.values.firstWhere((e) => e.name.startsWith(json['ty']));
    final id = json['id'] as String;
    final colorValue = json['col'] as int;
    final color = ColorHelper.resolveMaterialColor(colorValue);

    switch (type) {
      case ShapeType.circle:
        final c = json['sce'];
        final center = LatLng(c['lat'], c['lng']);
        final radius = (json['sra'] as num).toDouble();
        final inverted = (json['i'] as String) == 't';
        return CircleShape(id, center, color: color, radius: radius, inverted: inverted);

      case ShapeType.line:
        final pts = (json['pts'] as List).map((p) => LatLng(p['lat'], p['lng'])).toList();
        return LineShape(id, pts, color: color);

      case ShapeType.polygon:
        final pts = (json['pts'] as List).map((p) => LatLng(p['lat'], p['lng'])).toList();
        final inverted = (json['i'] as String) == 't';
        return PolygonShape(id, pts, color: color, inverted: inverted);
    }
  }
}
