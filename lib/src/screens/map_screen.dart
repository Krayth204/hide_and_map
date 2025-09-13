import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

          // Positioned control at bottom for radius input
          Positioned(
            left: 12,
            right: 12,
            bottom: 20,
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadiusInput(
                      initialKm: _circle.radiusMeters / 1000,
                      onChangedKm: (km) => _updateCircleRadiusKm(km),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _circle.center == null
                                ? 'Tap the map to set circle center'
                                : 'Center: ${_circle.center!.latitude.toStringAsFixed(5)}, ${_circle.center!.longitude.toStringAsFixed(5)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${(_circle.radiusMeters / 1000).toStringAsFixed(2)} km'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
