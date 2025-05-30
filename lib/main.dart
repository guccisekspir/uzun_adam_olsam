import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'screens/tutorial_screen.dart';
import 'theme/neo_ottoman_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uzun Adam Liderlik Kararları',
      theme: NeoOttomanTheme.themeData,
      home: const HomeScreen(),
      routes: {
        '/game': (context) => const GameScreen(),
        '/tutorial': (context) => const TutorialScreen(),
      },
    );
  }
}
