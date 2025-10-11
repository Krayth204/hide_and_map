import 'package:flutter/material.dart';
import '../../models/play_area/play_area_selector_controller.dart';
import '../radius_picker.dart';

class PlayAreaSelector extends StatelessWidget {
  final PlayAreaSelectorController controller;
  final VoidCallback onConfirmed;

  const PlayAreaSelector({
    super.key,
    required this.controller,
    required this.onConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Play Zone',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Tap map to set points. Drag marker to adjust.'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Circle'),
                        selected: controller.mode == SelectionMode.circle,
                        onSelected: (_) => controller.setMode(SelectionMode.circle),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Polygon'),
                        selected: controller.mode == SelectionMode.polygon,
                        onSelected: (_) => controller.setMode(SelectionMode.polygon),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (controller.mode == SelectionMode.circle)
                  RadiusPicker(controller: controller, min: 1000, max: 100000),
                if (controller.mode == SelectionMode.polygon)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.undo),
                        tooltip: 'Undo last point',
                        onPressed: controller.undoPolygon,
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Reset polygon',
                        onPressed: controller.resetPolygon,
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed:
                      (controller.mode == SelectionMode.circle &&
                              controller.circleCenter != null) ||
                          (controller.mode == SelectionMode.polygon &&
                              controller.polygonPoints.length >= 3)
                      ? onConfirmed
                      : null,
                  child: const Text('Confirm Play Area'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
