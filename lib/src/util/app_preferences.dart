import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LengthSystem { metric, imperial }

class AppPreferences extends ChangeNotifier {
  static final AppPreferences _instance = AppPreferences._internal();
  factory AppPreferences() => _instance;
  AppPreferences._internal();

  static const _keyMapType = 'map_type';
  static const _keyHidingZoneSize = 'hiding_zone_size';
  static const _keyLengthSystem = 'length_system';
  static const _keyIconWidth = 'icon_width';
  static const _keyIconHeight = 'icon_height';

  late SharedPreferences _prefs;

  MapType _mapType = MapType.normal;
  double _hidingZoneSize = 500.0;
  LengthSystem _lengthSystem = LengthSystem.metric;
  Size _iconSize = const Size(16, 16);

  MapType get mapType => _mapType;
  double get hidingZoneSize => _hidingZoneSize;
  LengthSystem get lengthSystem => _lengthSystem;
  Size get iconSize => _iconSize;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    final storedMapType = _prefs.getInt(_keyMapType);
    _mapType = MapType.values.elementAt(storedMapType ?? MapType.normal.index);

    _hidingZoneSize = _prefs.getDouble(_keyHidingZoneSize) ?? 500.0;

    final storedLengthSystem = _prefs.getInt(_keyLengthSystem);
    _lengthSystem =
        LengthSystem.values.elementAt(storedLengthSystem ?? LengthSystem.metric.index);

    final iconWidth = _prefs.getDouble(_keyIconWidth) ?? 16.0;
    final iconHeight = _prefs.getDouble(_keyIconHeight) ?? 16.0;
    _iconSize = Size(iconWidth, iconHeight);
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

  Future<void> setLengthSystem(LengthSystem system) async {
    _lengthSystem = system;
    await _prefs.setInt(_keyLengthSystem, system.index);
    notifyListeners();
  }

  Future<void> setIconSize(Size size) async {
    _iconSize = size;
    await _prefs.setDouble(_keyIconWidth, size.width);
    await _prefs.setDouble(_keyIconHeight, size.height);
    notifyListeners();
  }
}
