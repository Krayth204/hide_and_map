import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'circle_play_area.dart';
import 'polygon_play_area.dart';

/// Abstract play area base class
abstract class PlayArea {
  /// Returns a list of LatLng points that form the *outer boundary* of the area
  List<LatLng> getBoundary();

  /// Returns the center of the play area
  LatLng getCenter();

  Map<String, dynamic> toJson();

  /// Deserialize a PlayArea from JSON
  static PlayArea fromJson(Map<String, dynamic> json) {
    switch (json['t']) {
      case 'c':
        return CirclePlayArea(
          LatLng(json['cen']['lat'], json['cen']['lng']),
          double.parse(json['rad'].toString()),
        );
      case 'pg':
        final vertices = (json['ver'] as List)
            .map((v) => LatLng(v['lat'], v['lng']))
            .toList();
        return PolygonPlayArea(vertices);
      default:
        throw ArgumentError('Unknown PlayArea type: ${json['t']}');
    }
  }

  /// Build overlay polygons with translucent map cover and hole
  /// Returns a set of polygons ready to pass into GoogleMap.polygons
  static Set<Polygon> buildOverlay(PlayArea? playArea) {
    if (playArea == null) return {};

    final boundary = playArea.getBoundary();
    if (boundary.length < 3) return {};

    final outerEast = <LatLng>[
      const LatLng(-89, 0),
      const LatLng(89, 0),
      const LatLng(89, 179.99999),
      const LatLng(-89, 179.99999),
    ];
    final outerWest = <LatLng>[
      const LatLng(-89.9, 0),
      const LatLng(89.9, 0),
      const LatLng(89.9, -179.99999),
      const LatLng(-89.9, -179.99999),
    ];

    final holeEast = <LatLng>[];
    final holeWest = <LatLng>[];

    LatLng first = boundary.first;
    LatLng prev = first;
    bool prevEast = prev.longitude >= 0;

    for (int i = 1; i <= boundary.length; i++) {
      final LatLng curr = (i == boundary.length) ? first : boundary[i];
      final bool currEast = curr.longitude >= 0;

      if (prevEast) {
        holeEast.add(prev);
      } else {
        holeWest.add(prev);
      }

      if (currEast != prevEast) {
        // Check for crossing at lng=0
        if ((prev.longitude < 0 && prev.longitude >= -90 && curr.longitude >= 0) ||
            (prev.longitude < 0 && curr.longitude >= 0 && curr.longitude < 90) ||
            (prev.longitude >= 0 && prev.longitude < 90 && curr.longitude < 0) ||
            (prev.longitude >= 0 && curr.longitude < 0 && curr.longitude >= -90)) {
          final cross = _interpolateCrossing(prev, curr, 0);
          holeEast.add(cross);
          holeWest.add(cross);
        }

        // Check for crossing at lng=±180
        else if ((prev.longitude < 180 && prev.longitude >= 90 && curr.longitude >= -180) ||
            (prev.longitude < 180 && curr.longitude >= -180 && curr.longitude < -90) ||
            (prev.longitude >= -180 && prev.longitude < -90 && curr.longitude < 180) ||
            (prev.longitude >= -180 && curr.longitude < 180 && curr.longitude >= 90)) {
          final cross = _interpolateCrossing(prev, curr, -180);
          holeEast.add(LatLng(cross.latitude, 179.99999));
          holeWest.add(cross);
        }
      }

      prev = curr;
      prevEast = currEast;
    }

    return {
      Polygon(
        polygonId: const PolygonId('overlay_east'),
        points: outerEast,
        holes: [holeEast],
        fillColor: Colors.black.withAlpha(128), // 50%,
        strokeColor: Colors.transparent,
      ),
      Polygon(
        polygonId: const PolygonId('overlay_west'),
        points: outerWest,
        holes: [holeWest],
        fillColor: Colors.black.withAlpha(128), // 50%,
        strokeColor: Colors.transparent,
      ),
    };
  }

  /// Linear interpolation for latitude at a crossing longitude
  static LatLng _interpolateCrossing(LatLng a, LatLng b, double lngTarget) {
    final double t = (lngTarget - a.longitude) / (b.longitude - a.longitude);
    final double lat = a.latitude + t * (b.latitude - a.latitude);
    return LatLng(lat, lngTarget);
  }
}
