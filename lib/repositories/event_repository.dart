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

  /// Events that have been shown recently
  final List<String> _recentlyShownEvents = [];

  /// Random number generator
  final Random _random = Random();

  /// Constructor that initializes the event cards
  EventRepository() {
    loadEventsFromJson();
  }

  /// Gets the next event card based on the current game state
  EventCard getNextEvent(GameEra era, int turn) {
    // First check if there are any chain events

    if (allEvents.isEmpty) {
      loadEventsFromJson().then((_) {
        debugPrint('Events loaded successfully');
        getNextEvent(era, turn);
      }).catchError((error) {
        debugPrint('Error loading events: $error');
      });
    }
    if (_chainEvents.isNotEmpty) {
      return _chainEvents.removeAt(0);
    }

    // Filter events by era
    List<EventCard> eraEvents =
        allEvents.where((event) => event.era == era).toList();

    // If no events for this era, return a random event from any era
    if (eraEvents.isEmpty) {
      return _getRandomEventWithWeighting();
    }

    // Remove recently shown events to avoid repetition
    eraEvents.removeWhere((event) => _recentlyShownEvents.contains(event.id));

    // If all era events have been shown recently, reset the recently shown list
    if (eraEvents.isEmpty) {
      _recentlyShownEvents.clear();
      eraEvents = allEvents.where((event) => event.era == era).toList();
    }

    // Apply weighting to event selection
    EventCard selectedEvent = _getWeightedRandomEvent(eraEvents);

    // Add to recently shown events
    _recentlyShownEvents.add(selectedEvent.id);

    // Keep recently shown events list at a reasonable size
    if (_recentlyShownEvents.length > 10) {
      _recentlyShownEvents.removeAt(0);
    }

    return selectedEvent;
  }

  /// Adds a chain event to be triggered next
  void addChainEvent(String? eventId) {
    if (eventId == null) return;

    final event = allEvents.firstWhere(
      (e) => e.id == eventId,
      orElse: () => _getRandomEventWithWeighting(),
    );

    _chainEvents.add(event);
  }

  /// Gets a random event with weighting applied
  EventCard _getRandomEventWithWeighting() {
    // Apply weighting to all events
    return _getWeightedRandomEvent(allEvents);
  }

  /// Gets a weighted random event from a list of events
  EventCard _getWeightedRandomEvent(List<EventCard> events) {
    // If list is empty, return a fallback event
    if (events.isEmpty) {
      return _createFallbackEvent();
    }

    // Apply weighting based on event type
    List<EventCard> weightedEvents = [];

    for (var event in events) {
      // Add event multiple times based on weighting
      int weight = _getEventWeight(event);
      for (int i = 0; i < weight; i++) {
        weightedEvents.add(event);
      }
    }

    // Shuffle and select a random event
    weightedEvents.shuffle(_random);
    return weightedEvents[_random.nextInt(weightedEvents.length)];
  }

  /// Gets the weight for an event based on its properties
  int _getEventWeight(EventCard event) {
    // Base weight
    int weight = 1;

    // Increase weight for events with chain reactions
    if (event.yesChainEventId != null || event.noChainEventId != null) {
      weight += 1;
    }

    // Increase weight for events with significant impacts
    int totalImpact = _calculateTotalImpact(event);
    if (totalImpact > 30) {
      weight += 1;
    }

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
}
