import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hide_and_map/main.dart';

import '../models/play_area/circle_play_area.dart';
import '../models/play_area/play_area.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _initialCamera = CameraPosition(
    target: LatLng(49.4480, 11.0780), // Nuremberg default
    zoom: 13,
  );

  // Variable to store play area
  PlayArea? playArea;

  @override
  void initState() {
    super.initState();
    Permission.location.request();

    // Example: circle play area
    playArea = CirclePlayArea(const LatLng(49.4480, 11.0780), 1000000);

    // Example: polygon play area
    // playArea = PolygonPlayArea([
    //   LatLng(49.45, 11.07),
    //   LatLng(49.46, 11.08),
    //   LatLng(49.45, 11.09),
    // ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hide and Map'),
      ),
      body: GoogleMap(
        initialCameraPosition: _initialCamera,
        style: mapStyle,
        mapType: MapType.normal,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        polygons: PlayArea.buildOverlay(playArea),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
