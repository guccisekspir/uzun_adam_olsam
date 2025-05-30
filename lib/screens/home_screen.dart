import 'package:erdogan_leadership_game/providers/game_state_provider.dart';
import 'package:erdogan_leadership_game/repositories/event_repository.dart';
import 'package:erdogan_leadership_game/theme/neo_ottoman_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          OttomanPatternBackground(
            assetPath: 'assets/images/ottoman_pattern.jpeg',
          ),
          Container(
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo and title with Ottoman-style decoration
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: NeoOttomanTheme.deepRed.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: NeoOttomanTheme.gold,
                          width: 3,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.account_balance,
                            size: 80,
                            color: NeoOttomanTheme.ivory,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Uzun Adam',
                            style: NeoOttomanTheme.titleStyle.copyWith(
                              fontSize: 40,
                              letterSpacing: 2,
                              shadows: [
                                const Shadow(
                                  offset: Offset(2.0, 2.0),
                                  blurRadius: 3.0,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'LİDERLİK KARARLARI',
                            style: NeoOttomanTheme.subtitleStyle.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Game description with ornate border
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: NeoOttomanTheme.gold,
                          width: 2,
                        ),
                      ),
                      child: const Text(
                        '20 yıllık liderlik döneminde Uzun Adam\'ın karşılaştığı zorlu kararları deneyimleyin. Sağlık, Zenginlik, Politik ve Toplumsal değerleri dengede tutarak Türkiye\'yi yönetin.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: NeoOttomanTheme.ivory,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Start button with Ottoman-style decoration
                    ElevatedButton(
                      onPressed: () async {
                        if (ref
                            .read(eventRepositoryProvider)
                            .allEvents
                            .isEmpty) {
                          await ref
                              .read(eventRepositoryProvider)
                              .loadEventsFromJson();
                        }

                        Navigator.pushNamed(context, '/game');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NeoOttomanTheme.deepRed,
                        foregroundColor: NeoOttomanTheme.ivory,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(
                            color: NeoOttomanTheme.gold,
                            width: 2,
                          ),
                        ),
                        elevation: 5,
                        shadowColor: Colors.black54,
                      ),
                      child: const Text('OYUNA BAŞLA'),
                    ),
                    const SizedBox(height: 20),

                    // Tutorial button with Ottoman-style
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/tutorial');
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: NeoOttomanTheme.ivory,
                        backgroundColor:
                            NeoOttomanTheme.royalBlue.withOpacity(0.7),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(
                            color: NeoOttomanTheme.turquoise,
                            width: 1,
                          ),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      child: const Text('NASIL OYNANIR?'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OttomanPatternBackground extends StatelessWidget {
  final String assetPath;
  const OttomanPatternBackground({super.key, required this.assetPath});

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive grid calculation
    final Size screenSize = MediaQuery.of(context).size;

    // Calculate optimal tile size and count
    // We want tiles to be visible enough to appreciate the pattern
    // but not so large that the pattern becomes the focus
    final double tileSize =
        screenSize.width / 4; // 3 tiles per row for better visibility

    // Calculate how many tiles we need to fill the screen
    final int horizontalTileCount = (screenSize.width / tileSize).ceil();
    final int verticalTileCount = (screenSize.height / tileSize).ceil();

    return Opacity(
      opacity: 0.7, // Slightly transparent for a subtle background
      child: GridView.builder(
        // Disable scrolling since this is a background
        physics: const NeverScrollableScrollPhysics(),

        // Grid layout settings
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: horizontalTileCount,
          childAspectRatio: 1.0, // Square tiles for seamless tiling
        ),

        // Generate enough tiles to fill the screen
        itemCount: horizontalTileCount * verticalTileCount,

        // Build each tile
        itemBuilder: (context, index) {
          return Image.asset(
            assetPath,
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}
