import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/event_card.dart';
import '../models/game_values.dart' hide GameEra, ValueImpact;
import '../providers/game_state_provider.dart';

part 'event_repository.g.dart';

/// Provider for the event repository
@riverpod
EventRepository eventRepository(EventRepositoryRef ref) {
  return EventRepository();
}

/// Repository for managing event cards
class EventRepository {
  /// All event cards in the game
  final List<EventCard> allEvents = [];

  /// Events that have been triggered by chain reactions
  final List<EventCard> _chainEvents = [];

  /// Events that have been shown to the player, tracked by era
  final Map<GameEra, Set<String>> _shownEvents = {
    GameEra.iktidara_yukselis: {},
    GameEra.konsolidasyon: {},
    GameEra.kriz_ve_tepki: {},
    GameEra.gec_donem: {},
  };

  /// Tracks if an era transition event has been shown for each era
  final Map<GameEra, bool> _eraTransitionShown = {
    GameEra.iktidara_yukselis: false,
    GameEra.konsolidasyon: false,
    GameEra.kriz_ve_tepki: false,
    GameEra.gec_donem: false,
  };

  /// Random number generator with secure seed
  final Random _random = Random.secure();

  /// Tracks the last event type shown to manage sequence
  EventType _lastEventType = EventType.none;

  /// Tracks how many consecutive neutral events have been shown
  int _consecutiveNeutralCount = 0;

  /// Maximum number of consecutive neutral events allowed
  final int _maxConsecutiveNeutral = 2;

  /// Constructor that initializes the event cards
  EventRepository() {
    loadEventsFromJson();
  }

  /// Gets the next event card based on the current game state
  EventCard getNextEvent(GameEra era, int turn) {
    // Check if events are loaded, if not load them
    if (allEvents.isEmpty) {
      loadEventsFromJson().then((_) {
        debugPrint('Events loaded successfully');
        getNextEvent(era, turn);
      }).catchError((error) {
        debugPrint('Error loading events: $error');
      });
    }

    // First check if there are any chain events - these always take priority
    if (_chainEvents.isNotEmpty) {
      _lastEventType = EventType.chain;
      _consecutiveNeutralCount = 0;
      return _chainEvents.removeAt(0);
    }

    // Determine what type of event to show next based on sequence logic
    EventType nextEventType = _determineNextEventType();

    // Filter events by era
    List<EventCard> eraEvents =
        allEvents.where((event) => event.era == era).toList();

    // If no events for this era, return a random event from any era
    if (eraEvents.isEmpty) {
      return _getRandomEventWithWeighting();
    }

    // Remove already shown events to prevent repetition
    eraEvents.removeWhere((event) => _shownEvents[era]!.contains(event.id));

    // If all era events have been shown, create a special "era complete" event
    // that signals the game should move to the next era
    if (eraEvents.isEmpty) {
      // Check if we've already shown the transition event for this era
      if (_eraTransitionShown[era]!) {
        // If we've already shown the transition event, move to the next era
        GameEra nextEra;
        if (era == GameEra.gec_donem) {
          // For the last era, create a special "game complete" event
          return _createGameCompleteEvent();
        } else {
          // For other eras, determine the next era
          switch (era) {
            case GameEra.iktidara_yukselis:
              nextEra = GameEra.konsolidasyon;
              break;
            case GameEra.konsolidasyon:
              nextEra = GameEra.kriz_ve_tepki;
              break;
            case GameEra.kriz_ve_tepki:
              nextEra = GameEra.gec_donem;
              break;
            default:
              nextEra = GameEra.gec_donem;
          }

          // Get an event from the next era
          return getNextEvent(nextEra, turn);
        }
      } else {
        // Mark that we've shown the transition event for this era
        _eraTransitionShown[era] = true;

        // Return the era transition event
        return _createEraCompleteEvent(era);
      }
    }

    // Filter events by type (neutral or main)
    List<EventCard> filteredEvents;
    if (nextEventType == EventType.neutral) {
      filteredEvents = eraEvents.where((event) => event.isNeutral).toList();

      // If no neutral events available, fall back to main events
      if (filteredEvents.isEmpty) {
        nextEventType = EventType.main;
        filteredEvents = eraEvents.where((event) => !event.isNeutral).toList();
      }
    } else {
      // Main events
      filteredEvents = eraEvents.where((event) => !event.isNeutral).toList();

      // If no main events available, fall back to neutral events
      if (filteredEvents.isEmpty) {
        nextEventType = EventType.neutral;
        filteredEvents = eraEvents.where((event) => event.isNeutral).toList();
      }
    }

    // If still no events available after filtering, use any available event
    if (filteredEvents.isEmpty) {
      filteredEvents = eraEvents;
    }

    // Apply improved weighting and randomization to event selection
    EventCard selectedEvent = _getImprovedRandomEvent(filteredEvents);

    // Mark as shown to prevent repetition
    _shownEvents[era]!.add(selectedEvent.id);

    // Update tracking variables
    _lastEventType =
        selectedEvent.isNeutral ? EventType.neutral : EventType.main;
    if (selectedEvent.isNeutral) {
      _consecutiveNeutralCount++;
    } else {
      _consecutiveNeutralCount = 0;
    }

    return selectedEvent;
  }

