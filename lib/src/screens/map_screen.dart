import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

import '../models/play_area/play_area.dart';
import '../models/play_area/play_area_selector_controller.dart';
import '../widgets/play_area/play_area_selector.dart';

import '../models/add_shape/add_circle_controller.dart';
import '../models/add_shape/add_line_controller.dart';
import '../models/add_shape/add_polygon_controller.dart';
import '../widgets/add_shape/add_circle_popup.dart';
import '../widgets/add_shape/add_line_popup.dart';
import '../widgets/add_shape/add_polygon_popup.dart';

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

  Set<Polygon> _extraPolygons = HashSet();
  Set<Polyline> _extraPolylines = HashSet();
  Set<Circle> _extraCircles = HashSet();
  Set<Marker> _extraMarkers = HashSet();

  late final PlayAreaSelectorController _selectorController;

  AddCircleController? _activeCircleController;
  AddLineController? _activeLineController;
  AddPolygonController? _activePolygonController;

  @override
  void initState() {
    super.initState();
    Permission.location.request();
    _selectorController = PlayAreaSelectorController();
  }

  void _onConfirmInitial() {
    final selected = _selectorController.confirm();
    if (selected != null) {
      _polygons = PlayArea.buildOverlay(selected);
      setState(() {
        _playArea = selected;
      });
    }
  }

  void _closeActiveAdd() {
    _activeCircleController = null;
    _activeLineController = null;
    _activePolygonController = null;
  }

  void _openAddCircle() {
    _closeActiveAdd();
    setState(() {
      _activeCircleController = AddCircleController();
    });
  }

  void _openAddLine() {
    _closeActiveAdd();
    setState(() {
      _activeLineController = AddLineController();
    });
  }

  void _openAddPolygon() {
    _closeActiveAdd();
    setState(() {
      _activePolygonController = AddPolygonController();
    });
  }

  void _onMapTap(LatLng point) {
    if (_playArea == null) {
      _selectorController.onMapTap(point);
    } else {
      if (_activeCircleController != null) {
        _activeCircleController!.onMapTap(point);
        return;
      }
      if (_activeLineController != null) {
        _activeLineController!.onMapTap(point);
        return;
      }
      if (_activePolygonController != null) {
        _activePolygonController!.onMapTap(point);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hide and Map')),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: _playArea != null
          ? ExpandableFab(
              pos: ExpandableFabPos.right,
              type: ExpandableFabType.up,
              distance: 60,
              openButtonBuilder: RotateFloatingActionButtonBuilder(
                backgroundColor: Colors.blueAccent,
                child: const Icon(Icons.add, size: 28),
              ),
              children: [
                PointerInterceptor(
                  child: FloatingActionButton(
                    onPressed: () {
                      _openAddCircle();
                    },
                    tooltip: 'Add Circle',
                    child: const Icon(Icons.circle_outlined),
                  ),
                ),
                PointerInterceptor(
                  child: FloatingActionButton(
                    onPressed: () {
                      _openAddLine();
                    },
                    tooltip: 'Add Line',
                    child: const Icon(Icons.show_chart),
                  ),
                ),
                PointerInterceptor(
                  child: FloatingActionButton(
                    onPressed: () {
                      _openAddPolygon();
                    },
                    tooltip: 'Add Polygon',
                    child: const Icon(Icons.change_history),
                  ),
                ),
              ],
            )
          : null,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([
              _selectorController,
              if (_activeCircleController != null) _activeCircleController!,
              if (_activeLineController != null) _activeLineController!,
              if (_activePolygonController != null) _activePolygonController!,
            ]),
            builder: (_, __) {
              final polygonsToShow = <Polygon>{};
              polygonsToShow.addAll(_polygons); // confirmed playArea overlay
              polygonsToShow.addAll(_extraPolygons); // extra shapes

              if (_activePolygonController != null) {
                polygonsToShow.addAll(
                  _activePolygonController!.getPreviewPolygons(),
                );
              }

              if (_playArea == null) {
                polygonsToShow.addAll(_selectorController.getPolygons());
              }

              final polylinesToShow = <Polyline>{};
              polylinesToShow.addAll(_extraPolylines);
              if (_activeLineController != null) {
                polylinesToShow.addAll(
                  _activeLineController!.getPreviewPolylines(),
                );
              }

              final circlesToShow = <Circle>{};
              circlesToShow.addAll(_extraCircles);
              if (_activeCircleController != null) {
                circlesToShow.addAll(
                  _activeCircleController!.getPreviewCircles(),
                );
              }

              if (_playArea == null) {
                circlesToShow.addAll(_selectorController.getCircles());
              }

              final markersToShow = <Marker>{};
              markersToShow.addAll(_extraMarkers);
              if (_playArea == null) {
                markersToShow.addAll(_selectorController.getMarkers());
              } else {
                if (_activeCircleController != null) {
                  markersToShow.addAll(_activeCircleController!.getMarkers());
                }
                if (_activeLineController != null) {
                  markersToShow.addAll(_activeLineController!.getMarkers());
                }
                if (_activePolygonController != null) {
                  markersToShow.addAll(_activePolygonController!.getMarkers());
                }
              }

              return GoogleMap(
                initialCameraPosition: _initialCamera,
                style: mapStyle,
                mapType: MapType.normal,
                webCameraControlEnabled: false,
                zoomControlsEnabled: false,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                polygons: polygonsToShow,
                polylines: polylinesToShow,
                circles: circlesToShow,
                markers: markersToShow,
                onMapCreated: (controller) => _controller = controller,
                onTap: _onMapTap,
              );
            },
          ),

          if (_playArea == null)
            Align(
              alignment: Alignment.topCenter,
              child: PointerInterceptor(
                child: SizedBox(
                  width: 400,
                  height: 270,
                  child: PlayAreaSelector(
                    controller: _selectorController,
                    onConfirmed: _onConfirmInitial,
                  ),
                ),
              ),
            ),

          if (_activeCircleController != null)
            Align(
              alignment: Alignment.topCenter,
              child: PointerInterceptor(
                child: SizedBox(
                  width: 400,
                  height: 230,
                  child: AddCirclePopup(
                    controller: _activeCircleController!,
                    onCancel: () {
                      setState(() => _closeActiveAdd());
                    },
                    onConfirm: () {
                      final c = _activeCircleController!;
                      if (c.center != null) {
                        final id = CircleId(
                          'extra_circle_${DateTime.now().millisecondsSinceEpoch}',
                        );
                        final circle = Circle(
                          circleId: id,
                          center: c.center!,
                          radius: c.radius,
                          strokeColor: Colors.blue.shade900,
                          strokeWidth: 2,
                          fillColor: Colors.blue.withOpacity(0.45),
                        );
                        setState(() {
                          _extraCircles = Set.from(_extraCircles)..add(circle);
                          _closeActiveAdd();
                        });
                      }
                    },
                  ),
                ),
              ),
            ),

          if (_activeLineController != null)
            Align(
              alignment: Alignment.topCenter,
              child: PointerInterceptor(
                child: SizedBox(
                  width: 400,
                  height: 230,
                  child: AddLinePopup(
                    controller: _activeLineController!,
                    onCancel: () {
                      setState(() => _closeActiveAdd());
                    },
                    onConfirm: () {
                      final c = _activeLineController!;
                      if (c.points.length >= 2) {
                        final id = PolylineId(
                          'extra_line_${DateTime.now().millisecondsSinceEpoch}',
                        );
                        final pl = Polyline(
                          polylineId: id,
                          points: List.from(c.points),
                          color: Colors.blue.shade900,
                          width: 4,
                        );
                        setState(() {
                          _extraPolylines = Set.from(_extraPolylines)..add(pl);
                          _closeActiveAdd();
                        });
                      }
                    },
                  ),
                ),
              ),
            ),

          if (_activePolygonController != null)
            Align(
              alignment: Alignment.topCenter,
              child: PointerInterceptor(
                child: SizedBox(
                  width: 400,
                  height: 230,
                  child: AddPolygonPopup(
                    controller: _activePolygonController!,
                    onCancel: () {
                      setState(() => _closeActiveAdd());
                    },
                    onConfirm: () {
                      final c = _activePolygonController!;
                      if (c.points.length >= 3) {
                        final id = PolygonId(
                          'extra_polygon_${DateTime.now().millisecondsSinceEpoch}',
                        );
                        final pg = Polygon(
                          polygonId: id,
                          points: List.from(c.points),
                          strokeColor: Colors.blue.shade900,
                          strokeWidth: 2,
                          fillColor: Colors.blue.withOpacity(0.45),
                        );
                        setState(() {
                          _extraPolygons = Set.from(_extraPolygons)..add(pg);
                          _closeActiveAdd();
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
