import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_card.dart';
import '../models/game_values.dart';
import '../repositories/event_repository.dart';

/// Oyun durumu enum
enum GameState {
  playing,
  gameOver,
}

/// Oyun durumu provider
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
    _eventRepository.resetShownEvents();
    
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
    debugPrint('Loading next event for era: ${state.currentEra}, turn: $turnCount');
    
    final nextEvent = _eventRepository.getNextEvent(state.currentEra, turnCount);
    
    // Check if this is an era transition event
    if (nextEvent.id.startsWith('era_transition_')) {
      // Handle era transition
      _handleEraTransition(nextEvent);
    } else {
      // Regular event
      state = state.copyWith(
        currentEvent: nextEvent,
      );
    }
  }

  /// Handle era transition events
  void _handleEraTransition(EventCard transitionEvent) {
    debugPrint('Handling era transition from ${state.currentEra}');
    
    // Determine the next era
    GameEra nextEra;
    switch (state.currentEra) {
      case GameEra.iktidara_yukselis:
        nextEra = GameEra.konsolidasyon;
        break;
      case GameEra.konsolidasyon:
        nextEra = GameEra.kriz_ve_tepki;
        break;
      case GameEra.kriz_ve_tepki:
        nextEra = GameEra.gec_donem;
        break;
      case GameEra.gec_donem:
        // If we're already in the last era, stay there
        nextEra = GameEra.gec_donem;
        break;
    }
    
    // Show the transition event first
    state = state.copyWith(
      currentEvent: transitionEvent,
      // Don't update the era yet - we'll do that after the player makes a choice
    );
    
    // Store the next era to transition to after player makes a choice
    _nextEraAfterTransition = nextEra;
  }
  
  // Store the next era to transition to after a transition event
  GameEra? _nextEraAfterTransition;

  /// Turu ilerletir
  void _advanceTurn() {
    state = state.copyWith(
      turnCount: state.turnCount + 1,
    );
    
    // Check if we need to transition to a new era after a transition event
    if (_nextEraAfterTransition != null) {
      debugPrint('Transitioning to new era: $_nextEraAfterTransition');
      state = state.copyWith(
        currentEra: _nextEraAfterTransition,
      );
      _nextEraAfterTransition = null;
    }

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