  /// Determines what type of event to show next based on sequence logic
  EventType _determineNextEventType() {
    // If we've shown too many neutral events in a row, force a main event
    if (_consecutiveNeutralCount >= _maxConsecutiveNeutral) {
      return EventType.main;
    }

    // Base probabilities for event type selection
    double neutralProb;

    // Adjust probabilities based on last event type
    switch (_lastEventType) {
      case EventType.main:
        // After a main event, higher chance of neutral
        neutralProb = 0.7;
        break;
      case EventType.neutral:
        // After a neutral event, lower chance of another neutral
        neutralProb = 0.3;
        break;
      case EventType.chain:
        // After a chain event, moderate chance of neutral
        neutralProb = 0.5;
        break;
      case EventType.none:
        // At the start, equal chance
        neutralProb = 0.5;
        break;
    }

    // Random selection based on probabilities
    return _random.nextDouble() < neutralProb
        ? EventType.neutral
        : EventType.main;
  }

  /// Creates a special event that signals the end of an era
  EventCard _createEraCompleteEvent(GameEra era) {
    return EventCard(
      id: 'era_transition_${era.toString()}',
      title: 'Dönem Sonu: ${era.displayName}',
      description:
          'Bu dönemdeki önemli olaylar geride kaldı. Türkiye yeni bir döneme giriyor.',
      era: era,
      yesImpact: ValueImpact(
        health: 5,
        wealth: 5,
        political: 5,
        communal: 5,
        optionText: 'Yeni döneme geç',
      ),
      noImpact: ValueImpact(
        health: 0,
        wealth: 0,
        political: 0,
        communal: 0,
        optionText: 'Bekle',
      ),
    );
  }

  /// Creates a special event that signals the completion of the game
  EventCard _createGameCompleteEvent() {
    return EventCard(
      id: 'game_complete',
      title: 'Liderlik Yolculuğunuz Tamamlandı',
      description:
          'Türkiye\'nin liderliğinde uzun ve zorlu bir yolculuk geçirdiniz. Kararlarınız ülkenin geleceğini şekillendirdi.',
      era: GameEra.gec_donem,
      yesImpact: ValueImpact(
        health: 10,
        wealth: 10,
        political: 10,
        communal: 10,
        optionText: 'Yeni bir oyuna başla',
      ),
      noImpact: ValueImpact(
        health: 5,
        wealth: 5,
        political: 5,
        communal: 5,
        optionText: 'Devam et',
      ),
    );
  }

  /// Adds a chain event to be triggered next
  void addChainEvent(String? eventId) {
    if (eventId == null) return;

    final event = allEvents.firstWhere(
      (e) => e.id == eventId,
      orElse: () => _getRandomEventWithWeighting(),
    );

    _chainEvents.add(event);

    // Also mark as shown in its era to prevent it from appearing again in normal sequence
    _shownEvents[event.era]!.add(event.id);
  }

  /// Gets a random event with weighting applied
  EventCard _getRandomEventWithWeighting() {
    // Apply weighting to all events
    return _getImprovedRandomEvent(allEvents);
  }

