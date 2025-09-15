import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'circle_play_area.dart';
import 'play_area.dart';
import 'polygon_play_area.dart';

enum SelectionMode { circle, polygon }

class PlayAreaSelectorController extends ChangeNotifier {
  SelectionMode mode = SelectionMode.circle;

  // Circle state
  LatLng? circleCenter;
  double circleRadius = 5000; // meters

  // Polygon state
  final List<LatLng> polygonPoints = [];

  // Map objects for live preview
  Set<Polygon> getPolygons() {
    if (mode == SelectionMode.polygon && polygonPoints.length >= 2) {
      return {
        Polygon(
          polygonId: const PolygonId('temp_polygon'),
          points: polygonPoints,
          strokeColor: Colors.green,
          strokeWidth: 2,
          fillColor: Colors.green.withOpacity(0.2),
        ),
      };
    }
    return {};
  }

  Set<Circle> getCircles() {
    if (mode == SelectionMode.circle && circleCenter != null) {
      return {
        Circle(
          circleId: const CircleId('temp_circle'),
          center: circleCenter!,
          radius: circleRadius,
          strokeColor: Colors.blue,
          strokeWidth: 2,
          fillColor: Colors.blue.withOpacity(0.2),
        ),
      };
    }
    return {};
  }

  Set<Marker> getMarkers() {
    if (mode == SelectionMode.circle && circleCenter != null) {
      return {
        Marker(
          markerId: const MarkerId('circle_center'),
          position: circleCenter!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          draggable: true,
          onDragEnd: (newPos) {
            circleCenter = newPos;
            notifyListeners();
          },
        ),
      };
    } else if (mode == SelectionMode.polygon) {
      return {
        for (int i = 0; i < polygonPoints.length; i++)
          Marker(
            markerId: MarkerId('polygon_point_$i'),
            position: polygonPoints[i],
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
            draggable: true,
            onDragEnd: (newPos) {
              polygonPoints[i] = newPos;
              notifyListeners();
            },
          ),
      };
    }
    return {};
  }

  void setMode(SelectionMode newMode) {
    mode = newMode;
    notifyListeners();
  }

  void setRadius(double radius) {
    circleRadius = radius;
    notifyListeners();
  }

  void onMapTap(LatLng point) {
    if (mode == SelectionMode.circle) {
      circleCenter = point;
    } else {
      polygonPoints.add(point);
    }
    notifyListeners();
  }

  void undoPolygon() {
    if (polygonPoints.isNotEmpty) {
      polygonPoints.removeLast();
      notifyListeners();
    }
  }

  void resetPolygon() {
    polygonPoints.clear();
    notifyListeners();
  }

  PlayArea? confirm() {
    if (mode == SelectionMode.circle && circleCenter != null) {
      return CirclePlayArea(circleCenter!, circleRadius);
    } else if (mode == SelectionMode.polygon && polygonPoints.length >= 3) {
      return PolygonPlayArea(List.from(polygonPoints));
    }
    return null;
  }
}
