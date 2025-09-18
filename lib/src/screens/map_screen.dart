import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hide_and_map/src/util/color_helper.dart';
import 'package:hide_and_map/src/widgets/shape/shape_popup.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

import '../models/game_state.dart';
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
  GameState gameState = GameState();
  GoogleMapController? _controller;

  static const CameraPosition _initialCamera = CameraPosition(
    target: LatLng(49.4480, 11.0780),
    zoom: 4,
  );
  late Future gameStateLoadedFuture;

  Set<Polygon> _polygons = HashSet<Polygon>();
  String? _editingShapeId;
  MaterialColor? _editingShapeColor;

  final PlayAreaSelectorController _selectorController = PlayAreaSelectorController();
  ShapeController? _activeShapeController;

  @override
  void initState() {
    super.initState();
    gameStateLoadedFuture = GameState.loadGameState().then(
      (gS) => {
        if (gS.playArea != null) {_loadGameState(gS)},
      },
    );
  }

  void _loadGameState(GameState gS) {
    _polygons = PlayArea.buildOverlay(gS.playArea);
    setState(() {
      gameState = gS;
    });
  }

  void _onConfirmInitial() {
    final selected = _selectorController.confirm();
    if (selected != null) {
      _loadGameState(gameState.copyWith(playArea: selected));
      GameState.saveGameState(gameState);
    }
  }

  void _closeActiveAdd() {
    _activeShapeController = null;
    if (_editingShapeColor != null) {
      final shape = gameState.shapes.firstWhere((s) => s.id == _editingShapeId);
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
    if (gameState.playArea == null) {
      _selectorController.onMapTap(point);
    } else {
      _activeShapeController?.onMapTap(point);
    }
  }

  void _onShapeTapped(String id) {
    final shape = gameState.shapes.firstWhere((s) => s.id == id);

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
                      gameState.shapes.removeWhere((s) => s.id == id);
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
      floatingActionButton: gameState.playArea != null
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
              final polylinesToShow = <Polyline>{};
              final circlesToShow = <Circle>{};
              final markersToShow = <Marker>{};

              if (gameState.playArea == null) {
                polygonsToShow.addAll(_selectorController.getPolygons());
                circlesToShow.addAll(_selectorController.getCircles());
                markersToShow.addAll(_selectorController.getMarkers());
              } else {
                for (final s in gameState.shapes) {
                  final obj = s.toShapeObject(
                    gameState.playArea!,
                    editable: _isEditable(),
                    onTap: _onShapeTapped,
                  );

                  if (obj.circle != null) circlesToShow.add(obj.circle!);
                  if (obj.polyline != null) polylinesToShow.add(obj.polyline!);
                  if (obj.polygon != null) polygonsToShow.add(obj.polygon!);
                }

                if (_activeShapeController != null) {
                  final preview = _activeShapeController!.getPreviewShapeObject(
                    gameState.playArea!,
                  );
                  if (preview.circle != null) circlesToShow.add(preview.circle!);
                  if (preview.polyline != null) polylinesToShow.add(preview.polyline!);
                  if (preview.polygon != null) polygonsToShow.add(preview.polygon!);

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

          if (gameState.playArea == null)
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
    return gameState.playArea != null && _activeShapeController == null;
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
        final index = gameState.shapes.indexWhere((s) => s.id == _editingShapeId);
        if (index != -1) gameState.shapes[index] = shape;
      } else {
        gameState.shapes.add(shape);
      }
      _closeActiveAdd();
    });
    GameState.saveGameState(gameState);
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;

    gameStateLoadedFuture.then(
      (_) => {
        if (gameState.playArea != null)
          {
            _controller!.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(target: gameState.playArea!.getCenter(), zoom: 8),
              ),
            ),
          },
        LocationProvider.requestPermission().then(
          (granted) => {
            if (granted)
              {
                if (gameState.playArea == null)
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
        ),
      },
    );
  }

  @override
  void dispose() {
    GameState.saveGameState(gameState);
    super.dispose();
  }
}
