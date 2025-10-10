import 'package:google_maps_flutter/google_maps_flutter.dart';

enum StationType { train, subway }

class Station {
  final String id;
  final String name;
  final LatLng location;
  final StationType type;

  Station({
    required this.id,
    required this.name,
    required this.location,
    required this.type,
  });

  factory Station.fromOverpassElement(Map<String, dynamic> element) {
    final tags = element['tags'] ?? {};
    final name = tags['name'] ?? 'Unnamed Station';
    final typeTag = tags['station'] ?? tags['railway'] ?? '';
    final type = typeTag == 'subway' || typeTag == 'subway_entrance'
        ? StationType.subway
        : StationType.train;

    return Station(
      id: element['id'].toString(),
      name: name,
      location: LatLng(element['lat']?.toDouble() ?? 0, element['lon']?.toDouble() ?? 0),
      type: type,
    );
  }
}
