import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum StationType { trainStation, trainStop, subway, tram, bus, ferry }

class Station with ClusterItem {
  final String id;
  final String name;
  final String? nameEn;
  @override
  final LatLng location;
  final StationType type;

  Station({
    required this.id,
    required this.name,
    this.nameEn,
    required this.location,
    required this.type,
  });

  factory Station.fromOverpassElement(StationType type, Map<String, dynamic> element) {
    final id = element['id'].toString();
    final tags = element['tags'] ?? {};
    final name = tags['name'] ?? 'Unnamed Station';
    final nameEn = tags?['name:en'];

    if (element['type'] == 'node' && element['lat'] != null && element['lon'] != null) {
      return Station(
        id: id,
        name: name,
        nameEn: nameEn,
        location: LatLng(element['lat']?.toDouble() ?? 0, element['lon']?.toDouble() ?? 0),
        type: type,
      );
    }

    

    if (element['bounds'] != null) {
      final bounds = element['bounds'] as Map<String, dynamic>;
      final minLat = bounds['minlat'];
      final minLon = bounds['minlon'];
      final maxLat = bounds['maxlat'];
      final maxLon = bounds['maxlon'];

      final center = LatLng((minLat + maxLat) / 2, (minLon + maxLon) / 2);

      return Station(
        id: id,
        name: name,
        nameEn: nameEn,
        location: center,
        type: type,
      );
    }

    throw ArgumentError('Invalid element: missing coordinates or bounds for POI $id');
  }
}
