import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'
    hide ClusterManager, Cluster;

import 'map_poi.dart';
import 'station.dart';

class FeatureMarkerProvider extends ChangeNotifier {
  final bool Function() tapable;
  final Function(LatLng point) onTap;
  Set<Polygon> polygons = {};

  late ClusterManager<Station> _stationClusterManager;
  late ClusterManager<MapPOI> _themeParkClusterManager;
  late ClusterManager<MapPOI> _zooClusterManager;
  late ClusterManager<MapPOI> _aquariumClusterManager;
  late ClusterManager<MapPOI> _golfCourseClusterManager;
  late ClusterManager<MapPOI> _museumClusterManager;
  late ClusterManager<MapPOI> _movieTheaterClusterManager;
  late ClusterManager<MapPOI> _hospitalClusterManager;
  late ClusterManager<MapPOI> _libraryClusterManager;
  late ClusterManager<MapPOI> _consulateClusterManager;

  Set<Marker> _stationMarkers = {};
  Set<Marker> _themeParkMarkers = {};
  Set<Marker> _zooMarkers = {};
  Set<Marker> _aquariumMarkers = {};
  Set<Marker> _golfCourseMarkers = {};
  Set<Marker> _museumMarkers = {};
  Set<Marker> _movieTheaterMarkers = {};
  Set<Marker> _hospitalMarkers = {};
  Set<Marker> _libraryMarkers = {};
  Set<Marker> _consulateMarkers = {};

  FeatureMarkerProvider(this.tapable, this.onTap) {
    init();
  }

  void init() async {
    _stationClusterManager = _createClusterManager<Station>(
      items: [],
      onMarkersUpdated: (markers) {
        _stationMarkers = markers;
        notifyListeners();
      },
      markerBuilder: _getStationMarkerBuilder(),
    );

    _themeParkClusterManager = _createClusterManager<MapPOI>(
      items: [],
      onMarkersUpdated: (markers) {
        _themeParkMarkers = markers;
        notifyListeners();
      },
      markerBuilder: _getPOIMarkerBuilder(_themeParkIcon, const Color(0xFFFF6F00)),
    );

    _zooClusterManager = _createClusterManager<MapPOI>(
      items: [],
      onMarkersUpdated: (markers) {
        _zooMarkers = markers;
        notifyListeners();
      },
      markerBuilder: _getPOIMarkerBuilder(_zooIcon, const Color(0xFF43A047)),
    );

    _aquariumClusterManager = _createClusterManager<MapPOI>(
      items: [],
      onMarkersUpdated: (markers) {
        _aquariumMarkers = markers;
        notifyListeners();
      },
      markerBuilder: _getPOIMarkerBuilder(_aquariumIcon, const Color(0xFF3949AB)),
    );

    _golfCourseClusterManager = _createClusterManager<MapPOI>(
      items: [],
      onMarkersUpdated: (markers) {
        _golfCourseMarkers = markers;
        notifyListeners();
      },
      markerBuilder: _getPOIMarkerBuilder(_golfIcon, const Color(0xFF7CB342)),
    );

    _museumClusterManager = _createClusterManager<MapPOI>(
      items: [],
      onMarkersUpdated: (markers) {
        _museumMarkers = markers;
        notifyListeners();
      },
      markerBuilder: _getPOIMarkerBuilder(_museumIcon, const Color(0xFF8E24AA)),
    );

    _movieTheaterClusterManager = _createClusterManager<MapPOI>(
      items: [],
      onMarkersUpdated: (markers) {
        _movieTheaterMarkers = markers;
        notifyListeners();
      },
      markerBuilder: _getPOIMarkerBuilder(_cinemaIcon, const Color(0xFFD81B60)),
    );

    _hospitalClusterManager = _createClusterManager<MapPOI>(
      items: [],
      onMarkersUpdated: (markers) {
        _hospitalMarkers = markers;
        notifyListeners();
      },
      markerBuilder: _getPOIMarkerBuilder(_hospitalIcon, const Color(0xFFC62828)),
    );

    _libraryClusterManager = _createClusterManager<MapPOI>(
      items: [],
      onMarkersUpdated: (markers) {
        _libraryMarkers = markers;
        notifyListeners();
      },
      markerBuilder: _getPOIMarkerBuilder(_libraryIcon, const Color(0xFFFBC02D)),
    );

    _consulateClusterManager = _createClusterManager<MapPOI>(
      items: [],
      onMarkersUpdated: (markers) {
        _consulateMarkers = markers;
        notifyListeners();
      },
      markerBuilder: _getPOIMarkerBuilder(_consulateIcon, const Color(0xFF0097A7)),
    );
  }

