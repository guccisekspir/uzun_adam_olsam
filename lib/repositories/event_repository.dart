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

/// Event type enum for internal tracking
enum EventType {
  none,
  main,
  neutral,
  chain,
}

/// Repository for managing event cards
class EventRepository {
  /// All event cards in the game
  final List<EventCard> allEvents = [];

  /// Events that have been triggered by chain reactions
  final List<EventCard> _chainEvents = [];

  /// Waiting queue for chain events to ensure neutral events between them
  final List<EventCard> _chainEventWaitingQueue = [];

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

  /// Flag to track if we need to show a neutral event before the next chain event
  bool _needNeutralBeforeChain = false;

  /// Constructor that initializes the event cards
  EventRepository() {
    loadEventsFromJson();
  }

  /// Loads events from JSON file
  Future<void> loadEventsFromJson() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/events.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final List<dynamic> eventList = jsonData['events'];
      allEvents.clear();

      for (var eventData in eventList) {
        final event = EventCard(
          id: eventData['id'],
          title: eventData['title'],
          description: eventData['description'],
          era: _parseEra(eventData['era']),
          yesImpact: ValueImpact(
            health: eventData['yesImpact']['health'],
            wealth: eventData['yesImpact']['wealth'],
            political: eventData['yesImpact']['political'],
            communal: eventData['yesImpact']['communal'],
            optionText: eventData['yesImpact']['optionText'],
          ),
          noImpact: ValueImpact(
            health: eventData['noImpact']['health'],
            wealth: eventData['noImpact']['wealth'],
            political: eventData['noImpact']['political'],
            communal: eventData['noImpact']['communal'],
            optionText: eventData['noImpact']['optionText'],
          ),
          yesChainEventId: eventData['yesChainEventId'],
          noChainEventId: eventData['noChainEventId'],
          imagePath: eventData['imagePath'],
          isNeutral: eventData['isNeutralEvent'] ?? false,
          sequence: eventData['sequence'] ?? 999,
        );
        allEvents.add(event);
      }
      debugPrint('Loaded ${allEvents.length} events');
    } catch (e) {
      debugPrint('Error loading events: $e');
      rethrow;
    }
  }

  /// Parses era string to GameEra enum
  GameEra _parseEra(String eraString) {
    switch (eraString) {
      case 'iktidara_yukselis':
        return GameEra.iktidara_yukselis;
      case 'konsolidasyon':
        return GameEra.konsolidasyon;
      case 'kriz_ve_tepki':
        return GameEra.kriz_ve_tepki;
      case 'gec_donem':
        return GameEra.gec_donem;
      default:
        return GameEra.iktidara_yukselis;
    }
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

    // Handle chain events with waiting queue logic
    if (_chainEvents.isNotEmpty || _chainEventWaitingQueue.isNotEmpty) {
      // If we need a neutral event before showing a chain event
      if (_needNeutralBeforeChain) {
        // Try to find a neutral event
        EventCard? neutralEvent = _getNextNeutralEvent(era);

        // If we found a neutral event, show it and mark that we can show chain events next
        if (neutralEvent != null) {
          _needNeutralBeforeChain = false;
          _lastEventType = EventType.neutral;
          _consecutiveNeutralCount++;
          return neutralEvent;
        }
        // If no neutral events available, we'll have to show a main event instead
        else {
          _needNeutralBeforeChain = false;
        }
      }

      // If we have chain events in the active queue, show the next one
      if (_chainEvents.isNotEmpty) {
        // Mark that we need a neutral event before the next chain event
        _needNeutralBeforeChain = true;
        _lastEventType = EventType.chain;
        _consecutiveNeutralCount = 0;
        return _chainEvents.removeAt(0);
      }

      // If we have chain events in the waiting queue, move them to the active queue
      if (_chainEventWaitingQueue.isNotEmpty) {
        _chainEvents.addAll(_chainEventWaitingQueue);
        _chainEventWaitingQueue.clear();

        // If we just showed a chain event, we need a neutral event before showing another
        if (_lastEventType == EventType.chain) {
          _needNeutralBeforeChain = true;

          // Try to find a neutral event
          EventCard? neutralEvent = _getNextNeutralEvent(era);

          // If we found a neutral event, show it
          if (neutralEvent != null) {
            _needNeutralBeforeChain = false;
            _lastEventType = EventType.neutral;
            _consecutiveNeutralCount++;
            return neutralEvent;
          }
        }

        // Show the next chain event
        _needNeutralBeforeChain = true;
        _lastEventType = EventType.chain;
        _consecutiveNeutralCount = 0;
        return _chainEvents.removeAt(0);
      }
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

    // Handle event selection based on type
    EventCard selectedEvent;

    if (nextEventType == EventType.neutral) {
      // For neutral events, use random selection
      List<EventCard> neutralEvents =
          eraEvents.where((event) => event.isNeutral).toList();

      // If no neutral events available, fall back to main events
      if (neutralEvents.isEmpty) {
        nextEventType = EventType.main;
        selectedEvent = _getNextChronologicalMainEvent(eraEvents);
      } else {
        // Select a random neutral event
        selectedEvent = _getImprovedRandomEvent(neutralEvents);
      }
    } else {
      // For main events, use chronological selection
      selectedEvent = _getNextChronologicalMainEvent(eraEvents);

      // If no main events available, fall back to neutral events
      if (selectedEvent.id == 'fallback_event') {
        nextEventType = EventType.neutral;
        List<EventCard> neutralEvents =
            eraEvents.where((event) => event.isNeutral).toList();
        if (neutralEvents.isNotEmpty) {
          selectedEvent = _getImprovedRandomEvent(neutralEvents);
        }
      }
    }

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

  /// Gets the next neutral event from the current era
  EventCard? _getNextNeutralEvent(GameEra era) {
    // Filter events by era and neutral type
    List<EventCard> neutralEvents = allEvents
        .where((event) => event.era == era && event.isNeutral)
        .toList();

    // Remove already shown events
    neutralEvents.removeWhere((event) => _shownEvents[era]!.contains(event.id));

    // If no neutral events available in this era, try other eras
    if (neutralEvents.isEmpty) {
      neutralEvents = allEvents.where((event) => event.isNeutral).toList();

      // Remove already shown events from all eras
      for (var currentEra in GameEra.values) {
        neutralEvents.removeWhere((event) =>
            event.era == currentEra &&
            _shownEvents[currentEra]!.contains(event.id));
      }

      // If still no neutral events available, return null
      if (neutralEvents.isEmpty) {
        return null;
      }
    }

    // Select a random neutral event
    EventCard selectedEvent = _getImprovedRandomEvent(neutralEvents);

    // Mark as shown to prevent repetition
    _shownEvents[selectedEvent.era]!.add(selectedEvent.id);

    return selectedEvent;
  }

  /// Gets the next chronological main event from a list of events
  EventCard _getNextChronologicalMainEvent(List<EventCard> events) {
    // Filter to only main (non-neutral) events
    List<EventCard> mainEvents =
        events.where((event) => !event.isNeutral).toList();

    if (mainEvents.isEmpty) {
      return _createFallbackEvent();
    }

    // Assign sequence numbers based on predefined chronology
    for (var event in mainEvents) {
      event = _assignSequenceNumber(event);
    }

    // Sort by sequence number
    mainEvents.sort((a, b) => a.sequence.compareTo(b.sequence));

    // Return the earliest event in the chronology
    return mainEvents.first;
  }

  /// Assigns a sequence number to an event based on predefined chronology
  EventCard _assignSequenceNumber(EventCard event) {
    // Get the sequence number from the predefined map
    int sequence =
        event.sequence ?? 999; // Default high number for unknown events

    // Create a new event with the sequence number
    return EventCard(
      id: event.id,
      title: event.title,
      description: event.description,
      era: event.era,
      yesImpact: event.yesImpact,
      noImpact: event.noImpact,
      yesChainEventId: event.yesChainEventId,
      noChainEventId: event.noChainEventId,
      imagePath: event.imagePath,
      isNeutral: event.isNeutral,
      sequence: sequence,
    );
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
      sequence: 1000, // High sequence number to ensure it comes last
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
      sequence: 1001, // Highest sequence number
    );
  }

  /// Creates a fallback event when no suitable events are found
  EventCard _createFallbackEvent() {
    return EventCard(
      id: 'fallback_event',
      title: 'Günlük İşler',
      description: 'Rutin devlet işleriyle ilgileniyorsunuz.',
      era: GameEra.iktidara_yukselis,
      yesImpact: ValueImpact(
        health: 0,
        wealth: 0,
        political: 0,
        communal: 0,
        optionText: 'Devam et',
      ),
      noImpact: ValueImpact(
        health: 0,
        wealth: 0,
        political: 0,
        communal: 0,
        optionText: 'Bekle',
      ),
      sequence: 999,
    );
  }

  /// Adds a chain event to be triggered based on player decision
  /// This is the key method that has been updated to handle conditional chaining
  void addChainEvent(String? eventId) {
    // If no event ID is provided, do nothing
    if (eventId == null) return;

    // Find the event by ID
    final event = allEvents.firstWhere(
      (e) => e.id == eventId,
      orElse: () => _createFallbackEvent(),
    );

    // If the event is the fallback event, it means we couldn't find the chain event
    // This could happen if the event ID is invalid or the event doesn't exist
    if (event.id == 'fallback_event') {
      debugPrint('Warning: Chain event with ID $eventId not found');
      return;
    }

    // Assign sequence number to the chain event
    final chainEvent = _assignSequenceNumber(event);

    // Add to waiting queue instead of directly to chain events
    _chainEventWaitingQueue.add(chainEvent);

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

    return (yesImpact + noImpact) ~/ 2; // Average of yes and no impacts
  }

  /// Resets the shown events tracking
  void resetShownEvents() {
    for (var era in GameEra.values) {
      _shownEvents[era]?.clear();
      _eraTransitionShown[era] = false;
    }
    _chainEvents.clear();
    _chainEventWaitingQueue.clear();
    _lastEventType = EventType.none;
    _consecutiveNeutralCount = 0;
    _needNeutralBeforeChain = false;
  }
}
