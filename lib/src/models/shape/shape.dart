import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../util/color_helper.dart';
import '../../util/geo_math.dart';
import '../play_area/play_area.dart';
import 'shape_object.dart';

enum ShapeType { circle, line, polygon }

class Shape {
  final String id;
  final ShapeType type;
  MaterialColor color;
  final LatLng? center;
  final double? radius;
  final List<LatLng>? points;
  final bool inverted;

  Shape(
    this.id,
    this.type,
    this.color, {
    this.center,
    this.radius,
    this.points,
    this.inverted = false,
  });

  Shape.circle(
    String id,
    MaterialColor color,
    LatLng center,
    double radius, {
    bool inverted = false,
  }) : this(
         id,
         ShapeType.circle,
         color,
         center: center,
         radius: radius,
         inverted: inverted,
       );

  Shape.line(String id, MaterialColor color, List<LatLng> points)
    : this(id, ShapeType.line, color, points: points);

  Shape.polygon(
    String id,
    MaterialColor color,
    List<LatLng> points, {
    bool inverted = false,
  }) : this(id, ShapeType.polygon, color, points: points, inverted: inverted);

  ShapeObject toShapeObject(
    PlayArea playArea, {
    bool editable = false,
    void Function(String id)? onTap,
  }) {
    switch (type) {
      case ShapeType.circle:
        if (center == null || radius == null) return const ShapeObject();
        if (inverted) {
          return ShapeObject(
            polygon: Polygon(
              polygonId: PolygonId(id),
              points: playArea.getBoundary(),
              holes: [GeoMath.pointsOfCircle(center!, radius!)],
              strokeColor: color.shade700,
              strokeWidth: 2,
              fillColor: color.withAlpha(115),
              consumeTapEvents: editable,
              onTap: () => editable ? onTap?.call(id) : null,
            ),
          );
        } else {
          return ShapeObject(
            circle: Circle(
              circleId: CircleId(id),
              center: center!,
              radius: radius!,
              strokeColor: color.shade700,
              strokeWidth: 2,
              fillColor: color.withAlpha(115),
              consumeTapEvents: editable,
              onTap: () => editable ? onTap?.call(id) : null,
            ),
          );
        }

      case ShapeType.line:
        if (points == null || points!.length < 2) return const ShapeObject();
        return ShapeObject(
          polyline: Polyline(
            polylineId: PolylineId(id),
            points: points!,
            color: color,
            width: 4,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            consumeTapEvents: editable,
            onTap: () => editable ? onTap?.call(id) : null,
          ),
        );

      case ShapeType.polygon:
        if (points == null || points!.length < 3) return const ShapeObject();
        return ShapeObject(
          polygon: Polygon(
            polygonId: PolygonId(id),
            points: inverted ? playArea.getBoundary() : List<LatLng>.from(points!),
            holes: inverted ? [points!] : const [],
            strokeColor: color.shade700,
            strokeWidth: 2,
            fillColor: color.withAlpha(115),
            consumeTapEvents: editable,
            onTap: () => editable ? onTap?.call(id) : null,
          ),
        );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ty': type.name.substring(0, 1),
      'col': color.value,
      'sce': center != null
          ? {'lat': center!.latitude, 'lng': center!.longitude}
          : null,
      'sra': radius,
      'pts': points?.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      'i': inverted.toString()[0],
    };
  }

  static Shape fromJson(
    Map<String, dynamic> json, {
    List<MaterialColor>? availableColors,
  }) {
    final type = ShapeType.values.firstWhere((e) => e.name.startsWith(json['ty']));
    final id = json['id'] as String;
    final inverted = (json['i'] as String) == 't';

    final colorValue = json['col'] as int;
    MaterialColor resolvedColor = ColorHelper.resolveMaterialColor(colorValue);

    switch (type) {
      case ShapeType.circle:
        final c = json['sce'];
        final center = LatLng(c['lat'], c['lng']);
        final radius = (json['sra'] as num).toDouble();
        return Shape.circle(id, resolvedColor, center, radius, inverted: inverted);

      case ShapeType.line:
        final pts = (json['pts'] as List)
            .map((p) => LatLng(p['lat'], p['lng']))
            .toList();
        return Shape.line(id, resolvedColor, pts);

      case ShapeType.polygon:
        final pts = (json['pts'] as List)
            .map((p) => LatLng(p['lat'], p['lng']))
            .toList();
        return Shape.polygon(id, resolvedColor, pts, inverted: inverted);
    }
  }
}
