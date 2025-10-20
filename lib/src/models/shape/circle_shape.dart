import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../util/color_helper.dart';
import '../../util/geo_math.dart';
import '../play_area/play_area.dart';
import 'shape.dart';
import 'shape_object.dart';

class CircleShape implements Shape {
  @override
  final String id;

  @override
  final ShapeType type = ShapeType.circle;

  @override
  MaterialColor color;

  @override
  bool inverted;

  LatLng center;
  double radius;

  CircleShape(this.id, this.center, {this.color = Colors.blue, this.radius = 500, this.inverted = false});

  @override
  void addPoint(LatLng p) {
    center = p;
  }

  @override
  void undo() {
    // not in use
  }

  @override
  void reset() {
    // not in use
  }

  @override
  void setRadius(double r) {
    radius = r;
  }

  @override
  bool canConfirm() {
    return true;
  }

  @override
  double getDistance() {
    return radius;
  }

  @override
  ShapeObject toShapeObject(
    PlayArea playArea, {
    bool editable = false,
    void Function(String id)? onTap,
    String? customId,
  }) {
    if (inverted) {
      return ShapeObject(
        polygon: Polygon(
          polygonId: PolygonId(customId ?? id),
          points: playArea.getBoundary(),
          holes: [GeoMath.pointsOfCircle(center, radius)],
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
          circleId: CircleId(customId ?? id),
          center: center,
          radius: radius,
          strokeColor: color.shade700,
          strokeWidth: 2,
          fillColor: color.withAlpha(115),
          consumeTapEvents: editable,
          onTap: () => editable ? onTap?.call(id) : null,
        ),
      );
    }
  }

  @override
  Set<Marker> getMarkers(Function notify) {
    return {
      Marker(
        markerId: const MarkerId('preview_add_circle_center'),
        position: center,
        draggable: true,
        onDragEnd: (p) {
          center = p;
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
      'ty': 'c',
      'col': color.value,
      'sce': {'lat': center.latitude, 'lng': center.longitude},
      'sra': radius,
      'i': inverted ? 't' : 'f',
    };
  }
}