  /// Gets a weighted random event from a list of events with improved randomization
  EventCard _getImprovedRandomEvent(List<EventCard> events) {
    // If list is empty, return a fallback event
    if (events.isEmpty) {
      return _createFallbackEvent();
    }

    // Calculate total weight for reservoir sampling
    int totalWeight = 0;
    final weights = <int>[];

    for (var event in events) {
      final weight = _getEventWeight(event);
      weights.add(weight);
      totalWeight += weight;
    }

    // Use weighted reservoir sampling for better randomization
    // This algorithm ensures fair selection based on weights
    int selectedIndex = 0;
    double maxWeight = 0;

    for (int i = 0; i < events.length; i++) {
      // Take random value according to weight
      final r = pow(_random.nextDouble(), 1.0 / weights[i]);
      if (r > maxWeight) {
        maxWeight = r.toDouble();
        selectedIndex = i;
      }
    }

    return events[selectedIndex];
  }

  /// Gets the weight for an event based on its properties with improved weighting
  int _getEventWeight(EventCard event) {
    // Base weight
    int weight = 10;

    // Adjust weight based on event properties
    // Chain events are slightly more important
    if (event.yesChainEventId != null || event.noChainEventId != null) {
      weight += 5;
    }

    // Neutral events have slightly lower weight by default
    if (event.isNeutral) {
      weight -= 2;
    }

    // Events with significant impacts are more important
    int totalImpact = _calculateTotalImpact(event);
    weight += (totalImpact ~/ 10); // Add 1 weight per 10 impact points

    // Add some randomness to the weight to prevent predictable patterns
    weight += _random.nextInt(5);

    return weight;
  }

  /// Calculates the total absolute impact of an event
  int _calculateTotalImpact(EventCard event) {
    int yesImpact = event.yesImpact.health.abs() +
        event.yesImpact.wealth.abs() +
        event.yesImpact.political.abs() +
        event.yesImpact.communal.abs();

    int noImpact = event.noImpact.health.abs() +
        event.noImpact.wealth.abs() +
        event.noImpact.political.abs() +
        event.noImpact.communal.abs();

    return yesImpact + noImpact;
  }

  /// Creates a fallback event in case no events are available
  EventCard _createFallbackEvent() {
    return EventCard(
      id: 'fallback_event',
      title: 'Beklenmedik Durum',
      description:
          'Beklenmedik bir durumla karşı karşıyasınız. Nasıl yanıt vereceksiniz?',
      era: GameEra.iktidara_yukselis,
      yesImpact: ValueImpact(
        health: 5,
        wealth: 5,
        political: 5,
        communal: 5,
        optionText: 'Olumlu yaklaşım göster',
      ),
      noImpact: ValueImpact(
        health: -5,
        wealth: -5,
        political: -5,
        communal: -5,
        optionText: 'Olumsuz yaklaşım göster',
      ),
    );
  }

  /// Loads events from the JSON file
  Future<void> loadEventsFromJson() async {
    try {
      // Load the JSON file from assets
      final jsonString = await rootBundle.loadString('assets/data/events.json');

      // Parse the JSON
      final jsonData = json.decode(jsonString);

      // Clear existing events
      allEvents.clear();

      // Convert JSON to EventCard objects
      for (var eventData in jsonData['events']) {
        final event = _convertJsonToEventCard(eventData);
        allEvents.add(event);
      }

      debugPrint('Loaded ${allEvents.length} events from JSON');
    } catch (e) {
      debugPrint('Error loading events from JSON: $e');
      // Fallback to hardcoded events if JSON loading fails
      _initializeHardcodedEvents();
    }
  }

