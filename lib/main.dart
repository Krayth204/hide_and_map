// Entry point for the Hide and Map application.
import 'package:flutter/material.dart';
import 'src/models/map_features/feature_marker_provider.dart';
import 'src/screens/map_screen.dart';
import 'src/util/app_preferences.dart';

AppPreferences prefs = AppPreferences();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await prefs.init();
  await FeatureMarkerProvider.loadMarkerIcons();

  runApp(const HideAndMapApp());
}

class HideAndMapApp extends StatelessWidget {
  const HideAndMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hide and Map',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MapScreen(),
    );
  }
}
