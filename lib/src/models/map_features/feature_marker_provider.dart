import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'
    hide ClusterManager, Cluster;

import '../../../main.dart';
import '../../util/geo_math.dart';
import '../../util/location_provider.dart';
import 'map_poi.dart';
import 'station.dart';

class FeatureMarkerProvider extends ChangeNotifier {
  final void Function(LatLng point, MarkerId markerId) _onMarkerTap;
  final Set<Polygon> _polygons = {};
  final Set<Circle> _circles = {};
  Set<Polygon> get getPolygons => {..._polygons};
  Set<Circle> get getCircles => {..._circles};
  bool _hidingZonesVisible = false;
  double _hidingZoneSize = prefs.hidingZoneSize;

  bool dataChanged = false;

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

  FeatureMarkerProvider(this._onMarkerTap) {
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
      markerBuilder: _getPOIMarkerBuilder(const Color(0xFFFF6F00)),
    );

    _zooClusterManager = _createClusterManager<MapPOI>(
      items: [],
      onMarkersUpdated: (markers) {
        _zooMarkers = markers;
        notifyListeners();
      },
      markerBuilder: _getPOIMarkerBuilder(const Color(0xFF43A047)),
    );

    _aquariumClusterManager = _createClusterManager<MapPOI>(
      items: [],
      onMarkersUpdated: (markers) {
        _aquariumMarkers = markers;
        notifyListeners();
      },
      markerBuilder: _getPOIMarkerBuilder(const Color(0xFF3949AB)),
    );

    _golfCourseClusterManager = _createClusterManager<MapPOI>(
      items: [],
      onMarkersUpdated: (markers) {
        _golfCourseMarkers = markers;
        notifyListeners();
      },
      markerBuilder: _getPOIMarkerBuilder(const Color(0xFF7CB342)),
    );

    _museumClusterManager = _createClusterManager<MapPOI>(
      items: [],
      onMarkersUpdated: (markers) {
        _museumMarkers = markers;
        notifyListeners();
      },
      markerBuilder: _getPOIMarkerBuilder(const Color(0xFF8E24AA)),
    );

    _movieTheaterClusterManager = _createClusterManager<MapPOI>(
      items: [],
      onMarkersUpdated: (markers) {
        _movieTheaterMarkers = markers;
        notifyListeners();
      },
      markerBuilder: _getPOIMarkerBuilder(const Color(0xFFD81B60)),
    );

    _hospitalClusterManager = _createClusterManager<MapPOI>(
      items: [],
      onMarkersUpdated: (markers) {
        _hospitalMarkers = markers;
        notifyListeners();
      },
      markerBuilder: _getPOIMarkerBuilder(const Color(0xFFC62828)),
    );

    _libraryClusterManager = _createClusterManager<MapPOI>(
      items: [],
      onMarkersUpdated: (markers) {
        _libraryMarkers = markers;
        notifyListeners();
      },
      markerBuilder: _getPOIMarkerBuilder(const Color(0xFFFBC02D)),
    );

    _consulateClusterManager = _createClusterManager<MapPOI>(
      items: [],
      onMarkersUpdated: (markers) {
        _consulateMarkers = markers;
        notifyListeners();
      },
      markerBuilder: _getPOIMarkerBuilder(const Color(0xFF0097A7)),
    );

