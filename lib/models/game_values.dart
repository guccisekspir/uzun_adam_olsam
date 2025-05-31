import '../models/event_card.dart';
import '../providers/game_state_provider.dart';
import 'package:flutter/material.dart';

/// Oyun değerleri sınıfı
class GameValues {
  final int health;
  final int wealth;
  final int political;
  final int communal;
  final EventCard? currentEvent;
  final String? gameOverReason;
  final GameEra currentEra;
  final GameState gameState;
  final int turnCount;

  /// Constructor
  const GameValues({
    required this.health,
    required this.wealth,
    required this.political,
    required this.communal,
    this.currentEvent,
    this.gameOverReason,
    this.currentEra = GameEra.iktidara_yukselis,
    this.gameState = GameState.playing,
    this.turnCount = 0,
  });

  /// Başlangıç değerleri
  factory GameValues.initial() {
    return const GameValues(
      health: 50,
      wealth: 50,
      political: 50,
      communal: 50,
      currentEvent: null,
      gameOverReason: null,
      currentEra: GameEra.iktidara_yukselis,
      gameState: GameState.playing,
      turnCount: 0,
    );
  }

  /// Değerleri değiştirir
  GameValues copyWith({
    int? health,
    int? wealth,
    int? political,
    int? communal,
    EventCard? currentEvent,
    String? gameOverReason,
    GameEra? currentEra,
    GameState? gameState,
    int? turnCount,
  }) {
    return GameValues(
      health: health ?? this.health,
      wealth: wealth ?? this.wealth,
      political: political ?? this.political,
      communal: communal ?? this.communal,
      currentEvent: currentEvent ?? this.currentEvent,
      gameOverReason: gameOverReason ?? this.gameOverReason,
      currentEra: currentEra ?? this.currentEra,
      gameState: gameState ?? this.gameState,
      turnCount: turnCount ?? this.turnCount,
    );
  }

  /// Değerleri sınırlar içinde tutar
  GameValues clampValues() {
    return GameValues(
      health: health.clamp(0, 100),
      wealth: wealth.clamp(0, 100),
      political: political.clamp(0, 100),
      communal: communal.clamp(0, 100),
    );
  }

  /// Değerleri değiştirir
  GameValues applyChanges({
    required int health,
    required int wealth,
    required int political,
    required int communal,
  }) {
    return GameValues(
      health: (this.health + health).clamp(0, 100),
      wealth: (this.wealth + wealth).clamp(0, 100),
      political: (this.political + political).clamp(0, 100),
      communal: (this.communal + communal).clamp(0, 100),
    );
  }

  /// Doğal değer azalması
  GameValues applyDecay() {
    return GameValues(
      health: (health - 1).clamp(0, 100),
      wealth: (wealth - 1).clamp(0, 100),
      political: (political - 1).clamp(0, 100),
      communal: (communal - 1).clamp(0, 100),
    );
  }
}
