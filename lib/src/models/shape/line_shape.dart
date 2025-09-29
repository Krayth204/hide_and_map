import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../util/color_helper.dart';
import '../play_area/play_area.dart';
import 'shape.dart';
import 'shape_object.dart';

class LineShape implements Shape {
  @override
  final String id;

  @override
  final ShapeType type = ShapeType.line;

  @override
  MaterialColor color;

  @override
  bool inverted = false;

  final List<LatLng> points;

  LineShape(this.id, this.points, {this.color= Colors.blue});

  @override
  void addPoint(LatLng p) {
    points.add(p);
  }

  @override
  void undo() {
    if (points.isNotEmpty) points.removeLast();
  }

  @override
  void reset() {
    points.clear();
  }

  @override
  void setRadius(double r) {
    // not in use
  }

  @override
  bool canConfirm() {
    return points.length >= 2;
  }

  @override
  ShapeObject toShapeObject(
    PlayArea playArea, {
    bool editable = false,
    void Function(String id)? onTap,
    String? customId,
  }) {
    if (points.length < 2) return const ShapeObject();
    return ShapeObject(
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
      'ty': 'l',
      'col': color.value,
      'pts': points.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
    };
  }
}
