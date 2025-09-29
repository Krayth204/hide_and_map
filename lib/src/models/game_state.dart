import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:hide_and_map/src/models/shape/shape_factory.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'play_area/play_area.dart';
import 'shape/shape.dart';

class GameState {
  final PlayArea? playArea;
  final List<Shape> shapes;

  GameState({this.playArea, List<Shape>? shapes}) : shapes = shapes ?? [];

  GameState copyWith({PlayArea? playArea, List<Shape>? shapes}) {
    return GameState(playArea: playArea ?? this.playArea, shapes: shapes ?? this.shapes);
  }

  Map<String, dynamic> _toJson() => {
    'pA': playArea?.toJson(),
    'sh': shapes.map((s) => s.toJson()).toList(),
  };

  String encodeGameState() {
    final jsonStr = jsonEncode(_toJson());
    final compressed = GZipEncoder().encode(utf8.encode(jsonStr));
    return base64Encode(compressed);
  }

  static Future<void> saveGameState(GameState state) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = state.encodeGameState();
    await prefs.setString('game_state', encoded);
  }

  static GameState _fromJson(Map<String, dynamic> json) => GameState(
    playArea: json['pA'] != null ? PlayArea.fromJson(json['pA']) : null,
    shapes: (json['sh'] as List).map((s) => ShapeFactory.fromJson(s)).toList(),
  );

  static GameState decodeGameState(String stored) {
    try {
      final compressed = base64Decode(stored);
      final decompressed = GZipDecoder().decodeBytes(compressed);
      final data = jsonDecode(utf8.decode(decompressed)) as Map<String, dynamic>;
      return _fromJson(data);
    } catch (_) {
      return GameState();
    }
  }

  static Future<GameState> loadGameState() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString('game_state');
    if (encoded == null) return GameState();
    return decodeGameState(encoded);
  }

  static Future<void> clearGameState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('game_state');
  }
}