  /// Converts a JSON object to an EventCard
  EventCard _convertJsonToEventCard(Map<String, dynamic> json) {
    // Convert era string to GameEra enum
    GameEra era;
    switch (json['era']) {
      case 'iktidara_yukselis':
        era = GameEra.iktidara_yukselis;
        break;
      case 'konsolidasyon':
        era = GameEra.konsolidasyon;
        break;
      case 'kriz_ve_tepki':
        era = GameEra.kriz_ve_tepki;
        break;
      case 'gec_donem':
        era = GameEra.gec_donem;
        break;
      default:
        era = GameEra.iktidara_yukselis;
    }

    // Create YES impact
    final yesImpact = ValueImpact(
      health: json['yesImpact']['health'],
      wealth: json['yesImpact']['wealth'],
      political: json['yesImpact']['political'],
      communal: json['yesImpact']['communal'],
      optionText: json['yesImpact']['optionText'],
      isDelayed: json['yesImpact']['isDelayed'] ?? false,
      delayTurns: json['yesImpact']['delayTurns'] ?? 0,
    );

    // Create NO impact
    final noImpact = ValueImpact(
      health: json['noImpact']['health'],
      wealth: json['noImpact']['wealth'],
      political: json['noImpact']['political'],
      communal: json['noImpact']['communal'],
      optionText: json['noImpact']['optionText'],
      isDelayed: json['noImpact']['isDelayed'] ?? false,
      delayTurns: json['noImpact']['delayTurns'] ?? 0,
    );

    // Check if this is a neutral event
    final isNeutral = json['isNeutralEvent'] ?? false;

    // Create and return the EventCard
    return EventCard(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      era: era,
      yesImpact: yesImpact,
      noImpact: noImpact,
      yesChainEventId: json['yesChainEventId'],
      noChainEventId: json['noChainEventId'],
      imagePath: json['imagePath'],
      isNeutral: isNeutral,
    );
  }

  /// Initializes hardcoded events as a fallback
  void _initializeHardcodedEvents() {
    debugPrint('Using hardcoded events as fallback');

    // Era 1: Rise to Power (2003-2008)
    allEvents.add(
      EventCard(
        id: 'parti_liderligi',
        title: 'Parti Liderliği',
        description:
            'Adalet ve Kalkınma Partisi (AKP) yaklaşan seçimlere katılmak için güçlü bir lidere ihtiyaç duyuyor. Partiyi yönetmek için öne çıkacak mısınız?',
        era: GameEra.iktidara_yukselis,
        yesImpact: ValueImpact(
          health: -5,
          wealth: 0,
          political: 15,
          communal: 10,
          optionText: 'AKP\'yi zafere taşıyacağım',
        ),
        noImpact: ValueImpact(
          health: 0,
          wealth: 0,
          political: -10,
          communal: 5,
          optionText: 'Perde arkasından destek vereceğim',
        ),
        yesChainEventId: 'secim_zaferi',
      ),
    );

    // Add more hardcoded events as needed...
    // This is just a fallback in case JSON loading fails
  }

  /// Reset the shown events tracking (useful for testing or starting a new game)
  void resetShownEvents() {
    for (var era in GameEra.values) {
      _shownEvents[era]!.clear();
      _eraTransitionShown[era] = false;
    }
    _lastEventType = EventType.none;
    _consecutiveNeutralCount = 0;
  }

  /// Get the count of remaining events for an era
  int getRemainingEventCount(GameEra era) {
    final eraEvents = allEvents.where((event) => event.era == era).toList();
    final shownCount = _shownEvents[era]!.length;
    return eraEvents.length - shownCount;
  }

  /// Get the count of remaining neutral events for an era
  int getRemainingNeutralEventCount(GameEra era) {
    final neutralEvents = allEvents
        .where((event) => event.era == era && event.isNeutral)
        .toList();
    final shownNeutralIds = _shownEvents[era]!
        .where(
            (id) => allEvents.any((event) => event.id == id && event.isNeutral))
        .toList();
    return neutralEvents.length - shownNeutralIds.length;
  }

  /// Get the count of remaining main events for an era
  int getRemainingMainEventCount(GameEra era) {
    final mainEvents = allEvents
        .where((event) => event.era == era && !event.isNeutral)
        .toList();
    final shownMainIds = _shownEvents[era]!
        .where((id) =>
            allEvents.any((event) => event.id == id && !event.isNeutral))
        .toList();
    return mainEvents.length - shownMainIds.length;
  }
}

/// Enum to track event types for sequencing
enum EventType {
  main,
  neutral,
  chain,
  none,
}
