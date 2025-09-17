import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hide_and_map/src/util/color_helper.dart';
import 'package:hide_and_map/src/widgets/shape/shape_popup.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

import '../models/play_area/play_area.dart';
import '../models/play_area/play_area_selector_controller.dart';
import '../util/location_provider.dart';
import '../widgets/play_area/play_area_selector.dart';

import '../models/shape/shape_controller.dart';
import '../models/shape/shape.dart';
import 'package:hide_and_map/main.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;

  static const CameraPosition _initialCamera = CameraPosition(
    target: LatLng(49.4480, 11.0780),
    zoom: 4,
  );

  Set<Polygon> _polygons = HashSet<Polygon>();
  final Set<Marker> _markers = HashSet();
  final List<Shape> _shapes = [];
  String? _editingShapeId;
  MaterialColor? _editingShapeColor;

  late final PlayAreaSelectorController _selectorController;
  ShapeController? _activeShapeController;

  @override
  void initState() {
    super.initState();
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
    if (_editingShapeColor != null) {
      final shape = _shapes.firstWhere((s) => s.id == _editingShapeId);
      shape.color = _editingShapeColor!;
    }
    _editingShapeId = null;
    _editingShapeColor = null;
  }

  void _openAddShape(ShapeType type) {
    _closeActiveAdd();
    setState(() {
      _activeShapeController = ShapeController(type);
      if (type == ShapeType.circle) {
        LocationProvider.getLocation().then(
          (latLng) => {
            if (_activeShapeController != null && latLng != null)
              {
                if (_activeShapeController!.center == null)
                  {_activeShapeController!.onMapTap(latLng)},
              },
          },
        );
      }
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
    final shape = _shapes.firstWhere((s) => s.id == id);

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: PointerInterceptor(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit'),
                  onTap: () {
                    Navigator.pop(context);
                    _editingShapeColor = ColorHelper.copyMaterialColor(shape.color);
                    shape.color = Colors.grey;
                    _editShape(shape);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Remove'),
                  onTap: () {
                    setState(() {
                      _shapes.removeWhere((s) => s.id == id);
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editShape(Shape shape) {
    _editingShapeId = shape.id;
    _activeShapeController = ShapeController(shape.type)
      ..edit = true
      ..color = _editingShapeColor!;

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

    _activeShapeController!.inverted = shape.inverted;

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
              final preview = _activeShapeController?.getPreviewShapeObject();
              final polygonsToShow = <Polygon>{};
              polygonsToShow.addAll(_polygons); // confirmed playArea overlay
              final polylinesToShow = <Polyline>{};
              final circlesToShow = <Circle>{};
              final markersToShow = <Marker>{};

              for (final s in _shapes) {
                final obj = s.toShapeObject(
                  editable: _isEditable(),
                  onTap: _onShapeTapped,
                );

                if (obj.circle != null) circlesToShow.add(obj.circle!);
                if (obj.polyline != null) polylinesToShow.add(obj.polyline!);
                if (obj.polygon != null) polygonsToShow.add(obj.polygon!);
              }

              if (preview != null) {
                if (preview.circle != null) circlesToShow.add(preview.circle!);
                if (preview.polyline != null) polylinesToShow.add(preview.polyline!);
                if (preview.polygon != null) polygonsToShow.add(preview.polygon!);
              }

              if (PlayArea.playArea == null) {
                polygonsToShow.addAll(_selectorController.getPolygons());
                circlesToShow.addAll(_selectorController.getCircles());
              }

              markersToShow.addAll(_markers);
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
                onMapCreated: _onMapCreated,
                onTap: _onMapTap,
              );
            },
          ),

          if (PlayArea.playArea == null)
            Align(
              alignment: Alignment.topCenter,
              child: PointerInterceptor(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 400,
                      child: PlayAreaSelector(
                        controller: _selectorController,
                        onConfirmed: _onConfirmInitial,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (_activeShapeController != null)
            Align(
              alignment: Alignment.topCenter,
              child: PointerInterceptor(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 400,
                      child: _buildShapePopup(_activeShapeController!),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShapePopup(ShapeController controller) {
    return ShapePopup(
      controller: controller,
      onCancel: () => setState(_closeActiveAdd),
      onConfirm: () => _onConfirmShape(controller),
    );
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
        _editingShapeColor = null;
        final index = _shapes.indexWhere((s) => s.id == _editingShapeId);
        if (index != -1) _shapes[index] = shape;
      } else {
        _shapes.add(shape);
      }
      _closeActiveAdd();
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;

    LocationProvider.requestPermission().then(
      (granted) => {
        if (granted)
          {
            if (PlayArea.playArea != null)
              {
                _controller!.animateCamera(
                  CameraUpdate.newLatLng(PlayArea.playArea!.getCenter()),
                ),
              }
            else
              {
                LocationProvider.getLocation().then(
                  (latLng) async => {
                    if (latLng != null)
                      {
                        _controller!.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(target: latLng, zoom: 8),
                          ),
                        ),
                      },
                  },
                ),
              },
          },
      },
    );
  }
}
