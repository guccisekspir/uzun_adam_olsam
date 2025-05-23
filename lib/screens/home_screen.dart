import 'package:erdogan_leadership_game/providers/game_state_provider.dart';
import 'package:erdogan_leadership_game/repositories/event_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red.shade700, Colors.red.shade900],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo ve başlık
                const Icon(
                  Icons.account_balance,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                const Text(
                  'ERDOĞAN',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const Text(
                  'LİDERLİK KARARLARI',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 60),

                // Oyun açıklaması
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '20 yıllık liderlik döneminde Recep Tayyip Erdoğan\'ın karşılaştığı zorlu kararları deneyimleyin. Sağlık, Zenginlik, Politik ve Toplumsal değerleri dengede tutarak Türkiye\'yi yönetin.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 60),

                // Başla butonu
                ElevatedButton(
                  onPressed: () async {
                    if (ref.read(eventRepositoryProvider).allEvents.isEmpty) {
                      await ref
                          .read(eventRepositoryProvider)
                          .loadEventsFromJson();
                    }

                    Navigator.pushNamed(context, '/game');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red.shade900,
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
                    ),
                  ),
                  child: const Text('OYUNA BAŞLA'),
                ),
                const SizedBox(height: 20),

                // Tutorial butonu
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/tutorial');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
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
    );
  }
}
