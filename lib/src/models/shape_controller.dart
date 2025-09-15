import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../util/color_helper.dart';
import 'extra_shape.dart';

class ShapeController extends ChangeNotifier {
  final ShapeType type;
  bool edit = false;
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

  Set<Circle> getPreviewCircles() {
    if (type != ShapeType.circle || center == null) return {};
    return {
      Circle(
        circleId: const CircleId('preview_add_circle'),
        center: center!,
        radius: radius,
        strokeColor: color.shade900,
        strokeWidth: 2,
        fillColor: color.withAlpha(115),
      ),
    };
  }

  Set<Polyline> getPreviewPolylines() {
    if (type != ShapeType.line || points.length < 2) return {};
    return {
      Polyline(
        polylineId: const PolylineId('preview_add_line'),
        points: List.from(points),
        color: color.shade900,
        width: 4,
      ),
    };
  }

  Set<Polygon> getPreviewPolygons() {
    if (type != ShapeType.polygon || points.length < 3) return {};
    return {
      Polygon(
        polygonId: const PolygonId('preview_add_polygon'),
        points: List.from(points),
        strokeColor: color.shade900,
        strokeWidth: 2,
        fillColor: color.withAlpha(115),
      ),
    };
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
        return ExtraShape.circle(id, color, center!, radius);
      case ShapeType.line:
        if (points.length < 2) return null;
        return ExtraShape.line(id, color, List.from(points));
      case ShapeType.polygon:
        if (points.length < 3) return null;
        return ExtraShape.polygon(id, color, List.from(points));
    }
  }
}
