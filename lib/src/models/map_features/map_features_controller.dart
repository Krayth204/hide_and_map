import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../main.dart';
import 'feature_fetcher.dart';
import 'feature_marker_provider.dart';
import 'station.dart';
import 'map_poi.dart';

class StationState {
  List<Station> data = [];
  bool fetched = false;
  bool fetching = false;
  bool visible = false;
}

class PoiState {
  List<MapPOI> data = [];
  bool fetched = false;
  bool fetching = false;
  bool visible = false;
}

class MapFeaturesController extends ChangeNotifier {
  final FeatureMarkerProvider _featureMarkerProvider;
  List<LatLng> _playAreaBoundary = [];

  bool _busStopsWarningDismissed = false;

  bool get busStopsWarningDismissed => _busStopsWarningDismissed;

  void dismissBusStopsWarning() {
    _busStopsWarningDismissed = true;
  }

  final Map<StationType, StationState> _stationStates = {
    StationType.trainStation: StationState(),
    StationType.trainStop: StationState(),
    StationType.subway: StationState(),
    StationType.tram: StationState(),
    StationType.bus: StationState(),
    StationType.ferry: StationState(),
  };

  Map<StationType, bool> _previousStationVisibility = {};

  final Map<POIType, PoiState> _poiStates = {
    POIType.themePark: PoiState(),
    POIType.zoo: PoiState(),
    POIType.aquarium: PoiState(),
    POIType.golfCourse: PoiState(),
    POIType.museum: PoiState(),
    POIType.movieTheater: PoiState(),
    POIType.hospital: PoiState(),
    POIType.library: PoiState(),
    POIType.consulate: PoiState(),
  };

  MapFeaturesController(this._featureMarkerProvider);

  bool get showTrainStations => _stationStates[StationType.trainStation]!.visible;
  bool get showTrainStops => _stationStates[StationType.trainStop]!.visible;
  bool get showSubwayStations => _stationStates[StationType.subway]!.visible;
  bool get showTramStops => _stationStates[StationType.tram]!.visible;
  bool get showBusStops => _stationStates[StationType.bus]!.visible;
  bool get showFerryStops => _stationStates[StationType.ferry]!.visible;
  bool get showHidingZones => _featureMarkerProvider.hidingZonesVisible;
  bool get showThemeParks => _poiStates[POIType.themePark]!.visible;
  bool get showZoos => _poiStates[POIType.zoo]!.visible;
  bool get showAquariums => _poiStates[POIType.aquarium]!.visible;
  bool get showGolfCourses => _poiStates[POIType.golfCourse]!.visible;
  bool get showMuseums => _poiStates[POIType.museum]!.visible;
  bool get showMovieTheaters => _poiStates[POIType.movieTheater]!.visible;
  bool get showHospitals => _poiStates[POIType.hospital]!.visible;
  bool get showLibraries => _poiStates[POIType.library]!.visible;
  bool get showConsulates => _poiStates[POIType.consulate]!.visible;

  List<Station> get stations {
    final visibleLists = _stationStates.entries
        .where((e) => e.value.visible)
        .expand((e) => e.value.data)
        .toList();
    return visibleLists;
  }

  bool get anyStationTypeVisible => _stationStates.values.any((state) => state.visible);

  bool get isFetchingStations => _stationStates.values.any((state) => state.fetching);

  List<MapPOI> get themeParks => _getPoiList(POIType.themePark);
  List<MapPOI> get zoos => _getPoiList(POIType.zoo);
  List<MapPOI> get aquariums => _getPoiList(POIType.aquarium);
  List<MapPOI> get golfCourses => _getPoiList(POIType.golfCourse);
  List<MapPOI> get museums => _getPoiList(POIType.museum);
  List<MapPOI> get movieTheaters => _getPoiList(POIType.movieTheater);
  List<MapPOI> get hospitals => _getPoiList(POIType.hospital);
  List<MapPOI> get libraries => _getPoiList(POIType.library);
  List<MapPOI> get consulates => _getPoiList(POIType.consulate);

  List<MapPOI> _getPoiList(POIType type) {
    return _poiStates[type]!.visible ? _poiStates[type]!.data : <MapPOI>[];
  }

  bool get isFetchingTrainStations => _stationStates[StationType.trainStation]!.fetching;
  bool get isFetchingTrainStops => _stationStates[StationType.trainStop]!.fetching;
  bool get isFetchingSubwayStations => _stationStates[StationType.subway]!.fetching;
  bool get isFetchingTramStops => _stationStates[StationType.tram]!.fetching;
  bool get isFetchingBusStops => _stationStates[StationType.bus]!.fetching;
  bool get isFetchingFerryStops => _stationStates[StationType.ferry]!.fetching;
  bool get isFetchingThemeParks => _poiStates[POIType.themePark]!.fetching;
  bool get isFetchingZoos => _poiStates[POIType.zoo]!.fetching;
  bool get isFetchingAquariums => _poiStates[POIType.aquarium]!.fetching;
  bool get isFetchingGolfCourses => _poiStates[POIType.golfCourse]!.fetching;
  bool get isFetchingMuseums => _poiStates[POIType.museum]!.fetching;
  bool get isFetchingMovieTheaters => _poiStates[POIType.movieTheater]!.fetching;
  bool get isFetchingHospitals => _poiStates[POIType.hospital]!.fetching;
  bool get isFetchingLibraries => _poiStates[POIType.library]!.fetching;
  bool get isFetchingConsulates => _poiStates[POIType.consulate]!.fetching;

