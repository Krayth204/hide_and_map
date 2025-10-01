import 'dart:math' as math;
import 'dart:math';
import 'dart:ui';

import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class GeoMath {
  static const double _earthRadius = 6371000;

  /// Returns distance between [a] and [b] in metres
  static double distanceInMeters(LatLng a, LatLng b) {
    final lat1 = _degToRad(a.latitude);
    final lon1 = _degToRad(a.longitude);
    final lat2 = _degToRad(b.latitude);
    final lon2 = _degToRad(b.longitude);

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final hav = pow(sin(dLat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dLon / 2), 2);

    final c = 2 * atan2(sqrt(hav), sqrt(1 - hav));
    return _earthRadius * c;
  }

  static double _degToRad(double deg) => deg * pi / 180.0;

  static List<LatLng> pointsOfCircle(LatLng center, double radiusMeters) {
    final points = <LatLng>[];
    const steps = 64;
    for (var i = 0; i < steps; i++) {
      final theta = (i / steps) * (2 * math.pi);
      final latOffset = radiusMeters / 111320.0 * math.cos(theta);
      final lngOffset =
          radiusMeters /
          (111320.0 * math.cos(center.latitude * math.pi / 180)) *
          math.sin(theta);
      points.add(LatLng(center.latitude + latOffset, center.longitude + lngOffset));
    }
    return points;
  }

  static LatLng midpoint(LatLng a, LatLng b) {
    return LatLng((a.latitude + b.latitude) / 2, (a.longitude + b.longitude) / 2);
  }

  /// Project LatLng into locally Euclidean coordinates with longitude scaling
  static Offset project(LatLng p, double latRef) {
    final cosLat = math.cos(_degToRad(latRef));
    return Offset(p.longitude * cosLat, p.latitude);
  }

  /// Undo projection
  static LatLng unproject(Offset pt, double latRef) {
    final cosLat = math.cos(_degToRad(latRef));
    return LatLng(pt.dy, pt.dx / cosLat);
  }

  /// Perpendicular vector (already in projected space)
  static Offset perpendicular(Offset v) {
    return Offset(-v.dy, v.dx);
  }

  /// Returns positive/negative classification of a point, corrected with projection
  static double signedDistanceFromLine(
    LatLng p,
    LatLng linePoint,
    Offset perp,
    double latRef,
  ) {
    final pp = project(p, latRef);
    final lp = project(linePoint, latRef);
    final rel = pp - lp;
    return rel.dx * perp.dy - rel.dy * perp.dx;
  }

  /// Classify boundary points
  static List<LatLng> sideOfLine(
    List<LatLng> boundary,
    LatLng mid,
    Offset perp,
    double latRef,
    bool inverted,
  ) {
    final kept = <LatLng>[];
    for (final pt in boundary) {
      final side = signedDistanceFromLine(pt, mid, perp, latRef);
      if ((side >= 0) ^ inverted) {
        kept.add(pt);
      }
    }
    return kept;
  }

  /// Builds a polygon that "cuts" the play area along a perpendicular line
  static List<LatLng> buildCutPolygon(
    List<LatLng> boundary,
    LatLng mid,
    Offset perp,
    double latRef,
    List<LatLng> classified,
  ) {
    if (boundary.isEmpty || classified.isEmpty) return [];

    final projectedBoundary = boundary.map((p) => project(p, latRef)).toList();
    final midProj = project(mid, latRef);

    List<LatLng> polygonPoints = [];
    Offset? firstIntersection;
    bool firstClassified = classified.contains(boundary[0]);

    int len = projectedBoundary.length;

    for (int i = 0; i < len; i++) {
      final cur = projectedBoundary[i];
      final next = projectedBoundary[(i + 1) % len];

      final curLatLng = boundary[i];
      final nextLatLng = boundary[(i + 1) % len];

      bool curClassified = classified.contains(curLatLng);
      bool nextClassified = classified.contains(nextLatLng);

      // Add current point if it's on the side we want to keep
      if (curClassified) {
        polygonPoints.add(curLatLng);
      }

      // If crossing from classified → unclassified or vice versa
      if (curClassified != nextClassified) {
        var intersection = _lineIntersectSegment(midProj, perp, cur, next);
        if (intersection != null) {
          if (firstIntersection == null) {
            // first crossing: store it
            firstIntersection = intersection;
          } else {
            if (firstClassified) {
              //swap firstIntersection and intersection
              var temp = firstIntersection;
              firstIntersection = intersection;
              intersection = temp;
            }
            // add second intersection
            polygonPoints.add(unproject(intersection, latRef));

            // second crossing: add interpolated points + mid + intersections
            const numSteps = 3;

            // interpolate intersection → mid
            for (int s = 1; s <= numSteps; s++) {
              final t = s / (numSteps + 1);
              final interp = Offset.lerp(intersection, midProj, t)!;
              polygonPoints.add(unproject(interp, latRef));
            }

            // add midpoint
            polygonPoints.add(mid);

            // interpolate mid → firstIntersection
            for (int s = 1; s <= numSteps; s++) {
              final t = s / (numSteps + 1);
              final interp = Offset.lerp(midProj, firstIntersection, t)!;
              polygonPoints.add(unproject(interp, latRef));
            }

            polygonPoints.add(unproject(firstIntersection, latRef));
            firstIntersection = null; // reset for potential next segment
          }
        }
      }
    }

    return polygonPoints;
  }

  /// Intersection of infinite line (point + direction) with segment [a, b] in projected space
  static Offset? _lineIntersectSegment(
    Offset linePoint,
    Offset lineDir,
    Offset a,
    Offset b,
  ) {
    final r = lineDir;
    final s = b - a;

    final rxs = r.dx * s.dy - r.dy * s.dx;
    if (rxs.abs() < 1e-10) return null; // parallel

    final t = ((a.dx - linePoint.dx) * r.dy - (a.dy - linePoint.dy) * r.dx) / rxs;

    if (t < 0 || t > 1) return null; // intersection outside segment

    return a + s * t; // intersection point
  }
}
