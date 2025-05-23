import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_state_provider.dart';

/// A widget that displays game balance settings
class GameBalanceSettings extends ConsumerWidget {
  /// Creates a new GameBalanceSettings widget
  const GameBalanceSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Balance Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Difficulty Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Starting values slider
            _buildSliderSetting(
              context,
              'Starting Values',
              50,
              (value) {
                // TODO: Implement starting values adjustment
              },
            ),
            
            // Value decay rate slider
            _buildSliderSetting(
              context,
              'Value Decay Rate',
              1,
              (value) {
                // TODO: Implement decay rate adjustment
              },
            ),
            
            // Decision impact multiplier slider
            _buildSliderSetting(
              context,
              'Decision Impact Multiplier',
              1.0,
              (value) {
                // TODO: Implement impact multiplier adjustment
              },
            ),
            
            // Random event frequency slider
            _buildSliderSetting(
              context,
              'Random Event Frequency',
              0.2,
              (value) {
                // TODO: Implement random event frequency adjustment
              },
            ),
            
            const SizedBox(height: 32),
            
            // Difficulty presets
            const Text(
              'Difficulty Presets',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPresetButton(
                  context,
                  'Easy',
                  Colors.green,
                  () {
                    // TODO: Set easy difficulty preset
                  },
                ),
                _buildPresetButton(
                  context,
                  'Medium',
                  Colors.orange,
                  () {
                    // TODO: Set medium difficulty preset
                  },
                ),
                _buildPresetButton(
                  context,
                  'Hard',
                  Colors.red,
                  () {
                    // TODO: Set hard difficulty preset
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Reset to defaults button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Reset to default settings
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('Reset to Defaults'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a slider setting with label and value
  Widget _buildSliderSetting(
    BuildContext context,
    String label,
    double value,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 0,
          max: label == 'Starting Values' ? 100 : 2,
          divisions: label == 'Starting Values' ? 10 : 20,
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Builds a difficulty preset button
  Widget _buildPresetButton(
    BuildContext context,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
      ),
      child: Text(label),
    );
  }
}