  ClusterManager<T> _createClusterManager<T extends ClusterItem>({
    required List<T> items,
    required void Function(Set<Marker>) onMarkersUpdated,
    required Future<Marker> Function(Cluster<T>) markerBuilder,
  }) {
    return ClusterManager<T>(
      items,
      (markers) => onMarkersUpdated(markers),
      markerBuilder: markerBuilder,
      levels: const [1, 4.25, 6.5, 8.5, 10.0, 11.0],
      extraPercent: 0.2,
      stopClusteringZoom: 11,
    );
  }

  Future<Marker> Function(Cluster<Station>) _getStationMarkerBuilder() =>
      (cluster) async {
        if (!cluster.isMultiple) {
          return _buildStationMarker(cluster.items.first);
        } else {
          var consumeTaps = tapable();
          return Marker(
            markerId: MarkerId(cluster.getId()),
            anchor: Offset(0.5, 0.5),
            position: cluster.location,
            icon: await _getMarkerBitmap(
              60,
              Colors.deepPurple,
              text: cluster.count.toString(),
            ),
            consumeTapEvents: consumeTaps,
            onTap: () => consumeTaps ? onTap.call(cluster.location) : null,
          );
        }
      };

  Future<Marker> Function(Cluster<MapPOI>) _getPOIMarkerBuilder(
    BitmapDescriptor icon,
    Color color,
  ) => (cluster) async {
    if (!cluster.isMultiple) {
      _addPolygon(cluster.items.first, color);
      return _buildPoiMarker(cluster.items.first, icon);
    } else {
      var consumeTaps = tapable();
      return Marker(
        markerId: MarkerId(cluster.getId()),
        anchor: Offset(0.5, 0.5),
        position: cluster.location,
        icon: await _getMarkerBitmap(60, color, text: cluster.count.toString()),
        consumeTapEvents: consumeTaps,
        onTap: () => consumeTaps ? onTap.call(cluster.location) : null,
      );
    }
  };

  Future<Marker> _buildStationMarker(Station station) async {
    var consumeTaps = tapable();
    final icon = station.type == StationType.train ? _trainIcon : _subwayIcon;
    return Marker(
      markerId: MarkerId('station_${station.id}'),
      position: station.location,
      icon: icon,
      infoWindow: InfoWindow(title: station.name, snippet: station.nameEn),
      consumeTapEvents: consumeTaps,
      onTap: () => consumeTaps ? onTap.call(station.location) : null,
    );
  }

  Future<Marker> _buildPoiMarker(MapPOI poi, BitmapDescriptor icon) async {
    var consumeTaps = tapable();
    return Marker(
      markerId: MarkerId('poi_${poi.id}'),
      position: poi.center,
      icon: icon,
      infoWindow: InfoWindow(title: poi.name, snippet: poi.nameEn),
      consumeTapEvents: consumeTaps,
      onTap: () => consumeTaps ? onTap.call(poi.center) : null,
    );
  }

