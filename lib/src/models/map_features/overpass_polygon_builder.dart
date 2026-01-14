import 'package:google_maps_flutter/google_maps_flutter.dart';

class _WaySegment {
  final List<LatLng> points;

  _WaySegment(this.points);

  LatLng get start => points.first;
  LatLng get end => points.last;
}

class BuiltPolygon {
  final List<LatLng> outer;
  final List<List<LatLng>> holes;

  BuiltPolygon({required this.outer, required this.holes});
}

class OverpassPolygonBuilder {
  static List<BuiltPolygon> buildPolygons(Map<String, dynamic> e) {
    if (e['type'] != 'relation') {
      final geometry = (e['geometry'] as List?)
          ?.map((p) => LatLng(p['lat'], p['lon']))
          .toList();

      if (geometry == null || geometry.isEmpty) {
        throw ArgumentError('Invalid element: missing geometry');
      }

      return [BuiltPolygon(outer: _ensureClosedAndClockwise(geometry), holes: const [])];
    }

    final members = (e['members'] as List?) ?? [];

    final outerSegments = <_WaySegment>[];
    final innerSegments = <_WaySegment>[];

    for (final m in members) {
      final role = m['role'];
      final geometry = m['geometry'];

      if (geometry == null) continue;

      final pts = (geometry as List).map((p) => LatLng(p['lat'], p['lon'])).toList();

      if (pts.length < 2) continue;

      if (role == 'outer') {
        outerSegments.add(_WaySegment(pts));
      } else if (role == 'inner') {
        innerSegments.add(_WaySegment(pts));
      }
    }

    if (outerSegments.isEmpty) {
      throw ArgumentError('Relation has no outer geometries');
    }

    final outers = _buildRings(outerSegments);
    final inners = _buildRings(innerSegments);

    final result = <BuiltPolygon>[];

    for (final outer in outers) {
      final holes = <List<LatLng>>[];

      for (final inner in inners) {
        if (_isRingInside(inner, outer)) {
          holes.add(inner);
        }
      }

      result.add(BuiltPolygon(outer: outer, holes: holes));
    }

    return result;
  }

  static List<List<LatLng>> _buildRings(List<_WaySegment> segments) {
    final remaining = List<_WaySegment>.from(segments);
    final rings = <List<LatLng>>[];

    while (remaining.isNotEmpty) {
      final stitched = _stitchSingleRing(remaining);
      rings.add(_ensureClosedAndClockwise(stitched));
    }

    return rings;
  }

  static List<LatLng> _stitchSingleRing(List<_WaySegment> remaining) {
    final result = <LatLng>[];
    final first = remaining.removeAt(0);
    result.addAll(first.points);

    while (true) {
      final last = result.last;
      bool found = false;

      for (int i = 0; i < remaining.length; i++) {
        final seg = remaining[i];

        if (_samePoint(last, seg.start)) {
          result.addAll(seg.points.skip(1));
          remaining.removeAt(i);
          found = true;
          break;
        }

        if (_samePoint(last, seg.end)) {
          result.addAll(seg.points.reversed.skip(1));
          remaining.removeAt(i);
          found = true;
          break;
        }
      }

      if (!found) break;
      if (_samePoint(result.first, result.last)) break;
    }

    return result;
  }

  static bool _samePoint(LatLng a, LatLng b, {double eps = 1e-6}) {
    return (a.latitude - b.latitude).abs() < eps &&
        (a.longitude - b.longitude).abs() < eps;
  }

  static List<LatLng> _ensureClosedAndClockwise(List<LatLng> pts) {
    final result = List<LatLng>.from(pts);

    if (!_samePoint(result.first, result.last)) {
      result.add(result.first);
    }

    if (_signedArea(result) > 0) {
      return result.reversed.toList();
    }

    return result;
  }

  static double _signedArea(List<LatLng> pts) {
    double sum = 0;
    for (int i = 0; i < pts.length - 1; i++) {
      sum +=
          (pts[i + 1].longitude - pts[i].longitude) *
          (pts[i + 1].latitude + pts[i].latitude);
    }
    return sum;
  }

  static bool _isRingInside(List<LatLng> inner, List<LatLng> outer) {
    final centroid = _centroid(inner);
    return _pointInPolygon(centroid, outer);
  }

  static LatLng _centroid(List<LatLng> pts) {
    double lat = 0;
    double lon = 0;

    for (final p in pts) {
      lat += p.latitude;
      lon += p.longitude;
    }

    return LatLng(lat / pts.length, lon / pts.length);
  }

  static bool _pointInPolygon(LatLng p, List<LatLng> polygon) {
    bool inside = false;

    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final xi = polygon[i].longitude;
      final yi = polygon[i].latitude;
      final xj = polygon[j].longitude;
      final yj = polygon[j].latitude;

      final intersect =
          ((yi > p.latitude) != (yj > p.latitude)) &&
          (p.longitude < (xj - xi) * (p.latitude - yi) / (yj - yi + 0.0) + xi);

      if (intersect) inside = !inside;
    }

    return inside;
  }
}
