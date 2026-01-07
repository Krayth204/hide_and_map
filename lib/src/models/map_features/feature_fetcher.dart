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

  static Future<List<Station>> _fetchStationsGeneric(
    List<LatLng> boundary,
    String nodeFilter,
    StationType type,
  ) async {
    if (boundary.isEmpty) return [];

    final polygonQuery = _polygonQuery(boundary);
    final query =
        """
      [out:json][timeout:300];
      (
        $nodeFilter(poly:"$polygonQuery");
      );
      out geom;
    """;

    final elements = await _fetchElements(query);
    final result = <Station>[];
    for (var element in elements) {
      final station = Station.fromOverpassElement(type, element);
      final alreadyThere = result.any((e) => e.name == station.name);
      if (!alreadyThere) result.add(station);
    }
    return result;
  }

  static Future<List<Station>> fetchTrainStations(List<LatLng> boundary) {
    return _fetchStationsGeneric(
      boundary,
      'nwr["railway"="station"]["station"!="subway"]',
      StationType.trainStation,
    );
  }

  static Future<List<Station>> fetchTrainStops(List<LatLng> boundary) {
    return _fetchStationsGeneric(
      boundary,
      'nwr["railway"="halt"]',
      StationType.trainStop,
    );
  }

  static Future<List<Station>> fetchSubwayStations(List<LatLng> boundary) {
    return _fetchStationsGeneric(
      boundary,
      'nwr["station"="subway"]',
      StationType.subway,
    );
  }

  static Future<List<Station>> fetchTramStops(List<LatLng> boundary) {
    return _fetchStationsGeneric(
      boundary,
      'nwr["railway"="tram_stop"]',
      StationType.tram,
    );
  }

  static Future<List<Station>> fetchBusStops(List<LatLng> boundary) {
    return _fetchStationsGeneric(boundary, 'nwr["highway"="bus_stop"]', StationType.bus);
  }

  static Future<List<Station>> fetchFerryStops(List<LatLng> boundary) {
    return _fetchStationsGeneric(boundary, 'nwr["amenity"="ferry_terminal"]', StationType.ferry);
  }

  static Future<List<MapPOI>> fetchThemeParks(List<LatLng> boundary) async {
    return _fetchGeneric(boundary, 'tourism', 'theme_park', POIType.themePark);
  }

  static Future<List<MapPOI>> fetchZoos(List<LatLng> boundary) async {
    return _fetchGeneric(boundary, 'tourism', 'zoo', POIType.zoo);
  }

  static Future<List<MapPOI>> fetchAquariums(List<LatLng> boundary) async {
    return _fetchGeneric(boundary, 'tourism', 'aquarium', POIType.aquarium);
  }

  static Future<List<MapPOI>> fetchGolfCourses(List<LatLng> boundary) async {
    return _fetchGeneric(boundary, 'leisure', 'golf_course', POIType.golfCourse);
  }

  static Future<List<MapPOI>> fetchMuseums(List<LatLng> boundary) async {
    return _fetchGeneric(boundary, 'tourism', 'museum', POIType.museum);
  }

  static Future<List<MapPOI>> fetchMovieTheaters(List<LatLng> boundary) async {
    return _fetchGeneric(boundary, 'amenity', 'cinema', POIType.movieTheater);
  }

  static Future<List<MapPOI>> fetchHospitals(List<LatLng> boundary) async {
    return _fetchGeneric(boundary, 'amenity', 'hospital', POIType.hospital);
  }

  static Future<List<MapPOI>> fetchLibraries(List<LatLng> boundary) async {
    return _fetchGeneric(boundary, 'amenity', 'library', POIType.library);
  }

  static Future<List<MapPOI>> fetchConsulates(List<LatLng> boundary) async {
    return _fetchGeneric(
      boundary,
      'diplomatic',
      'consulate',
      POIType.consulate,
      additional: '["consulate"!="honorary_consul"]["consulate"!="honorary_consulate"]',
    );
  }

  static Future<List<MapPOI>> _fetchGeneric<T>(
    List<LatLng> boundary,
    String key,
    String value,
    POIType type, {
    String additional = "",
  }) async {
    if (boundary.isEmpty) return [];

    final polygonQuery = _polygonQuery(boundary);
    final query =
        """
      [out:json][timeout:300];
      (
        nwr["$key"="$value"]$additional(poly:"$polygonQuery");
      );
      out geom;
    """;

    final elements = await _fetchElements(query);
    return elements.map((element) => MapPOI.fromOverpassElement(type, element)).toList();
  }
}
