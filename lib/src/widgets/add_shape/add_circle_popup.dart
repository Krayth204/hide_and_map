import 'package:flutter/material.dart';
import '../../models/extra_shape.dart';
import '../../models/shape_controller.dart';

class AddCirclePopup extends StatelessWidget {
  final ShapeController controller;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const AddCirclePopup({
    super.key,
    required this.controller,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    assert(
      controller.type == ShapeType.circle,
      'AddCirclePopup must be used with a circle ShapeController',
    );

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
                Text(
                  controller.edit ? 'Edit Circle' : 'Add Circle',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Tap map to set center. Drag marker to adjust.'),
                const SizedBox(height: 8),
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
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: onCancel,
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: controller.center != null ? onConfirm : null,
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
