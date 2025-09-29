import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:location/location.dart';

abstract class LocationProvider {
  static bool _locationAvailable = false;
  static final Location _location = Location();

  static Future<bool> requestPermission() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    if (kIsWeb) {
      _locationAvailable = true;
      await getLocation();
      return true;
    }

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return false;
      }
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }
    return _locationAvailable = true;
  }

  static Future<LatLng?> getLocation() async {
    if (!_locationAvailable) return Future.value(null);
    var locationData = await _location.getLocation();
    if (locationData.latitude == null || locationData.longitude == null) {
      return Future.value(null);
    }
    return Future.value(LatLng(locationData.latitude!, locationData.longitude!));
  }

  static void onLocationChanged(Function(LatLng) onChanged) {
    if (!_locationAvailable) return;
    _location.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null || currentLocation.longitude != null) {
        onChanged(LatLng(currentLocation.latitude!, currentLocation.longitude!));
      }
    });
  }
}
