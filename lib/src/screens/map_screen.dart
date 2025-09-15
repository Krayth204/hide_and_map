import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

import '../models/play_area/play_area.dart';
import '../models/play_area/play_area_selector_controller.dart';
import '../widgets/play_area/play_area_selector.dart';

import '../models/extra_shape.dart';
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

  Set<Polygon> _polygons = HashSet<Polygon>();

  final Set<Marker> _extraMarkers = HashSet();
  final List<ExtraShape> _extraShapes = [];
  String? _editingShapeId;

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
        PlayArea.playArea = selected;
      });
    }
  }

  void _closeActiveAdd() {
    _activeCircleController = null;
    _activeLineController = null;
    _activePolygonController = null;
    _editingShapeId = null;
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
    if (PlayArea.playArea == null) {
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

  void _onShapeTapped(String id) {
    final shape = _extraShapes.firstWhere((s) => s.id == id);

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _editShape(shape);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Remove'),
                onTap: () {
                  setState(() {
                    _extraShapes.removeWhere((s) => s.id == id);
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _editShape(ExtraShape shape) {
    if (shape.type == ShapeType.circle &&
        shape.center != null &&
        shape.radius != null) {
      _editingShapeId = shape.id;

      _activeCircleController = AddCircleController()
        ..center = shape.center!
        ..radius = shape.radius!
        ..edit = true;

      setState(() {});
    }

    if (shape.type == ShapeType.polygon && shape.points != null) {
      _editingShapeId = shape.id;

      _activePolygonController = AddPolygonController()
        ..points = List.from(shape.points!)
        ..edit = true;

      setState(() {});
    }

    if (shape.type == ShapeType.line && shape.points != null) {
      _editingShapeId = shape.id;

      _activeLineController = AddLineController()
        ..points = List.from(shape.points!)
        ..edit = true;

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hide and Map')),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: PlayArea.playArea != null
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
              polygonsToShow.addAll(
                _extraShapes
                    .where(
                      (s) => s.type == ShapeType.polygon && s.points != null,
                    )
                    .map(
                      (s) => Polygon(
                        polygonId: PolygonId(s.id),
                        points: s.points!,
                        strokeColor: Colors.blue.shade900,
                        strokeWidth: 2,
                        fillColor: Colors.blue.withAlpha(115),
                        consumeTapEvents: _isEditable(),
                        onTap: () =>
                            _isEditable() ? _onShapeTapped(s.id) : null,
                      ),
                    )
                    .toSet(),
              ); // extra shapes
              if (_activePolygonController != null) {
                polygonsToShow.addAll(
                  _activePolygonController!.getPreviewPolygons(),
                );
              }
              if (PlayArea.playArea == null) {
                polygonsToShow.addAll(_selectorController.getPolygons());
              }

              final polylinesToShow = <Polyline>{};
              polylinesToShow.addAll(
                _extraShapes
                    .where((s) => s.type == ShapeType.line && s.points != null)
                    .map(
                      (s) => Polyline(
                        polylineId: PolylineId(s.id),
                        points: s.points!,
                        color: Colors.blue.shade900,
                        width: 4,
                        consumeTapEvents: _isEditable(),
                        onTap: () =>
                            _isEditable() ? _onShapeTapped(s.id) : null,
                      ),
                    )
                    .toSet(),
              );
              if (_activeLineController != null) {
                polylinesToShow.addAll(
                  _activeLineController!.getPreviewPolylines(),
                );
              }

              final circlesToShow = <Circle>{};
              circlesToShow.addAll(
                _extraShapes
                    .where(
                      (s) =>
                          s.type == ShapeType.circle &&
                          s.center != null &&
                          s.radius != null,
                    )
                    .map(
                      (s) => Circle(
                        circleId: CircleId(s.id),
                        center: s.center!,
                        radius: s.radius!,
                        strokeColor: Colors.blue.shade900,
                        strokeWidth: 2,
                        fillColor: Colors.blue.withAlpha(115),
                        consumeTapEvents: _isEditable(),
                        onTap: () =>
                            _isEditable() ? _onShapeTapped(s.id) : null,
                      ),
                    )
                    .toSet(),
              );
              if (_activeCircleController != null) {
                circlesToShow.addAll(
                  _activeCircleController!.getPreviewCircles(),
                );
              }
              if (PlayArea.playArea == null) {
                circlesToShow.addAll(_selectorController.getCircles());
              }

              final markersToShow = <Marker>{};
              markersToShow.addAll(_extraMarkers);
              if (PlayArea.playArea == null) {
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

          if (PlayArea.playArea == null)
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
                      _onConfirmCircle(_activeCircleController!);
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
                      _onConfirmLine(_activeLineController!);
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
                      _onConfirmPolygon(_activePolygonController!);
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _isEditable() {
    return PlayArea.playArea != null &&
        _activeCircleController == null &&
        _activeLineController == null &&
        _activePolygonController == null;
  }

  void _onConfirmCircle(AddCircleController c) {
    if (c.center == null || c.radius == 0) return;
    final id =
        _editingShapeId ??
        'extra_circle_${DateTime.now().millisecondsSinceEpoch}';
    final shape = ExtraShape.circle(id, c.center!, c.radius);

    setState(() {
      if (_editingShapeId != null) {
        final index = _extraShapes.indexWhere((s) => s.id == _editingShapeId);
        if (index != -1) _extraShapes[index] = shape;
        _editingShapeId = null;
      } else {
        _extraShapes.add(shape);
      }
      _closeActiveAdd();
    });
  }

  void _onConfirmLine(AddLineController c) {
    if (c.points.length < 2) return;
    final id =
        _editingShapeId ??
        'extra_line_${DateTime.now().millisecondsSinceEpoch}';
    final shape = ExtraShape.line(id, List.from(c.points));

    setState(() {
      if (_editingShapeId != null) {
        final index = _extraShapes.indexWhere((s) => s.id == _editingShapeId);
        if (index != -1) _extraShapes[index] = shape;
        _editingShapeId = null;
      } else {
        _extraShapes.add(shape);
      }
      _closeActiveAdd();
    });
  }

  void _onConfirmPolygon(AddPolygonController c) {
    if (c.points.length < 3) return;
    final id =
        _editingShapeId ??
        'extra_polygon_${DateTime.now().millisecondsSinceEpoch}';
    final shape = ExtraShape.polygon(id, List.from(c.points));

    setState(() {
      if (_editingShapeId != null) {
        final index = _extraShapes.indexWhere((s) => s.id == _editingShapeId);
        if (index != -1) _extraShapes[index] = shape;
        _editingShapeId = null;
      } else {
        _extraShapes.add(shape);
      }
      _closeActiveAdd();
    });
  }
}
