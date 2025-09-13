import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hide_and_map/main.dart';

import '../models/circle_model.dart';
import '../widgets/radius_input.dart';

/// Main screen that displays Google Map and circle controls.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  // Application model for the circle: center and radius in meters.
  final CircleModel _circle = CircleModel.empty();

  static const CameraPosition _initialCamera = CameraPosition(
    target: LatLng(49.4480, 11.0780), // Nuremburg default
    zoom: 13,
  );

  @override
  void initState() {
    super.initState();
    Permission.location.request();
  }

  // Update the UI when circle changes
  void _updateCircleCenter(LatLng center) {
    setState(() {
      _circle.center = center;
    });
  }

  void _updateCircleRadiusKm(double km) {
    setState(() {
      _circle.radiusMeters = (km * 1000).clamp(0, 1000000);
    });
  }

  @override
  Widget build(BuildContext context) {
    final circles = <Circle>{
      if (_circle.center != null)
        Circle(
          circleId: const CircleId('user_circle'),
          center: _circle.center!,
          radius: _circle.radiusMeters,
          fillColor: Colors.blue.withOpacity(0.15),
          strokeColor: Colors.blueAccent,
          strokeWidth: 2,
        )
    };

    final markers = <Marker>{
      if (_circle.center != null)
        Marker(
          markerId: const MarkerId('center_marker'),
          position: _circle.center!,
          infoWindow: InfoWindow(
            title: 'Circle Center',
            snippet: '${(_circle.radiusMeters / 1000).toStringAsFixed(2)} km radius',
          ),
        ),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hide and Map'),
        actions: [
          IconButton(
            tooltip: 'Reset',
            onPressed: () {
              setState(() {
                _circle.reset();
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCamera,
            style: mapStyle,
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            onTap: (LatLng pos) {
              // User tapped -> set circle center
              _updateCircleCenter(pos);
            },
            circles: circles,
            markers: markers,
            // Polylines and other overlays would also scale automatically.
          ),
        ],
      ),
    );
  }
}
