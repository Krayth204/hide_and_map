import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddCircleController extends ChangeNotifier {
  LatLng? center;
  double radius = 500; // default meters
  bool edit = false;

  void onMapTap(LatLng p) {
    center = p;
    notifyListeners();
  }

  void setRadius(double r) {
    radius = r;
    notifyListeners();
  }

  Set<Circle> getPreviewCircles() {
    if (center == null) return {};
    return {
      Circle(
        circleId: const CircleId('preview_add_circle'),
        center: center!,
        radius: radius,
        strokeColor: Colors.blue.shade900,
        strokeWidth: 2,
        fillColor: Colors.blue.withAlpha(115), // 45%
      )
    };
  }

  Set<Marker> getMarkers() {
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
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      )
    };
  }
}
