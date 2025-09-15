import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddPolygonController extends ChangeNotifier {
  List<LatLng> points = [];
  bool edit = false;

  void onMapTap(LatLng p) {
    points.add(p);
    notifyListeners();
  }

  void undo() {
    if (points.isNotEmpty) {
      points.removeLast();
      notifyListeners();
    }
  }

  void reset() {
    points.clear();
    notifyListeners();
  }

  Set<Polygon> getPreviewPolygons() {
    if (points.length < 3) return {};
    return {
      Polygon(
        polygonId: const PolygonId('preview_add_polygon'),
        points: List.from(points),
        strokeColor: Colors.blue.shade900,
        strokeWidth: 2,
        fillColor: Colors.blue.withAlpha(115), // 45%
      )
    };
  }

  Set<Marker> getMarkers() {
    return {
      for (int i = 0; i < points.length; i++)
        Marker(
          markerId: MarkerId('add_polygon_point_$i'),
          position: points[i],
          draggable: true,
          onDragEnd: (p) {
            points[i] = p;
            notifyListeners();
          },
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        )
    };
  }
}
