import 'package:flutter/material.dart';
import '../../models/add_shape/add_line_controller.dart';

class AddLinePopup extends StatelessWidget {
  final AddLineController controller;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const AddLinePopup({
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
        padding: const EdgeInsets.all(12),
        child: AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add Line',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Tap map to add points. Drag points to move.'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.undo),
                      onPressed: controller.undo,
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: controller.reset,
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
                      onPressed: controller.points.length >= 2
                          ? onConfirm
                          : null,
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
