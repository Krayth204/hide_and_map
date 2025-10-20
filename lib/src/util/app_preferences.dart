import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences extends ChangeNotifier {
  static final AppPreferences _instance = AppPreferences._internal();
  factory AppPreferences() => _instance;
  AppPreferences._internal();

  static const _keyMapType = 'map_type';
  static const _keyHidingZoneSize = 'hiding_zone_size';

  late SharedPreferences _prefs;
  MapType _mapType = MapType.normal;
  double _hidingZoneSize = 500.0;

  MapType get mapType => _mapType;
  double get hidingZoneSize => _hidingZoneSize;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    final storedMapType = _prefs.getInt(_keyMapType);
    _mapType = MapType.values.elementAt(storedMapType ?? MapType.normal.index);

    _hidingZoneSize = _prefs.getDouble(_keyHidingZoneSize) ?? 500.0;
  }

  Future<void> setMapType(MapType type) async {
    _mapType = type;
    await _prefs.setInt(_keyMapType, type.index);
    notifyListeners();
  }

  Future<void> setHidingZoneSize(double size) async {
    _hidingZoneSize = size;
    await _prefs.setDouble(_keyHidingZoneSize, size);
    notifyListeners();
  }
}
