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
import 'map_overlay.dart';
import 'station.dart';

class PoiConfig {
  final POIType type;
  final Color color;
  final BitmapDescriptor Function() icon;

  const PoiConfig({required this.type, required this.color, required this.icon});
}

class FeatureMarkerProvider extends ChangeNotifier {
  final void Function(LatLng point, MarkerId markerId) _onMarkerTap;
  final void Function(MapOverlay overlay) _onOverlayTap;

  final Set<Polygon> _polygons = {};
  final Set<Polygon> _overlayPolygons = {};
  final Set<Circle> _circles = {};

  Set<Polygon> get getPolygons => {..._polygons, ..._overlayPolygons};
  Set<Circle> get getCircles => {..._circles};

  bool _hidingZonesVisible = false;
  double _hidingZoneSize = prefs.hidingZoneSize;
  bool get hidingZonesVisible => _hidingZonesVisible;

  bool dataChanged = false;

  late ClusterManager<Station> _stationClusterManager;
  Set<Marker> _stationMarkers = {};

  final Map<POIType, ClusterManager<MapPOI>> _poiManagers = {};
  final Map<POIType, Set<Marker>> _poiMarkers = {};

  FeatureMarkerProvider(this._onMarkerTap, this._onOverlayTap) {
    init();
  }

  final Map<POIType, PoiConfig> _poiConfigs = {
    POIType.themePark: PoiConfig(
      type: POIType.themePark,
      color: const Color(0xFFFF6F00),
      icon: () => icons.themeParkIcon,
    ),
    POIType.zoo: PoiConfig(
      type: POIType.zoo,
      color: const Color(0xFF43A047),
      icon: () => icons.zooIcon,
    ),
    POIType.aquarium: PoiConfig(
      type: POIType.aquarium,
      color: const Color(0xFF3949AB),
      icon: () => icons.aquariumIcon,
    ),
    POIType.golfCourse: PoiConfig(
      type: POIType.golfCourse,
      color: const Color(0xFF7CB342),
      icon: () => icons.golfIcon,
    ),
    POIType.museum: PoiConfig(
      type: POIType.museum,
      color: const Color(0xFF8E24AA),
      icon: () => icons.museumIcon,
    ),
    POIType.movieTheater: PoiConfig(
      type: POIType.movieTheater,
      color: const Color(0xFFD81B60),
      icon: () => icons.cinemaIcon,
    ),
    POIType.hospital: PoiConfig(
      type: POIType.hospital,
      color: const Color(0xFFC62828),
      icon: () => icons.hospitalIcon,
    ),
    POIType.library: PoiConfig(
      type: POIType.library,
      color: const Color(0xFFFBC02D),
      icon: () => icons.libraryIcon,
    ),
    POIType.consulate: PoiConfig(
      type: POIType.consulate,
      color: const Color(0xFF0097A7),
      icon: () => icons.consulateIcon,
    ),
  };

  void init() async {
    _stationClusterManager = _createClusterManager<Station>(
      items: [],
      onMarkersUpdated: (markers) {
        _stationMarkers = markers;
        notifyListeners();
      },
      markerBuilder: _getStationMarkerBuilder(),
    );

    for (final config in _poiConfigs.values) {
      _poiManagers[config.type] = _createClusterManager<MapPOI>(
        items: [],
        onMarkersUpdated: (markers) {
          _poiMarkers[config.type] = markers;
          notifyListeners();
        },
        markerBuilder: _getPoiMarkerBuilder(config),
      );
    }

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
      onMarkersUpdated,
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
        }

