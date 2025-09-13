import 'package:flutter/material.dart';

/// A compact widget that lets the user set a radius in kilometers.
/// Provides both a slider and a numeric text field for convenience.
class RadiusInput extends StatefulWidget {
  final double initialKm;
  final ValueChanged<double> onChangedKm;

  const RadiusInput({super.key, required this.initialKm, required this.onChangedKm});

  @override
  State<RadiusInput> createState() => _RadiusInputState();
}

class _RadiusInputState extends State<RadiusInput> {
  late double _km;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _km = widget.initialKm;
    _controller = TextEditingController(text: _km.toStringAsFixed(2));
  }

  @override
  void didUpdateWidget(covariant RadiusInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialKm != oldWidget.initialKm) {
      _km = widget.initialKm;
      _controller.text = _km.toStringAsFixed(2);
    }
  }

  void _onSliderChanged(double value) {
    setState(() {
      _km = value;
      _controller.text = _km.toStringAsFixed(2);
    });
    widget.onChangedKm(_km);
  }

  void _onTextChanged(String text) {
    final parsed = double.tryParse(text);
    if (parsed == null) return;
    setState(() {
      _km = parsed.clamp(0.0, 1000.0);
    });
    widget.onChangedKm(_km);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Radius (km):'),
            const SizedBox(width: 8),
            Expanded(
              child: Slider(
                value: _km.clamp(0.0, 1000.0),
                min: 0,
                max: 100,
                divisions: 100,
                label: '${_km.toStringAsFixed(2)} km',
                onChanged: _onSliderChanged,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              child: TextField(
                controller: _controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(isDense: true),
                onSubmitted: _onTextChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
