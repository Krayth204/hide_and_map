import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'overpass_polygon_builder.dart';

enum MapOverlayType { borderInter, border1AD, border2AD, border3AD, border4AD }

class MapOverlay {
  final String id;
  final String name;
  final String? nameEn;
  final List<BuiltPolygon> boundaryPolygons;
  final MapOverlayType type;

  MapOverlay({
    required this.id,
    required this.name,
    this.nameEn,
    required this.boundaryPolygons,
    required this.type,
  });

  factory MapOverlay.fromOverpassElement(MapOverlayType type, Map<String, dynamic> e) {
    final id = e['id'].toString();
    final tags = (e['tags'] as Map?)?.cast<String, String>();
    final name = tags?['name'] ?? 'Unnamed Overlay';
    final nameEn = tags?['name:en'];

    final built = OverpassPolygonBuilder.buildPolygons(e);

    return MapOverlay(
      id: id,
      name: name,
      nameEn: nameEn,
      boundaryPolygons: built,
      type: type,
    );
  }

  List<Polygon> toPolygons(Function(MapOverlay) onOverlayTap) {
    int index = 0;
    return boundaryPolygons.map((b) {
      return Polygon(
        polygonId: PolygonId('${type.name}_${id}_${index++}'),
        points: b.outer,
        holes: b.holes,
        strokeWidth: 3,
        strokeColor: Colors.brown.shade700,
        fillColor: Colors.brown.withAlpha(50),
        consumeTapEvents: true,
        onTap: () => onOverlayTap(this),
      );
    }).toList();
  }

  @override
  String toString() =>
      'MapOverlay(name: $name, type: ${type.name}, points: ${boundaryPolygons.length})';

  double toleranceMeters() {
    return switch (type) {
      MapOverlayType.borderInter => 50,
      MapOverlayType.border1AD => 50,
      MapOverlayType.border2AD => 20,
      MapOverlayType.border3AD => 10,
      MapOverlayType.border4AD => 5,
    };
  }
}
