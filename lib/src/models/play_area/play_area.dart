import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Abstract play area base class
abstract class PlayArea {
  /// Returns a list of LatLng points that form the *outer boundary* of the area
  List<LatLng> getBoundary();

  /// Returns the center of the play area
  LatLng getCenter();

  /// Build overlay polygons with translucent map cover and hole
  /// Returns a set of polygons ready to pass into GoogleMap.polygons
  static Set<Polygon> buildOverlay(PlayArea? playArea) {
    if (playArea == null) return {};

    final boundary = playArea.getBoundary();
    if (boundary.length < 3) return {};

    final outerEast = <LatLng>[
      const LatLng(-89, 0),
      const LatLng(89, 0),
      const LatLng(89, 179.999),
      const LatLng(-89, 179.999),
    ];
    final outerWest = <LatLng>[
      const LatLng(-89.9, 0),
      const LatLng(89.9, 0),
      const LatLng(89.9, -179.999),
      const LatLng(-89.9, -179.999),
    ];

    final List<List<LatLng>> holeEast = [];
    final List<List<LatLng>> holeWest = [];

    List<LatLng> current = [];
    bool? currentEast;

    LatLng first = boundary.first;
    LatLng prev = first;
    currentEast = prev.longitude >= 0;
    current.add(prev);

    for (int i = 1; i <= boundary.length; i++) {
      final LatLng curr = (i == boundary.length) ? first : boundary[i];
      final bool currIsEast = curr.longitude >= 0;
      if (currIsEast == currentEast) {
        current.add(curr);
      } else {
        // crossing longitude=0 → interpolate
        final double t =
            (0 - prev.longitude) / (curr.longitude - prev.longitude);
        final double latAtZero =
            prev.latitude + t * (curr.latitude - prev.latitude);
        final LatLng cross = LatLng(latAtZero, 0);

        current.add(cross);
        if (currentEast == true) {
          holeEast.add(List.from(current));
        } else {
          holeWest.add(List.from(current));
        }

        // start new
        current = [cross, curr];
        currentEast = currIsEast;
      }
      prev = curr;
    }

    if (current.length >= 3) {
      if (currentEast == true) {
        holeEast.add(current);
      } else {
        holeWest.add(current);
      }
    }

    return {
      Polygon(
        polygonId: const PolygonId('overlay_east'),
        points: outerEast,
        holes: holeEast,
        fillColor: Colors.black.withAlpha(128), // 50%,
        strokeColor: Colors.transparent,
      ),
      Polygon(
        polygonId: const PolygonId('overlay_west'),
        points: outerWest,
        holes: holeWest,
        fillColor: Colors.black.withAlpha(128), // 50%,
        strokeColor: Colors.transparent,
      ),
    };
  }
}
