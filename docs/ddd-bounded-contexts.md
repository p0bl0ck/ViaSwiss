# Domain-Driven Design Analysis for ViaSwiss

**Status:** Proposal  
**Last Updated:** 2026-05-18  
**Related:** [routing-enhancements-design.md](./routing-enhancements-design.md)

---

## Executive Summary

This document applies Domain-Driven Design (DDD) strategic and tactical patterns to ViaSwiss, a Flutter mobile app for planning scenic Swiss train journeys with weather integration. The analysis identifies bounded contexts, aggregates, value objects, domain services, and integration patterns for both the current implementation and the proposed feature roadmap (F1-F11).

---

## Table of Contents

1. [Domain Vision](#1-domain-vision)
2. [Strategic Design](#2-strategic-design)
3. [Bounded Contexts](#3-bounded-contexts)
4. [Context Map](#4-context-map)
5. [Tactical Patterns](#5-tactical-patterns)
6. [Domain Events](#6-domain-events)
7. [Anti-Corruption Layers](#7-anti-corruption-layers)
8. [Shared Kernel](#8-shared-kernel)
9. [Ubiquitous Language](#9-ubiquitous-language)
10. [Implementation Roadmap](#10-implementation-roadmap)
11. [Package Structure](#11-package-structure)

---

## 1. Domain Vision

### 1.1 Vision Statement

> ViaSwiss enables travelers to plan scenic Swiss train journeys optimized for weather, experience quality, and personal preferences, with contextual discovery of points of interest along the way.

### 1.2 Core Domain Identification

The **Core Domain** is **Journey Planning & Optimization** - this is the primary value proposition that differentiates ViaSwiss from generic travel apps.

| Classification | Domain Area | Rationale |
|---------------|-------------|-----------|
| **Core Domain** | Journey Planning & Optimization | Primary differentiator - scenic route planning |
| **Core Domain** | Experience & Scenic Routing | Key differentiator - "scenic" is in the app's DNA |
| **Supporting** | Weather Intelligence | Enhances core but could use external services |
| **Supporting** | POI Discovery | Adds value but not primary purpose |
| **Supporting** | User Identity & Persistence | Enabler for personalization |
| **Generic** | Station Management | Standard reference data |
| **Generic** | Map Visualization | Commodity functionality |

---

## 2. Strategic Design

### 2.1 Subdomains

```
┌─────────────────────────────────────────────────────────────────┐
│                      ViaSwiss Domain                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    CORE DOMAIN                          │   │
│  │  ┌─────────────────┐  ┌─────────────────────────────┐   │   │
│  │  │ Journey Planning│  │ Experience & Scenic Routing │   │   │
│  │  │ & Optimization  │  │                             │   │   │
│  │  └─────────────────┘  └─────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                  SUPPORTING SUBDOMAINS                   │   │
│  │  ┌────────────┐ ┌────────────┐ ┌────────────┐           │   │
│  │  │  Weather   │ │    POI     │ │  Identity  │           │   │
│  │  │Intelligence│ │ Discovery  │ │ & Persist  │           │   │
│  │  └────────────┘ └────────────┘ └────────────┘           │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                   GENERIC SUBDOMAINS                     │   │
│  │  ┌────────────┐ ┌────────────┐ ┌────────────┐           │   │
│  │  │  Station   │ │    Map     │ │  Offline   │           │   │
│  │  │ Management │ │Visualization│ │   Cache   │           │   │
│  │  └────────────┘ └────────────┘ └────────────┘           │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 Problem Space vs Solution Space

| Problem Space (What) | Solution Space (How) |
|---------------------|---------------------|
| Finding scenic train routes | Journey Planning Context + Experience Context |
| Weather-aware travel planning | Weather Context + Recommendation Context |
| Discovering things to do during transfers | POI Context |
| Remembering good routes | Trips Context |
| Planning multi-day trips | Trips Context (Itinerary) |
| Offline access in mountains | Offline Context |
| Cross-device sync | Identity Context |

---

## 3. Bounded Contexts

### 3.1 Context Overview

| Context | Type | Status | Features |
|---------|------|--------|----------|
| Station | Generic | Implemented | Core search |
| Journey Planning | Core | Implemented | F1, F2, F11 |
| Weather | Supporting | Implemented | F2, F6 |
| Recommendation | Core | Partial | F2, F6 |
| Experience | Core | **NEW** | F7 |
| POI | Supporting | **NEW** | F3, F5, F11 |
| Trips | Supporting | **NEW** | F8 |
| Identity | Generic | **NEW** | F9 |
| Offline | Supporting | **NEW** | F10 |
| Map | Generic | Scaffolded | F4 |

### 3.2 Station Context (Generic)

**Responsibility:** Managing train station reference data and search

**Current Files:**
- `lib/features/search/domain/models/station.dart`
- `lib/features/search/data/repositories/station_repository.dart`
- `lib/features/search/providers/station_providers.dart`

**Domain Model:**

| Concept | DDD Type | Description |
|---------|----------|-------------|
| `Station` | Entity | Train station with unique identity |
| `StationId` | Value Object | Typed identifier |
| `Coordinates` | Value Object | Latitude/longitude (Shared Kernel) |
| `StationSearchService` | Domain Service | Search orchestration |

```dart
// Proposed Station Aggregate
@freezed
class Station with _$Station {
  const Station._();
  
  const factory Station({
    required StationId id,
    required String name,
    required Coordinates coordinates,
    int? elevation, // For weather risk assessment (F2)
  }) = _Station;
  
  bool get isHighAltitude => elevation != null && elevation! > 1000;
}

// Typed ID
class StationId extends EntityId<Station> {
  const StationId(super.value);
}
```

---

### 3.3 Journey Planning Context (Core Domain)

**Responsibility:** Planning optimal train journeys between stations

**Related Features:** F1 (Preferences), F2 (Weather Replanning), F11 (Car API)

**Current Files:**
- `lib/features/journey/domain/models/journey.dart`
- `lib/features/journey/domain/models/leg.dart`
- `lib/features/journey/domain/models/transport.dart`
- `lib/features/journey/data/repositories/journey_repository.dart`

**Domain Model:**

| Concept | DDD Type | Status | Description |
|---------|----------|--------|-------------|
| `Journey` | **Aggregate Root** | Exists | Complete journey A to B |
| `JourneyId` | Value Object | **NEW** | Typed identifier |
| `Leg` | Entity | Exists | Single journey segment |
| `Transport` | Value Object | Exists | Transport type/number |
| `TransportType` | Value Object (Enum) | Exists | IC, IR, RE, S, etc. |
| `RoutePreferences` | Value Object | **NEW (F1)** | User preferences |
| `ScenicScore` | Value Object | **NEW** | Quality rating (0-100) |
| `Duration` | Value Object | **NEW** | Travel time |
| `Delay` | Value Object | **NEW** | Minutes delayed |
| `Platform` | Value Object | **NEW** | Platform identifier |
| `JourneyScoringService` | Domain Service | **NEW (F1)** | Score/rank journeys |

**Aggregate Structure:**

```
Journey (Aggregate Root)
├── id: JourneyId
├── from: Station (reference)
├── to: Station (reference)
├── departure: DateTime
├── arrival: DateTime
├── duration: Duration
├── transfers: int
├── scenicScore: ScenicScore?
└── legs: List<Leg>
    ├── id: LegId
    ├── from: Station (reference)
    ├── to: Station (reference)
    ├── departure: DateTime
    ├── arrival: DateTime
    ├── platform: Platform?
    ├── transport: Transport
    └── delay: Delay?
```

**Aggregate Invariants:**

```dart
@freezed
class Journey with _$Journey {
  const Journey._();
  
  const factory Journey({
    required JourneyId id,
    required Station from,
    required Station to,
    required DateTime departure,
    required DateTime arrival,
    required Duration duration,
    required int transfers,
    ScenicScore? scenicScore,
    required List<Leg> legs,
  }) = _Journey;
  
  // Invariant: Legs form continuous path
  bool get hasValidLegContinuity {
    for (int i = 0; i < legs.length - 1; i++) {
      if (legs[i].to.id != legs[i + 1].from.id) return false;
    }
    return true;
  }
  
  // Invariant: Times are sequential
  bool get hasValidTimings {
    for (int i = 0; i < legs.length - 1; i++) {
      if (legs[i].arrival.isAfter(legs[i + 1].departure)) return false;
    }
    return true;
  }
  
  // Domain logic
  bool get isDirect => transfers == 0;
  bool get isScenic => scenicScore != null && scenicScore!.value >= 80;
  bool get departsSoon => departure.difference(DateTime.now()).inMinutes < 15;
  
  Duration get totalDelay => legs
    .where((leg) => leg.delay != null)
    .fold(Duration.zero, (sum, leg) => sum + leg.delay!.toDuration());
  
  bool get hasDelay => totalDelay > Duration.zero;
  
  Leg? get firstLeg => legs.isNotEmpty ? legs.first : null;
  Leg? get lastLeg => legs.isNotEmpty ? legs.last : null;
}
```

**Route Preferences (F1):**

```dart
enum RouteOptimization { scenic, fastest, fewestTransfers, balanced }

@freezed
class RoutePreferences with _$RoutePreferences {
  const factory RoutePreferences({
    @Default(RouteOptimization.balanced) RouteOptimization optimizeFor,
    @Default(false) bool avoidSteepElevation,
    @Default(false) bool preferLowCarbon,
    int? maxTransfers,
    int? maxDurationMinutes,
  }) = _RoutePreferences;
}
```

**Journey Scoring Service (F1):**

```dart
class JourneyScoringService {
  JourneyScore scoreJourney(
    Journey journey,
    RoutePreferences preferences,
    Weather? weather,
  ) {
    double score = 0;
    
    switch (preferences.optimizeFor) {
      case RouteOptimization.scenic:
        score = (journey.scenicScore?.value ?? 50).toDouble();
        break;
      case RouteOptimization.fastest:
        score = 100 - (journey.duration.inMinutes / 10).clamp(0, 100);
        break;
      case RouteOptimization.fewestTransfers:
        score = 100 - (journey.transfers * 20).clamp(0, 100);
        break;
      case RouteOptimization.balanced:
        final scenic = journey.scenicScore?.value ?? 50;
        final speed = 100 - (journey.duration.inMinutes / 10).clamp(0, 100);
        final transfers = 100 - (journey.transfers * 20).clamp(0, 100);
        score = (scenic + speed + transfers) / 3;
        break;
    }
    
    // Apply weather bonus/penalty
    if (weather != null) {
      score += _weatherModifier(weather);
    }
    
    return JourneyScore(value: score.clamp(0, 100).toInt());
  }
  
  double _weatherModifier(Weather weather) {
    return switch (weather.condition) {
      WeatherCondition.CLEAR => 10,
      WeatherCondition.PARTLY_CLOUDY => 5,
      WeatherCondition.CLOUDY => 0,
      WeatherCondition.RAINY => -10,
      WeatherCondition.SNOWY => -5,
      WeatherCondition.STORMY => -20,
      WeatherCondition.FOGGY => -15,
    };
  }
}
```

---

### 3.4 Weather Context (Supporting)

**Responsibility:** Weather data, forecasting, and risk assessment

**Related Features:** F2 (Weather Replanning), F6 (Weather Escape)

**Current Files:**
- `lib/features/weather/domain/models/weather.dart`

**Domain Model:**

| Concept | DDD Type | Status | Description |
|---------|----------|--------|-------------|
| `Weather` | Entity | Exists | Current weather snapshot |
| `WeatherForecast` | Entity | Exists | Future prediction |
| `WeatherCondition` | Value Object (Enum) | Exists | CLEAR, RAINY, etc. |
| `Temperature` | Value Object | **NEW** | Celsius value |
| `PrecipitationProbability` | Value Object | **NEW** | 0-100% |
| `WindSpeed` | Value Object | **NEW** | km/h |
| `WeatherRisk` | Value Object | **NEW (F2)** | Risk assessment |
| `RiskLevel` | Value Object (Enum) | **NEW (F2)** | HIGH/MEDIUM/LOW |
| `LegWeatherRisk` | Value Object | **NEW (F2)** | Per-leg risk |
| `WeatherScore` | Value Object | **NEW (F6)** | Comfort score |
| `WeatherRiskAssessmentService` | Domain Service | **NEW (F2)** | Assess risks |
| `WeatherEscapeService` | Domain Service | **NEW (F6)** | Find better weather |

**Weather Risk Assessment (F2):**

```dart
enum RiskLevel { high, medium, low }

@freezed
class LegWeatherRisk with _$LegWeatherRisk {
  const factory LegWeatherRisk({
    required RiskLevel level,
    String? reason,
    required Weather legWeather,
    List<Journey>? alternatives,
  }) = _LegWeatherRisk;
}

class WeatherRiskAssessmentService {
  LegWeatherRisk assessLegRisk(Leg leg, Weather weather, {int? stationElevation}) {
    // HIGH RISK conditions
    if (_isHighRisk(weather, leg, stationElevation)) {
      return LegWeatherRisk(
        level: RiskLevel.high,
        reason: _buildHighRiskReason(weather),
        legWeather: weather,
      );
    }
    
    // MEDIUM RISK conditions
    if (_isMediumRisk(weather, leg, stationElevation)) {
      return LegWeatherRisk(
        level: RiskLevel.medium,
        reason: _buildMediumRiskReason(weather),
        legWeather: weather,
      );
    }
    
    return LegWeatherRisk(
      level: RiskLevel.low,
      reason: null,
      legWeather: weather,
    );
  }
  
  bool _isHighRisk(Weather w, Leg leg, int? elevation) {
    // Precipitation > 70% with snow/storm
    if (w.precipitationProbability > 70 &&
        [WeatherCondition.SNOWY, WeatherCondition.STORMY].contains(w.condition)) {
      return true;
    }
    // Wind > 80 km/h
    if (w.windSpeed != null && w.windSpeed! > 80) return true;
    // Fog with road transport
    if (w.condition == WeatherCondition.FOGGY &&
        leg.transport.type == TransportType.BUS) {
      return true;
    }
    return false;
  }
  
  bool _isMediumRisk(Weather w, Leg leg, int? elevation) {
    // Precipitation > 50% with rain
    if (w.precipitationProbability > 50 &&
        w.condition == WeatherCondition.RAINY) {
      return true;
    }
    // Wind > 60 km/h
    if (w.windSpeed != null && w.windSpeed! > 60) return true;
    // Snow at high altitude
    if (w.condition == WeatherCondition.SNOWY &&
        elevation != null && elevation > 1000) {
      return true;
    }
    return false;
  }
}
```

**Weather Escape Service (F6):**

```dart
@freezed
class WeatherEscape with _$WeatherEscape {
  const factory WeatherEscape({
    required Station destination,
    required Weather destinationWeather,
    required int travelMinutes,
    required double weatherImprovement,
    Journey? suggestedJourney,
  }) = _WeatherEscape;
}

class WeatherEscapeService {
  double calculateWeatherScore(Weather weather) {
    final precipitationScore = (100 - weather.precipitationProbability) * 0.4;
    final temperatureScore = _temperatureComfort(weather.temperature) * 0.3;
    final conditionScore = _conditionScore(weather.condition) * 0.3;
    return precipitationScore + temperatureScore + conditionScore;
  }
  
  double calculateImprovement(Weather origin, Weather destination) {
    return calculateWeatherScore(destination) - calculateWeatherScore(origin);
  }
  
  double _temperatureComfort(double temp) {
    // Optimal: 18-24°C
    if (temp >= 18 && temp <= 24) return 100;
    if (temp < 18) return 100 - ((18 - temp) * 5).clamp(0, 100);
    return 100 - ((temp - 24) * 5).clamp(0, 100);
  }
  
  double _conditionScore(WeatherCondition condition) {
    return switch (condition) {
      WeatherCondition.CLEAR => 100,
      WeatherCondition.PARTLY_CLOUDY => 80,
      WeatherCondition.CLOUDY => 60,
      WeatherCondition.FOGGY => 40,
      WeatherCondition.RAINY => 30,
      WeatherCondition.SNOWY => 50,
      WeatherCondition.STORMY => 10,
    };
  }
}
```

---

### 3.5 Recommendation Context (Core Domain - Composite)

**Responsibility:** Combining journey, weather, and preferences into actionable recommendations

**Related Features:** F2 (Weather Replanning), F6 (Weather Escape)

**Current Files:**
- `lib/features/journey/domain/models/route_recommendation.dart`

**Domain Model:**

| Concept | DDD Type | Status | Description |
|---------|----------|--------|-------------|
| `RouteRecommendation` | **Aggregate Root** | Exists | Journey + weather + advice |
| `TravelWarning` | Value Object | **Enhanced** | Structured warning |
| `WarningType` | Value Object (Enum) | **NEW** | Weather/delay/scenic |
| `Recommendation` | Value Object | **Enhanced** | Structured advice |
| `RecommendationService` | Domain Service | **NEW** | Generate recommendations |
| `WarningGeneratorService` | Domain Service | **NEW** | Generate warnings |

```dart
enum WarningType { weather, delay, scenic, capacity }

@freezed
class TravelWarning with _$TravelWarning {
  const factory TravelWarning({
    required WarningType type,
    required String message,
    required RiskLevel severity,
    Leg? affectedLeg,
  }) = _TravelWarning;
  
  factory TravelWarning.weather(String message, {Leg? leg}) => TravelWarning(
    type: WarningType.weather,
    message: message,
    severity: RiskLevel.medium,
    affectedLeg: leg,
  );
  
  factory TravelWarning.delay(String message, {Leg? leg}) => TravelWarning(
    type: WarningType.delay,
    message: message,
    severity: RiskLevel.medium,
    affectedLeg: leg,
  );
}

class WarningGeneratorService {
  List<TravelWarning> generateWarnings(Journey journey, Weather weather) {
    final warnings = <TravelWarning>[];
    
    if (weather.precipitationProbability > 70) {
      warnings.add(TravelWarning.weather(
        'High chance of ${weather.condition.name.toLowerCase()}. '
        'Bring appropriate gear.',
      ));
    }
    
    if (journey.hasDelay) {
      warnings.add(TravelWarning.delay(
        'Current delays of ${journey.totalDelay.inMinutes} minutes on this route.',
      ));
    }
    
    if (weather.condition == WeatherCondition.FOGGY && journey.isScenic) {
      warnings.add(TravelWarning(
        type: WarningType.scenic,
        message: 'Fog may reduce scenic visibility. Consider alternative timing.',
        severity: RiskLevel.low,
      ));
    }
    
    return warnings;
  }
}
```

---

### 3.6 Experience Context (Core Domain) - NEW

**Responsibility:** Multi-dimensional experience scoring and scenic moment guidance

**Related Features:** F7 (Experience-Aware Routes)

**Domain Model:**

| Concept | DDD Type | Description |
|---------|----------|-------------|
| `ExperienceScore` | **Aggregate Root** | Multi-dimensional rating |
| `ExperienceMoment` | Entity | Timed scenic highlight |
| `GoldenHourAlignment` | Value Object | Sunset/sunrise timing |
| `PhotoOpportunity` | Value Object | Photo spot quality |
| `TranquilityScore` | Value Object | Crowding rating |
| `WindowSide` | Value Object (Enum) | Left/Right window |
| `ExperienceScoringService` | Domain Service | Calculate scores |

```dart
@freezed
class ExperienceScore with _$ExperienceScore {
  const ExperienceScore._();
  
  const factory ExperienceScore({
    required int overall,           // 0-100
    required int scenicLandscape,   // Pre-scored per segment
    required int goldenHour,        // Sun position alignment
    required int photoOpportunities,// POI density
    required int tranquility,       // Quieter routes/times
    String? highlight,              // "Best for sunset views"
    @Default([]) List<ExperienceMoment> moments,
  }) = _ExperienceScore;
  
  bool get isExceptional => overall >= 90;
  bool get isRecommended => overall >= 70;
}

enum WindowSide { left, right, both }

@freezed
class ExperienceMoment with _$ExperienceMoment {
  const factory ExperienceMoment({
    required String description,      // "Lake Brienz panorama"
    required int minutesFromDeparture,// When to look
    required WindowSide side,         // Left or right
    String? tip,                      // "Best in morning light"
    Coordinates? location,
  }) = _ExperienceMoment;
}

class ExperienceScoringService {
  ExperienceScore scoreJourney(
    Journey journey,
    DateTime departureTime,
    List<POI> nearbyPOIs,
  ) {
    final scenic = journey.scenicScore?.value ?? 50;
    final goldenHour = _calculateGoldenHourScore(journey, departureTime);
    final photoOps = _calculatePhotoScore(journey, nearbyPOIs);
    final tranquility = _calculateTranquilityScore(departureTime);
    
    final overall = (scenic * 0.4 + goldenHour * 0.2 + 
                     photoOps * 0.2 + tranquility * 0.2).round();
    
    return ExperienceScore(
      overall: overall,
      scenicLandscape: scenic,
      goldenHour: goldenHour,
      photoOpportunities: photoOps,
      tranquility: tranquility,
      highlight: _generateHighlight(journey, departureTime),
      moments: _generateMoments(journey),
    );
  }
  
  int _calculateGoldenHourScore(Journey journey, DateTime departure) {
    // Check if journey aligns with sunrise/sunset
    final hour = departure.hour;
    // Golden hours: 6-8 AM, 6-8 PM (varies by season)
    if ((hour >= 6 && hour <= 8) || (hour >= 18 && hour <= 20)) {
      return 90;
    }
    return 50;
  }
  
  int _calculateTranquilityScore(DateTime departure) {
    // Off-peak times score higher
    final hour = departure.hour;
    final isWeekend = departure.weekday >= 6;
    
    if (isWeekend && (hour < 9 || hour > 18)) return 90;
    if (hour < 7 || hour > 20) return 85;
    if (hour >= 9 && hour <= 17) return 40; // Rush hours
    return 60;
  }
}
```

---

### 3.7 POI Context (Supporting) - NEW

**Responsibility:** Points of interest discovery and management

**Related Features:** F3 (Along-Route POIs), F5 (POIs in Radius), F11 (Stored POIs)

**Domain Model:**

| Concept | DDD Type | Description |
|---------|----------|-------------|
| `POI` | Entity | Point of interest |
| `POIId` | Value Object | Typed identifier |
| `POICategory` | Value Object (Enum) | Classification |
| `TransferPOI` | Value Object | POI at transfer station |
| `POISearchCriteria` | Value Object | Search parameters |
| `VisitDuration` | Value Object | Estimated visit time |
| `DistanceFromStation` | Value Object | Walking distance |
| `SavedPOI` | Entity | User-bookmarked POI |
| `POIDiscoveryService` | Domain Service | Filter by transfer window |

```dart
enum POICategory {
  viewpoint,
  cafe,
  restaurant,
  museum,
  historic,
  nature,
  photoSpot,
  shopping,
}

@freezed
class POI with _$POI {
  const POI._();
  
  const factory POI({
    required POIId id,
    required String name,
    required POICategory category,
    required Coordinates coordinates,
    required int estimatedVisitMinutes,
    double? distanceFromStation,
    String? description,
    String? imageUrl,
  }) = _POI;
  
  bool fitsInWindow(int availableMinutes) {
    // Allow 5 min buffer for walking back
    return estimatedVisitMinutes <= (availableMinutes - 5);
  }
  
  bool get isQuickStop => estimatedVisitMinutes <= 15;
}

@freezed
class TransferPOI with _$TransferPOI {
  const factory TransferPOI({
    required Station station,
    required int availableMinutes,
    required List<POI> pois,
  }) = _TransferPOI;
}

@freezed
class POISearchCriteria with _$POISearchCriteria {
  const factory POISearchCriteria({
    required Coordinates center,
    @Default(2.0) double radiusKm,
    List<POICategory>? categories,
    @Default(20) int limit,
    int? maxVisitMinutes,
  }) = _POISearchCriteria;
}

class POIDiscoveryService {
  List<TransferPOI> findPOIsAlongRoute(Journey journey, List<POI> allPOIs) {
    final transferPOIs = <TransferPOI>[];
    
    for (int i = 0; i < journey.legs.length - 1; i++) {
      final currentLeg = journey.legs[i];
      final nextLeg = journey.legs[i + 1];
      
      // Calculate transfer window
      final transferMinutes = nextLeg.departure
          .difference(currentLeg.arrival)
          .inMinutes;
      
      if (transferMinutes >= 10) {
        // Find POIs near this transfer station
        final nearbyPOIs = allPOIs
            .where((poi) => poi.coordinates.isWithinRadius(
                currentLeg.to.coordinates, 0.5))
            .where((poi) => poi.fitsInWindow(transferMinutes))
            .toList();
        
        if (nearbyPOIs.isNotEmpty) {
          transferPOIs.add(TransferPOI(
            station: currentLeg.to,
            availableMinutes: transferMinutes,
            pois: nearbyPOIs,
          ));
        }
      }
    }
    
    return transferPOIs;
  }
}
```

---

### 3.8 Trips Context (Supporting) - NEW

**Responsibility:** Saving and organizing trips and itineraries

**Related Features:** F8 (Saved Trips & Itineraries)

**Domain Model:**

| Concept | DDD Type | Description |
|---------|----------|-------------|
| `SavedTrip` | Entity | Bookmarked journey |
| `TripId` | Value Object | Typed identifier |
| `Itinerary` | **Aggregate Root** | Multi-day trip plan |
| `ItineraryId` | Value Object | Typed identifier |
| `ItineraryDay` | Entity | Single day in plan |
| `ItineraryItem` | Value Object | Trip or POI stop |
| `TripNote` | Value Object | User annotation |
| `ItineraryService` | Domain Service | Validate consistency |

```dart
@freezed
class SavedTrip with _$SavedTrip {
  const factory SavedTrip({
    required TripId id,
    required StationId fromStationId,
    required StationId toStationId,
    required String fromStationName,
    required String toStationName,
    DateTime? preferredDeparture,
    String? notes,
    required DateTime savedAt,
    RoutePreferences? preferences,
  }) = _SavedTrip;
}

@freezed
class Itinerary with _$Itinerary {
  const Itinerary._();
  
  const factory Itinerary({
    required ItineraryId id,
    required String name,
    required List<ItineraryDay> days,
    required DateTime createdAt,
    DateTime? startDate,
  }) = _Itinerary;
  
  int get totalDays => days.length;
  
  bool get hasGaps {
    for (int i = 0; i < days.length - 1; i++) {
      final currentDay = days[i];
      final nextDay = days[i + 1];
      if (currentDay.dayNumber + 1 != nextDay.dayNumber) return true;
    }
    return false;
  }
  
  Duration get totalTravelTime => days
      .expand((d) => d.items)
      .whereType<TripItem>()
      .fold(Duration.zero, (sum, item) => 
          sum + Duration(minutes: item.estimatedMinutes));
}

@freezed
class ItineraryDay with _$ItineraryDay {
  const factory ItineraryDay({
    required int dayNumber,
    required List<ItineraryItem> items,
    String? notes,
  }) = _ItineraryDay;
}

@freezed
class ItineraryItem with _$ItineraryItem {
  const factory ItineraryItem.trip({
    required SavedTrip trip,
    required int estimatedMinutes,
  }) = TripItem;
  
  const factory ItineraryItem.poiStop({
    required POI poi,
    required int durationMinutes,
  }) = POIStopItem;
}

class ItineraryValidationService {
  List<String> validate(Itinerary itinerary) {
    final errors = <String>[];
    
    if (itinerary.days.isEmpty) {
      errors.add('Itinerary must have at least one day');
    }
    
    if (itinerary.hasGaps) {
      errors.add('Itinerary has gaps between days');
    }
    
    for (final day in itinerary.days) {
      if (day.items.isEmpty) {
        errors.add('Day ${day.dayNumber} has no items');
      }
    }
    
    return errors;
  }
}
```

---

### 3.9 Identity Context (Generic) - NEW

**Responsibility:** User authentication and profile management

**Related Features:** F9 (Accounts)

**Domain Model:**

| Concept | DDD Type | Description |
|---------|----------|-------------|
| `UserProfile` | Entity | User account |
| `UserId` | Value Object | Unique identifier |
| `Email` | Value Object | Validated email |
| `AuthState` | Value Object | Authentication status |
| `AuthService` | Domain Service | Authentication logic |

```dart
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required UserId id,
    required Email email,
    String? displayName,
    RoutePreferences? defaultPreferences,
    DateTime? createdAt,
  }) = _UserProfile;
}

@freezed
class Email with _$Email {
  const Email._();
  
  const factory Email(String value) = _Email;
  
  bool get isValid => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
}

@freezed
class AuthState with _$AuthState {
  const factory AuthState.unauthenticated() = Unauthenticated;
  const factory AuthState.authenticating() = Authenticating;
  const factory AuthState.authenticated(UserProfile user) = Authenticated;
  const factory AuthState.error(String message) = AuthError;
}
```

---

### 3.10 Offline Context (Supporting) - NEW

**Responsibility:** Local caching and offline operation

**Related Features:** F10 (Offline Mode)

**Domain Model:**

| Concept | DDD Type | Description |
|---------|----------|-------------|
| `OfflineCache` | Service | Local storage manager |
| `CacheEntry` | Entity | Cached item with TTL |
| `CachePolicy` | Value Object | Caching rules |
| `SyncQueue` | Entity | Pending sync operations |
| `ConnectivityState` | Value Object | Online/offline status |

```dart
@freezed
class CachePolicy with _$CachePolicy {
  const factory CachePolicy({
    required Duration ttl,
    @Default(false) bool refreshOnConnect,
    @Default(true) bool allowStale,
  }) = _CachePolicy;
  
  static const stations = CachePolicy(
    ttl: Duration(days: 7),
    refreshOnConnect: false,
    allowStale: true,
  );
  
  static const journeys = CachePolicy(
    ttl: Duration(hours: 24),
    refreshOnConnect: true,
    allowStale: true,
  );
  
  static const weather = CachePolicy(
    ttl: Duration(hours: 1),
    refreshOnConnect: true,
    allowStale: false,
  );
  
  static const pois = CachePolicy(
    ttl: Duration(days: 7),
    refreshOnConnect: false,
    allowStale: true,
  );
}

@freezed
class CacheEntry<T> with _$CacheEntry<T> {
  const CacheEntry._();
  
  const factory CacheEntry({
    required String key,
    required T value,
    required DateTime cachedAt,
    required CachePolicy policy,
  }) = _CacheEntry;
  
  bool get isExpired => 
      DateTime.now().isAfter(cachedAt.add(policy.ttl));
  
  bool get canUseStale => policy.allowStale && isExpired;
}

enum ConnectivityState { online, offline, unknown }

abstract class OfflineCacheService {
  Future<T?> get<T>(String key);
  Future<void> put<T>(String key, T value, CachePolicy policy);
  Future<void> invalidate(String key);
  Stream<ConnectivityState> get connectivityStream;
}
```

---

## 4. Context Map

### 4.1 Visual Context Map

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           ViaSwiss Context Map                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────┐                    ┌─────────────────────────┐        │
│  │    STATION      │◄══════════════════►│   JOURNEY PLANNING      │        │
│  │    CONTEXT      │    Shared Kernel   │      CONTEXT            │        │
│  │   (Generic)     │    (Coordinates,   │   (Core Domain)         │        │
│  │                 │     Station ref)   │                         │        │
│  └────────┬────────┘                    └───────────┬─────────────┘        │
│           │                                         │                       │
│           │ Shared Kernel                           │ Conformist            │
│           │                                         │                       │
│  ┌────────▼────────┐            ┌───────────────────▼─────────────┐        │
│  │    WEATHER      │            │       RECOMMENDATION            │        │
│  │    CONTEXT      │◄══════════►│          CONTEXT                │        │
│  │  (Supporting)   │ Conformist │       (Core Domain)             │        │
│  │                 │            │                                 │        │
│  └────────┬────────┘            └───────────┬─────────────────────┘        │
│           │                                 │                               │
│           │ Customer/Supplier               │ Conformist                    │
│           │                                 │                               │
│  ┌────────▼────────┐            ┌───────────▼─────────────┐                │
│  │   EXPERIENCE    │            │          POI            │                │
│  │    CONTEXT      │◄══════════►│        CONTEXT          │                │
│  │  (Core Domain)  │  Customer/ │     (Supporting)        │                │
│  │                 │  Supplier  │                         │                │
│  └─────────────────┘            └───────────┬─────────────┘                │
│                                             │                               │
│                                             │ Customer/Supplier             │
│                                             │                               │
│  ┌─────────────────┐            ┌───────────▼─────────────┐                │
│  │    IDENTITY     │◄══════════►│         TRIPS           │                │
│  │    CONTEXT      │  Customer/ │        CONTEXT          │                │
│  │   (Generic)     │  Supplier  │     (Supporting)        │                │
│  │                 │            │                         │                │
│  └────────┬────────┘            └─────────────────────────┘                │
│           │                                                                 │
│           │ Customer/Supplier                                               │
│           │                                                                 │
│  ┌────────▼────────┐            ┌─────────────────────────┐                │
│  │    OFFLINE      │            │          MAP            │                │
│  │    CONTEXT      │            │        CONTEXT          │                │
│  │  (Supporting)   │            │       (Generic)         │                │
│  │                 │            │                         │                │
│  └─────────────────┘            └─────────────────────────┘                │
│                                                                             │
│  ═══════════ Shared Kernel    ──────────► Upstream/Downstream              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 Integration Patterns

| Upstream | Downstream | Pattern | Description |
|----------|------------|---------|-------------|
| Station | Journey Planning | **Shared Kernel** | Station entity shared |
| Station | Weather | **Shared Kernel** | Coordinates shared |
| Station | POI | **Shared Kernel** | Coordinates shared |
| Journey Planning | Recommendation | **Conformist** | Rec adapts to Journey |
| Weather | Recommendation | **Conformist** | Rec adapts to Weather |
| Weather | Journey Planning | **Customer/Supplier** | Risk data flows |
| POI | Recommendation | **Customer/Supplier** | Transfer POIs flow |
| POI | Trips | **Customer/Supplier** | POI stops in itinerary |
| Journey Planning | Trips | **Customer/Supplier** | Saved journeys |
| Identity | Trips | **Customer/Supplier** | User ownership |
| Identity | Offline | **Customer/Supplier** | Sync identity |
| All Contexts | Offline | **Anti-Corruption Layer** | Cache operations |
| External APIs | POI | **Anti-Corruption Layer** | OSM/external POI data |
| GraphQL Backend | All | **Anti-Corruption Layer** | API responses |

---

## 5. Tactical Patterns

### 5.1 Value Objects

Convert primitives to rich value objects:

| Current (Primitive) | Proposed Value Object | Benefits |
|---------------------|----------------------|----------|
| `int duration` | `Duration` | Type safety, display methods |
| `double temperature` | `Temperature` | Unit clarity, conversions |
| `int precipitationProbability` | `Probability` | Range validation (0-100) |
| `int scenicScore` | `ScenicScore` | Rating methods, validation |
| `String id` | Typed IDs (`StationId`, etc.) | Type safety, equality |
| `double windSpeed` | `WindSpeed` | Unit clarity (km/h) |

```dart
// Example: ScenicScore Value Object
@freezed
class ScenicScore with _$ScenicScore {
  const ScenicScore._();
  
  const factory ScenicScore(int value) = _ScenicScore;
  
  factory ScenicScore.fromJson(int value) {
    assert(value >= 0 && value <= 100, 'Scenic score must be 0-100');
    return ScenicScore(value);
  }
  
  bool get isHighlyScenic => value >= 80;
  bool get isModeratelyScenic => value >= 50 && value < 80;
  bool get isStandard => value < 50;
  
  String get rating => isHighlyScenic ? 'Excellent' : 
                       isModeratelyScenic ? 'Good' : 'Standard';
  
  String get displayStars => '★' * (value ~/ 20) + '☆' * (5 - value ~/ 20);
}

// Example: Typed ID
abstract class EntityId<T> {
  final String value;
  const EntityId(this.value);
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is EntityId<T> && other.value == value;
  
  @override
  int get hashCode => value.hashCode;
  
  @override
  String toString() => value;
}

class JourneyId extends EntityId<Journey> {
  const JourneyId(super.value);
}
```

### 5.2 Aggregates

Design principles for aggregates:

1. **Small aggregates** - Prefer small over large
2. **Reference by ID** - Cross-aggregate references use IDs
3. **Transactional consistency** - Within aggregate boundaries
4. **Eventual consistency** - Between aggregates

```dart
// Journey Aggregate - enforces invariants
@freezed
class Journey with _$Journey {
  const Journey._();
  
  const factory Journey({
    required JourneyId id,
    required StationId fromId,  // Reference by ID, not full Station
    required StationId toId,
    required String fromName,   // Denormalized for display
    required String toName,
    required DateTime departure,
    required DateTime arrival,
    required Duration duration,
    required int transfers,
    ScenicScore? scenicScore,
    required List<Leg> legs,
  }) = _Journey;
  
  // Factory that validates invariants
  factory Journey.create({
    required JourneyId id,
    required Station from,
    required Station to,
    required List<Leg> legs,
  }) {
    // Validate continuous legs
    for (int i = 0; i < legs.length - 1; i++) {
      if (legs[i].toId != legs[i + 1].fromId) {
        throw JourneyInvariantViolation('Legs must form continuous path');
      }
    }
    
    return Journey(
      id: id,
      fromId: from.id,
      toId: to.id,
      fromName: from.name,
      toName: to.name,
      departure: legs.first.departure,
      arrival: legs.last.arrival,
      duration: legs.last.arrival.difference(legs.first.departure),
      transfers: legs.length - 1,
      legs: legs,
    );
  }
}
```

### 5.3 Repositories

Abstract repository interfaces in domain, implementations in infrastructure:

```dart
// Domain layer - abstract interface
abstract class JourneyRepository {
  Future<List<Journey>> findJourneys(JourneySearchCriteria criteria);
  Future<Journey?> findById(JourneyId id);
}

@freezed
class JourneySearchCriteria with _$JourneySearchCriteria {
  const factory JourneySearchCriteria({
    required StationId from,
    required StationId to,
    DateTime? departureTime,
    @Default(5) int limit,
    RoutePreferences? preferences,
  }) = _JourneySearchCriteria;
}

// Infrastructure layer - GraphQL implementation
class GraphQLJourneyRepository implements JourneyRepository {
  final GraphQLClient _client;
  final JourneyACL _acl;
  
  GraphQLJourneyRepository(this._client, this._acl);
  
  @override
  Future<List<Journey>> findJourneys(JourneySearchCriteria criteria) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(JourneyQueries.getJourneys),
        variables: {
          'from': criteria.from.value,
          'to': criteria.to.value,
          'departureTime': criteria.departureTime?.toIso8601String(),
          'limit': criteria.limit,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    
    if (result.hasException) {
      throw JourneyQueryException(result.exception.toString());
    }
    
    return (result.data!['journeys'] as List)
        .map((json) => _acl.fromGraphQL(json as Map<String, dynamic>))
        .toList();
  }
}
```

---

## 6. Domain Events

### 6.1 Event Catalog

```dart
// Base event
abstract class DomainEvent {
  final DateTime occurredAt;
  final String? correlationId;
  
  DomainEvent({DateTime? occurredAt, this.correlationId})
    : occurredAt = occurredAt ?? DateTime.now();
}

// Journey Context Events
class JourneySearched extends DomainEvent {
  final StationId from;
  final StationId to;
  final DateTime? departureTime;
  final RoutePreferences? preferences;
  
  JourneySearched({
    required this.from,
    required this.to,
    this.departureTime,
    this.preferences,
    super.correlationId,
  });
}

class JourneySelected extends DomainEvent {
  final JourneyId journeyId;
  final RouteRecommendation? recommendation;
  
  JourneySelected({
    required this.journeyId,
    this.recommendation,
    super.correlationId,
  });
}

// Weather Context Events
class WeatherAlertTriggered extends DomainEvent {
  final Coordinates location;
  final RiskLevel riskLevel;
  final String alertType;
  
  WeatherAlertTriggered({
    required this.location,
    required this.riskLevel,
    required this.alertType,
    super.correlationId,
  });
}

class WeatherEscapeRequested extends DomainEvent {
  final StationId fromStation;
  final int maxTravelMinutes;
  final Weather currentWeather;
  
  WeatherEscapeRequested({
    required this.fromStation,
    required this.maxTravelMinutes,
    required this.currentWeather,
    super.correlationId,
  });
}

// Trips Context Events
class TripSaved extends DomainEvent {
  final SavedTrip trip;
  
  TripSaved({required this.trip, super.correlationId});
}

class TripDeleted extends DomainEvent {
  final TripId tripId;
  
  TripDeleted({required this.tripId, super.correlationId});
}

class ItineraryCreated extends DomainEvent {
  final Itinerary itinerary;
  
  ItineraryCreated({required this.itinerary, super.correlationId});
}

// Identity Context Events
class UserAuthenticated extends DomainEvent {
  final UserId userId;
  final String email;
  
  UserAuthenticated({
    required this.userId,
    required this.email,
    super.correlationId,
  });
}

class UserSignedOut extends DomainEvent {
  final UserId userId;
  
  UserSignedOut({required this.userId, super.correlationId});
}

class UserPreferencesUpdated extends DomainEvent {
  final UserId userId;
  final RoutePreferences preferences;
  
  UserPreferencesUpdated({
    required this.userId,
    required this.preferences,
    super.correlationId,
  });
}
```

### 6.2 Event Bus

```dart
abstract class DomainEventBus {
  void publish(DomainEvent event);
  Stream<T> on<T extends DomainEvent>();
}

class InMemoryEventBus implements DomainEventBus {
  final _controller = StreamController<DomainEvent>.broadcast();
  
  @override
  void publish(DomainEvent event) {
    _controller.add(event);
  }
  
  @override
  Stream<T> on<T extends DomainEvent>() {
    return _controller.stream.whereType<T>();
  }
  
  void dispose() {
    _controller.close();
  }
}
```

---

## 7. Anti-Corruption Layers

### 7.1 GraphQL ACL

Protect domain models from GraphQL API changes:

```dart
// lib/contexts/journey/infrastructure/acl/journey_acl.dart

class JourneyACL {
  final StationACL _stationACL;
  final LegACL _legACL;
  
  JourneyACL(this._stationACL, this._legACL);
  
  Journey fromGraphQL(Map<String, dynamic> data) {
    _validateRequired(data, ['id', 'from', 'to', 'departure', 'arrival', 'legs']);
    
    final legs = (data['legs'] as List)
        .map((leg) => _legACL.fromGraphQL(leg as Map<String, dynamic>))
        .toList();
    
    return Journey(
      id: JourneyId(data['id'] as String),
      fromId: StationId(data['from']['id'] as String),
      toId: StationId(data['to']['id'] as String),
      fromName: data['from']['name'] as String,
      toName: data['to']['name'] as String,
      departure: DateTime.parse(data['departure'] as String),
      arrival: DateTime.parse(data['arrival'] as String),
      duration: Duration(minutes: data['duration'] as int),
      transfers: data['transfers'] as int,
      scenicScore: data['scenicScore'] != null 
          ? ScenicScore(data['scenicScore'] as int) 
          : null,
      legs: legs,
    );
  }
  
  Map<String, dynamic> toGraphQL(Journey journey) {
    return {
      'id': journey.id.value,
      'from': journey.fromId.value,
      'to': journey.toId.value,
      'departureTime': journey.departure.toIso8601String(),
    };
  }
  
  void _validateRequired(Map<String, dynamic> data, List<String> fields) {
    for (final field in fields) {
      if (!data.containsKey(field) || data[field] == null) {
        throw ACLValidationException('Missing required field: $field');
      }
    }
  }
}

class ACLValidationException implements Exception {
  final String message;
  ACLValidationException(this.message);
  
  @override
  String toString() => 'ACLValidationException: $message';
}
```

### 7.2 External POI Provider ACL

For future OpenStreetMap/external POI integration:

```dart
// lib/contexts/poi/infrastructure/acl/osm_poi_acl.dart

class OpenStreetMapPOIACL {
  POI fromOSMNode(Map<String, dynamic> osmNode) {
    final tags = osmNode['tags'] as Map<String, dynamic>? ?? {};
    
    return POI(
      id: POIId('osm_${osmNode['id']}'),
      name: _extractName(tags),
      category: _mapOSMCategory(tags),
      coordinates: Coordinates(
        latitude: osmNode['lat'] as double,
        longitude: osmNode['lon'] as double,
      ),
      estimatedVisitMinutes: _estimateVisitTime(tags),
      description: tags['description'] as String?,
    );
  }
  
  String _extractName(Map<String, dynamic> tags) {
    return tags['name'] as String? ??
           tags['name:en'] as String? ??
           tags['name:de'] as String? ??
           'Unknown';
  }
  
  POICategory _mapOSMCategory(Map<String, dynamic> tags) {
    // Tourism tags
    if (tags['tourism'] == 'viewpoint') return POICategory.viewpoint;
    if (tags['tourism'] == 'museum') return POICategory.museum;
    
    // Amenity tags
    if (tags['amenity'] == 'cafe') return POICategory.cafe;
    if (tags['amenity'] == 'restaurant') return POICategory.restaurant;
    
    // Historic tags
    if (tags.containsKey('historic')) return POICategory.historic;
    
    // Natural features
    if (tags.containsKey('natural')) return POICategory.nature;
    
    // Default
    return POICategory.nature;
  }
  
  int _estimateVisitTime(Map<String, dynamic> tags) {
    if (tags['tourism'] == 'viewpoint') return 15;
    if (tags['tourism'] == 'museum') return 60;
    if (tags['amenity'] == 'cafe') return 20;
    if (tags['amenity'] == 'restaurant') return 45;
    return 30; // Default
  }
}
```

---

## 8. Shared Kernel

### 8.1 Shared Types

Types that are shared across multiple bounded contexts:

```dart
// lib/core/domain/shared_kernel/coordinates.dart

@freezed
class Coordinates with _$Coordinates {
  const Coordinates._();
  
  const factory Coordinates({
    required double latitude,
    required double longitude,
  }) = _Coordinates;
  
  factory Coordinates.fromJson(Map<String, dynamic> json) => Coordinates(
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
  );
  
  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
  };
  
  double distanceTo(Coordinates other) {
    return _haversineDistance(
      latitude, longitude,
      other.latitude, other.longitude,
    );
  }
  
  bool isWithinRadius(Coordinates center, double radiusKm) {
    return distanceTo(center) <= radiusKm;
  }
  
  static double _haversineDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    const earthRadius = 6371.0; // km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
              cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
              sin(dLon / 2) * sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }
  
  static double _toRadians(double degrees) => degrees * pi / 180;
}
```

```dart
// lib/core/domain/shared_kernel/entity_id.dart

abstract class EntityId<T> {
  final String value;
  const EntityId(this.value);
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is EntityId<T> && runtimeType == other.runtimeType && value == other.value;
  
  @override
  int get hashCode => value.hashCode;
  
  @override
  String toString() => value;
}
```

```dart
// lib/core/domain/shared_kernel/result.dart

@freezed
class Result<T, E> with _$Result<T, E> {
  const Result._();
  
  const factory Result.success(T value) = Success<T, E>;
  const factory Result.failure(E error) = Failure<T, E>;
  
  bool get isSuccess => this is Success<T, E>;
  bool get isFailure => this is Failure<T, E>;
  
  T? get valueOrNull => maybeWhen(
    success: (value) => value,
    orElse: () => null,
  );
  
  E? get errorOrNull => maybeWhen(
    failure: (error) => error,
    orElse: () => null,
  );
  
  Result<R, E> map<R>(R Function(T) transform) => when(
    success: (value) => Result.success(transform(value)),
    failure: (error) => Result.failure(error),
  );
  
  Result<T, R> mapError<R>(R Function(E) transform) => when(
    success: (value) => Result.success(value),
    failure: (error) => Result.failure(transform(error)),
  );
}
```

### 8.2 Shared Kernel Package Structure

```
lib/core/domain/shared_kernel/
├── coordinates.dart        # Coordinates value object
├── entity_id.dart          # Base typed ID class
├── result.dart             # Result<T, E> monad
├── date_time_range.dart    # Time period value object
└── shared_kernel.dart      # Barrel export file
```

---

## 9. Ubiquitous Language

### 9.1 Glossary by Context

#### Station Context

| Term | Definition |
|------|------------|
| **Station** | A Swiss railway station or stop with a unique identifier |
| **Coordinates** | Geographic location as latitude/longitude (WGS84) |
| **Elevation** | Height above sea level in meters |
| **Search Query** | Text entered by user to find stations |
| **Autocomplete** | Suggestions based on partial station name |

#### Journey Planning Context

| Term | Definition |
|------|------------|
| **Journey** | Complete travel plan from origin to destination |
| **Leg** | Single continuous segment of a journey (no transfers) |
| **Transfer** | Change between transport vehicles at a station |
| **Connection** | Available journey option between two stations |
| **Route** | Physical path taken by a journey |
| **Scenic Score** | Quality rating (0-100) of landscape beauty |
| **Duration** | Total travel time in minutes |
| **Platform** | Designated boarding/alighting location |
| **Delay** | Minutes behind schedule |

#### Transport Types

| Term | Definition |
|------|------------|
| **IC** | Intercity - Fast long-distance train |
| **IR** | Interregio - Regional express train |
| **RE** | Regional Express - Stops at major stations |
| **S** | S-Bahn - Suburban/commuter train |
| **ICE** | InterCityExpress - German high-speed train |
| **EC** | EuroCity - International express train |
| **BUS** | Road-based transport |
| **TRAM** | Urban light rail |

#### Weather Context

| Term | Definition |
|------|------------|
| **Weather** | Current atmospheric conditions at a location |
| **Forecast** | Predicted weather for future time |
| **Condition** | Categorical weather state (CLEAR, RAINY, etc.) |
| **Precipitation Probability** | Chance of rain/snow (0-100%) |
| **Risk Level** | Safety classification (HIGH, MEDIUM, LOW) |
| **Föhn** | Warm dry wind on Alpine leeward slopes |
| **Hochnebel** | High fog layer common in Swiss Mittelland |

#### Experience Context

| Term | Definition |
|------|------------|
| **Experience Score** | Multi-dimensional quality rating |
| **Golden Hour** | Optimal lighting near sunrise/sunset |
| **Experience Moment** | Notable point during journey with viewing tip |
| **Window Side** | Left or right window for best view |
| **Tranquility** | Quietness/crowding level |

#### POI Context

| Term | Definition |
|------|------------|
| **POI** | Point of Interest - Notable location |
| **Transfer POI** | POI accessible during transfer window |
| **Transfer Window** | Time available during connection |
| **Visit Duration** | Estimated time to experience POI |
| **Viewpoint** | Location with scenic vista |

#### Trips Context

| Term | Definition |
|------|------------|
| **Saved Trip** | Bookmarked journey for future reference |
| **Itinerary** | Multi-day travel plan |
| **Day Plan** | Activities scheduled for one day |
| **Trip Note** | User annotation on saved trip |

---

## 10. Implementation Roadmap

### 10.1 Phase Alignment with Features

| Phase | Focus | Features | DDD Concepts |
|-------|-------|----------|--------------|
| **1** | Foundation | F1, F8a | Value objects, Shared Kernel |
| **2** | Weather Intelligence | F2, F6 | Domain Services, Events |
| **3** | POI Ecosystem | F3, F5, F4 | New Context, ACL |
| **4** | Experience & Identity | F7, F9 | Core Domain, Identity |
| **5** | Persistence & Sync | F10, F11 | Offline, Repository |

### 10.2 Phase 1: Foundation (2-3 weeks)

**Goal:** Establish DDD infrastructure and quick wins

**Tasks:**
1. Create Shared Kernel package
   - Extract `Coordinates` value object
   - Create `EntityId` base class
   - Add typed IDs (`StationId`, `JourneyId`, etc.)

2. Implement Value Objects
   - `ScenicScore`, `Duration`, `Delay`, `Platform`
   - `Temperature`, `Probability`, `WindSpeed`

3. Add Domain Logic to Journey
   - Invariant validation
   - Domain methods (`isDirect`, `hasDelay`, etc.)

4. Implement F1 Preferences (client-side)
   - `RoutePreferences` value object
   - `JourneyScoringService` domain service
   - Persist to SharedPreferences

5. Implement F8 Phase A (local trips)
   - `SavedTrip` entity
   - Hive local storage
   - Basic UI for saving/listing

### 10.3 Phase 2: Weather Intelligence (2-3 weeks)

**Goal:** Weather-aware routing and escape feature

**Tasks:**
1. Weather Risk Assessment (F2)
   - `WeatherRisk`, `RiskLevel`, `LegWeatherRisk` value objects
   - `WeatherRiskAssessmentService` domain service
   - Risk badges in UI

2. Weather Escape (F6)
   - `WeatherEscape` entity
   - `WeatherEscapeService` domain service
   - GraphQL query integration
   - Home screen card

3. Domain Events
   - `WeatherAlertTriggered`
   - `WeatherEscapeRequested`
   - In-memory event bus

### 10.4 Phase 3: POI Ecosystem (3-4 weeks)

**Goal:** POI discovery along routes and nearby

**Tasks:**
1. Establish POI Context
   - `POI`, `POICategory`, `TransferPOI` models
   - `POIDiscoveryService` domain service

2. Anti-Corruption Layer
   - `OSMPOIAcl` for external data
   - GraphQL ACL for backend POIs

3. Implement F5 (POIs in Radius)
   - `POISearchCriteria` value object
   - Geolocation integration
   - Map visualization

4. Implement F3 (Along-Route POIs)
   - Transfer window calculation
   - POI chips in journey detail

5. Enable F4 (Map View)
   - MapTiler configuration
   - Route polylines
   - POI markers

### 10.5 Phase 4: Experience & Identity (3-4 weeks)

**Goal:** Experience scoring and user accounts

**Tasks:**
1. Experience Context (F7)
   - `ExperienceScore`, `ExperienceMoment` models
   - `ExperienceScoringService` domain service
   - Experience tab in results

2. Identity Context (F9)
   - `UserProfile`, `AuthState` models
   - Supabase integration
   - Sign in/out flows

3. Cross-Context Integration
   - User preferences in Journey context
   - Experience in Recommendation context

### 10.6 Phase 5: Persistence & Sync (3-4 weeks)

**Goal:** Offline support and data sync

**Tasks:**
1. Offline Context (F10)
   - `CachePolicy`, `CacheEntry` models
   - `OfflineCacheService` implementation
   - Connectivity handling

2. F8 Phase B (Synced Trips)
   - Sync queue for offline changes
   - Conflict resolution

3. F11 Extensions
   - CAR, WALK transport types
   - Stored POIs with sync
   - Carbon tracking

---

## 11. Package Structure

### 11.1 Proposed Directory Layout

```
lib/
├── core/
│   ├── domain/
│   │   ├── shared_kernel/           # Shared Value Objects
│   │   │   ├── coordinates.dart
│   │   │   ├── entity_id.dart
│   │   │   ├── result.dart
│   │   │   ├── date_time_range.dart
│   │   │   └── shared_kernel.dart   # Barrel export
│   │   └── events/
│   │       ├── domain_event.dart
│   │       └── event_bus.dart
│   ├── config/
│   │   ├── app_config.dart
│   │   ├── feature_flags.dart
│   │   └── theme.dart
│   ├── router/
│   │   └── app_router.dart
│   └── utils/
│       ├── constants.dart
│       ├── date_formatter.dart
│       └── logger.dart
│
├── contexts/                        # Bounded Contexts
│   ├── station/
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   └── station.dart
│   │   │   ├── services/
│   │   │   └── repositories/
│   │   │       └── station_repository.dart
│   │   ├── application/
│   │   │   └── station_providers.dart
│   │   ├── infrastructure/
│   │   │   ├── graphql/
│   │   │   │   └── station_queries.dart
│   │   │   ├── repositories/
│   │   │   │   └── graphql_station_repository.dart
│   │   │   └── acl/
│   │   │       └── station_acl.dart
│   │   └── presentation/
│   │       ├── station_search_screen.dart
│   │       └── widgets/
│   │
│   ├── journey/
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── journey.dart
│   │   │   │   ├── leg.dart
│   │   │   │   ├── transport.dart
│   │   │   │   └── route_preferences.dart
│   │   │   ├── services/
│   │   │   │   └── journey_scoring_service.dart
│   │   │   ├── events/
│   │   │   │   └── journey_events.dart
│   │   │   └── repositories/
│   │   │       └── journey_repository.dart
│   │   ├── application/
│   │   │   ├── journey_providers.dart
│   │   │   └── use_cases/
│   │   ├── infrastructure/
│   │   │   ├── graphql/
│   │   │   ├── repositories/
│   │   │   └── acl/
│   │   └── presentation/
│   │
│   ├── weather/
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── weather.dart
│   │   │   │   └── weather_risk.dart
│   │   │   ├── services/
│   │   │   │   ├── weather_risk_service.dart
│   │   │   │   └── weather_escape_service.dart
│   │   │   └── repositories/
│   │   ├── application/
│   │   ├── infrastructure/
│   │   └── presentation/
│   │
│   ├── recommendation/
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── route_recommendation.dart
│   │   │   │   ├── travel_warning.dart
│   │   │   │   └── weather_escape.dart
│   │   │   └── services/
│   │   │       ├── recommendation_service.dart
│   │   │       └── warning_generator_service.dart
│   │   ├── application/
│   │   ├── infrastructure/
│   │   └── presentation/
│   │
│   ├── experience/                  # NEW
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── experience_score.dart
│   │   │   │   └── experience_moment.dart
│   │   │   └── services/
│   │   │       └── experience_scoring_service.dart
│   │   ├── application/
│   │   ├── infrastructure/
│   │   └── presentation/
│   │
│   ├── poi/                         # NEW
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── poi.dart
│   │   │   │   ├── transfer_poi.dart
│   │   │   │   └── poi_search_criteria.dart
│   │   │   ├── services/
│   │   │   │   └── poi_discovery_service.dart
│   │   │   └── repositories/
│   │   ├── application/
│   │   ├── infrastructure/
│   │   │   └── acl/
│   │   │       └── osm_poi_acl.dart
│   │   └── presentation/
│   │
│   ├── trips/                       # NEW
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── saved_trip.dart
│   │   │   │   ├── itinerary.dart
│   │   │   │   └── itinerary_item.dart
│   │   │   ├── services/
│   │   │   │   └── itinerary_validation_service.dart
│   │   │   └── repositories/
│   │   ├── application/
│   │   ├── infrastructure/
│   │   │   └── persistence/
│   │   │       └── hive_trips_repository.dart
│   │   └── presentation/
│   │
│   ├── identity/                    # NEW
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── user_profile.dart
│   │   │   │   └── auth_state.dart
│   │   │   ├── services/
│   │   │   └── repositories/
│   │   ├── application/
│   │   ├── infrastructure/
│   │   │   └── supabase/
│   │   └── presentation/
│   │
│   ├── offline/                     # NEW
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── cache_policy.dart
│   │   │   │   ├── cache_entry.dart
│   │   │   │   └── sync_queue.dart
│   │   │   └── services/
│   │   │       └── offline_cache_service.dart
│   │   ├── application/
│   │   ├── infrastructure/
│   │   │   └── hive/
│   │   └── presentation/
│   │
│   └── map/
│       ├── domain/
│       ├── application/
│       ├── infrastructure/
│       └── presentation/
│
└── shared/
    ├── graphql/
    │   └── graphql_client.dart
    └── widgets/
        ├── app_card.dart
        ├── app_button.dart
        ├── loading_indicator.dart
        └── error_widget.dart
```

---

## Appendix A: Migration Strategy

### A.1 Incremental Migration

The existing code can be migrated incrementally:

1. **Keep existing `lib/features/`** working during migration
2. **Create new `lib/contexts/`** structure alongside
3. **Move one context at a time**, starting with Station (simplest)
4. **Update imports** as contexts are migrated
5. **Delete old feature folders** once fully migrated

### A.2 Coexistence Pattern

```dart
// Temporary re-export for backwards compatibility
// lib/features/search/domain/models/station.dart

export 'package:viaswiss/contexts/station/domain/models/station.dart';
```

---

## Appendix B: Testing Strategy

### B.1 Testing by Layer

| Layer | Test Type | Tools |
|-------|-----------|-------|
| Domain Models | Unit | flutter_test |
| Domain Services | Unit | flutter_test, mockito |
| Repositories | Integration | flutter_test, mockito |
| ACL | Unit | flutter_test |
| Providers | Unit | riverpod_test |
| Presentation | Widget | flutter_test, golden_toolkit |

### B.2 Domain Model Testing

```dart
void main() {
  group('Journey', () {
    test('isDirect returns true when no transfers', () {
      final journey = Journey(
        id: JourneyId('1'),
        fromId: StationId('zrh'),
        toId: StationId('bern'),
        // ... other fields
        transfers: 0,
        legs: [singleLeg],
      );
      
      expect(journey.isDirect, isTrue);
    });
    
    test('validates leg continuity', () {
      final journey = Journey(
        // ... with valid continuous legs
      );
      
      expect(journey.hasValidLegContinuity, isTrue);
    });
  });
  
  group('ScenicScore', () {
    test('isHighlyScenic when score >= 80', () {
      expect(ScenicScore(80).isHighlyScenic, isTrue);
      expect(ScenicScore(79).isHighlyScenic, isFalse);
    });
  });
}
```

---

## Appendix C: References

- Evans, Eric. "Domain-Driven Design: Tackling Complexity in the Heart of Software" (2003)
- Vernon, Vaughn. "Implementing Domain-Driven Design" (2013)
- [routing-enhancements-design.md](./routing-enhancements-design.md) - Feature specifications
- [API.md](../API.md) - GraphQL API reference
- [README.md](../README.md) - Project overview
