import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'feature_fetcher.dart';
import 'station.dart';

class MapFeaturesController extends ChangeNotifier {
  List<LatLng> _playAreaBoundary = [];
  List<Station> _stations = [];
  bool _stationsFetched = false;
  bool isFetchingStations = false;

  bool _showRailwayStations = false;
  bool _showTrainStations = false;
  bool _showSubwayStations = false;

  BitmapDescriptor? _trainIcon;
  BitmapDescriptor? _subwayIcon;

  bool get showRailwayStations => _showRailwayStations;
  bool get showTrainStations => _showTrainStations;
  bool get showSubwayStations => _showSubwayStations;

  bool get railwayPartial =>
      (_showTrainStations || _showSubwayStations) &&
      !(_showTrainStations && _showSubwayStations);

  MapFeaturesController() {
    _loadMarkerIcons();
  }

  Future<void> _loadMarkerIcons() async {
    _trainIcon ??= await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(16, 16)),
      'assets/markers/train_station_marker.png',
    );
    _subwayIcon ??= await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(16, 16)),
      'assets/markers/subway_station_marker.png',
    );
  }

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

  void setPlayAreaBoundary(List<LatLng> newBoundary) {
    if (!_areBoundariesEqual(_playAreaBoundary, newBoundary)) {
      _playAreaBoundary = newBoundary;
      _stations = [];
      _stationsFetched = false;
      _showRailwayStations = false;
      _showTrainStations = false;
      _showSubwayStations = false;
      notifyListeners();
    }
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

    if (_stations.isEmpty) return markers;

    for (final station in _stations) {
      final isVisible =
          (station.type == StationType.train && _showTrainStations) ||
          (station.type == StationType.subway && _showSubwayStations);

      if (!isVisible) continue;

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

    return markers;
  }
}
