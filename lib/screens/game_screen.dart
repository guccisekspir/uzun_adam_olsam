import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_card.dart';
import '../providers/game_state_provider.dart';
import '../widgets/card_swiper.dart';
import '../widgets/value_indicator.dart';
import '../widgets/game_over_screen.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  ValueIndicator(
                    label: 'Sağlık',
                    value: gameValues.health,
                    color: Colors.red,
                  ),
                  ValueIndicator(
                    label: 'Zenginlik',
                    value: gameValues.wealth,
                    color: Colors.amber,
                  ),
                  ValueIndicator(
                    label: 'Politik',
                    value: gameValues.political,
                    color: Colors.blue,
                  ),
                  ValueIndicator(
                    label: 'Toplumsal',
                    value: gameValues.communal,
                    color: Colors.green,
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
                        ref.read(gameStateProvider.notifier).decideNo();
                      },
                      onSwipeRight: () {
                        ref.read(gameStateProvider.notifier).decideYes();
                      },
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
            ),

            // Kaydırma talimatları
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.arrow_back, color: Colors.red),
                      Text(
                        'HAYIR',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (currentEvent != null)
                        Text(
                          currentEvent.noImpact.optionText,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(Icons.arrow_forward, color: Colors.green),
                      Text(
                        'EVET',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (currentEvent != null)
                        Text(
                          currentEvent.yesImpact.optionText,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
