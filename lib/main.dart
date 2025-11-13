// Entry point for the Hide and Map application.
import 'package:flutter/material.dart';
import 'src/screens/map_screen.dart';
import 'src/util/app_preferences.dart';
import 'src/util/icon_provider.dart';

AppPreferences prefs = AppPreferences();
IconProvider icons = IconProvider();
GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await prefs.init();
  await icons.init();

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
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      home: const MapScreen(),
    );
  }
}
