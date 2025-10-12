import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'feature_fetcher.dart';
import 'station.dart';
import 'map_poi.dart';

class MapFeaturesController extends ChangeNotifier {
  List<LatLng> _playAreaBoundary = [];

  List<Station> _stations = [];
  bool _stationsFetched = false;
  bool isFetchingStations = false;

  List<MapPOI> _themeParks = [];
  List<MapPOI> _zoos = [];
  List<MapPOI> _aquariums = [];
  List<MapPOI> _golfCourses = [];
  List<MapPOI> _museums = [];
  List<MapPOI> _movieTheaters = [];
  List<MapPOI> _hospitals = [];
  List<MapPOI> _libraries = [];
  List<MapPOI> _consulates = [];

  bool _themeParksFetched = false;
  bool _zoosFetched = false;
  bool _aquariumsFetched = false;
  bool _golfCoursesFetched = false;
  bool _museumsFetched = false;
  bool _movieTheatersFetched = false;
  bool _hospitalsFetched = false;
  bool _librariesFetched = false;
  bool _consulatesFetched = false;

  bool isFetchingThemeParks = false;
  bool isFetchingZoos = false;
  bool isFetchingAquariums = false;
  bool isFetchingGolfCourses = false;
  bool isFetchingMuseums = false;
  bool isFetchingMovieTheaters = false;
  bool isFetchingHospitals = false;
  bool isFetchingLibraries = false;
  bool isFetchingConsulates = false;

  bool _showRailwayStations = false;
  bool _showTrainStations = false;
  bool _showSubwayStations = false;
  bool _showThemeParks = false;
  bool _showZoos = false;
  bool _showAquariums = false;
  bool _showGolfCourses = false;
  bool _showMuseums = false;
  bool _showMovieTheaters = false;
  bool _showHospitals = false;
  bool _showLibraries = false;
  bool _showConsulates = false;

  BitmapDescriptor? _trainIcon;
  BitmapDescriptor? _subwayIcon;
  BitmapDescriptor? _themeParkIcon;
  BitmapDescriptor? _zooIcon;
  BitmapDescriptor? _aquariumIcon;
  BitmapDescriptor? _golfIcon;
  BitmapDescriptor? _museumIcon;
  BitmapDescriptor? _cinemaIcon;
  BitmapDescriptor? _hospitalIcon;
  BitmapDescriptor? _libraryIcon;
  BitmapDescriptor? _consulateIcon;

  MapFeaturesController() {
    _loadMarkerIcons();
  }

