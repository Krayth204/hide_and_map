import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import '../../models/map_features/map_features_controller.dart';

class MapFeaturesPanel extends StatelessWidget {
  final MapFeaturesController controller;

  const MapFeaturesPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PointerInterceptor(
      child: Drawer(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Toggle Visibilities',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ExpansionTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                        childrenPadding: const EdgeInsets.only(
                          left: 16,
                          right: 8,
                          bottom: 8,
                        ),
                        title: Row(
                          children: [
                            const Icon(Icons.train, color: Colors.deepPurple),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Railway Stations',
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                            if (controller.isFetchingStations)
                              const SizedBox(
                                height: 48,
                                width: 48,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            else
                              Switch(
                                value:
                                    controller.showRailwayStations ||
                                    controller.railwayPartial,
                                onChanged: controller.toggleRailwayStations,
                                activeTrackColor: controller.railwayPartial
                                    ? Colors.blueGrey
                                    : theme.colorScheme.primary,
                              ),
                          ],
                        ),
                        children: [
                          SwitchListTile(
                            title: const Text('Train Stations'),
                            value: controller.showTrainStations,
                            onChanged: controller.toggleTrainStations,
                            secondary: const Icon(
                              Icons.train_outlined,
                              color: Colors.indigo,
                            ),
                          ),
                          SwitchListTile(
                            title: const Text('Subway Stations'),
                            value: controller.showSubwayStations,
                            onChanged: controller.toggleSubwayStations,
                            secondary: const Icon(
                              Icons.subway_outlined,
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Divider(height: 32, thickness: 1),

                  Text(
                    'More features coming soon...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
