import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../circle_controller.dart';
import '../play_area/play_area.dart';
import 'circle_shape.dart';
import 'shape.dart';
import 'shape_object.dart';

class ShapeController extends ChangeNotifier implements CircleController {
  bool edit;
  Shape shape;

  ShapeController(this.shape, {this.edit = false});

  void onMapTap(LatLng p) {
    shape.addPoint(_roundLatLng(p));
    notifyListeners();
  }

  void undo() {
    shape.undo();
    notifyListeners();
  }

  void reset() {
    shape.reset();
    notifyListeners();
  }

  void setInverted(bool i) {
    shape.inverted = i;
    notifyListeners();
  }

  void setColor(MaterialColor c) {
    shape.color = c;
    notifyListeners();
  }

  @override
  void setRadius(double r) {
    shape.setRadius(r);
    notifyListeners();
  }

  @override
  double getRadius() {
    if (shape is CircleShape) return (shape as CircleShape).radius;
    return 0;
  }

  ShapeObject getPreviewShapeObject(PlayArea playArea) {
    return shape.toShapeObject(playArea, editable: false, onTap: null, customId: 'previewObject');
  }

  Set<Marker> getMarkers() {
    return shape.getMarkers(() => notifyListeners());
  }

  LatLng _roundLatLng(LatLng p) {
    double round(double v) => double.parse(v.toStringAsFixed(5));
    return LatLng(round(p.latitude), round(p.longitude));
  }
}