  Future<void> _loadMarkerIcons() async {
    _trainIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(16, 16)),
      'assets/markers/train_station_marker.png',
    );
    _subwayIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(16, 16)),
      'assets/markers/subway_station_marker.png',
    );
    _themeParkIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(16, 16)),
      'assets/markers/theme_park_marker.png',
    );
    _zooIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(16, 16)),
      'assets/markers/zoo_marker.png',
    );
    _aquariumIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(16, 16)),
      'assets/markers/aquarium_marker.png',
    );
    _golfIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(16, 16)),
      'assets/markers/golf_marker.png',
    );
    _museumIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(16, 16)),
      'assets/markers/museum_marker.png',
    );
    _cinemaIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(16, 16)),
      'assets/markers/cinema_marker.png',
    );
    _hospitalIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(16, 16)),
      'assets/markers/hospital_marker.png',
    );
    _libraryIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(16, 16)),
      'assets/markers/library_marker.png',
    );
    _consulateIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(16, 16)),
      'assets/markers/consulate_marker.png',
    );
  }

  bool get showRailwayStations => _showRailwayStations;
  bool get showTrainStations => _showTrainStations;
  bool get showSubwayStations => _showSubwayStations;
  bool get showThemeParks => _showThemeParks;
  bool get showZoos => _showZoos;
  bool get showAquariums => _showAquariums;
  bool get showGolfCourses => _showGolfCourses;
  bool get showMuseums => _showMuseums;
  bool get showMovieTheaters => _showMovieTheaters;
  bool get showHospitals => _showHospitals;
  bool get showLibraries => _showLibraries;
  bool get showConsulates => _showConsulates;

  bool get railwayPartial =>
      (_showTrainStations || _showSubwayStations) &&
      !(_showTrainStations && _showSubwayStations);

  void toggleRailwayStations(bool value) {
    _showRailwayStations = value;
    _showTrainStations = value;
    _showSubwayStations = value;

    if (value) _fetchStationsIfNeeded();
    notifyListeners();
  }

  void toggleTrainStations(bool value) {
    _showTrainStations = value;
    _showRailwayStations = _showTrainStations && _showSubwayStations;

    if (value) _fetchStationsIfNeeded();
    notifyListeners();
  }

  void toggleSubwayStations(bool value) {
    _showSubwayStations = value;
    _showRailwayStations = _showTrainStations && _showSubwayStations;

    if (value) _fetchStationsIfNeeded();
    notifyListeners();
  }

  void toggleThemeParks(bool value) => _togglePoi(
    value,
    fetcher: _fetchThemeParksIfNeeded,
    setter: (v) => _showThemeParks = v,
  );

  void toggleZoos(bool value) =>
      _togglePoi(value, fetcher: _fetchZoosIfNeeded, setter: (v) => _showZoos = v);

  void toggleAquariums(bool value) => _togglePoi(
    value,
    fetcher: _fetchAquariumsIfNeeded,
    setter: (v) => _showAquariums = v,
  );

  void toggleGolfCourses(bool value) => _togglePoi(
    value,
    fetcher: _fetchGolfCoursesIfNeeded,
    setter: (v) => _showGolfCourses = v,
  );

  void toggleMuseums(bool value) =>
      _togglePoi(value, fetcher: _fetchMuseumsIfNeeded, setter: (v) => _showMuseums = v);

  void toggleMovieTheaters(bool value) => _togglePoi(
    value,
    fetcher: _fetchMovieTheatersIfNeeded,
    setter: (v) => _showMovieTheaters = v,
  );

  void toggleHospitals(bool value) => _togglePoi(
    value,
    fetcher: _fetchHospitalsIfNeeded,
    setter: (v) => _showHospitals = v,
  );

  void toggleLibraries(bool value) => _togglePoi(
    value,
    fetcher: _fetchLibrariesIfNeeded,
    setter: (v) => _showLibraries = v,
  );

  void toggleConsulates(bool value) => _togglePoi(
    value,
    fetcher: _fetchConsulatesIfNeeded,
    setter: (v) => _showConsulates = v,
  );

  void _togglePoi(
    bool value, {
    required Future<void> Function() fetcher,
    required void Function(bool) setter,
  }) {
    setter(value);
    if (value) fetcher();
    notifyListeners();
  }

  Future<void> _fetchStationsIfNeeded() async {
    if (_stationsFetched || isFetchingStations) return;
    isFetchingStations = true;
    notifyListeners();

    try {
      _stations = await FeatureFetcher.fetchStations(_playAreaBoundary);
      _stationsFetched = true;
    } catch (e) {
      debugPrint('Error fetching stations: $e');
      _showRailwayStations = false;
      _showTrainStations = false;
      _showSubwayStations = false;
    } finally {
      isFetchingStations = false;
      notifyListeners();
    }
  }

  Future<void> _fetchThemeParksIfNeeded() async => _fetchGenericPoi(
    _themeParksFetched,
    isFetchingThemeParks,
    FeatureFetcher.fetchThemeParks,
    (v) => isFetchingThemeParks = v,
    (v) => _themeParksFetched = v,
    (list) => _themeParks = list,
    () => _showThemeParks = false,
  );

  Future<void> _fetchZoosIfNeeded() async => _fetchGenericPoi(
    _zoosFetched,
    isFetchingZoos,
    FeatureFetcher.fetchZoos,
    (v) => isFetchingZoos = v,
    (v) => _zoosFetched = v,
    (list) => _zoos = list,
    () => _showZoos = false,
  );

  Future<void> _fetchAquariumsIfNeeded() async => _fetchGenericPoi(
    _aquariumsFetched,
    isFetchingAquariums,
    FeatureFetcher.fetchAquariums,
    (v) => isFetchingAquariums = v,
    (v) => _aquariumsFetched = v,
    (list) => _aquariums = list,
    () => _showAquariums = false,
  );

  Future<void> _fetchGolfCoursesIfNeeded() async => _fetchGenericPoi(
    _golfCoursesFetched,
    isFetchingGolfCourses,
    FeatureFetcher.fetchGolfCourses,
    (v) => isFetchingGolfCourses = v,
    (v) => _golfCoursesFetched = v,
    (list) => _golfCourses = list,
    () => _showGolfCourses = false,
  );

  Future<void> _fetchMuseumsIfNeeded() async => _fetchGenericPoi(
    _museumsFetched,
    isFetchingMuseums,
    FeatureFetcher.fetchMuseums,
    (v) => isFetchingMuseums = v,
    (v) => _museumsFetched = v,
    (list) => _museums = list,
    () => _showMuseums = false,
  );

  Future<void> _fetchMovieTheatersIfNeeded() async => _fetchGenericPoi(
    _movieTheatersFetched,
    isFetchingMovieTheaters,
    FeatureFetcher.fetchMovieTheaters,
    (v) => isFetchingMovieTheaters = v,
    (v) => _movieTheatersFetched = v,
    (list) => _movieTheaters = list,
    () => _showMovieTheaters = false,
  );

  Future<void> _fetchHospitalsIfNeeded() async => _fetchGenericPoi(
    _hospitalsFetched,
    isFetchingHospitals,
    FeatureFetcher.fetchHospitals,
    (v) => isFetchingHospitals = v,
    (v) => _hospitalsFetched = v,
    (list) => _hospitals = list,
    () => _showHospitals = false,
  );

  Future<void> _fetchLibrariesIfNeeded() async => _fetchGenericPoi(
    _librariesFetched,
    isFetchingLibraries,
    FeatureFetcher.fetchLibraries,
    (v) => isFetchingLibraries = v,
    (v) => _librariesFetched = v,
    (list) => _libraries = list,
    () => _showLibraries = false,
  );

  Future<void> _fetchConsulatesIfNeeded() async => _fetchGenericPoi(
    _consulatesFetched,
    isFetchingConsulates,
    FeatureFetcher.fetchConsulates,
    (v) => isFetchingConsulates = v,
    (v) => _consulatesFetched = v,
    (list) => _consulates = list,
    () => _showConsulates = false,
  );

  Future<void> _fetchGenericPoi(
    bool fetchedFlag,
    bool fetchingFlag,
    Future<List<MapPOI>> Function(List<LatLng>) fetchFn,
    void Function(bool) setFetching,
    void Function(bool) setFetched,
    void Function(List<MapPOI>) setList,
    void Function() onFail,
  ) async {
    if (fetchedFlag || fetchingFlag) return;
    setFetching(true);
    notifyListeners();

    try {
      final result = await fetchFn(_playAreaBoundary);
      setList(result);
      setFetched(true);
    } catch (e) {
      debugPrint('Error fetching POI: $e');
      onFail();
    } finally {
      setFetching(false);
      notifyListeners();
    }
  }

  void setPlayAreaBoundary(List<LatLng> newBoundary) {
    if (!_areBoundariesEqual(_playAreaBoundary, newBoundary)) {
      _playAreaBoundary = newBoundary;

      _resetData();
      notifyListeners();
    }
  }

  void _resetData() {
    _stations = [];
    _stationsFetched = false;

    _themeParks = [];
    _zoos = [];
    _aquariums = [];
    _golfCourses = [];
    _museums = [];
    _movieTheaters = [];
    _hospitals = [];
    _libraries = [];
    _consulates = [];

    _themeParksFetched = false;
    _zoosFetched = false;
    _aquariumsFetched = false;
    _golfCoursesFetched = false;
    _museumsFetched = false;
    _movieTheatersFetched = false;
    _hospitalsFetched = false;
    _librariesFetched = false;
    _consulatesFetched = false;

    _showRailwayStations = false;
    _showTrainStations = false;
    _showSubwayStations = false;
    _showThemeParks = false;
    _showZoos = false;
    _showAquariums = false;
    _showGolfCourses = false;
    _showMuseums = false;
    _showMovieTheaters = false;
    _showHospitals = false;
    _showLibraries = false;
    _showConsulates = false;
  }

  bool _areBoundariesEqual(List<LatLng> a, List<LatLng> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].latitude != b[i].latitude || a[i].longitude != b[i].longitude) {
        return false;
      }
    }
    return true;
  }

  Set<Marker> getMarkers({bool tapable = false, void Function(LatLng point)? onTap}) {
    final markers = <Marker>{};

    for (final station in _stations) {
      final visible =
          (station.type == StationType.train && _showTrainStations) ||
          (station.type == StationType.subway && _showSubwayStations);
      if (!visible) continue;

      final icon = station.type == StationType.train ? _trainIcon : _subwayIcon;
      if (icon == null) continue;

      markers.add(
        Marker(
          markerId: MarkerId('station_${station.id}'),
          position: station.location,
          icon: icon,
          infoWindow: InfoWindow(title: station.name),
          consumeTapEvents: tapable,
          onTap: () => tapable ? onTap?.call(station.location) : null,
        ),
      );
    }

    void addPoiMarkers(
      List<MapPOI> pois,
      bool show,
      BitmapDescriptor? icon,
      String prefix,
    ) {
      if (!show || icon == null) return;
      for (final poi in pois) {
        markers.add(
          Marker(
            markerId: MarkerId('${prefix}_${poi.id}'),
            position: poi.center,
            icon: icon,
            infoWindow: InfoWindow(title: poi.name),
            consumeTapEvents: tapable,
            onTap: () => tapable ? onTap?.call(poi.center) : null,
          ),
        );
      }
    }

    addPoiMarkers(_themeParks, _showThemeParks, _themeParkIcon, 'theme_park');
    addPoiMarkers(_zoos, _showZoos, _zooIcon, 'zoo');
    addPoiMarkers(_aquariums, _showAquariums, _aquariumIcon, 'aquarium');
    addPoiMarkers(_golfCourses, _showGolfCourses, _golfIcon, 'golf');
    addPoiMarkers(_museums, _showMuseums, _museumIcon, 'museum');
    addPoiMarkers(_movieTheaters, _showMovieTheaters, _cinemaIcon, 'cinema');
    addPoiMarkers(_hospitals, _showHospitals, _hospitalIcon, 'hospital');
    addPoiMarkers(_libraries, _showLibraries, _libraryIcon, 'library');
    addPoiMarkers(_consulates, _showConsulates, _consulateIcon, 'consulate');

    return markers;
  }

  Set<Polygon> getPolygons() {
    final polygons = <Polygon>{};

    void addPoiPolygons(
      List<MapPOI> pois,
      bool show,
      Color fillColor,
      Color strokeColor,
      String prefix,
    ) {
      if (!show) return;

      for (final poi in pois) {
        if (poi.boundary == null || poi.boundary!.isEmpty) continue;

        polygons.add(
          Polygon(
            polygonId: PolygonId('${prefix}_${poi.id}'),
            points: poi.boundary!,
            strokeWidth: 2,
            strokeColor: strokeColor,
            fillColor: fillColor,
          ),
        );
      }
    }

    addPoiPolygons(
      _themeParks,
      _showThemeParks,
      const Color(0x66FF6F00),
      const Color(0xFFFF6F00),
      'theme_park',
    );

    addPoiPolygons(
      _zoos,
      _showZoos,
      const Color(0x6657BB8A),
      const Color(0xFF43A047),
      'zoo',
    );

    addPoiPolygons(
      _aquariums,
      _showAquariums,
      const Color(0x66396EFF),
      const Color(0xFF3949AB),
      'aquarium',
    );

    addPoiPolygons(
      _golfCourses,
      _showGolfCourses,
      const Color(0x669CCC65),
      const Color(0xFF7CB342),
      'golf',
    );

    addPoiPolygons(
      _museums,
      _showMuseums,
      const Color(0x66BA68C8),
      const Color(0xFF8E24AA),
      'museum',
    );

    addPoiPolygons(
      _movieTheaters,
      _showMovieTheaters,
      const Color(0x66F06292),
      const Color(0xFFD81B60),
      'cinema',
    );

    addPoiPolygons(
      _hospitals,
      _showHospitals,
      const Color(0x66E57373),
      const Color(0xFFC62828),
      'hospital',
    );

    addPoiPolygons(
      _libraries,
      _showLibraries,
      const Color(0x66FFD54F),
      const Color(0xFFFBC02D),
      'library',
    );

    addPoiPolygons(
      _consulates,
      _showConsulates,
      const Color(0x6680CBC4),
      const Color(0xFF0097A7),
      'consulate',
    );

    return polygons;
  }
}
