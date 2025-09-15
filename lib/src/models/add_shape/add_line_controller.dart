import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddLineController extends ChangeNotifier {
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

  Set<Polyline> getPreviewPolylines() {
    if (points.length < 2) return {};
    return {
      Polyline(
        polylineId: const PolylineId('preview_add_line'),
        points: List.from(points),
        color: Colors.blue.shade900,
        width: 4,
      )
    };
  }

  Set<Marker> getMarkers() {
    return {
      for (int i = 0; i < points.length; i++)
        Marker(
          markerId: MarkerId('add_line_point_$i'),
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
