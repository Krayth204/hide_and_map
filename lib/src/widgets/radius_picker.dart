import 'package:flutter/material.dart';
import '../models/circle_controller.dart';
import '../util/app_preferences.dart';
import '../util/geo_math.dart';

class RadiusPicker extends StatefulWidget {
  final CircleController controller;
  final List<double> sliderValues;
  final LengthSystem lengthSystem;

  const RadiusPicker({
    super.key,
    required this.controller,
    required this.sliderValues,
    this.lengthSystem = LengthSystem.metric,
  });

  @override
  State<RadiusPicker> createState() => _RadiusPickerState();
}

class _RadiusPickerState extends State<RadiusPicker> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();

    double displayValue = _convertFromMeters(widget.controller.getRadius());
    _textController = TextEditingController(
      text: displayValue.toStringAsFixed(displayValue < 1 ? 2 : 0),
    );

    widget.controller.addListener(_updateField);
  }

  void _updateField() {
    final displayValue = _convertFromMeters(widget.controller.getRadius());
    final parsed = double.tryParse(_textController.text);
    if (parsed == null || (parsed - displayValue).abs() > 0.01) {
      _textController.text = displayValue.toStringAsFixed(displayValue < 1 ? 2 : 0);
    }
  }

  double _convertFromMeters(double meters) {
    return widget.lengthSystem == LengthSystem.metric
        ? meters
        : GeoMath.metersToMiles(meters);
  }

  double _convertToMeters(double value) {
    return widget.lengthSystem == LengthSystem.metric
        ? value
        : GeoMath.milesToMeters(value);
  }

  String _getUnitSuffix() => widget.lengthSystem == LengthSystem.metric ? 'm' : 'mi';

  @override
  void dispose() {
    widget.controller.removeListener(_updateField);
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double displayValue = _convertFromMeters(widget.controller.getRadius());

    int currentIndex = 0;
    double closestDiff = double.infinity;
    for (int i = 0; i < widget.sliderValues.length; i++) {
      final diff = (widget.sliderValues[i] - displayValue).abs();
      if (diff < closestDiff) {
        closestDiff = diff;
        currentIndex = i;
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Radius (${_getUnitSuffix()}):'),
        Expanded(
          child: Slider(
            value: currentIndex.toDouble(),
            min: 0,
            max: (widget.sliderValues.length - 1).toDouble(),
            divisions: widget.sliderValues.length - 1,
            label: widget.sliderValues[currentIndex].toStringAsFixed(
              widget.sliderValues[currentIndex] < 1 ? 2 : 0,
            ),
            onChanged: (v) {
              final index = v.round();
              final meters = _convertToMeters(widget.sliderValues[index]);
              widget.controller.setRadius(meters);
            },
          ),
        ),
        SizedBox(
          width: 80,
          child: TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            controller: _textController,
            onChanged: (s) {
              final value = double.tryParse(s);
              if (value != null) {
                final meters = _convertToMeters(value);
                widget.controller.setRadius(meters);
              }
            },
          ),
        ),
      ],
    );
  }
}
