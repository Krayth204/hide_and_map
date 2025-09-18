import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../util/color_helper.dart';
import '../play_area/play_area.dart';
import 'shape.dart';
import 'shape_object.dart';

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

  ShapeObject getPreviewShapeObject(PlayArea playArea) {
    final previewShape = Shape(
      'preview_${type.name}',
      type,
      color,
      center: center,
      radius: radius,
      points: points.isNotEmpty ? List<LatLng>.from(points) : null,
      inverted: inverted,
    );

    return previewShape.toShapeObject(playArea, editable: false, onTap: null);
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

  Shape? buildShape(String id) {
    LatLng roundLatLng(LatLng p) {
      double round(double v) => double.parse(v.toStringAsFixed(5));
      return LatLng(round(p.latitude), round(p.longitude));
    }

    switch (type) {
      case ShapeType.circle:
        if (center == null) return null;
        return Shape.circle(id, color, roundLatLng(center!), radius, inverted: inverted);

      case ShapeType.line:
        if (points.length < 2) return null;
        return Shape.line(id, color, points.map(roundLatLng).toList());

      case ShapeType.polygon:
        if (points.length < 3) return null;
        return Shape.polygon(
          id,
          color,
          points.map(roundLatLng).toList(),
          inverted: inverted,
        );
    }
  }
}
