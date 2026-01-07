import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import '../../models/map_features/map_features_controller.dart';
import '../../models/map_features/map_poi.dart';

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

                  _buildRailwayTile(context, theme),

                  const Divider(height: 24, thickness: 1),

                  _buildPoiTile(
                    theme: theme,
                    icon: Icons.attractions,
                    title: 'Theme Parks',
                    color: const Color(0xFFFF6F00),
                    value: controller.showThemeParks,
                    isLoading: controller.isFetchingThemeParks,
                    onChanged: (b) => controller.togglePoi(POIType.themePark, b),
                  ),
                  _buildPoiTile(
                    theme: theme,
                    icon: Icons.pets,
                    title: 'Zoos',
                    color: const Color(0xFF43A047),
                    value: controller.showZoos,
                    isLoading: controller.isFetchingZoos,
                    onChanged: (b) => controller.togglePoi(POIType.zoo, b),
                  ),
                  _buildPoiTile(
                    theme: theme,
                    icon: Icons.water,
                    title: 'Aquariums',
                    color: const Color(0xFF3949AB),
                    value: controller.showAquariums,
                    isLoading: controller.isFetchingAquariums,
                    onChanged: (b) => controller.togglePoi(POIType.aquarium, b),
                  ),
                  _buildPoiTile(
                    theme: theme,
                    icon: Icons.golf_course,
                    title: 'Golf Courses',
                    color: const Color(0xFF7CB342),
                    value: controller.showGolfCourses,
                    isLoading: controller.isFetchingGolfCourses,
                    onChanged: (b) => controller.togglePoi(POIType.golfCourse, b),
                  ),
                  _buildPoiTile(
                    theme: theme,
                    icon: Icons.museum,
                    title: 'Museums',
                    color: const Color(0xFF8E24AA),
                    value: controller.showMuseums,
                    isLoading: controller.isFetchingMuseums,
                    onChanged: (b) => controller.togglePoi(POIType.museum, b),
                  ),
                  _buildPoiTile(
                    theme: theme,
                    icon: Icons.movie,
                    title: 'Movie Theaters',
                    color: const Color(0xFFD81B60),
                    value: controller.showMovieTheaters,
                    isLoading: controller.isFetchingMovieTheaters,
                    onChanged: (b) => controller.togglePoi(POIType.movieTheater, b),
                  ),
                  _buildPoiTile(
                    theme: theme,
                    icon: Icons.emergency,
                    title: 'Hospitals',
                    color: const Color(0xFFC62828),
                    value: controller.showHospitals,
                    isLoading: controller.isFetchingHospitals,
                    onChanged: (b) => controller.togglePoi(POIType.hospital, b),
                  ),
                  _buildPoiTile(
                    theme: theme,
                    icon: Icons.local_library,
                    title: 'Libraries',
                    color: const Color(0xFFFBC02D),
                    value: controller.showLibraries,
                    isLoading: controller.isFetchingLibraries,
                    onChanged: (b) => controller.togglePoi(POIType.library, b),
                  ),
                  _buildPoiTile(
                    theme: theme,
                    icon: Icons.flag,
                    title: 'Consulates',
                    color: const Color(0xFF0097A7),
                    value: controller.showConsulates,
                    isLoading: controller.isFetchingConsulates,
                    onChanged: (b) => controller.togglePoi(POIType.consulate, b),
                  ),

                  const Divider(height: 32, thickness: 1),
                  Text(
                    'The data of these locations is from www.openstreetmap.org. The data is made available under ODbL.',
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

  Widget _buildRailwayTile(BuildContext context, ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.only(left: 16, right: 8, bottom: 8),
          title: Row(
            children: [
              const Icon(Icons.train, color: Colors.deepPurple),
              const SizedBox(width: 12),
              Expanded(child: Text('Stations', style: theme.textTheme.titleMedium)),
              controller.isFetchingStations
                  ? Padding(
                      padding: const EdgeInsets.only(right: 14.0),
                      child: const SizedBox(
                        height: 40,
                        width: 40,
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : Switch(
                      value: controller.anyStationTypeVisible,
                      onChanged: controller.toggleStations,
                      activeTrackColor: theme.colorScheme.primary,
                    ),
            ],
          ),
          children: [
            _buildStationTile(
              title: 'Train Stations',
              value: controller.showTrainStations,
              isLoading: controller.isFetchingTrainStations,
              onChanged: (value) => controller.toggleTrainStations(value),
              icon: const Icon(Icons.train_outlined, color: Colors.indigo),
            ),
            _buildStationTile(
              title: 'Train Stops',
              value: controller.showTrainStops,
              isLoading: controller.isFetchingTrainStops,
              onChanged: (value) => controller.toggleTrainStops(value),
              icon: const Icon(Icons.train_outlined, color: Color(0xFF7B68EE)),
            ),
            _buildStationTile(
              title: 'Subway Stations',
              value: controller.showSubwayStations,
              isLoading: controller.isFetchingSubwayStations,
              onChanged: (value) => controller.toggleSubwayStations(value),
              icon: const Icon(Icons.subway_outlined, color: Colors.purple),
            ),
            _buildStationTile(
              title: 'Tram Stops',
              value: controller.showTramStops,
              isLoading: controller.isFetchingTramStops,
              onChanged: (value) => controller.toggleTramStops(value),
              icon: const Icon(Icons.tram_outlined, color: Color(0xFF8A2BE2)),
            ),
            _buildStationTile(
              title: 'Bus Stops',
              value: controller.showBusStops,
              isLoading: controller.isFetchingBusStops,
              onChanged: (value) => _handleBusStopsToggle(context, value),
              icon: const Icon(Icons.directions_bus_outlined, color: Color(0xFFDA70D6)),
            ),
            _buildStationTile(
              title: 'Ferry Stops',
              value: controller.showFerryStops,
              isLoading: controller.isFetchingFerryStops,
              onChanged: (value) => controller.toggleFerryStops(value),
              icon: const Icon(Icons.directions_ferry_outlined, color: Color(0xFF0921AA)),
            ),
            if (controller.anyStationTypeVisible)
              _buildStationTile(
                title: 'Hiding Zones',
                value: controller.showHidingZones,
                isLoading: false,
                onChanged: (value) => controller.toggleHidingZones(value),
                icon: const Icon(Icons.visibility, color: Colors.teal),
              ),
          ],
        ),
      ),
    );
  }

  void _handleBusStopsToggle(BuildContext context, bool value) {
    if (value && !controller.busStopsWarningDismissed) {
      _showBusStopsWarningDialog(context);
    } else {
      controller.toggleBusStops(value);
    }
  }

  void _showBusStopsWarningDialog(BuildContext context) {
    bool dontAskAgain = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Performance Warning'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enabling Bus Stops can significantly impact performance. \n'
                'This feature is not recommended for large play areas.',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: dontAskAgain,
                    onChanged: (value) {
                      setState(() => dontAskAgain = value ?? false);
                    },
                  ),
                  const Expanded(child: Text("Don't ask again")),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (dontAskAgain) {
                  controller.dismissBusStopsWarning();
                }
                controller.toggleBusStops(true);
                Navigator.of(context).pop();
              },
              child: const Text('Enable'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationTile({
    required String title,
    required bool value,
    required bool isLoading,
    required ValueChanged<bool> onChanged,
    required Icon icon,
  }) {
    return ListTile(
      title: Text(title),
      leading: icon,
      onTap: isLoading ? null : () => onChanged(!value),
      trailing: isLoading
          ? Padding(
              padding: const EdgeInsets.only(left: 4.0, right: 14.0),
              child: const SizedBox(
                height: 32,
                width: 32,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : Switch(value: value, onChanged: onChanged),
    );
  }

  Widget _buildPoiTile({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required Color color,
    required bool value,
    required bool isLoading,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        onTap: () => onChanged(!value),
        trailing: isLoading
            ? Padding(
                padding: const EdgeInsets.only(right: 14.0),
                child: const SizedBox(
                  height: 32,
                  width: 32,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : Switch(value: value, onChanged: onChanged, activeTrackColor: color),
      ),
    );
  }
}