  Future<BitmapDescriptor> _getMarkerBitmap(int size, Color color, {String? text}) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint1 = Paint()..color = color;
    final Paint paint2 = Paint()..color = Colors.white;

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, paint2);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.4, paint1);

    if (text != null) {
      TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
      painter.text = TextSpan(
        text: text,
        style: TextStyle(
          fontSize: size / 3,
          color: Colors.white,
          fontWeight: FontWeight.normal,
        ),
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
      );
    }

    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ImageByteFormat.png) as ByteData;

    return BitmapDescriptor.bytes(data.buffer.asUint8List());
  }

  void _addPolygon(MapPOI poi, Color color) {
    if (poi.boundary == null || poi.boundary!.isEmpty) return;
    polygons.add(
      Polygon(
        polygonId: PolygonId('${poi.type}_${poi.id}'),
        points: poi.boundary!,
        strokeWidth: 2,
        strokeColor: color,
        fillColor: color.withAlpha(102),
      ),
    );
  }

  void setStations(List<Station> stations) {
    _stationClusterManager.setItems(stations);
  }

  void setThemeParks(List<MapPOI> elements) {
    _themeParkClusterManager.setItems(elements);
  }

  void setZoos(List<MapPOI> elements) {
    _zooClusterManager.setItems(elements);
  }

  void setAquariums(List<MapPOI> elements) {
    _aquariumClusterManager.setItems(elements);
  }

  void setGolfCourses(List<MapPOI> elements) {
    _golfCourseClusterManager.setItems(elements);
  }

  void setMuseums(List<MapPOI> elements) {
    _museumClusterManager.setItems(elements);
  }

  void setMovieTheaters(List<MapPOI> elements) {
    _movieTheaterClusterManager.setItems(elements);
  }

  void setHospitals(List<MapPOI> elements) {
    _hospitalClusterManager.setItems(elements);
  }

  void setLibraries(List<MapPOI> elements) {
    _libraryClusterManager.setItems(elements);
  }

  void setConsulates(List<MapPOI> elements) {
    _consulateClusterManager.setItems(elements);
  }

  void setMapId(int mapId) {
    for (final manager in _allManagers) {
      manager.setMapId(mapId);
    }
  }

  void onCameraMove(CameraPosition position) {
    for (final manager in _allManagers) {
      if (manager.items.isNotEmpty) {
        manager.onCameraMove(position);
      }
    }
  }

  void onCameraIdle() {
    polygons.clear();
    for (final manager in _allManagers) {
      if (manager.items.isNotEmpty) {
        manager.updateMap();
      }
    }
  }

  Set<Marker> get allMarkers => {
    ..._stationMarkers,
    ..._themeParkMarkers,
    ..._zooMarkers,
    ..._aquariumMarkers,
    ..._golfCourseMarkers,
    ..._museumMarkers,
    ..._movieTheaterMarkers,
    ..._hospitalMarkers,
    ..._libraryMarkers,
    ..._consulateMarkers,
  };

  List<ClusterManager> get _allManagers => [
    _stationClusterManager,
    _themeParkClusterManager,
    _zooClusterManager,
    _aquariumClusterManager,
    _golfCourseClusterManager,
    _museumClusterManager,
    _movieTheaterClusterManager,
    _hospitalClusterManager,
    _libraryClusterManager,
    _consulateClusterManager,
  ];

  void resetAll() {
    polygons.clear();
    for (var manager in _allManagers) {
      if (manager == _stationClusterManager) {
        manager.setItems(<Station>[]);
      } else {
        manager.setItems(<MapPOI>[]);
      }
    }
  }

  static late BitmapDescriptor _trainIcon;
  static late BitmapDescriptor _subwayIcon;
  static late BitmapDescriptor _themeParkIcon;
  static late BitmapDescriptor _zooIcon;
  static late BitmapDescriptor _aquariumIcon;
  static late BitmapDescriptor _golfIcon;
  static late BitmapDescriptor _museumIcon;
  static late BitmapDescriptor _cinemaIcon;
  static late BitmapDescriptor _hospitalIcon;
  static late BitmapDescriptor _libraryIcon;
  static late BitmapDescriptor _consulateIcon;

  static Future<void> loadMarkerIcons() async {
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
}
