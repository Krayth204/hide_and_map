import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum StationType { trainStation, trainStop, subway, tram, bus }

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
    final tags = element['tags'] ?? {};
    final name = tags['name'] ?? 'Unnamed Station';
    final nameEn = tags?['name:en'];

    return Station(
      id: element['id'].toString(),
      name: name,
      nameEn: nameEn,
      location: LatLng(element['lat']?.toDouble() ?? 0, element['lon']?.toDouble() ?? 0),
      type: type,
    );
  }
}
