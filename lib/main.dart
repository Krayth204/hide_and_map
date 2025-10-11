// Entry point for the Hide and Map application.
import 'package:flutter/material.dart';
import 'src/screens/map_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
