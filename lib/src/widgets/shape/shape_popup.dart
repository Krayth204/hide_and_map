import 'package:flutter/material.dart';
import 'package:hide_and_map/src/util/app_preferences.dart';
import 'package:hide_and_map/src/util/geo_math.dart';
import '../../models/shape/shape.dart';
import '../../models/shape/shape_controller.dart';
import '../../util/color_helper.dart';
import '../radius_picker.dart';
import 'color_picker_overlay.dart';

class ShapePopup extends StatelessWidget {
  final ShapeController controller;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const ShapePopup({
    super.key,
    required this.controller,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        child: AnimatedBuilder(
          animation: controller,
          builder: (_, _) {
            final shape = controller.shape;

            String title;
            String instructions = 'Tap map to add points. Drag markers to move.';
            bool canConfirm = shape.canConfirm();
            bool showUndoReset = false;
            bool showInvertedCheckbox = false;
            bool showDistance = false;
            String invertedText = 'Invert (cover outside of shape)';

            switch (shape.type) {
              case ShapeType.circle:
                title = controller.edit ? 'Edit Circle' : 'Add Circle';
                instructions = 'Tap map to set center. Drag marker to adjust.';
                showInvertedCheckbox = true;
                break;
              case ShapeType.line:
                title = controller.edit ? 'Edit Line' : 'Add Line';
                showUndoReset = true;
                showDistance = true;
                break;
              case ShapeType.polygon:
                title = controller.edit ? 'Edit Polygon' : 'Add Polygon';
                showUndoReset = true;
                showInvertedCheckbox = true;
                break;
              case ShapeType.thermometer:
                title = controller.edit ? 'Edit Thermometer' : 'Add Thermometer';
                showUndoReset = true;
                showInvertedCheckbox = true;
                showDistance = true;
                invertedText = 'Hotter (Hider closer to second point?)';
                break;
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final selected = await showDialog<MaterialColor>(
                          context: context,
                          builder: (_) => ColorPickerOverlay(
                            current: shape.color,
                            available: ColorHelper.availableColors,
                          ),
                        );
                        if (selected != null) controller.setColor(selected);
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: shape.color,
                          border: Border.all(color: Colors.black54, width: 1),
                        ),
                      ),
                    ),

                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),

                    IconButton(
                      icon: const Icon(Icons.share, size: 24),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                      splashRadius: 24,
                      onPressed: () {
                        shape.share();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(instructions),
                const SizedBox(height: 4),

                if (shape.type == ShapeType.circle)
                  RadiusPicker(
                    controller: controller,
                    sliderValues: AppPreferences().lengthSystem == LengthSystem.metric
                        ? metricRadiusValues
                        : imperialRadiusValues,
                    lengthSystem: AppPreferences().lengthSystem,
                  ),

                if (showUndoReset)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.undo),
                        onPressed: controller.undo,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: controller.reset,
                      ),
                    ],
                  ),

                if (showInvertedCheckbox) ...[
                  Row(
                    children: [
                      Checkbox(
                        value: shape.inverted,
                        onChanged: (v) => controller.setInverted(v ?? false),
                      ),
                      Text(invertedText),
                    ],
                  ),
                ],

                Row(
                  children: [
                    Expanded(
                      child: showDistance
                          ? Center(
                              child: Text(
                                GeoMath.toDistanceString(shape.getDistance()),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(width: 8),
                    TextButton(onPressed: onCancel, child: const Text('Cancel')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: canConfirm ? onConfirm : null,
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

final List<double> metricRadiusValues = [500, 1000, 2000, 5000, 10000, 15000, 40000, 80000, 160000];
final List<double> imperialRadiusValues = [ 0.25, 0.5, 1, 3, 5, 10, 25, 50, 100];
