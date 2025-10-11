import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'station.dart';

class FeatureFetcher {
  static const String _overpassUrl = 'https://overpass-api.de/api/interpreter';

  static Future<List<Station>> fetchStations(List<LatLng> boundary) async {
    if (boundary.isEmpty) return [];

    final polygonQuery = boundary.map((p) => '${p.latitude} ${p.longitude}').join(' ');

    final query =
        """
      [out:json][timeout:300];
      (
        node["railway"="station"](poly:"$polygonQuery");
        node["station"="subway"](poly:"$polygonQuery");
      );
      out body;
    """;

    final response = await http.post(Uri.parse(_overpassUrl), body: {'data': query});

    if (response.statusCode != 200) {
      throw Exception('Overpass API error: ${response.statusCode}');
    }

    final json = jsonDecode(response.body);
    final elements = (json['elements'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    return elements.map((e) => Station.fromOverpassElement(e)).toList();
  }
}
