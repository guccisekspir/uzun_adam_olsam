import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_card.dart';
import '../providers/game_state_provider.dart';
import '../widgets/card_swiper.dart';
import '../widgets/animated_value_indicator.dart';
import '../widgets/game_over_screen.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  // Previous values for animation
  int? _previousHealth;
  int? _previousWealth;
  int? _previousPolitical;
  int? _previousCommunal;

  // Animation flag
  bool _shouldAnimate = false;

  @override
  Widget build(BuildContext context) {
    final gameValues = ref.watch(gameStateProvider);
    final turnCount =
        ref.watch(gameStateProvider.select((state) => state.turnCount));
    final currentEvent =
        ref.watch(gameStateProvider.select((state) => state.currentEvent));
    final currentEra =
        ref.watch(gameStateProvider.select((state) => state.currentEra));
    final gameStatus =
        ref.watch(gameStateProvider.select((state) => state.gameState));
    final gameOverReason =
        ref.watch(gameStateProvider.select((state) => state.gameOverReason));

    // Oyun bitti mi kontrolü
    if (gameStatus == GameState.gameOver) {
      return GameOverScreen(
        reason: gameOverReason ?? 'Oyun bitti',
        onRestart: () {
          ref.read(gameStateProvider.notifier).restartGame();
          setState(() {
            _previousHealth = null;
            _previousWealth = null;
            _previousPolitical = null;
            _previousCommunal = null;
            _shouldAnimate = false;
          });
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Erdoğan Liderlik Kararları - ${currentEra.displayName}'),
        backgroundColor: currentEra.color,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(gameStateProvider.notifier).restartGame();
          setState(() {
            _previousHealth = null;
            _previousWealth = null;
            _previousPolitical = null;
            _previousCommunal = null;
            _shouldAnimate = false;
          });
        },
        child: const Icon(Icons.refresh),
        backgroundColor: Colors.red,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Değer göstergeleri
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AnimatedValueIndicator(
                    label: 'Sağlık',
                    value: gameValues.health,
                    previousValue: _previousHealth,
                    color: Colors.red,
                    animate: _shouldAnimate,
                  ),
                  AnimatedValueIndicator(
                    label: 'Zenginlik',
                    value: gameValues.wealth,
                    previousValue: _previousWealth,
                    color: Colors.amber,
                    animate: _shouldAnimate,
                  ),
                  AnimatedValueIndicator(
                    label: 'Politik',
                    value: gameValues.political,
                    previousValue: _previousPolitical,
                    color: Colors.blue,
                    animate: _shouldAnimate,
                  ),
                  AnimatedValueIndicator(
                    label: 'Toplumsal',
                    value: gameValues.communal,
                    previousValue: _previousCommunal,
                    color: Colors.green,
                    animate: _shouldAnimate,
                  ),
                ],
              ),
            ),

            // Tur bilgisi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tur: $turnCount',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    currentEra.displayName,
                    style: TextStyle(
                      color: currentEra.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Kart kaydırıcı
            Expanded(
              child: currentEvent != null
                  ? CardSwiper(
                      event: currentEvent,
                      onSwipeLeft: () {
                        // Store current values before decision
                        setState(() {
                          _previousHealth = gameValues.health;
                          _previousWealth = gameValues.wealth;
                          _previousPolitical = gameValues.political;
                          _previousCommunal = gameValues.communal;
                          _shouldAnimate = true;
                        });

                        // Make decision
                        ref.read(gameStateProvider.notifier).decideNo();

                        // Reset animation flag after a delay
                        Future.delayed(const Duration(milliseconds: 2000), () {
                          if (mounted) {
                            setState(() {
                              _shouldAnimate = false;
                            });
                          }
                        });
                      },
                      onSwipeRight: () {
                        // Store current values before decision
                        setState(() {
                          _previousHealth = gameValues.health;
                          _previousWealth = gameValues.wealth;
                          _previousPolitical = gameValues.political;
                          _previousCommunal = gameValues.communal;
                          _shouldAnimate = true;
                        });

                        // Make decision
                        ref.read(gameStateProvider.notifier).decideYes();

                        // Reset animation flag after a delay
                        Future.delayed(const Duration(milliseconds: 2000), () {
                          if (mounted) {
                            setState(() {
                              _shouldAnimate = false;
                            });
                          }
                        });
                      },
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
