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

                  _buildRailwayTile(theme),

                  const Divider(height: 24, thickness: 1),

                  _buildPoiTile(
                    theme: theme,
                    icon: Icons.attractions,
                    title: 'Theme Parks',
                    color: const Color(0xFFFF6F00),
                    value: controller.showThemeParks,
                    isLoading: controller.isFetchingThemeParks,
                    onChanged: controller.toggleThemeParks,
                  ),
                  _buildPoiTile(
                    theme: theme,
                    icon: Icons.pets,
                    title: 'Zoos',
                    color: const Color(0xFF43A047),
                    value: controller.showZoos,
                    isLoading: controller.isFetchingZoos,
                    onChanged: controller.toggleZoos,
                  ),
                  _buildPoiTile(
                    theme: theme,
                    icon: Icons.water,
                    title: 'Aquariums',
                    color: const Color(0xFF3949AB),
                    value: controller.showAquariums,
                    isLoading: controller.isFetchingAquariums,
                    onChanged: controller.toggleAquariums,
                  ),
                  _buildPoiTile(
                    theme: theme,
                    icon: Icons.golf_course,
                    title: 'Golf Courses',
                    color: const Color(0xFF7CB342),
                    value: controller.showGolfCourses,
                    isLoading: controller.isFetchingGolfCourses,
                    onChanged: controller.toggleGolfCourses,
                  ),
                  _buildPoiTile(
                    theme: theme,
                    icon: Icons.museum,
                    title: 'Museums',
                    color: const Color(0xFF8E24AA),
                    value: controller.showMuseums,
                    isLoading: controller.isFetchingMuseums,
                    onChanged: controller.toggleMuseums,
                  ),
                  _buildPoiTile(
                    theme: theme,
                    icon: Icons.movie,
                    title: 'Movie Theaters',
                    color: const Color(0xFFD81B60),
                    value: controller.showMovieTheaters,
                    isLoading: controller.isFetchingMovieTheaters,
                    onChanged: controller.toggleMovieTheaters,
                  ),
                  _buildPoiTile(
                    theme: theme,
                    icon: Icons.emergency,
                    title: 'Hospitals',
                    color: const Color(0xFFC62828),
                    value: controller.showHospitals,
                    isLoading: controller.isFetchingHospitals,
                    onChanged: controller.toggleHospitals,
                  ),
                  _buildPoiTile(
                    theme: theme,
                    icon: Icons.local_library,
                    title: 'Libraries',
                    color: const Color(0xFFFBC02D),
                    value: controller.showLibraries,
                    isLoading: controller.isFetchingLibraries,
                    onChanged: controller.toggleLibraries,
                  ),
                  _buildPoiTile(
                    theme: theme,
                    icon: Icons.flag,
                    title: 'Consulates',
                    color: const Color(0xFF0097A7),
                    value: controller.showConsulates,
                    isLoading: controller.isFetchingConsulates,
                    onChanged: controller.toggleConsulates,
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

  Widget _buildRailwayTile(ThemeData theme) {
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
              Expanded(
                child: Text('Railway Stations', style: theme.textTheme.titleMedium),
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
                  value: controller.showRailwayStations || controller.railwayPartial,
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
              secondary: const Icon(Icons.train_outlined, color: Colors.indigo),
            ),
            SwitchListTile(
              title: const Text('Subway Stations'),
              value: controller.showSubwayStations,
              onChanged: controller.toggleSubwayStations,
              secondary: const Icon(Icons.subway_outlined, color: Colors.purple),
            ),

            if (controller.showRailwayStations || controller.railwayPartial)
              SwitchListTile(
                title: const Text('Hiding Zones'),
                value: controller.showHidingZones,
                onChanged: controller.toggleHidingZones,
                secondary: const Icon(Icons.visibility, color: Colors.teal),
              ),
          ],
        ),
      ),
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
                padding: EdgeInsets.only(right: 14.0),
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
