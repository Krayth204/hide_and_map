import 'dart:collection';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

import '../../main.dart';
import '../models/game_state.dart';
import '../models/map_features/map_features_controller.dart';
import '../models/play_area/play_area.dart';
import '../models/play_area/play_area_selector_controller.dart';
import '../models/shape/shape_factory.dart';
import '../util/color_helper.dart';
import '../util/location_provider.dart';
import '../widgets/import_export/import_dialog.dart';
import '../widgets/import_export/share_dialog.dart';
import '../widgets/map_features/map_features_panel.dart';
import '../widgets/map_type_popup.dart';
import '../widgets/play_area/play_area_selector.dart';

import '../models/shape/shape_controller.dart';
import '../models/shape/shape.dart';
import '../widgets/shape/shape_popup.dart';

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
  LatLng? _locationForWeb;
  BitmapDescriptor? _iconForWeb;

  final PlayAreaSelectorController _selectorController = PlayAreaSelectorController();
  final MapFeaturesController _featuresController = MapFeaturesController();
  ShapeController? _activeShapeController;
  bool _isBottomSheetOpen = false;

  @override
  void initState() {
    super.initState();
    gameStateLoadedFuture = GameState.loadGameState().then(
      (gS) => {
        if (gS.playArea != null) {_loadGameState(gS)},
      },
    );
    if (kIsWeb) {
      BitmapDescriptor.asset(
        ImageConfiguration(size: const Size(16, 16)),
        'assets/markers/blue_marker.png',
      ).then(
        (asset) => {
          setState(() {
            _iconForWeb = asset;
          }),
        },
      );
    }
  }

  void _loadGameState(GameState gS) {
    _activeShapeController = null;
    _editingShapeId = null;
    _editingShapeColor = null;
    _polygons = PlayArea.buildOverlay(gS.playArea);
    if (gS.playArea != null) {
      _featuresController.setPlayAreaBoundary(gS.playArea!.getBoundary());
    }
    setState(() {
      gameState = gS;
    });
    GameState.saveGameState(gS);
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
    var shape = ShapeFactory.createShape(type, gameState.playArea!);
    setState(() {
      _activeShapeController = ShapeController(shape);
      if (type == ShapeType.circle || type == ShapeType.thermometer) {
        if (LocationProvider.lastLocation.latitude != 0.0 &&
            LocationProvider.lastLocation.longitude != 0.0) {
          _activeShapeController!.onMapTap(LocationProvider.lastLocation);
        }
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
    if (_isBottomSheetOpen) return; // <-- Prevent opening multiple sheets
    _isBottomSheetOpen = true;

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
    ).whenComplete(() {
      Future.delayed(const Duration(milliseconds: 300), () {
        _isBottomSheetOpen = false;
      });
    });
  }

  void _editShape(Shape shape) {
    _editingShapeColor = ColorHelper.copyMaterialColor(shape.color);
    _editingShapeId = shape.id;
    _activeShapeController = ShapeController(ShapeFactory.copy(shape), edit: true);

    setState(() {
      shape.color = Colors.grey;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: gameState.playArea != null
          ? MapFeaturesPanel(controller: _featuresController)
          : null,
      appBar: AppBar(
        title: const Text('Hide and Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            iconSize: 32,
            onPressed: () => MapTypePopup.show(context),
          ),
          PointerInterceptor(
            child: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'import':
                    showDialog<String>(
                      context: context,
                      builder: (_) => const ImportDialog(),
                    ).then((imported) => {_decodeImport(imported, context)});
                    break;
                  case 'share':
                    final encoded = gameState.encodeGameState();
                    showDialog(
                      context: context,
                      builder: (_) => ShareDialog(base64String: encoded),
                    );
                    break;
                  case 'reset':
                    _showResetDialog();
                    break;
                }
              },
              iconSize: 35,
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'import',
                  child: PointerInterceptor(
                    child: Row(
                      children: const [
                        Icon(Icons.file_download, color: Colors.black54),
                        SizedBox(width: 8),
                        Text("Import"),
                      ],
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'share',
                  child: PointerInterceptor(
                    child: Row(
                      children: const [
                        Icon(Icons.share, color: Colors.black54),
                        SizedBox(width: 8),
                        Text("Share"),
                      ],
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'reset',
                  child: PointerInterceptor(
                    child: Row(
                      children: const [
                        Icon(Icons.restart_alt, color: Colors.black54),
                        SizedBox(width: 8),
                        Text("Reset"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: gameState.playArea != null
          ? ExpandableFab(
              pos: ExpandableFabPos.right,
              type: ExpandableFabType.up,
              distance: 60,
              openButtonBuilder: RotateFloatingActionButtonBuilder(
                backgroundColor: Colors.blueAccent,
                child: PointerInterceptor(child: const Icon(Icons.add, size: 28)),
              ),
              closeButtonBuilder: DefaultFloatingActionButtonBuilder(
                fabSize: ExpandableFabSize.small,
                child: PointerInterceptor(child: const Icon(Icons.close)),
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
                    onPressed: () => _openAddShape(ShapeType.thermometer),
                    tooltip: 'Add Thermometer',
                    child: const Icon(Icons.thermostat),
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
              prefs,
              _selectorController,
              _featuresController,
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

              markersToShow.addAll(
                _featuresController.getMarkers(tapable: !_isEditable(), onTap: _onMapTap),
              );
              polygonsToShow.addAll(_featuresController.getPolygons());

              if (kIsWeb && _locationForWeb != null && _iconForWeb != null) {
                markersToShow.add(
                  Marker(
                    markerId: const MarkerId('locationMarker'),
                    position: _locationForWeb!,
                    icon: _iconForWeb!,
                    onTap: () => _onMapTap(_locationForWeb!),
                  ),
                );
              }

              return GoogleMap(
                initialCameraPosition: _initialCamera,
                mapType: prefs.mapType,
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
                cloudMapId: 'f16d3398e3253ffb9e2ab473',
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

          if (kIsWeb && _locationForWeb != null)
            Positioned(
              bottom: 16,
              left: 16,
              child: PointerInterceptor(
                child: FloatingActionButton(
                  heroTag: 'webLocationFab',
                  onPressed: () {
                    if (_controller != null) {
                      _controller!.animateCamera(
                        CameraUpdate.newLatLng(_locationForWeb!),
                      );
                    }
                  },
                  backgroundColor: Colors.blueAccent,
                  child: const Icon(Icons.my_location),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _decodeImport(String? imported, BuildContext context) {
    if (imported != null && imported.isNotEmpty) {
      final gS = GameState.decodeGameState(imported);
      if (gS.playArea != null) {
        _loadGameState(gS);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Import failed!")));
      }
    }
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
    final shape = controller.shape;

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
                LocationProvider.onLocationChanged(
                  (location) => _onLocationChanged(location),
                ),
              },
          },
        ),
      },
    );
  }

  void _onLocationChanged(LatLng location) {
    if (kIsWeb) {
      setState(() {
        _locationForWeb = location;
      });
    }
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PointerInterceptor(
          child: AlertDialog(
            title: const Text("Reset Game"),
            content: const Text(
              "Do you really want to reset everything? This cannot be undone.",
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Reset", style: TextStyle(color: Colors.white)),
                onPressed: () {
                  setState(() {
                    gameState = GameState();
                    _polygons.clear();
                    _activeShapeController = null;
                    _editingShapeId = null;
                    _editingShapeColor = null;
                    _featuresController.setPlayAreaBoundary([]);
                  });
                  GameState.saveGameState(gameState);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    GameState.saveGameState(gameState);
    super.dispose();
  }
}
