import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../play_area/play_area.dart';
import 'shape_object.dart';

enum ShapeType { circle, line, polygon, thermometer }

abstract class Shape {
  String get id;
  ShapeType get type;
  MaterialColor color = Colors.blue;
  bool inverted = false;

  Shape({
    this.color = Colors.blue,
    this.inverted = false,
  });

  void addPoint(LatLng p);
  void setRadius(double r);
  void undo();
  void reset();
  bool canConfirm();
  double getDistance();

  ShapeObject toShapeObject(
    PlayArea playArea, {
    bool editable = false,
    void Function(String id)? onTap,
    String? customId,
  });

  Set<Marker> getMarkers(Function notify);

  Map<String, dynamic> toJson();

  void share() {
    final jsonString = jsonEncode(toJson());
    SharePlus.instance.share(ShareParams(text: jsonString));
  }
}
