import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'map_poi.dart';
import 'station.dart';

class FeatureFetcher {
  static const String _overpassUrl = 'https://overpass-api.de/api/interpreter';

  static Future<List<Map<String, dynamic>>> _fetchElements(String query) async {
    final response = await http.post(Uri.parse(_overpassUrl), body: {'data': query});

    if (response.statusCode != 200) {
      throw Exception('Overpass API error: ${response.statusCode}');
    }

    final json = jsonDecode(response.body);
    return (json['elements'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
  }

  static String _polygonQuery(List<LatLng> boundary) =>
      boundary.map((p) => '${p.latitude} ${p.longitude}').join(' ');

  static Future<List<Station>> fetchStations(List<LatLng> boundary) async {
    if (boundary.isEmpty) return [];

    final polygonQuery = _polygonQuery(boundary);
    final query =
        """
      [out:json][timeout:300];
      (
        node["railway"="station"](poly:"$polygonQuery");
        node["station"="subway"](poly:"$polygonQuery");
      );
      out body;
    """;

    final elements = await _fetchElements(query);
    return elements.map(Station.fromOverpassElement).toList();
  }

  static Future<List<MapPOI>> fetchThemeParks(List<LatLng> boundary) async {
    return _fetchGeneric(boundary, 'tourism', 'theme_park');
  }

  static Future<List<MapPOI>> fetchZoos(List<LatLng> boundary) async {
    return _fetchGeneric(boundary, 'tourism', 'zoo');
  }

  static Future<List<MapPOI>> fetchAquariums(List<LatLng> boundary) async {
    return _fetchGeneric(boundary, 'tourism', 'aquarium');
  }

  static Future<List<MapPOI>> fetchGolfCourses(List<LatLng> boundary) async {
    return _fetchGeneric(boundary, 'leisure', 'golf_course');
  }

  static Future<List<MapPOI>> fetchMuseums(List<LatLng> boundary) async {
    return _fetchGeneric(boundary, 'tourism', 'museum');
  }

  static Future<List<MapPOI>> fetchMovieTheaters(List<LatLng> boundary) async {
    return _fetchGeneric(boundary, 'amenity', 'cinema');
  }

  static Future<List<MapPOI>> fetchHospitals(List<LatLng> boundary) async {
    return _fetchGeneric(boundary, 'amenity', 'hospital');
  }

  static Future<List<MapPOI>> fetchLibraries(List<LatLng> boundary) async {
    return _fetchGeneric(boundary, 'amenity', 'library');
  }

  static Future<List<MapPOI>> fetchConsulates(List<LatLng> boundary) async {
    return _fetchGeneric(boundary, 'diplomatic', 'consulate');
  }

  static Future<List<MapPOI>> _fetchGeneric<T>(
    List<LatLng> boundary,
    String key,
    String value,
  ) async {
    if (boundary.isEmpty) return [];

    final polygonQuery = _polygonQuery(boundary);
    final query =
        """
      [out:json][timeout:300];
      (
        nwr["$key"="$value"](poly:"$polygonQuery");
      );
      out geom;
    """;

    final elements = await _fetchElements(query);
    return elements.map(MapPOI.fromOverpassElement).toList();
  }
}
