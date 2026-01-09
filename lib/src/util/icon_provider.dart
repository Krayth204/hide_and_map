import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../main.dart';

class IconProvider {
  static final IconProvider _instance = IconProvider._internal();
  factory IconProvider() => _instance;
  IconProvider._internal();

  late BitmapDescriptor trainStationIcon;
  late BitmapDescriptor trainStopIcon;
  late BitmapDescriptor subwayIcon;
  late BitmapDescriptor tramIcon;
  late BitmapDescriptor busIcon;
  late BitmapDescriptor ferryIcon;
  late BitmapDescriptor themeParkIcon;
  late BitmapDescriptor zooIcon;
  late BitmapDescriptor aquariumIcon;
  late BitmapDescriptor golfIcon;
  late BitmapDescriptor museumIcon;
  late BitmapDescriptor cinemaIcon;
  late BitmapDescriptor hospitalIcon;
  late BitmapDescriptor libraryIcon;
  late BitmapDescriptor consulateIcon;

  late BitmapDescriptor webLocationIcon;
  late Map<int, BitmapDescriptor> timerIcons;

  late Size _iconSize;

  Future<void> init() async {
    _iconSize = prefs.iconSize;
    await loadIcons();
    prefs.addListener(() {
      if (prefs.iconSize != _iconSize) {
        _iconSize = prefs.iconSize;
        loadIcons();
      }
    });
  }

  Future<void> loadIcons() async {
    trainStationIcon = await BitmapDescriptor.asset(
      ImageConfiguration(size: _iconSize),
      'assets/markers/train_station_marker.png',
    );
    trainStopIcon = await BitmapDescriptor.asset(
      ImageConfiguration(size: _iconSize),
      'assets/markers/train_stop_marker.png',
    );
    subwayIcon = await BitmapDescriptor.asset(
      ImageConfiguration(size: _iconSize),
      'assets/markers/subway_station_marker.png',
    );
    tramIcon = await BitmapDescriptor.asset(
      ImageConfiguration(size: _iconSize),
      'assets/markers/tram_stop_marker.png',
    );
    busIcon = await BitmapDescriptor.asset(
      ImageConfiguration(size: _iconSize),
      'assets/markers/bus_stop_marker.png',
    );
    ferryIcon = await BitmapDescriptor.asset(
      ImageConfiguration(size: _iconSize),
      'assets/markers/ferry_stop_marker.png',
    );
    themeParkIcon = await BitmapDescriptor.asset(
      ImageConfiguration(size: _iconSize),
      'assets/markers/theme_park_marker.png',
    );
    zooIcon = await BitmapDescriptor.asset(
      ImageConfiguration(size: _iconSize),
      'assets/markers/zoo_marker.png',
    );
    aquariumIcon = await BitmapDescriptor.asset(
      ImageConfiguration(size: _iconSize),
      'assets/markers/aquarium_marker.png',
    );
    golfIcon = await BitmapDescriptor.asset(
      ImageConfiguration(size: _iconSize),
      'assets/markers/golf_marker.png',
    );
    museumIcon = await BitmapDescriptor.asset(
      ImageConfiguration(size: _iconSize),
      'assets/markers/museum_marker.png',
    );
    cinemaIcon = await BitmapDescriptor.asset(
      ImageConfiguration(size: _iconSize),
      'assets/markers/cinema_marker.png',
    );
    hospitalIcon = await BitmapDescriptor.asset(
      ImageConfiguration(size: _iconSize),
      'assets/markers/hospital_marker.png',
    );
    libraryIcon = await BitmapDescriptor.asset(
      ImageConfiguration(size: _iconSize),
      'assets/markers/library_marker.png',
    );
    consulateIcon = await BitmapDescriptor.asset(
      ImageConfiguration(size: _iconSize),
      'assets/markers/consulate_marker.png',
    );

    webLocationIcon = await BitmapDescriptor.asset(
      ImageConfiguration(size: _iconSize),
      'assets/markers/blue_marker.png',
    );

    timerIcons = {
      Colors.blue.toARGB32(): await _loadTimerIcon('blue'),
      Colors.cyan.toARGB32(): await _loadTimerIcon('cyan'),
      Colors.green.toARGB32(): await _loadTimerIcon('green'),
      Colors.yellow.toARGB32(): await _loadTimerIcon('yellow'),
      Colors.orange.toARGB32(): await _loadTimerIcon('orange'),
      Colors.red.toARGB32(): await _loadTimerIcon('red'),
      Colors.pink.toARGB32(): await _loadTimerIcon('pink'),
      Colors.purple.toARGB32(): await _loadTimerIcon('purple'),
      Colors.deepPurple.toARGB32(): await _loadTimerIcon('deep_purple'),
      Colors.indigo.toARGB32(): await _loadTimerIcon('indigo'),
      Colors.grey.toARGB32(): await _loadTimerIcon('grey'),
    };
  }

  Future<BitmapDescriptor> _loadTimerIcon(String colorName) {
    return BitmapDescriptor.asset(
      ImageConfiguration(size: _iconSize + Offset(8, 8)),
      'assets/markers/timer_${colorName}_marker.png',
    );
  }
}
