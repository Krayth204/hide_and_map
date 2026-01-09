import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../main.dart';
import '../play_area/play_area.dart';
import 'shape.dart';
import 'shape_object.dart';

class TimerShape extends Shape {
  @override
  final String id;

  @override
  final ShapeType type = ShapeType.timer;

  String name;
  LatLng location;
  final DateTime startTime;
  DateTime? stopTime;

  TimerShape(
    this.id,
    this.location, {
    this.name = 'Timer',
    DateTime? startTime,
    this.stopTime,
    super.color,
  }) : startTime = startTime ?? DateTime.now();

  Duration get elapsed =>
      stopTime?.difference(startTime) ?? DateTime.now().difference(startTime);

  String get formattedTime {
    final d = elapsed;
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  void stopTimer() {
    stopTime = DateTime.now();
  }

  @override
  void addPoint(LatLng p) {
    location = p;
  }

  @override
  void undo() {}

  @override
  void reset() {}

  @override
  void setRadius(double r) {}

  @override
  bool canConfirm() => true;

  @override
  String getDistance() => formattedTime;

  @override
  ShapeObject toShapeObject(
    PlayArea playArea, {
    bool editable = false,
    void Function(String id)? onTap,
    String? customId,
  }) {
    return ShapeObject(
      marker: Marker(
        markerId: MarkerId(customId ?? id),
        position: location,
        icon: icons.timerIcons[color.toARGB32()]!,
        consumeTapEvents: editable,
        onTap: () => editable ? onTap?.call(id) : null,
      ),
    );
  }

  @override
  Set<Marker> getMarkers(Function notify) {
    return {
      Marker(
        markerId: MarkerId('${id}_timer'),
        position: location,
        draggable: true,
        onDragEnd: (p) {
          location = p;
          notify();
        },
        icon: icons.timerIcons[color.toARGB32()]!,
      ),
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ty': 'ti',
      'col': color.toARGB32(),
      'na': name,
      'loc': {'lat': location.latitude, 'lng': location.longitude},
      'sta': startTime.toIso8601String(),
      'sto': stopTime?.toIso8601String() ?? 'null',
    };
  }
}
