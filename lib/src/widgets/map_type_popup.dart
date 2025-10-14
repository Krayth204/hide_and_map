import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../main.dart';

class MapTypePopup {
  static Future<void> show(BuildContext context) async {
    final top = kToolbarHeight + 8;

    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (ctx) {
        return Align(
          alignment: Alignment.topRight,
          child: PointerInterceptor(
            child: Padding(
              padding: EdgeInsets.only(top: top, right: 8),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).cardColor,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8, left: 4, right: 4),
                  child: _MapTypeRow(
                    onSelected: (type) {
                      prefs.setMapType(type);
                      Navigator.pop(ctx);
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MapTypeRow extends StatelessWidget {
  final void Function(MapType) onSelected;

  const _MapTypeRow({required this.onSelected});

  static const _options = <MapType, String>{
    MapType.normal: 'assets/map_previews/normal.png',
    MapType.hybrid: 'assets/map_previews/hybrid.png',
    MapType.terrain: 'assets/map_previews/terrain.png',
  };

  @override
  Widget build(BuildContext context) {
    final selected = prefs.mapType;
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _options.entries.map((e) {
        final isSelected = e.key == selected;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Material(
              color: Theme.of(context).cardColor,
              child: InkWell(
                onTap: () => onSelected(e.key),
                child: Stack(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Image.asset(e.value, fit: BoxFit.cover),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 6,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Text(
                            _getLabel(e.key),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? theme.colorScheme.primary : Colors.grey.shade400,
                              width: isSelected ? 3 : 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getLabel(MapType type) {
    switch (type) {
      case MapType.normal:
        return 'Default';
      case MapType.hybrid:
        return 'Satellite';
      case MapType.terrain:
        return 'Terrain';
      default:
        return '';
    }
  }
}
