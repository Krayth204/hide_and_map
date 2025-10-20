import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum StationType { train, subway }

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

  factory Station.fromOverpassElement(Map<String, dynamic> element) {
    final tags = element['tags'] ?? {};
    final name = tags['name'] ?? 'Unnamed Station';
    final nameEn = tags?['name:en'];
    final typeTag = tags['station'] ?? tags['railway'] ?? '';
    final type = typeTag == 'subway' || typeTag == 'subway_entrance'
        ? StationType.subway
        : StationType.train;

    return Station(
      id: element['id'].toString(),
      name: name,
      nameEn: nameEn,
      location: LatLng(element['lat']?.toDouble() ?? 0, element['lon']?.toDouble() ?? 0),
      type: type,
    );
  }
}
