import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hide_and_map/src/models/play_area/play_area.dart';
import 'package:hide_and_map/src/models/shape/shape.dart';
import 'package:hide_and_map/src/models/shape/shape_object.dart';
import 'package:hide_and_map/src/util/location_provider.dart';

import '../../util/color_helper.dart';
import '../../util/geo_math.dart';

class ThermometerShape implements Shape {
  @override
  final String id;

  @override
  final ShapeType type = ShapeType.thermometer;

  @override
  MaterialColor color;

  @override
  bool inverted;

  final List<LatLng> points;
  double distance = 0;

  ThermometerShape(
    this.id,
    this.points, {
    this.color = Colors.blue,
    this.inverted = false,
  }) {
    _calculateDistance();
  }

  @override
  void addPoint(LatLng p) {
    if (points.length < 2) {
      points.add(p);
    } else {
      points[1] = p;
    }
    _calculateDistance();
  }

  void _calculateDistance() {
    if (points.isEmpty) {
      distance = 0;
    } else if (points.length == 1) {
      distance = GeoMath.distanceInMeters(points[0], LocationProvider.lastLocation);
    } else {
      distance = GeoMath.distanceInMeters(points[0], points[1]);
    }
  }

  @override
  void undo() {
    if (points.isNotEmpty) points.removeLast();
    _calculateDistance();
  }

  @override
  void reset() {
    points.clear();
    _calculateDistance();
  }

  @override
  void setRadius(double r) {
    // not in use
  }

  @override
  bool canConfirm() {
    return points.length == 2;
  }

  @override
  double getDistance() {
    return distance;
  }

  @override
  ShapeObject toShapeObject(
    PlayArea playArea, {
    bool editable = false,
    void Function(String id)? onTap,
    String? customId,
  }) {
    if (points.length != 2) return const ShapeObject();
    final p1 = points[0];
    final p2 = points[1];

    final boundary = playArea.getBoundary();

    // 1. Midpoint
    final mid = GeoMath.midpoint(p1, p2);

    // 2. Reference latitude for projection
    final latRef = mid.latitude;

    // 3. Projected direction + perpendicular
    final aProj = GeoMath.project(p1, latRef);
    final bProj = GeoMath.project(p2, latRef);
    final dir = bProj - aProj;
    final perp = GeoMath.perpendicular(dir);

    // 4. Classify boundary points
    final excludedSide = GeoMath.sideOfLine(boundary, mid, perp, latRef, inverted);

    // 5. Build polygon (still basic, but now geometrically correct)
    final polygonPoints = GeoMath.buildCutPolygon(
      boundary,
      mid,
      perp,
      latRef,
      excludedSide,
    );

    return ShapeObject(
      polygon: Polygon(
        polygonId: PolygonId(customId ?? id),
        points: polygonPoints,
        strokeColor: color.shade700,
        strokeWidth: 2,
        fillColor: color.withAlpha(115),
        consumeTapEvents: editable,
        onTap: () => editable ? onTap?.call(id) : null,
      ),
      polyline: Polyline(
        polylineId: PolylineId(customId ?? id),
        points: points,
        color: color,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        consumeTapEvents: editable,
        onTap: () => editable ? onTap?.call(id) : null,
      ),
    );
  }

  @override
  Set<Marker> getMarkers(Function notify) {
    return {
      for (int i = 0; i < points.length; i++)
        Marker(
          markerId: MarkerId('add_point_$i'),
          position: points[i],
          draggable: true,
          onDragEnd: (p) {
            points[i] = p;
            _calculateDistance();
            notify();
          },
          icon: ColorHelper.hueFromMaterialColor(color),
        ),
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ty': 't',
      'col': color.value,
      'pts': points.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      'i': inverted ? 't' : 'f',
    };
  }
}
