import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hide_and_map/src/util/geo_math.dart';
import '../util/color_helper.dart';
import 'extra_shape.dart';
import 'play_area/play_area.dart';

class ShapeController extends ChangeNotifier {
  final ShapeType type;
  bool edit = false;
  bool inverted = false;
  MaterialColor color = Colors.blue;

  LatLng? center;
  double radius = 500;
  List<LatLng> points = [];

  ShapeController(this.type);

  void onMapTap(LatLng p) {
    switch (type) {
      case ShapeType.circle:
        center = p;
        break;
      case ShapeType.line:
      case ShapeType.polygon:
        points.add(p);
        break;
    }
    notifyListeners();
  }

  void undo() {
    if (type == ShapeType.line || type == ShapeType.polygon) {
      if (points.isNotEmpty) points.removeLast();
      notifyListeners();
    }
  }

  void reset() {
    switch (type) {
      case ShapeType.circle:
        center = null;
        radius = 500;
        break;
      case ShapeType.line:
      case ShapeType.polygon:
        points.clear();
        break;
    }
    notifyListeners();
  }

  void setInverted(bool i) {
    inverted = i;
    notifyListeners();
  }

  void setColor(MaterialColor c) {
    color = c;
    notifyListeners();
  }

  void setRadius(double r) {
    if (type == ShapeType.circle) {
      radius = r;
      notifyListeners();
    }
  }

  PreviewShapes getPreviewShapes() {
    switch (type) {
      case ShapeType.circle:
        if (center == null) return const PreviewShapes();
        return PreviewShapes(
          circles: inverted
              ? const {}
              : {
                  Circle(
                    circleId: const CircleId('preview_add_circle'),
                    center: center!,
                    radius: radius,
                    strokeColor: color.shade900,
                    strokeWidth: 2,
                    fillColor: color.withAlpha(115),
                  ),
                },
          polygons: inverted
              ? {
                  Polygon(
                    polygonId: const PolygonId('preview_inverted_circle'),
                    points: PlayArea.playArea!.getBoundary(),
                    holes: [(GeoMath.pointsOfCircle(center!, radius))],
                    strokeColor: color.shade900,
                    strokeWidth: 2,
                    fillColor: color.withAlpha(115),
                  ),
                }
              : const {},
        );

      case ShapeType.line:
        if (points.length < 2) return const PreviewShapes();
        return PreviewShapes(
          polylines: {
            Polyline(
              polylineId: const PolylineId('preview_add_line'),
              points: points,
              color: color.shade900,
              width: 4,
            ),
          },
        );

      case ShapeType.polygon:
        if (points.length < 3) return const PreviewShapes();
        return PreviewShapes(
          polygons: {
            inverted
                ? Polygon(
                    polygonId: const PolygonId('preview_inverted_polygon'),
                    points: PlayArea.playArea!.getBoundary(),
                    holes: [List<LatLng>.from(points)],
                    strokeColor: color.shade900,
                    strokeWidth: 2,
                    fillColor: color.withAlpha(115),
                  )
                : Polygon(
                    polygonId: const PolygonId('preview_add_polygon'),
                    points: points,
                    strokeColor: color.shade900,
                    strokeWidth: 2,
                    fillColor: color.withAlpha(115),
                  ),
          },
        );
    }
  }

  Set<Marker> getMarkers() {
    switch (type) {
      case ShapeType.circle:
        if (center == null) return {};
        return {
          Marker(
            markerId: const MarkerId('preview_add_circle_center'),
            position: center!,
            draggable: true,
            onDragEnd: (p) {
              center = p;
              notifyListeners();
            },
            icon: ColorHelper.hueFromMaterialColor(color),
          ),
        };
      case ShapeType.line:
      case ShapeType.polygon:
        return {
          for (int i = 0; i < points.length; i++)
            Marker(
              markerId: MarkerId('add_point_$i'),
              position: points[i],
              draggable: true,
              onDragEnd: (p) {
                points[i] = p;
                notifyListeners();
              },
              icon: ColorHelper.hueFromMaterialColor(color),
            ),
        };
    }
  }

  ExtraShape? buildShape(String id) {
    switch (type) {
      case ShapeType.circle:
        if (center == null) return null;
        return ExtraShape.circle(id, color, center!, radius, inverted);
      case ShapeType.line:
        if (points.length < 2) return null;
        return ExtraShape.line(id, color, List.from(points));
      case ShapeType.polygon:
        if (points.length < 3) return null;
        return ExtraShape.polygon(id, color, List.from(points), inverted);
    }
  }
}

class PreviewShapes {
  final Set<Circle> circles;
  final Set<Polyline> polylines;
  final Set<Polygon> polygons;

  const PreviewShapes({
    this.circles = const {},
    this.polylines = const {},
    this.polygons = const {},
  });
}
