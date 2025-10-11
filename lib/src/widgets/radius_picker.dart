import 'package:flutter/material.dart';

import '../models/circle_controller.dart';

class RadiusPicker extends StatefulWidget {
  final CircleController controller; 
  final double min;
  final double max;

  const RadiusPicker({
    super.key,
    required this.controller,
    this.min = 500,
    this.max = 50000,
  });

  @override
  State<RadiusPicker> createState() => _RadiusPickerState();
}

class _RadiusPickerState extends State<RadiusPicker> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.controller.getRadius().round().toString(),
    );

    widget.controller.addListener(_updateField);
  }

  void _updateField() {
    final newRadius = widget.controller.getRadius().round();
    if (_textController.text.isEmpty ||
        int.tryParse(_textController.text) != newRadius) {
      _textController.text = newRadius.toString();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateField);
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.controller.getRadius();

    return Row(
      children: [
        const Text('Radius (m):'),
        Expanded(
          child: Slider(
            value: radius.clamp(widget.min, widget.max),
            min: widget.min,
            max: widget.max,
            divisions: 99,
            label: radius.round().toString(),
            onChanged: (v) => widget.controller.setRadius(v),
          ),
        ),
        SizedBox(
          width: 80,
          child: TextField(
            keyboardType: TextInputType.number,
            controller: _textController,
            onChanged: (s) {
              final v = double.tryParse(s);
              if (v != null) widget.controller.setRadius(v);
            },
          ),
        ),
      ],
    );
  }
}
