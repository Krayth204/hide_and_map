import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../play_area/play_area.dart';
import 'shape.dart';
import 'shape_object.dart';
import 'serializable_polygon.dart';

class MultiPolygonShape extends Shape {
  @override
  final String id;

  @override
  final ShapeType type = ShapeType.multiPolygon;

  String name;
  List<SerializablePolygon> polygons;

  MultiPolygonShape(
    this.id,
    this.polygons, {
    this.name = 'MultiPolygon',
    super.color,
    super.inverted,
  });

  @override
  void addPoint(LatLng p) {
    // not in use
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
    // not applicable
  }

  @override
  bool canConfirm() {
    return true;
  }

  @override
  String getDistance() {
    return "0";
  }

  @override
  ShapeObject toShapeObject(
    PlayArea playArea, {
    bool editable = false,
    void Function(String id)? onTap,
    String? customId,
  }) {
    final googlePolygons = <Polygon>[];

    if (!inverted) {
      for (int i = 0; i < polygons.length; i++) {
        final poly = polygons[i];
        if (!poly.isValid) continue;

        googlePolygons.add(
          Polygon(
            polygonId: PolygonId('${customId ?? id}_$i'),
            points: poly.outer,
            holes: poly.holes,
            strokeColor: color.shade700,
            strokeWidth: 2,
            fillColor: color.withAlpha(115),
            consumeTapEvents: editable,
            onTap: () => editable ? onTap?.call(id) : null,
          ),
        );
      }
    } else {
      final outerHoles = <List<LatLng>>[];
      for (int i = 0; i < polygons.length; i++) {
        final poly = polygons[i];
        if (!poly.isValid) continue;
        outerHoles.add(poly.outer);

        for (int j = 0; j < poly.holes.length; j++) {
          final hole = poly.holes[j];
          googlePolygons.add(
            Polygon(
              polygonId: PolygonId('${customId ?? id}_${i}_$j'),
              points: hole,
              strokeColor: color.shade700,
              strokeWidth: 2,
              fillColor: color.withAlpha(115),
              consumeTapEvents: editable,
              onTap: () => editable ? onTap?.call(id) : null,
            ),
          );
        }
      }
      googlePolygons.add(
          Polygon(
            polygonId: PolygonId('${customId ?? id}_0'),
            points: playArea.getBoundary(),
            holes: outerHoles,
            strokeColor: color.shade700,
            strokeWidth: 2,
            fillColor: color.withAlpha(115),
            consumeTapEvents: editable,
            onTap: () => editable ? onTap?.call(id) : null,
          ),
        );
    }

    if (googlePolygons.isEmpty) return const ShapeObject();

    return ShapeObject(polygons: googlePolygons);
  }

  @override
  Set<Marker> getMarkers(Function notify) {
    return const {};
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ty': 'mu',
      'col': color.toARGB32(),
      'na': name,
      'pgs': polygons.map((p) => p.toJson()).toList(),
      'i': inverted ? 't' : 'f',
    };
  }
}
