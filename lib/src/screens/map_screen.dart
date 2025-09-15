import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import '../models/play_area/play_area.dart';
import '../models/play_area/play_area_selector_controller.dart';
import '../widgets/play_area_selector.dart';
import 'package:hide_and_map/main.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final GoogleMapController _controller;

  static const CameraPosition _initialCamera = CameraPosition(
    target: LatLng(49.4480, 11.0780),
    zoom: 13,
  );

  PlayArea? _playArea;
  Set<Polygon> _polygons = HashSet<Polygon>();
  late final PlayAreaSelectorController _selectorController;

  @override
  void initState() {
    super.initState();
    Permission.location.request();
    _selectorController = PlayAreaSelectorController();
  }

  void _onConfirm() {
    final selected = _selectorController.confirm();
    if (selected != null) {
      _polygons = PlayArea.buildOverlay(selected);
      setState(() {
        _playArea = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hide and Map')),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _selectorController,
            builder: (_, __) {
              return GoogleMap(
                initialCameraPosition: _initialCamera,
                style: mapStyle,
                mapType: MapType.normal,
                webCameraControlEnabled: false,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                polygons:
                    _playArea == null &&
                        _selectorController.mode == SelectionMode.polygon
                    ? _selectorController.getPolygons()
                    : _polygons,
                circles:
                    _playArea == null &&
                        _selectorController.mode == SelectionMode.circle
                    ? _selectorController.getCircles()
                    : {},
                markers: _playArea == null
                    ? _selectorController.getMarkers()
                    : {},
                onMapCreated: (controller) => _controller = controller,
                onTap: (point) {
                  if (_playArea == null) _selectorController.onMapTap(point);
                },
              );
            },
          ),
          if (_playArea == null)
            Align(
              alignment: Alignment.topCenter,
              child: PointerInterceptor(
                child: SizedBox(
                  width: 400,
                  height: 230,
                  child: PlayAreaSelector(
                    controller: _selectorController,
                    onConfirmed: _onConfirm,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
