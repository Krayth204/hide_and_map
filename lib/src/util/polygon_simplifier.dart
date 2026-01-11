import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PolygonSimplifier {
  static List<LatLng> simplify(List<LatLng> polygon, {required double toleranceMeters}) {
    if (polygon.length < 4) return polygon;

    final closed = _isClosed(polygon) ? polygon : [...polygon, polygon.first];

    final projected = closed.map(_project).toList();
    final simplified = _rdp(projected, toleranceMeters);

    return simplified.map((p) => _roundLatLng(p.original)).toList();
  }

  static bool _isClosed(List<LatLng> pts) {
    final a = pts.first;
    final b = pts.last;
    return (a.latitude - b.latitude).abs() < 1e-6 &&
        (a.longitude - b.longitude).abs() < 1e-6;
  }

  static List<_ProjectedPoint> _rdp(List<_ProjectedPoint> pts, double epsilon) {
    if (pts.length < 3) return pts;

    double maxDist = 0;
    int index = 0;

    final start = pts.first;
    final end = pts.last;

    for (int i = 1; i < pts.length - 1; i++) {
      final d = _perpendicularDistance(pts[i], start, end);
      if (d > maxDist) {
        maxDist = d;
        index = i;
      }
    }

    if (maxDist > epsilon) {
      final left = _rdp(pts.sublist(0, index + 1), epsilon);
      final right = _rdp(pts.sublist(index), epsilon);

      return [...left.sublist(0, left.length - 1), ...right];
    }

    return [start, end];
  }

  static double _perpendicularDistance(
    _ProjectedPoint p,
    _ProjectedPoint a,
    _ProjectedPoint b,
  ) {
    final dx = b.x - a.x;
    final dy = b.y - a.y;

    if (dx == 0 && dy == 0) {
      return sqrt((p.x - a.x) * (p.x - a.x) + (p.y - a.y) * (p.y - a.y));
    }

    final t = ((p.x - a.x) * dx + (p.y - a.y) * dy) / (dx * dx + dy * dy);

    final projX = a.x + t * dx;
    final projY = a.y + t * dy;

    return sqrt((p.x - projX) * (p.x - projX) + (p.y - projY) * (p.y - projY));
  }

  static _ProjectedPoint _project(LatLng p) {
    const earthRadius = 6378137.0;
    const originShift = 2 * pi * earthRadius / 2;

    final x = p.longitude * originShift / 180.0;
    final y = log(tan((90 + p.latitude) * pi / 360.0)) / (pi / 180.0);

    return _ProjectedPoint(x, y * originShift / 180.0, p);
  }

  static LatLng _roundLatLng(LatLng p) {
    double r(double v) => double.parse(v.toStringAsFixed(5));
    return LatLng(r(p.latitude), r(p.longitude));
  }
}

class _ProjectedPoint {
  final double x;
  final double y;
  final LatLng original;

  _ProjectedPoint(this.x, this.y, this.original);
}
