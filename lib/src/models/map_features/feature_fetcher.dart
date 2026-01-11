import 'dart:convert';
import 'dart:developer';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'map_poi.dart';
import 'map_overlay.dart';
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

  static String _polygon(List<LatLng> boundary) =>
      boundary.map((p) => '${p.latitude} ${p.longitude}').join(' ');

  static String _buildQuery(String filter, List<LatLng> boundary) {
    final poly = _polygon(boundary);
    return '''
      [out:json][timeout:300];
      (
        $filter(poly:"$poly");
      );
      out geom;
      ''';
  }

  static Future<List<T>> _fetchAndParse<T>(
    List<LatLng> boundary,
    String filter,
    T Function(Map<String, dynamic>) parser,
  ) async {
    if (boundary.isEmpty) return [];

    final query = _buildQuery(filter, boundary);
    final elements = await _fetchElements(query);

    final result = <T>[];

    for (final e in elements) {
      try {
        result.add(parser(e));
      } catch (err) {
        log('Element parsing failed: $err');
      }
    }

    return result;
  }

  static Future<List<Station>> _fetchStations(
    List<LatLng> boundary,
    String filter,
    StationType type,
  ) async {
    final stations = await _fetchAndParse(
      boundary,
      filter,
      (e) => Station.fromOverpassElement(type, e),
    );

    final seen = <String>{};
    return stations.where((s) => seen.add(s.name)).toList();
  }

  static Future<List<Station>> fetchTrainStations(List<LatLng> boundary) =>
      _fetchStations(
        boundary,
        'nwr["railway"="station"]["station"!="subway"]',
        StationType.trainStation,
      );

  static Future<List<Station>> fetchTrainStops(List<LatLng> boundary) =>
      _fetchStations(boundary, 'nwr["railway"="halt"]', StationType.trainStop);

  static Future<List<Station>> fetchSubwayStations(List<LatLng> boundary) =>
      _fetchStations(boundary, 'nwr["station"="subway"]', StationType.subway);

  static Future<List<Station>> fetchTramStops(List<LatLng> boundary) =>
      _fetchStations(boundary, 'nwr["railway"="tram_stop"]', StationType.tram);

  static Future<List<Station>> fetchBusStops(List<LatLng> boundary) =>
      _fetchStations(boundary, 'nwr["highway"="bus_stop"]', StationType.bus);

  static Future<List<Station>> fetchFerryStops(List<LatLng> boundary) =>
      _fetchStations(boundary, 'nwr["amenity"="ferry_terminal"]', StationType.ferry);

  static Future<List<MapOverlay>> _fetchOverlays(
    List<LatLng> boundary,
    String filter,
    MapOverlayType type,
  ) {
    return _fetchAndParse(
      boundary,
      filter,
      (e) => MapOverlay.fromOverpassElement(type, e),
    );
  }

  static Future<List<MapOverlay>> fetchBorderInternational(List<LatLng> boundary) =>
      _fetchOverlays(
        boundary,
        'rel["boundary"="administrative"]["admin_level"="2"]["name"]',
        MapOverlayType.borderInter,
      );

  static Future<List<MapOverlay>> fetchBorder1AD(List<LatLng> boundary) => _fetchOverlays(
    boundary,
    'rel["boundary"="administrative"]["admin_level"="4"]["name"]',
    MapOverlayType.border1AD,
  );

  static Future<List<MapOverlay>> fetchBorder2AD(List<LatLng> boundary) => _fetchOverlays(
    boundary,
    'rel["boundary"="administrative"]["admin_level"="6"]["name"]',
    MapOverlayType.border2AD,
  );

  static Future<List<MapOverlay>> fetchBorder3AD(List<LatLng> boundary) => _fetchOverlays(
    boundary,
    'rel["boundary"="administrative"]["admin_level"="8"]["name"]',
    MapOverlayType.border3AD,
  );

  static Future<List<MapOverlay>> fetchBorder4AD(List<LatLng> boundary) => _fetchOverlays(
    boundary,
    'rel["boundary"="administrative"]["admin_level"="9"]["name"]',
    MapOverlayType.border4AD,
  );

  static Future<List<MapPOI>> _fetchPOIs(
    List<LatLng> boundary,
    String filter,
    POIType type,
  ) {
    return _fetchAndParse(boundary, filter, (e) => MapPOI.fromOverpassElement(type, e));
  }

  static Future<List<MapPOI>> fetchThemeParks(List<LatLng> boundary) =>
      _fetchPOIs(boundary, 'nwr["tourism"="theme_park"]', POIType.themePark);

  static Future<List<MapPOI>> fetchZoos(List<LatLng> boundary) =>
      _fetchPOIs(boundary, 'nwr["tourism"="zoo"]', POIType.zoo);

  static Future<List<MapPOI>> fetchAquariums(List<LatLng> boundary) =>
      _fetchPOIs(boundary, 'nwr["tourism"="aquarium"]', POIType.aquarium);

  static Future<List<MapPOI>> fetchGolfCourses(List<LatLng> boundary) =>
      _fetchPOIs(boundary, 'nwr["leisure"="golf_course"]', POIType.golfCourse);

  static Future<List<MapPOI>> fetchMuseums(List<LatLng> boundary) =>
      _fetchPOIs(boundary, 'nwr["tourism"="museum"]', POIType.museum);

  static Future<List<MapPOI>> fetchMovieTheaters(List<LatLng> boundary) =>
      _fetchPOIs(boundary, 'nwr["amenity"="cinema"]', POIType.movieTheater);

  static Future<List<MapPOI>> fetchHospitals(List<LatLng> boundary) =>
      _fetchPOIs(boundary, 'nwr["amenity"="hospital"]', POIType.hospital);

  static Future<List<MapPOI>> fetchLibraries(List<LatLng> boundary) =>
      _fetchPOIs(boundary, 'nwr["amenity"="library"]', POIType.library);

  static Future<List<MapPOI>> fetchConsulates(List<LatLng> boundary) => _fetchPOIs(
    boundary,
    'nwr["diplomatic"="consulate"]["consulate"!="honorary_consul"]["consulate"!="honorary_consulate"]',
    POIType.consulate,
  );
}
