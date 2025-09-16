import 'package:flutter/material.dart';
import '../models/extra_shape.dart';
import '../models/shape_controller.dart';

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
    String title;
    String instructions;
    bool canConfirm;
    bool showUndoReset = false;
    bool showInvertedCheckbox = false;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            switch (controller.type) {
              case ShapeType.circle:
                title = controller.edit ? 'Edit Circle' : 'Add Circle';
                instructions = 'Tap map to set center. Drag marker to adjust.';
                canConfirm = controller.center != null;
                showInvertedCheckbox = true;
                break;
              case ShapeType.line:
                title = controller.edit ? 'Edit Line' : 'Add Line';
                instructions = 'Tap map to add points. Drag points to move.';
                canConfirm = controller.points.length >= 2;
                showUndoReset = true;
                break;
              case ShapeType.polygon:
                title = controller.edit ? 'Edit Polygon' : 'Add Polygon';
                instructions = 'Tap map to add points. Drag markers to move.';
                canConfirm = controller.points.length >= 3;
                showUndoReset = true;
                showInvertedCheckbox = true;
                break;
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(instructions),
                const SizedBox(height: 8),
                if (controller.type == ShapeType.circle)
                  Row(
                    children: [
                      const Text('Radius (m):'),
                      Expanded(
                        child: Slider(
                          value: controller.radius.clamp(500, 50000),
                          min: 500,
                          max: 50000,
                          divisions: 99,
                          label: controller.radius.round().toString(),
                          onChanged: (v) => controller.setRadius(v),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: TextEditingController(
                            text: controller.radius.round().toString(),
                          ),
                          onSubmitted: (s) {
                            final v = double.tryParse(s);
                            if (v != null) controller.setRadius(v);
                          },
                        ),
                      ),
                    ],
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: controller.inverted,
                        onChanged: (v) => controller.setInverted(v ?? false),
                      ),
                      const Text('Invert (cover outside of shape)'),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: onCancel,
                      child: const Text('Cancel'),
                    ),
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
