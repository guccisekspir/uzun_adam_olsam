import 'package:flutter/material.dart';

/// Olay kartı sınıfı
class EventCard {
  final String id;
  final String title;
  final String description;
  final GameEra era;
  final ValueImpact yesImpact;
  final ValueImpact noImpact;
  final String? yesChainEventId;
  final String? noChainEventId;
  final String? imagePath;

  /// Constructor
  const EventCard({
    required this.id,
    required this.title,
    required this.description,
    required this.era,
    required this.yesImpact,
    required this.noImpact,
    this.yesChainEventId,
    this.noChainEventId,
    this.imagePath,
  });
}

/// Değer etkisi sınıfı
class ValueImpact {
  final int health;
  final int wealth;
  final int political;
  final int communal;
  final String optionText;
  final bool isDelayed;
  final int delayTurns;

  /// Constructor
  const ValueImpact({
    required this.health,
    required this.wealth,
    required this.political,
    required this.communal,
    required this.optionText,
    this.isDelayed = false,
    this.delayTurns = 0,
  });
}

/// Oyun dönemi enum
enum GameEra {
  iktidara_yukselis,
  konsolidasyon,
  kriz_ve_tepki,
  gec_donem,
}

/// Oyun dönemi uzantıları
extension GameEraExtension on GameEra {
  String get displayName {
    switch (this) {
      case GameEra.iktidara_yukselis:
        return 'İktidara Yükseliş (2003-2008)';
      case GameEra.konsolidasyon:
        return 'Konsolidasyon (2009-2015)';
      case GameEra.kriz_ve_tepki:
        return 'Kriz ve Tepki (2016-2020)';
      case GameEra.gec_donem:
        return 'Geç Dönem (2021-2025)';
    }
  }

  Color get color {
    switch (this) {
      case GameEra.iktidara_yukselis:
        return Colors.green;
      case GameEra.konsolidasyon:
        return Colors.blue;
      case GameEra.kriz_ve_tepki:
        return Colors.orange;
      case GameEra.gec_donem:
        return Colors.red;
    }
  }
}
