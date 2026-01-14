import 'dart:math' show Random;

import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../util/color_helper.dart';
import '../play_area/play_area.dart';
import 'multi_polygon_shape.dart';
import 'serializable_polygon.dart';
import 'timer_shape.dart';
import 'circle_shape.dart';
import 'line_shape.dart';
import 'polygon_shape.dart';
import 'shape.dart';
import 'thermometer_shape.dart';

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
      case ShapeType.multiPolygon:
        return MultiPolygonShape(id, List.empty(growable: true));
      case ShapeType.thermometer:
        return ThermometerShape(id, List.empty(growable: true));
      case ShapeType.timer:
        return TimerShape(id, playArea.getCenter(), startTime: DateTime.now());
    }
  }

  static Shape copy(Shape shape) {
    switch (shape.type) {
      case ShapeType.circle:
        final s = shape as CircleShape;
        return CircleShape(
          s.id,
          s.center,
          color: s.color,
          radius: s.radius,
          inverted: s.inverted,
        );

      case ShapeType.line:
        final s = shape as LineShape;
        return LineShape(s.id, [...s.points], color: s.color);

      case ShapeType.polygon:
        final s = shape as PolygonShape;
        return PolygonShape(s.id, [...s.points], color: s.color, inverted: s.inverted);

      case ShapeType.multiPolygon:
        final s = shape as MultiPolygonShape;
        return MultiPolygonShape(
          s.id,
          s.polygons,
          name: s.name,
          color: s.color,
          inverted: s.inverted,
        );

      case ShapeType.thermometer:
        final s = shape as ThermometerShape;
        return ThermometerShape(
          s.id,
          [...s.points],
          color: s.color,
          inverted: s.inverted,
        );

      case ShapeType.timer:
        final s = shape as TimerShape;
        return TimerShape(
          s.id,
          s.location,
          name: s.name,
          startTime: s.startTime,
          stopTime: s.stopTime,
          color: s.color,
        );
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

      case ShapeType.multiPolygon:
        final pts = (json['pgs'] as List)
            .map((p) => SerializablePolygon.fromJson(p))
            .toList();
        final name = json['na'] ?? 'MultiPolygon';
        final inverted = (json['i'] as String) == 't';
        return MultiPolygonShape(id, pts, name: name, color: color, inverted: inverted);

      case ShapeType.thermometer:
        final pts = (json['pts'] as List).map((p) => LatLng(p['lat'], p['lng'])).toList();
        final inverted = (json['i'] as String) == 't';
        return ThermometerShape(id, pts, color: color, inverted: inverted);

      case ShapeType.timer:
        final loc = json['loc'];
        final location = LatLng(loc['lat'], loc['lng']);
        final name = json['na'] ?? 'Timer';
        final start = DateTime.parse(json['sta'] as String);
        final stop = DateTime.tryParse(json['sto'] as String);
        return TimerShape(
          id,
          location,
          name: name,
          startTime: start,
          stopTime: stop,
          color: color,
        );
    }
  }
}