        final markerId = MarkerId(cluster.getId());
        return Marker(
          markerId: markerId,
          position: cluster.location,
          anchor: const Offset(0.5, 0.5),
          icon: await _getMarkerBitmap(
            60,
            Colors.deepPurple,
            text: cluster.count.toString(),
          ),
          consumeTapEvents: true,
          onTap: () => _onMarkerTap(cluster.location, markerId),
        );
      };

  Future<Marker> Function(Cluster<MapPOI>) _getPoiMarkerBuilder(PoiConfig config) =>
      (cluster) async {
        if (!cluster.isMultiple) {
          _addPolygon(cluster.items.first, config.color);
          return _buildPoiMarker(cluster.items.first, config.icon());
        }

        final markerId = MarkerId(cluster.getId());
        return Marker(
          markerId: markerId,
          position: cluster.location,
          anchor: const Offset(0.5, 0.5),
          icon: await _getMarkerBitmap(60, config.color, text: cluster.count.toString()),
          consumeTapEvents: true,
          onTap: () => _onMarkerTap(cluster.location, markerId),
        );
      };

  Future<Marker> _buildStationMarker(Station station) async {
    String title = station.name;

    if (LocationProvider.lastLocation.latitude != 0.0 &&
        LocationProvider.lastLocation.longitude != 0.0) {
      title +=
          ' (${GeoMath.toDistanceString(GeoMath.distanceInMeters(LocationProvider.lastLocation, station.location))})';
    }

    final markerId = MarkerId('station_${station.id}');
    return Marker(
      markerId: markerId,
      position: station.location,
      icon: _getStationIcon(station.type),
      infoWindow: InfoWindow(title: title, snippet: station.nameEn),
      consumeTapEvents: true,
      onTap: () => _onMarkerTap(station.location, markerId),
    );
  }

  BitmapDescriptor _getStationIcon(StationType type) {
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
      case StationType.ferry:
        return icons.ferryIcon;
    }
  }

  Future<Marker> _buildPoiMarker(MapPOI poi, BitmapDescriptor icon) async {
    String title = poi.name;

    if (LocationProvider.lastLocation.latitude != 0.0 &&
        LocationProvider.lastLocation.longitude != 0.0) {
      title +=
          ' (${GeoMath.toDistanceString(GeoMath.distanceInMeters(LocationProvider.lastLocation, poi.center))})';
    }

    final markerId = MarkerId('${poi.type.name}_${poi.id}');
    return Marker(
      markerId: markerId,
      position: poi.center,
      icon: icon,
      infoWindow: InfoWindow(title: title, snippet: poi.nameEn),
      consumeTapEvents: true,
      onTap: () => _onMarkerTap(poi.center, markerId),
    );
  }

  Future<BitmapDescriptor> _getMarkerBitmap(int size, Color color, {String? text}) async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    final paint1 = Paint()..color = color;
    final paint2 = Paint()..color = Colors.white;

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint1);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, paint2);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.4, paint1);

    if (text != null) {
      final painter = TextPainter(textDirection: TextDirection.ltr)
        ..text = TextSpan(
          text: text,
          style: TextStyle(fontSize: size / 3, color: Colors.white),
        )
        ..layout();

      painter.paint(
        canvas,
        Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
      );
    }

    final image = await recorder.endRecording().toImage(size, size);
    final bytes = await image.toByteData(format: ImageByteFormat.png) as ByteData;

    return BitmapDescriptor.bytes(bytes.buffer.asUint8List());
  }

  void _addCircle(Station station) {
    if (!_hidingZonesVisible) return;

    if (_circles.any((c) => GeoMath.distanceInMeters(c.center, station.location) < 316)) {
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

  void setOverlays(MapOverlayType type, List<MapOverlay> overlays) {
    _overlayPolygons.removeWhere((p) => p.polygonId.value.startsWith(type.name));

    for (final overlay in overlays) {
      if (overlay.boundaryPolygons.isEmpty) continue;

      _overlayPolygons.addAll(overlay.toPolygons(_onOverlayTap));
    }

    dataChanged = true;
    notifyListeners();
  }

  void setStations(List<Station> stations) {
    dataChanged = true;
    _circles.clear();
    _stationClusterManager.setItems(stations);
  }

  void setPOIs(POIType type, List<MapPOI> items) {
    dataChanged = true;
    _poiManagers[type]?.setItems(items);

    if (items.isEmpty) {
      _polygons.removeWhere((p) => p.mapsId.value.startsWith(type.name));
    }
  }

  void setHidingZonesVisible(bool value) {
    _hidingZonesVisible = value;
    dataChanged = true;
    _circles.clear();
    _stationClusterManager.updateMap();
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
    for (final markers in _poiMarkers.values) ...markers,
  };

  List<ClusterManager> get _allManagers => [
    _stationClusterManager,
    ..._poiManagers.values,
  ];

  void resetAll() {
    _polygons.clear();
    _overlayPolygons.clear();
    _circles.clear();
    _stationClusterManager.setItems(<Station>[]);

    for (final manager in _poiManagers.values) {
      manager.setItems(<MapPOI>[]);
    }

    dataChanged = true;
  }
}