    prefs.addListener(() {
      if (prefs.hidingZoneSize != _hidingZoneSize) {
        _hidingZoneSize = prefs.hidingZoneSize;
        setHidingZonesVisible(_hidingZonesVisible);
      }
    });
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
          _addCircle(cluster.items.first);
          return _buildStationMarker(cluster.items.first);
        } else {
          final markerId = MarkerId(cluster.getId());
          return Marker(
            markerId: markerId,
            anchor: Offset(0.5, 0.5),
            position: cluster.location,
            icon: await _getMarkerBitmap(
              60,
              Colors.deepPurple,
              text: cluster.count.toString(),
            ),
            consumeTapEvents: true,
            onTap: () => _onMarkerTap.call(cluster.location, markerId),
          );
        }
      };

  Future<Marker> Function(Cluster<MapPOI>) _getPOIMarkerBuilder(Color color) =>
      (cluster) async {
        if (!cluster.isMultiple) {
          _addPolygon(cluster.items.first, color);
          return _buildPoiMarker(cluster.items.first);
        } else {
          final markerId = MarkerId(cluster.getId());
          return Marker(
            markerId: MarkerId(cluster.getId()),
            anchor: Offset(0.5, 0.5),
            position: cluster.location,
            icon: await _getMarkerBitmap(60, color, text: cluster.count.toString()),
            consumeTapEvents: true,
            onTap: () => _onMarkerTap.call(cluster.location, markerId),
          );
        }
      };

  Future<Marker> _buildStationMarker(Station station) async {
    final icon = _getStationMarker(station.type);
    String? distance;
    if (LocationProvider.lastLocation.latitude != 0.0 &&
        LocationProvider.lastLocation.longitude != 0.0) {
      distance = GeoMath.toDistanceString(
        GeoMath.distanceInMeters(LocationProvider.lastLocation, station.location),
      );
    }
    String title = station.name;
    title += distance != null ? ' ($distance)' : '';
    final markerId = MarkerId('station_${station.id}');
    return Marker(
      markerId: markerId,
      position: station.location,
      icon: icon,
      infoWindow: InfoWindow(title: title, snippet: station.nameEn),
      consumeTapEvents: true,
      onTap: () => _onMarkerTap.call(station.location, markerId),
    );
  }

  BitmapDescriptor _getStationMarker(StationType type) {
    switch (type) {
      case StationType.trainStation:
        return icons.trainStationIcon;
      case StationType.trainStop:
        return icons.trainStopIcon;
      case StationType.subway:
        return icons.subwayIcon;
      case StationType.tram:
        return icons.tramIcon;
      case StationType.bus:
        return icons.busIcon;
    }
  }

  Future<Marker> _buildPoiMarker(MapPOI poi) async {
    final icon = _getPoiMarker(poi.type);
    String? distance;
    if (LocationProvider.lastLocation.latitude != 0.0 &&
        LocationProvider.lastLocation.longitude != 0.0) {
      distance = GeoMath.toDistanceString(
        GeoMath.distanceInMeters(LocationProvider.lastLocation, poi.center),
      );
    }
    String title = poi.name;
    title += distance != null ? ' ($distance)' : '';
    final markerId = MarkerId('${poi.type.name}_${poi.id}');
    return Marker(
      markerId: markerId,
      position: poi.center,
      icon: icon,
      infoWindow: InfoWindow(title: title, snippet: poi.nameEn),
      consumeTapEvents: true,
      onTap: () => _onMarkerTap.call(poi.center, markerId),
    );
  }

  BitmapDescriptor _getPoiMarker(POIType type) {
    switch (type) {
      case POIType.themePark:
        return icons.themeParkIcon;
      case POIType.zoo:
        return icons.zooIcon;
      case POIType.aquarium:
        return icons.aquariumIcon;
      case POIType.golfCourse:
        return icons.golfIcon;
      case POIType.museum:
        return icons.museumIcon;
      case POIType.movieTheater:
        return icons.cinemaIcon;
      case POIType.hospital:
        return icons.hospitalIcon;
      case POIType.library:
        return icons.libraryIcon;
      case POIType.consulate:
        return icons.consulateIcon;
    }
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

  void _addCircle(Station station) {
    if (!_hidingZonesVisible) return;
    if (_circles.any(
      (cirlce) => GeoMath.distanceInMeters(cirlce.center, station.location) < 316,
    )) {
      return;
    }
    _circles.add(
      Circle(
        circleId: CircleId('zone_${station.id}'),
        center: station.location,
        radius: _hidingZoneSize,
        fillColor: Colors.teal.withAlpha(20),
        strokeColor: Colors.teal.withAlpha(100),
        strokeWidth: 2,
      ),
    );
  }

  void _addPolygon(MapPOI poi, Color color) {
    if (poi.boundary == null || poi.boundary!.isEmpty) return;
    _polygons.add(
      Polygon(
        polygonId: PolygonId('${poi.type.name}_${poi.id}'),
        points: poi.boundary!,
        strokeWidth: 2,
        strokeColor: color,
        fillColor: color.withAlpha(102),
      ),
    );
  }

  void setStations(List<Station> stations) {
    dataChanged = true;
    _circles.clear();
    _stationClusterManager.setItems(stations);
  }

  bool get hidingZonesVisible => _hidingZonesVisible;

  void setHidingZonesVisible(bool value) {
    _hidingZonesVisible = value;
    dataChanged = true;
    _circles.clear();
    _stationClusterManager.updateMap();
  }

  void setThemeParks(List<MapPOI> elements) {
    dataChanged = true;
    _themeParkClusterManager.setItems(elements);
    if (elements.isEmpty) {
      _polygons.removeWhere((poly) => poly.mapsId.value.startsWith('themePark'));
    }
  }

  void setZoos(List<MapPOI> elements) {
    dataChanged = true;
    _zooClusterManager.setItems(elements);
    if (elements.isEmpty) {
      _polygons.removeWhere((poly) => poly.mapsId.value.startsWith('zoo'));
    }
  }

  void setAquariums(List<MapPOI> elements) {
    dataChanged = true;
    _aquariumClusterManager.setItems(elements);
    if (elements.isEmpty) {
      _polygons.removeWhere((poly) => poly.mapsId.value.startsWith('aquarium'));
    }
  }

  void setGolfCourses(List<MapPOI> elements) {
    dataChanged = true;
    _golfCourseClusterManager.setItems(elements);
    if (elements.isEmpty) {
      _polygons.removeWhere((poly) => poly.mapsId.value.startsWith('golfCourse'));
    }
  }

  void setMuseums(List<MapPOI> elements) {
    dataChanged = true;
    _museumClusterManager.setItems(elements);
    if (elements.isEmpty) {
      _polygons.removeWhere((poly) => poly.mapsId.value.startsWith('museum'));
    }
  }

  void setMovieTheaters(List<MapPOI> elements) {
    dataChanged = true;
    _movieTheaterClusterManager.setItems(elements);
    if (elements.isEmpty) {
      _polygons.removeWhere((poly) => poly.mapsId.value.startsWith('movieTheater'));
    }
  }

  void setHospitals(List<MapPOI> elements) {
    dataChanged = true;
    _hospitalClusterManager.setItems(elements);
    if (elements.isEmpty) {
      _polygons.removeWhere((poly) => poly.mapsId.value.startsWith('hospital'));
    }
  }

  void setLibraries(List<MapPOI> elements) {
    dataChanged = true;
    _libraryClusterManager.setItems(elements);
    if (elements.isEmpty) {
      _polygons.removeWhere((poly) => poly.mapsId.value.startsWith('library'));
    }
  }

  void setConsulates(List<MapPOI> elements) {
    dataChanged = true;
    _consulateClusterManager.setItems(elements);
    if (elements.isEmpty) {
      _polygons.removeWhere((poly) => poly.mapsId.value.startsWith('consulate'));
    }
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
    _polygons.clear();
    _circles.clear();
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
    _polygons.clear();
    _circles.clear();
    for (var manager in _allManagers) {
      if (manager == _stationClusterManager) {
        manager.setItems(<Station>[]);
      } else {
        manager.setItems(<MapPOI>[]);
      }
    }
    dataChanged = true;
  }
}
