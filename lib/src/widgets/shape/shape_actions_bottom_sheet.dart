import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../models/shape/shape.dart';
import '../../models/shape/timer_shape.dart';

class ShapeActionsBottomSheet extends StatefulWidget {
  final Shape shape;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ShapeActionsBottomSheet({
    super.key,
    required this.shape,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<ShapeActionsBottomSheet> createState() => _ShapeActionsBottomSheetState();
}

class _ShapeActionsBottomSheetState extends State<ShapeActionsBottomSheet> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();

    final shape = widget.shape;

    if (shape is TimerShape && shape.stopTime == null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String get _shapeTitle {
    switch (widget.shape.type) {
      case ShapeType.circle:
        return 'Circle';
      case ShapeType.line:
        return 'Line';
      case ShapeType.polygon:
        return 'Polygon';
      case ShapeType.thermometer:
        return 'Thermometer';
      case ShapeType.timer:
        return 'Timer';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTimer = widget.shape is TimerShape;
    final timerShape = isTimer ? widget.shape as TimerShape? : null;

    return SafeArea(
      child: PointerInterceptor(
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: Center(
                child: isTimer
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            timerShape!.name,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            timerShape.formattedTime,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        _shapeTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                widget.onEdit();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                widget.shape.share();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Remove'),
              onTap: () {
                Navigator.pop(context);
                widget.onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
