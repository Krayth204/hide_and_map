import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

import '../models/play_area/play_area.dart';
import '../models/play_area/play_area_selector_controller.dart';
import '../widgets/play_area/play_area_selector.dart';

import '../models/shape_controller.dart';
import '../models/extra_shape.dart';
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
  ShapeController? _activeShapeController;

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
    _activeShapeController = null;
    _editingShapeId = null;
  }

  void _openAddShape(ShapeType type) {
    _closeActiveAdd();
    setState(() {
      _activeShapeController = ShapeController(type);
    });
  }

  void _onMapTap(LatLng point) {
    if (PlayArea.playArea == null) {
      _selectorController.onMapTap(point);
    } else {
      _activeShapeController?.onMapTap(point);
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
    _editingShapeId = shape.id;
    _activeShapeController = ShapeController(shape.type)..edit = true;

    switch (shape.type) {
      case ShapeType.circle:
        _activeShapeController!.center = shape.center;
        _activeShapeController!.radius = shape.radius ?? 500;
        break;
      case ShapeType.line:
      case ShapeType.polygon:
        _activeShapeController!.points = shape.points != null
            ? List.from(shape.points!)
            : [];
        break;
    }

    setState(() {});
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
                    onPressed: () => _openAddShape(ShapeType.circle),
                    tooltip: 'Add Circle',
                    child: const Icon(Icons.circle_outlined),
                  ),
                ),
                PointerInterceptor(
                  child: FloatingActionButton(
                    onPressed: () => _openAddShape(ShapeType.line),
                    tooltip: 'Add Line',
                    child: const Icon(Icons.show_chart),
                  ),
                ),
                PointerInterceptor(
                  child: FloatingActionButton(
                    onPressed: () => _openAddShape(ShapeType.polygon),
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
              if (_activeShapeController != null) _activeShapeController!,
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
              );

              if (_activeShapeController?.type == ShapeType.polygon) {
                polygonsToShow.addAll(
                  _activeShapeController!.getPreviewPolygons(),
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
              if (_activeShapeController?.type == ShapeType.line) {
                polylinesToShow.addAll(
                  _activeShapeController!.getPreviewPolylines(),
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
              if (_activeShapeController?.type == ShapeType.circle) {
                circlesToShow.addAll(
                  _activeShapeController!.getPreviewCircles(),
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
                if (_activeShapeController != null) {
                  markersToShow.addAll(_activeShapeController!.getMarkers());
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

          if (_activeShapeController != null)
            Align(
              alignment: Alignment.topCenter,
              child: PointerInterceptor(
                child: SizedBox(
                  width: 400,
                  height: 230,
                  child: _buildShapePopup(_activeShapeController!),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShapePopup(ShapeController controller) {
    switch (controller.type) {
      case ShapeType.circle:
        return AddCirclePopup(
          controller: controller,
          onCancel: () => setState(_closeActiveAdd),
          onConfirm: () => _onConfirmShape(controller),
        );
      case ShapeType.line:
        return AddLinePopup(
          controller: controller,
          onCancel: () => setState(_closeActiveAdd),
          onConfirm: () => _onConfirmShape(controller),
        );
      case ShapeType.polygon:
        return AddPolygonPopup(
          controller: controller,
          onCancel: () => setState(_closeActiveAdd),
          onConfirm: () => _onConfirmShape(controller),
        );
    }
  }

  bool _isEditable() {
    return PlayArea.playArea != null && _activeShapeController == null;
  }

  void _onConfirmShape(ShapeController controller) {
    final id =
        _editingShapeId ??
        'extra_${controller.type.name}_${DateTime.now().millisecondsSinceEpoch}';
    final shape = controller.buildShape(id);
    if (shape == null) return;

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
