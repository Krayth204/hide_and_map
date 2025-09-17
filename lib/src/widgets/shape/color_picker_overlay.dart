import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class ColorPickerOverlay extends StatelessWidget {
  final MaterialColor current;
  final List<MaterialColor> available;

  const ColorPickerOverlay({super.key, required this.current, required this.available});

  @override
  Widget build(BuildContext context) {
    return PointerInterceptor(
      child: AlertDialog(
        title: const Text('Pick a color'),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: available.map((c) {
            final isSelected = c == current;
            return GestureDetector(
              onTap: () => Navigator.of(context).pop(c),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.black54,
                    width: isSelected ? 3 : 1,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
