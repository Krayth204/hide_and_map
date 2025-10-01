import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../util/color_helper.dart';
import '../play_area/play_area.dart';
import 'shape.dart';
import 'shape_object.dart';

class PolygonShape implements Shape {
  @override
  final String id;

  @override
  final ShapeType type = ShapeType.polygon;

  @override
  MaterialColor color;
  
  @override
  bool inverted;

  final List<LatLng> points;

  PolygonShape(this.id, this.points, {this.color= Colors.blue, this.inverted = false});
  
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
    return points.length >= 3;
  }

  @override
  ShapeObject toShapeObject(
    PlayArea playArea, {
    bool editable = false,
    void Function(String id)? onTap,
    String? customId,
  }) {
    if (points.length < 3) return const ShapeObject();
    return ShapeObject(
      polygon: Polygon(
        polygonId: PolygonId(customId ?? id),
        points: inverted ? playArea.getBoundary() : List<LatLng>.from(points),
        holes: inverted ? [points] : const [],
        strokeColor: color.shade700,
        strokeWidth: 2,
        fillColor: color.withAlpha(115),
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
      'ty': 'p',
      'col': color.value,
      'pts': points.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      'i': inverted ? 't' : 'f',
    };
  }
}
