import 'package:flutter/material.dart';
import '../models/play_area/play_area_selector_controller.dart';

class PlayAreaSelector extends StatefulWidget {
  final PlayAreaSelectorController controller;
  final VoidCallback onConfirmed;

  const PlayAreaSelector({
    super.key,
    required this.controller,
    required this.onConfirmed,
  });

  @override
  State<PlayAreaSelector> createState() => _PlayAreaSelectorState();
}

class _PlayAreaSelectorState extends State<PlayAreaSelector> {
  late TextEditingController _radiusController;

  @override
  void initState() {
    super.initState();
    _radiusController = TextEditingController(
      text: widget.controller.circleRadius.round().toString(),
    );

    widget.controller.addListener(() {
      if (widget.controller.mode == SelectionMode.circle) {
        _radiusController.text = widget.controller.circleRadius
            .round()
            .toString();
      }
    });
  }

  @override
  void dispose() {
    _radiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (_, __) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Circle'),
                        selected:
                            widget.controller.mode == SelectionMode.circle,
                        onSelected: (_) =>
                            widget.controller.setMode(SelectionMode.circle),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Polygon'),
                        selected:
                            widget.controller.mode == SelectionMode.polygon,
                        onSelected: (_) =>
                            widget.controller.setMode(SelectionMode.polygon),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (widget.controller.mode == SelectionMode.circle)
                  Row(
                    children: [
                      const Text('Radius (m):'),
                      Expanded(
                        child: Slider(
                          value: widget.controller.circleRadius.clamp(
                            1000,
                            100000,
                          ),
                          min: 1000,
                          max: 100000,
                          divisions: 99,
                          label: '${widget.controller.circleRadius.round()} m',
                          onChanged: (val) => widget.controller.setRadius(val),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 6),
                          ),
                          keyboardType: TextInputType.number,
                          controller: _radiusController,
                          onSubmitted: (val) {
                            final parsed = double.tryParse(val);
                            if (parsed != null) {
                              widget.controller.setRadius(parsed);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                if (widget.controller.mode == SelectionMode.polygon)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.undo),
                        tooltip: 'Undo last point',
                        onPressed: widget.controller.undoPolygon,
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Reset polygon',
                        onPressed: widget.controller.resetPolygon,
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed:
                      (widget.controller.mode == SelectionMode.circle &&
                              widget.controller.circleCenter != null) ||
                          (widget.controller.mode == SelectionMode.polygon &&
                              widget.controller.polygonPoints.length >= 3)
                      ? widget.onConfirmed
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
