import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'feature_fetcher.dart';
import 'feature_marker_provider.dart';
import 'station.dart';
import 'map_poi.dart';

class MapFeaturesController extends ChangeNotifier {
  final FeatureMarkerProvider _featureMarkerProvider;
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

  MapFeaturesController(this._featureMarkerProvider);

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

  List<Station> get stations => _stations
      .where(
        (station) =>
            (station.type == StationType.train && _showTrainStations) ||
            (station.type == StationType.subway && _showSubwayStations),
      )
      .toList();
  List<MapPOI> get themeParks => _showThemeParks ? _themeParks : <MapPOI>[];
  List<MapPOI> get zoos => _showZoos ? _zoos : <MapPOI>[];
  List<MapPOI> get aquariums => _showAquariums ? _aquariums : <MapPOI>[];
  List<MapPOI> get golfCourses => _showGolfCourses ? _golfCourses : <MapPOI>[];
  List<MapPOI> get museums => _showMuseums ? _museums : <MapPOI>[];
  List<MapPOI> get movieTheaters => _showMovieTheaters ? _movieTheaters : <MapPOI>[];
  List<MapPOI> get hospitals => _showHospitals ? _hospitals : <MapPOI>[];
  List<MapPOI> get libraries => _showLibraries ? _libraries : <MapPOI>[];
  List<MapPOI> get consulates => _showConsulates ? _consulates : <MapPOI>[];

  void toggleRailwayStations(bool value) async {
    _showRailwayStations = value;
    _showTrainStations = value;
    _showSubwayStations = value;

    if (value) await _fetchStationsIfNeeded();
    _setFeatureMarkerProviderStations();
    notifyListeners();
  }

  void toggleTrainStations(bool value) async {
    _showTrainStations = value;
    _showRailwayStations = _showTrainStations && _showSubwayStations;

    if (value) await _fetchStationsIfNeeded();
    _setFeatureMarkerProviderStations();
    notifyListeners();
  }

  void toggleSubwayStations(bool value) async {
    _showSubwayStations = value;
    _showRailwayStations = _showTrainStations && _showSubwayStations;

    if (value) await _fetchStationsIfNeeded();
    _setFeatureMarkerProviderStations();
    notifyListeners();
  }

  void _setFeatureMarkerProviderStations() {
    if (_showRailwayStations) {
      _featureMarkerProvider.setStations(_stations);
    } else if (_showTrainStations) {
      _featureMarkerProvider.setStations(
        _stations.where((station) => station.type == StationType.train).toList(),
      );
    } else if (_showSubwayStations) {
      _featureMarkerProvider.setStations(
        _stations.where((station) => station.type == StationType.subway).toList(),
      );
    } else {
      _featureMarkerProvider.setStations(<Station>[]);
    }
  }

  void toggleThemeParks(bool value) async {
    _showThemeParks = value;
    if (value) {
      await _fetchThemeParksIfNeeded();
      _featureMarkerProvider.setThemeParks(_themeParks);
    } else {
      _featureMarkerProvider.setThemeParks(<MapPOI>[]);
    }
    notifyListeners();
  }

  void toggleZoos(bool value) async {
    _showZoos = value;
    if (value) {
      await _fetchZoosIfNeeded();
      _featureMarkerProvider.setZoos(_zoos);
    } else {
      _featureMarkerProvider.setZoos(<MapPOI>[]);
    }
    notifyListeners();
  }

  void toggleAquariums(bool value) async {
    _showAquariums = value;
    if (value) {
      await _fetchAquariumsIfNeeded();
      _featureMarkerProvider.setAquariums(_aquariums);
    } else {
      _featureMarkerProvider.setAquariums(<MapPOI>[]);
    }
    notifyListeners();
  }

  void toggleGolfCourses(bool value) async {
    _showGolfCourses = value;
    if (value) {
      await _fetchGolfCoursesIfNeeded();
      _featureMarkerProvider.setGolfCourses(_golfCourses);
    } else {
      _featureMarkerProvider.setGolfCourses(<MapPOI>[]);
    }
    notifyListeners();
  }

  void toggleMuseums(bool value) async {
    _showMuseums = value;
    if (value) {
      await _fetchMuseumsIfNeeded();
      _featureMarkerProvider.setMuseums(_museums);
    } else {
      _featureMarkerProvider.setMuseums(<MapPOI>[]);
    }
    notifyListeners();
  }

  void toggleMovieTheaters(bool value) async {
    _showMovieTheaters = value;
    if (value) {
      await _fetchMovieTheatersIfNeeded();
      _featureMarkerProvider.setMovieTheaters(_movieTheaters);
    } else {
      _featureMarkerProvider.setMovieTheaters(<MapPOI>[]);
    }
    notifyListeners();
  }

  void toggleHospitals(bool value) async {
    _showHospitals = value;
    if (value) {
      await _fetchHospitalsIfNeeded();
      _featureMarkerProvider.setHospitals(_hospitals);
    } else {
      _featureMarkerProvider.setHospitals(<MapPOI>[]);
    }
    notifyListeners();
  }

  void toggleLibraries(bool value) async {
    _showLibraries = value;
    if (value) {
      await _fetchLibrariesIfNeeded();
      _featureMarkerProvider.setLibraries(_libraries);
    } else {
      _featureMarkerProvider.setLibraries(<MapPOI>[]);
    }
    notifyListeners();
  }

  void toggleConsulates(bool value) async {
    _showConsulates = value;
    if (value) {
      await _fetchConsulatesIfNeeded();
      _featureMarkerProvider.setConsulates(_consulates);
    } else {
      _featureMarkerProvider.setConsulates(<MapPOI>[]);
    }
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

    _featureMarkerProvider.resetAll();
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
}
