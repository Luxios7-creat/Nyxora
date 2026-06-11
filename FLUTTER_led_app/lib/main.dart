import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'led_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LedService.loadIp();

  runApp(const LedApp());
}

class LedApp extends StatelessWidget {
  const LedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,

        scaffoldBackgroundColor: const Color(0xFF050816),
      ),

      home: const HomeScreen(),
    );
  }
}