import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences extends ChangeNotifier {
  static final AppPreferences _instance = AppPreferences._internal();
  factory AppPreferences() => _instance;
  AppPreferences._internal();

  static const _keyMapType = 'map_type';

  late SharedPreferences _prefs;
  MapType _mapType = MapType.normal;

  MapType get mapType => _mapType;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final storedValue = _prefs.getInt(_keyMapType);
    _mapType = MapType.values.elementAt(storedValue ?? MapType.normal.index);
  }

  Future<void> setMapType(MapType type) async {
    _mapType = type;
    await _prefs.setInt(_keyMapType, type.index);
    notifyListeners();
  }
}
