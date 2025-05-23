import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_card.dart';
import '../models/game_values.dart' hide GameEra;
import '../repositories/event_repository.dart';

/// Oyun durumu için enum
enum GameState {
  playing,
  gameOver,
}

/// Oyun değerlerini ve durumunu yöneten provider
class GameStateNotifier extends StateNotifier<GameValues> {
  final EventRepository _eventRepository;

  /// Constructor
  GameStateNotifier(this._eventRepository) : super(GameValues.initial()) {
    if (_eventRepository.allEvents.isEmpty) {
      _eventRepository.loadEventsFromJson().then((_) {
        debugPrint('Events loaded successfully');
        _loadNextEvent();
      }).catchError((error) {
        debugPrint('Error loading events: $error');
      });
    } else {
      _loadNextEvent();
    }
  }

  /// Mevcut olayı döndürür
  EventCard? get currentEvent => state.currentEvent;

  /// Mevcut dönemi döndürür
  GameEra get currentEra => state.currentEra;

  /// Tur sayısını döndürür
  int get turnCount => state.turnCount;

  /// Oyun durumunu döndürür
  GameState get gameState => state.gameState;

  /// Oyun sonu nedenini döndürür
  String? get gameOverReason => state.gameOverReason;

  /// Evet kararı verildiğinde çağrılır
  void decideYes() {
    if (state.gameState == GameState.gameOver || state.currentEvent == null)
      return;

    // Değerleri güncelle
    final newValues = state.applyChanges(
      health: state.currentEvent!.yesImpact.health,
      wealth: state.currentEvent!.yesImpact.wealth,
      political: state.currentEvent!.yesImpact.political,
      communal: state.currentEvent!.yesImpact.communal,
    );

    // Zincir olayı ekle
    _eventRepository.addChainEvent(state.currentEvent!.yesChainEventId);

    // Durumu güncelle
    state = newValues;
    _checkGameOver();
    if (state.gameState != GameState.gameOver) {
      _advanceTurn();
    }
  }

  /// Hayır kararı verildiğinde çağrılır
  void decideNo() {
    if (state.gameState == GameState.gameOver || state.currentEvent == null)
      return;

    // Değerleri güncelle
    final newValues = state.applyChanges(
      health: state.currentEvent!.noImpact.health,
      wealth: state.currentEvent!.noImpact.wealth,
      political: state.currentEvent!.noImpact.political,
      communal: state.currentEvent!.noImpact.communal,
    );

    // Zincir olayı ekle
    _eventRepository.addChainEvent(state.currentEvent!.noChainEventId);

    // Durumu güncelle
    state = newValues;
    _checkGameOver();
    if (state.gameState != GameState.gameOver) {
      _advanceTurn();
    }
  }

  /// Oyunu yeniden başlatır
  void restartGame() {
    state = const GameValues(
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

    _loadNextEvent();
  }

  /// Bir sonraki olayı yükler
  void _loadNextEvent() {
    debugPrint(
        'Loading next event for era: $state.currentEvent, turn: $turnCount');

    state = state.copyWith(
      health: state.health,
      wealth: state.wealth,
      political: state.political,
      communal: state.communal,
      currentEvent: _eventRepository.getNextEvent(state.currentEra, turnCount),
    );
  }

  /// Turu ilerletir
  void _advanceTurn() {
    state = state.copyWith(
      turnCount: state.turnCount + 1,
    );

    GameEra? newEra;

    // Dönem değişimi kontrolü
    if (turnCount >= 10 && state.currentEvent == GameEra.iktidara_yukselis) {
      newEra = GameEra.konsolidasyon;
    } else if (turnCount >= 20 && state.currentEvent == GameEra.konsolidasyon) {
      newEra = GameEra.kriz_ve_tepki;
    } else if (turnCount >= 30 && state.currentEvent == GameEra.gec_donem) {
      newEra = GameEra.gec_donem;
    }

    state = state.copyWith(
      currentEra: newEra ?? state.currentEra,
    );

    // Doğal değer azalması
    state = state.applyDecay();

    // Oyun sonu kontrolü
    _checkGameOver();

    // Yeni olay yükleme
    if (state.gameState != GameState.gameOver) {
      _loadNextEvent();
    }
  }

  /// Oyun sonu kontrolü
  void _checkGameOver() {
    GameState? newGameState;
    String? _gameOverReason;
    if (state.health <= 0) {
      newGameState = GameState.gameOver;
      _gameOverReason = "Halk sağlığı ve refahı çöktü. Hükümetiniz düştü.";
    } else if (state.wealth <= 0) {
      newGameState = GameState.gameOver;
      _gameOverReason = "Ekonomi çöktü. Hükümetiniz düştü.";
    } else if (state.political <= 0) {
      newGameState = GameState.gameOver;
      _gameOverReason = "Siyasi gücünüzü kaybettiniz. Hükümetiniz düştü.";
    } else if (state.communal <= 0) {
      newGameState = GameState.gameOver;
      _gameOverReason = "Toplumsal destek tamamen kayboldu. Hükümetiniz düştü.";
    }

    // Oyun durumu güncelle
    if (newGameState != null) {
      state = state.copyWith(
        gameState: newGameState,
        gameOverReason: _gameOverReason,
      );
    }
  }
}

/// Oyun durumu için provider
final gameStateProvider =
    StateNotifierProvider<GameStateNotifier, GameValues>((ref) {
  final eventRepository = ref.watch(eventRepositoryProvider);
  return GameStateNotifier(eventRepository);
});
