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

  static const _keyAdminLevel1 = 'admin_level_1';
  static const _keyAdminLevel2 = 'admin_level_2';
  static const _keyAdminLevel3 = 'admin_level_3';
  static const _keyAdminLevel4 = 'admin_level_4';

  late SharedPreferences _prefs;

  MapType _mapType = MapType.normal;
  double _hidingZoneSize = 500.0;
  LengthSystem _lengthSystem = LengthSystem.metric;
  Size _iconSize = const Size(16, 16);

  int _adminLevel1 = 4;
  int _adminLevel2 = 6;
  int _adminLevel3 = 8;
  int _adminLevel4 = 9;

  MapType get mapType => _mapType;
  double get hidingZoneSize => _hidingZoneSize;
  LengthSystem get lengthSystem => _lengthSystem;
  Size get iconSize => _iconSize;

  int get adminLevel1 => _adminLevel1;
  int get adminLevel2 => _adminLevel2;
  int get adminLevel3 => _adminLevel3;
  int get adminLevel4 => _adminLevel4;
  List<int> get adminLevels => [adminLevel1, adminLevel2, adminLevel3, adminLevel4];

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    final storedMapType = _prefs.getInt(_keyMapType);
    _mapType = MapType.values.elementAt(storedMapType ?? MapType.normal.index);

    _hidingZoneSize = _prefs.getDouble(_keyHidingZoneSize) ?? 500.0;

    final storedLengthSystem = _prefs.getInt(_keyLengthSystem);
    _lengthSystem = LengthSystem.values.elementAt(
      storedLengthSystem ?? LengthSystem.metric.index,
    );

    final iconWidth = _prefs.getDouble(_keyIconWidth) ?? 16.0;
    final iconHeight = _prefs.getDouble(_keyIconHeight) ?? 16.0;
    _iconSize = Size(iconWidth, iconHeight);

    _adminLevel1 = _prefs.getInt(_keyAdminLevel1) ?? 4;
    _adminLevel2 = _prefs.getInt(_keyAdminLevel2) ?? 6;
    _adminLevel3 = _prefs.getInt(_keyAdminLevel3) ?? 8;
    _adminLevel4 = _prefs.getInt(_keyAdminLevel4) ?? 9;
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

  Future<void> setAdminLevel(int division, int level) async {
    if (level < 3 || level > 11) return;

    switch (division) {
      case 1:
        _adminLevel1 = level;
        await _prefs.setInt(_keyAdminLevel1, level);
        break;
      case 2:
        _adminLevel2 = level;
        await _prefs.setInt(_keyAdminLevel2, level);
        break;
      case 3:
        _adminLevel3 = level;
        await _prefs.setInt(_keyAdminLevel3, level);
        break;
      case 4:
        _adminLevel4 = level;
        await _prefs.setInt(_keyAdminLevel4, level);
        break;
      default:
        return;
    }

    notifyListeners();
  }
}