  void toggleStations(bool value) async {
    if (!value) {
      _previousStationVisibility = {
        for (var k in _stationStates.keys) k: _stationStates[k]!.visible,
      };
      for (var state in _stationStates.values) {
        state.visible = false;
      }
      _setFeatureMarkerProviderStations();
      notifyListeners();
      return;
    }

    if (_previousStationVisibility.isNotEmpty) {
      for (var entry in _previousStationVisibility.entries) {
        _stationStates[entry.key]!.visible = entry.value;
      }
    } else {
      for (var k in _stationStates.keys) {
        _stationStates[k]!.visible = k == StationType.trainStation;
      }
    }

    final toFetch = _stationStates.entries
        .where((e) => e.value.visible)
        .map((e) => _fetchStationIfNeeded(e.key));
    await Future.wait(toFetch);

    _setFeatureMarkerProviderStations();
    notifyListeners();
  }

  void toggleTrainStations(bool value) async {
    await _toggleStationType(StationType.trainStation, value);
  }

  void toggleTrainStops(bool value) async {
    await _toggleStationType(StationType.trainStop, value);
  }

  void toggleSubwayStations(bool value) async {
    await _toggleStationType(StationType.subway, value);
  }

  void toggleTramStops(bool value) async {
    await _toggleStationType(StationType.tram, value);
  }

  void toggleBusStops(bool value) async {
    await _toggleStationType(StationType.bus, value);
  }

  void toggleFerryStops(bool value) async {
    await _toggleStationType(StationType.ferry, value);
  }

  Future<void> _toggleStationType(StationType type, bool value) async {
    final state = _stationStates[type]!;
    state.visible = value;

    if (value) {
      await _fetchStationIfNeeded(type);
    }

    _setFeatureMarkerProviderStations();
    notifyListeners();
  }

  Future<void> _fetchStationIfNeeded(StationType type) async {
    final state = _stationStates[type]!;
    if (state.fetched || state.fetching) return;

    state.fetching = true;
    notifyListeners();

    try {
      state.data = await _getStationFetchFunction(type)(_playAreaBoundary);
      state.fetched = true;
    } catch (e) {
      debugPrint('Error fetching ${type.name}: $e');
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Fetching station locations failed! Please try again!"),
        ),
      );
      state.visible = false;
    } finally {
      state.fetching = false;
      notifyListeners();
    }
  }

  Future<List<Station>> Function(List<LatLng>) _getStationFetchFunction(
    StationType type,
  ) {
    return switch (type) {
      StationType.trainStation => FeatureFetcher.fetchTrainStations,
      StationType.trainStop => FeatureFetcher.fetchTrainStops,
      StationType.subway => FeatureFetcher.fetchSubwayStations,
      StationType.tram => FeatureFetcher.fetchTramStops,
      StationType.bus => FeatureFetcher.fetchBusStops,
      StationType.ferry => FeatureFetcher.fetchFerryStops,
    };
  }

  void _setFeatureMarkerProviderStations() {
    final combined = _stationStates.values
        .where((s) => s.visible)
        .expand((s) => s.data)
        .toList();
    _featureMarkerProvider.setStations(combined);
  }

  void toggleHidingZones(bool value) async {
    _featureMarkerProvider.setHidingZonesVisible(value);
    notifyListeners();
  }

  void togglePoi(POIType type, bool value) async {
    _poiStates[type]!.visible = value;

    await _fetchPoiIfNeeded(type);
    _updateFeatureMarkerProvider(type);

    notifyListeners();
  }

  Future<void> _fetchPoiIfNeeded(POIType type) async {
    final state = _poiStates[type]!;
    if (state.fetched || state.fetching) return;

    state.fetching = true;
    notifyListeners();

    try {
      state.data = await _getFetchFunction(type)(_playAreaBoundary);
      state.fetched = true;
    } catch (e) {
      debugPrint('Error fetching ${type.name}: $e');
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text("Fetching locations failed! Please try again!")),
      );
      state.visible = false;
    } finally {
      state.fetching = false;
      notifyListeners();
    }
  }

  Future<List<MapPOI>> Function(List<LatLng>) _getFetchFunction(POIType type) {
    return switch (type) {
      POIType.themePark => FeatureFetcher.fetchThemeParks,
      POIType.zoo => FeatureFetcher.fetchZoos,
      POIType.aquarium => FeatureFetcher.fetchAquariums,
      POIType.golfCourse => FeatureFetcher.fetchGolfCourses,
      POIType.museum => FeatureFetcher.fetchMuseums,
      POIType.movieTheater => FeatureFetcher.fetchMovieTheaters,
      POIType.hospital => FeatureFetcher.fetchHospitals,
      POIType.library => FeatureFetcher.fetchLibraries,
      POIType.consulate => FeatureFetcher.fetchConsulates,
    };
  }

  void _updateFeatureMarkerProvider(POIType type) {
    final data = _getPoiList(type);
    _featureMarkerProvider.setPOIs(type, data);
  }

  void setPlayAreaBoundary(List<LatLng> newBoundary) {
    if (!_areBoundariesEqual(_playAreaBoundary, newBoundary)) {
      _playAreaBoundary = newBoundary;
      _resetData();
      notifyListeners();
    }
  }

  void _resetData() {
    _busStopsWarningDismissed = false;
    _previousStationVisibility = {};

    for (var state in _stationStates.values) {
      state.data = [];
      state.fetched = false;
      state.fetching = false;
      state.visible = false;
    }

    for (var state in _poiStates.values) {
      state.data = [];
      state.fetched = false;
      state.visible = false;
    }

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
