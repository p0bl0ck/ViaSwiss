# Routing Enhancements - Design Document

## Status: Draft

## Overview

This document outlines planned enhancements to ViaSwiss's routing and journey planning capabilities. The features are grouped by technical dependency and build incrementally on the existing architecture.

## Current Architecture Summary

### What Exists

| Component | Status | Key Details |
|-----------|--------|-------------|
| Journey search | Live | `getJourneys` + `getRouteRecommendations` queries |
| Weather integration | Live | Per-route weather via `RouteRecommendation` |
| Scenic scoring | Live | `scenicScore` (0-100) on Journey model |
| Warnings | Live | `warnings: List<String>` on RouteRecommendation |
| AI recommendations | Live | `recommendation: String` on RouteRecommendation |
| Map view | Scaffolded, disabled | MapLibre GL placeholders, `FeatureFlags.mapView = false` |
| Leg timeline | Live | Per-leg transport, platform, delay display |

### Key Constraints

- **Read-only GraphQL**: No mutations exist today. Adding accounts/persistence requires backend changes.
- **No local persistence**: All data is in-memory (`GraphQLCache` with `InMemoryStore`).
- **No auth**: No user identity or session management.
- **No geolocation**: Device location not currently accessed.

---

## Feature Specifications

---

### F1: Preference-Based Routing

#### Problem

Users get a single ranking of routes with no way to express what matters to them. A commuter wants fastest; a tourist wants scenic; a parent with a stroller wants fewest transfers.

#### Solution

Add route preference controls that influence result ordering and filtering.

#### Preference Dimensions

| Preference | Data Source | Scoring |
|------------|-------------|---------|
| Scenic | `journey.scenicScore` | Higher = better |
| Fastest | `journey.duration` | Lower = better |
| Fewest transfers | `journey.transfers` | Lower = better |
| Avoid elevation | Leg elevation data (new) | Lower max elevation = better |
| Low-carbon | Transport type weighting | Rail > bus > car |

#### Data Model

```dart
// lib/features/journey/domain/models/route_preferences.dart
@freezed
class RoutePreferences with _$RoutePreferences {
  const factory RoutePreferences({
    @Default(RouteOptimization.balanced) RouteOptimization optimizeFor,
    @Default(false) bool avoidSteepElevation,
    @Default(false) bool preferLowCarbon,
    @Default(3) int maxTransfers,
  }) = _RoutePreferences;
}

enum RouteOptimization {
  scenic,
  fastest,
  fewestTransfers,
  balanced,
}
```

#### Implementation Phases

**Phase A (client-side, no backend changes)**:
- Add `RoutePreferences` model
- Sort results from `routeRecommendationsProvider` client-side based on preferences
- Persist preferences locally with SharedPreferences
- UI: Bottom sheet on journey search screen with preference controls

**Phase B (backend-supported)**:
- Pass preferences as query variables to `getRouteRecommendations`
- Backend applies scoring weights before returning results
- Add `elevationProfile` data to Leg model for elevation-aware routing

#### GraphQL Changes (Phase B)

```graphql
query getRouteRecommendations(
  $from: ID!
  $to: ID!
  $departureTime: String
  $preferences: RoutePreferencesInput  # NEW
) {
  routeRecommendations(
    from: $from
    to: $to
    departureTime: $departureTime
    preferences: $preferences
  ) {
    # existing fields...
  }
}

input RoutePreferencesInput {
  optimizeFor: RouteOptimization
  avoidSteepElevation: Boolean
  preferLowCarbon: Boolean
  maxTransfers: Int
}
```

#### UI Wireframe

```
┌─────────────────────────────┐
│  Route Preferences          │
├─────────────────────────────┤
│                             │
│  Optimize for:              │
│  [Scenic] [Fastest] [Fewer  │
│           transfers]        │
│                             │
│  ☐ Avoid steep elevation    │
│  ☐ Prefer low-carbon        │
│                             │
│  Max transfers: [___3___]   │
│                             │
│  [Apply]                    │
└─────────────────────────────┘
```

#### Files to Create/Modify

| Action | File |
|--------|------|
| Create | `lib/features/journey/domain/models/route_preferences.dart` |
| Create | `lib/features/journey/providers/route_preferences_provider.dart` |
| Modify | `lib/features/journey/providers/journey_providers.dart` (add sorting) |
| Modify | `lib/features/journey/presentation/journey_results_screen.dart` (add prefs button) |
| Create | `lib/features/journey/presentation/widgets/preferences_sheet.dart` |

---

### F2: Weather-Aware Route Replanning

#### Problem

Mountain routes are vulnerable to weather (snow on passes, wind on exposed segments, fog in valleys). Users discover problems only after boarding.

#### Solution

Proactively flag risky route segments and suggest safer alternatives.

#### Risk Assessment Rules

```
RISK_HIGH when:
  - precipitationProbability > 70% AND condition IN (SNOWY, STORMY)
  - windSpeed > 80 km/h
  - condition == FOGGY AND transport IN (BUS, TRAM)  # road vehicles

RISK_MEDIUM when:
  - precipitationProbability > 50% AND condition == RAINY
  - windSpeed > 60 km/h
  - condition == SNOWY AND elevation > 1000m

RISK_LOW:
  - Everything else
```

#### Data Model Changes

```dart
// Add to Leg model
@freezed
class LegWeatherRisk with _$LegWeatherRisk {
  const factory LegWeatherRisk({
    required RiskLevel level,        // high, medium, low
    required String reason,          // "Heavy snow expected on Bernina Pass"
    required Weather legWeather,     // Weather at leg midpoint
    List<Journey>? alternatives,     // Safer route options
  }) = _LegWeatherRisk;
}

enum RiskLevel { low, medium, high }
```

#### GraphQL Changes

```graphql
# Extend RouteRecommendation
type RouteRecommendation {
  journey: Journey!
  weather: Weather!
  warnings: [String!]!
  recommendation: String!
  legRisks: [LegWeatherRisk!]       # NEW
  saferAlternatives: [Journey!]     # NEW
}

type LegWeatherRisk {
  legIndex: Int!
  level: RiskLevel!
  reason: String!
  weather: Weather!
}
```

#### UI Behavior

1. **Journey Results Screen**: Risk badge on cards with high-risk legs (red/orange indicator)
2. **Journey Detail Screen**: Per-leg risk indicators in `LegTimeline`
3. **Risk Detail Sheet**: Tap risk indicator to see explanation + "View safer routes" button
4. **Safer Routes**: Navigates to filtered journey results excluding risky segments

#### Files to Create/Modify

| Action | File |
|--------|------|
| Create | `lib/features/journey/domain/models/leg_weather_risk.dart` |
| Modify | `lib/features/journey/domain/models/route_recommendation.dart` |
| Modify | `lib/features/journey/data/graphql/journey_queries.dart` |
| Create | `lib/features/journey/presentation/widgets/risk_indicator.dart` |
| Modify | `lib/features/journey/presentation/widgets/leg_timeline.dart` |
| Modify | `lib/features/journey/presentation/widgets/journey_card.dart` |

---

### F3: Contextual POI Suggestions (Along-Route)

#### Problem

Transfer windows are dead time. Users don't know what's accessible during a 15-minute wait at an intermediate station.

#### Solution

Show relevant POIs at transfer points, filtered by available time.

#### Data Model

```dart
// lib/features/poi/domain/models/poi.dart
@freezed
class POI with _$POI {
  const factory POI({
    required String id,
    required String name,
    required POICategory category,
    required Coordinates coordinates,
    required int estimatedVisitMinutes,
    String? description,
    String? imageUrl,
    double? rating,
    double? distanceFromStation,  // meters
  }) = _POI;
}

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
class TransferPOI with _$TransferPOI {
  const factory TransferPOI({
    required Station station,
    required int availableMinutes,  // transfer window
    required List<POI> pois,        // filtered by time
  }) = _TransferPOI;
}
```

#### GraphQL Query

```graphql
query getPOIsAlongRoute(
  $journeyId: ID!
  $maxDistanceMeters: Int = 500
  $categories: [POICategory!]
  $limit: Int = 5
) {
  poisAlongRoute(
    journeyId: $journeyId
    maxDistanceMeters: $maxDistanceMeters
    categories: $categories
    limit: $limit
  ) {
    station { id name }
    availableMinutes
    pois {
      id
      name
      category
      coordinates { latitude longitude }
      estimatedVisitMinutes
      description
      distanceFromStation
    }
  }
}
```

#### Transfer Window Calculation

```
For each consecutive leg pair (legN, legN+1):
  transferStation = legN.to  (== legN+1.from)
  availableMinutes = legN+1.departure - legN.arrival
  if availableMinutes >= 5:
    fetch POIs where estimatedVisitMinutes <= availableMinutes - 3  # 3 min buffer
```

#### UI Integration

- **LegTimeline**: Show POI chips at transfer points between legs
- **POI Detail Sheet**: Tap chip to see name, category, distance, visit time
- **POI List**: Expandable section in journey detail showing all transfer POIs

#### Files to Create/Modify

| Action | File |
|--------|------|
| Create | `lib/features/poi/domain/models/poi.dart` |
| Create | `lib/features/poi/data/graphql/poi_queries.dart` |
| Create | `lib/features/poi/data/repositories/poi_repository.dart` |
| Create | `lib/features/poi/providers/poi_providers.dart` |
| Create | `lib/features/poi/presentation/widgets/poi_chip.dart` |
| Create | `lib/features/poi/presentation/widgets/poi_detail_sheet.dart` |
| Modify | `lib/features/journey/presentation/widgets/leg_timeline.dart` |
| Modify | `lib/core/config/feature_flags.dart` (add `contextualPois` flag) |

---

### F4: Map View (Enable & Extend)

#### Problem

Route geography is invisible. Users can't visualize where they're going or what's along the way.

#### Solution

Enable the existing MapLibre GL scaffold and extend with route polylines, POI markers, and weather overlays.

#### Prerequisites

- MapTiler API key (or alternative tile provider)
- iOS: Add MapLibre native pod
- Android: MapLibre native dependency (already in scaffold)

#### Implementation Phases

**Phase A: Basic map**
- Configure MapTiler key in `AppConfig`
- Draw polylines between leg stations
- Station markers at origin, destination, transfers
- Fit bounds to route

**Phase B: POI layer** (depends on F3)
- POI markers with category icons
- Tap marker for POI detail
- Filter by category

**Phase C: Weather overlay**
- Color-coded route segments by weather risk
- Weather icons at key points
- Animated precipitation overlay (if tile data available)

#### Map Configuration

```dart
// lib/core/config/app_config.dart
static const String mapTilerKey = String.fromEnvironment(
  'MAPTILER_KEY',
  defaultValue: '',
);

static String get mapStyleUrl =>
    'https://api.maptiler.com/maps/ch-swisstopo-lbm/style.json?key=$mapTilerKey';
```

#### Files to Modify

| Action | File |
|--------|------|
| Modify | `lib/core/config/app_config.dart` (real key config) |
| Modify | `lib/core/config/feature_flags.dart` (`mapView = true`) |
| Modify | `lib/features/map/presentation/widgets/route_map.dart` (real implementation) |
| Create | `lib/features/map/presentation/widgets/poi_marker.dart` |
| Create | `lib/features/map/presentation/widgets/weather_overlay.dart` |
| Modify | `lib/features/map/providers/map_providers.dart` (route data) |

---

### F5: POIs in Radius

#### Problem

Users at a station or location want to discover what's nearby without having a specific journey planned.

#### Solution

Location-based POI search with radius, category filters, and optional map display.

#### Data Model

Reuses `POI` model from F3.

```dart
// lib/features/poi/domain/models/poi_search_params.dart
@freezed
class POISearchParams with _$POISearchParams {
  const factory POISearchParams({
    required double latitude,
    required double longitude,
    @Default(2.0) double radiusKm,
    List<POICategory>? categories,
    @Default(20) int limit,
  }) = _POISearchParams;
}
```

#### GraphQL Query

```graphql
query getPOIsNearby(
  $latitude: Float!
  $longitude: Float!
  $radiusKm: Float = 2.0
  $categories: [POICategory!]
  $limit: Int = 20
) {
  poisNearby(
    latitude: $latitude
    longitude: $longitude
    radiusKm: $radiusKm
    categories: $categories
    limit: $limit
  ) {
    id
    name
    category
    coordinates { latitude longitude }
    estimatedVisitMinutes
    description
    distanceFromStation
  }
}
```

#### UI

- **Entry point**: New tab or home screen card "Explore nearby"
- **Radius control**: Slider (0.5 - 10 km)
- **Category filter**: Chip row (viewpoint, cafe, museum, etc.)
- **Results**: List sorted by distance, with map toggle (if F4 enabled)
- **Location source**: Device GPS or selected station coordinates

#### Dependencies

- `geolocator` package for device location
- Location permissions (iOS Info.plist, Android manifest)
- F3's POI model (shared)

#### Files to Create/Modify

| Action | File |
|--------|------|
| Create | `lib/features/poi/presentation/nearby_pois_screen.dart` |
| Create | `lib/features/poi/presentation/widgets/radius_slider.dart` |
| Create | `lib/features/poi/presentation/widgets/category_filter.dart` |
| Create | `lib/features/poi/presentation/widgets/poi_list_tile.dart` |
| Modify | `lib/features/poi/data/graphql/poi_queries.dart` (add nearby query) |
| Modify | `lib/features/poi/providers/poi_providers.dart` (add nearby provider) |
| Modify | `lib/core/router/app_router.dart` (add route) |
| Modify | `pubspec.yaml` (add geolocator) |

---

### F6: Weather Escape

#### Problem

It's raining where you are. You want to find sunshine within a reasonable travel time.

#### Solution

"Escape the weather" feature that finds destinations with better conditions reachable within a time budget.

#### Data Model

```dart
// lib/features/weather/domain/models/weather_escape.dart
@freezed
class WeatherEscape with _$WeatherEscape {
  const factory WeatherEscape({
    required Station destination,
    required Weather destinationWeather,
    required int travelMinutes,
    required double weatherImprovement,  // score delta
    Journey? suggestedJourney,
  }) = _WeatherEscape;
}
```

#### Weather Improvement Score

```
score(weather) =
  (100 - precipitationProbability) * 0.4 +
  temperatureComfort(temperature) * 0.3 +   // peaks at 20-25C
  conditionScore(condition) * 0.3            // CLEAR=100, PARTLY_CLOUDY=70, ...

improvement = score(destination) - score(origin)
```

#### GraphQL Query

```graphql
query getWeatherEscapes(
  $from: ID!
  $maxTravelMinutes: Int = 90
  $limit: Int = 5
) {
  weatherEscapes(
    from: $from
    maxTravelMinutes: $maxTravelMinutes
    limit: $limit
  ) {
    destination { id name coordinates { latitude longitude } }
    destinationWeather {
      temperature
      condition
      precipitationProbability
    }
    travelMinutes
    weatherImprovement
    suggestedJourney { id departure arrival duration }
  }
}
```

#### UI

- **Entry point**: Home screen card when local weather is poor (rain/snow/fog)
- **Display**: Cards showing destination + weather + travel time
- **Action**: Tap to view full journey details
- **Map view**: Show escape destinations on map with weather icons (if F4 enabled)

```
┌─────────────────────────────┐
│  ☀️ Escape the rain          │
├─────────────────────────────┤
│  ┌───────────────────────┐  │
│  │ Lugano        45 min  │  │
│  │ 23°C Clear    ↑↑↑     │  │
│  └───────────────────────┘  │
│  ┌───────────────────────┐  │
│  │ Locarno       52 min  │  │
│  │ 22°C Partly   ↑↑      │  │
│  └───────────────────────┘  │
└─────────────────────────────┘
```

#### Swiss Relevance

- Föhn effect: North side cloudy, south side clear
- Ticino sunshine: Often sunny when Mittelland is foggy
- Lake regions: Microclimates vary within short distances
- Seasonal: Hochnebel (high fog) in winter — escape to mountains above fog line

#### Files to Create/Modify

| Action | File |
|--------|------|
| Create | `lib/features/weather/domain/models/weather_escape.dart` |
| Create | `lib/features/weather/data/graphql/weather_escape_queries.dart` |
| Create | `lib/features/weather/providers/weather_escape_provider.dart` |
| Create | `lib/features/weather/presentation/weather_escape_screen.dart` |
| Create | `lib/features/weather/presentation/widgets/escape_card.dart` |
| Modify | `lib/features/home/presentation/home_screen.dart` (add escape card) |
| Modify | `lib/core/router/app_router.dart` (add route) |
| Modify | `lib/core/config/feature_flags.dart` (add `weatherEscape` flag) |

---

### F7: Experience-Aware Routes

#### Problem

`scenicScore` is a single number. It doesn't capture time-of-day beauty (sunset over lakes), seasonal highlights (autumn foliage), or experiential factors (window seats, quiet cars).

#### Solution

Multi-dimensional experience scoring with time-awareness.

#### Data Model

```dart
// lib/features/journey/domain/models/experience_score.dart
@freezed
class ExperienceScore with _$ExperienceScore {
  const factory ExperienceScore({
    required int overall,              // 0-100
    required int scenicLandscape,      // mountain/lake views
    required int goldenHour,           // sunset/sunrise alignment
    required int photoOpportunities,   // known photo spots along route
    required int tranquility,          // quieter routes/times
    String? highlight,                 // "Golden hour over Lake Thun"
    List<ExperienceMoment>? moments,   // key moments along route
  }) = _ExperienceScore;
}

@freezed
class ExperienceMoment with _$ExperienceMoment {
  const factory ExperienceMoment({
    required String description,       // "Lake Brienz panorama"
    required int minutesFromDeparture, // when to look
    required String side,              // "left" or "right" window
    String? tip,                       // "Sit on the left side"
  }) = _ExperienceMoment;
}
```

#### Scoring Factors

| Factor | Data Source | Computation |
|--------|-------------|-------------|
| Scenic landscape | Static route metadata | Pre-scored per route segment |
| Golden hour | Sun position API + route timing | Overlap of route with golden hour |
| Photo opportunities | POI density (viewpoints, landmarks) | Count along route buffer |
| Tranquility | Passenger load data (if available) | Off-peak = higher score |

#### UI Integration

- **Journey Results**: Experience tab alongside default results
- **Journey Detail**: "Experience moments" timeline overlay
- **Moments**: Cards showing when to look and which side

#### Files to Create/Modify

| Action | File |
|--------|------|
| Create | `lib/features/journey/domain/models/experience_score.dart` |
| Modify | `lib/features/journey/domain/models/journey.dart` (add experienceScore field) |
| Modify | `lib/features/journey/data/graphql/journey_queries.dart` |
| Create | `lib/features/journey/presentation/widgets/experience_timeline.dart` |
| Create | `lib/features/journey/presentation/widgets/moment_card.dart` |
| Modify | `lib/features/journey/presentation/journey_detail_screen.dart` |

---

### F8: Saved Trips & Itineraries

#### Problem

Users can't remember good routes or plan multi-day trips.

#### Solution

Local-first trip bookmarking with optional multi-day itinerary builder.

#### Data Model

```dart
// lib/features/trips/domain/models/saved_trip.dart
@freezed
class SavedTrip with _$SavedTrip {
  const factory SavedTrip({
    required String id,
    required String fromStationId,
    required String toStationId,
    required String fromStationName,
    required String toStationName,
    DateTime? preferredDeparture,
    String? notes,
    required DateTime savedAt,
    RoutePreferences? preferences,
  }) = _SavedTrip;
}

// lib/features/trips/domain/models/itinerary.dart
@freezed
class Itinerary with _$Itinerary {
  const factory Itinerary({
    required String id,
    required String name,
    required List<ItineraryDay> days,
    required DateTime createdAt,
    DateTime? startDate,
  }) = _Itinerary;
}

@freezed
class ItineraryDay with _$ItineraryDay {
  const factory ItineraryDay({
    required int dayNumber,
    required List<ItineraryItem> items,  // trips + POI stops
  }) = _ItineraryDay;
}

@freezed
class ItineraryItem with _$ItineraryItem {
  const factory ItineraryItem.trip({
    required SavedTrip trip,
  }) = _ItineraryTrip;

  const factory ItineraryItem.poiStop({
    required POI poi,
    required int durationMinutes,
  }) = _ItineraryPOIStop;
}
```

#### Storage Strategy

**Phase A: Local-only**
- Hive boxes for `SavedTrip` and `Itinerary`
- No sync, device-local

**Phase B: With accounts** (depends on F9)
- Sync to backend via new GraphQL mutations
- Conflict resolution: last-write-wins

#### UI

- **Save button**: On JourneyCard and JourneyDetailScreen
- **My Trips screen**: List of saved trips, grouped by recency
- **Itinerary builder**: Drag-and-drop day planner
- **Quick re-search**: Tap saved trip to search for next departure

#### Files to Create/Modify

| Action | File |
|--------|------|
| Create | `lib/features/trips/domain/models/saved_trip.dart` |
| Create | `lib/features/trips/domain/models/itinerary.dart` |
| Create | `lib/features/trips/data/repositories/trips_repository.dart` |
| Create | `lib/features/trips/providers/trips_providers.dart` |
| Create | `lib/features/trips/presentation/saved_trips_screen.dart` |
| Create | `lib/features/trips/presentation/itinerary_builder_screen.dart` |
| Create | `lib/features/trips/presentation/widgets/saved_trip_tile.dart` |
| Modify | `lib/features/journey/presentation/widgets/journey_card.dart` (save button) |
| Modify | `lib/core/router/app_router.dart` |
| Modify | `pubspec.yaml` (add hive, hive_flutter) |

---

### F9: Accounts

#### Problem

No user identity means no cross-device sync, no personalization history, no social features.

#### Solution

Optional account system (anonymous-first, account for sync).

#### Auth Strategy

| Option | Pros | Cons |
|--------|------|------|
| Firebase Auth | Fast setup, social login, free tier | Google dependency |
| Supabase Auth | Open source, PostgreSQL, row-level security | Self-host or pay |
| Custom JWT | Full control | More backend work |

Recommended: **Supabase** for alignment with open-source ethos and PostgreSQL backend.

#### Data Model

```dart
// lib/features/auth/domain/models/user_profile.dart
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String email,
    String? displayName,
    RoutePreferences? defaultPreferences,
    DateTime? createdAt,
  }) = _UserProfile;
}
```

#### State Management

```dart
// lib/features/auth/providers/auth_providers.dart
@riverpod
class AuthState extends _$AuthState {
  // States: unauthenticated, authenticating, authenticated, error
}

@riverpod
Stream<UserProfile?> currentUser(CurrentUserRef ref) {
  // Stream from auth provider
}
```

#### Architecture Impact

- **First mutations**: Need to add mutation support to GraphQL client
- **Token management**: Auth headers on GraphQL requests
- **Offline-first conflict**: Local changes need sync queue

#### Files to Create

| Action | File |
|--------|------|
| Create | `lib/features/auth/domain/models/user_profile.dart` |
| Create | `lib/features/auth/data/repositories/auth_repository.dart` |
| Create | `lib/features/auth/providers/auth_providers.dart` |
| Create | `lib/features/auth/presentation/login_screen.dart` |
| Create | `lib/features/auth/presentation/profile_screen.dart` |
| Modify | `lib/shared/graphql/graphql_client.dart` (auth headers) |
| Modify | `lib/core/router/app_router.dart` (auth guard) |

---

### F10: Offline Mode

#### Problem

Mountain areas have poor connectivity. Users lose access to their journey details mid-trip.

#### Solution

Cache recently viewed data locally; degrade gracefully when offline.

#### Caching Strategy

| Data | Cache Duration | Storage |
|------|----------------|---------|
| Station list (searched) | 7 days | Hive |
| Journey results (viewed) | 24 hours | Hive |
| Route recommendations | 24 hours | Hive |
| Weather data | 1 hour | Memory only (stale quickly) |
| Map tiles | 30 days | MapTiler offline packs |
| POI data | 7 days | Hive |

#### Implementation

```dart
// lib/shared/cache/offline_cache.dart
class OfflineCache {
  Future<T?> get<T>(String key);
  Future<void> put<T>(String key, T value, Duration ttl);
  Future<void> invalidate(String key);
  Future<bool> get isOnline;  // connectivity check
}

// Modify GraphQL fetch policy based on connectivity
FetchPolicy get effectivePolicy {
  if (!isOnline) return FetchPolicy.cacheOnly;
  return originalPolicy;
}
```

#### Connectivity Handling

- Use `connectivity_plus` package to detect network state
- Show offline banner when disconnected
- Queue failed requests for retry when back online
- Show "last updated" timestamps on cached data

#### Files to Create/Modify

| Action | File |
|--------|------|
| Create | `lib/shared/cache/offline_cache.dart` |
| Create | `lib/shared/cache/cache_config.dart` |
| Create | `lib/shared/providers/connectivity_provider.dart` |
| Create | `lib/shared/widgets/offline_banner.dart` |
| Modify | `lib/shared/graphql/graphql_client.dart` (persistent cache) |
| Modify | `pubspec.yaml` (add hive, connectivity_plus) |

---

### F11: Stored POIs & Car API

#### Problem

Users discover good POIs but can't save them. Some journeys are better with a car segment to/from the station.

#### Solution

POI bookmarking + optional car routing for first/last mile.

#### Car API Integration

```dart
// lib/features/journey/domain/models/transport.dart
// Extend TransportType enum:
enum TransportType {
  IC, IR, RE, S, ICE, EC, BUS, TRAM,
  CAR,  // NEW
  WALK, // NEW - for short connections
}
```

#### Mixed-Mode Journey

```graphql
query getMixedJourneys(
  $from: Coordinates!        # Can be arbitrary location (not just station)
  $to: Coordinates!
  $departureTime: String
  $includeCarSegments: Boolean = false
  $maxCarMinutes: Int = 20   # Limit car portions
) {
  mixedJourneys(...) {
    legs {
      # Existing leg fields plus:
      transport {
        type   # Now includes CAR, WALK
        distance  # km, for car/walk segments
        co2Grams  # Carbon footprint
      }
    }
    totalCo2Grams
  }
}
```

#### Scope Consideration

Adding car routing shifts the app from "Swiss train journeys" to "Swiss travel planner." This is an intentional product decision. Start with park-and-ride scenarios: drive to nearest station, train for the scenic part.

---

## Feature Dependencies

```
F1 (Preferences) ──────────────────────────────────┐
                                                     │
F2 (Weather Replanning) ───────────────────────┐    │
                                                │    │
F3 (Along-Route POIs) ──────┐                  │    │
                             │                  │    │
F4 (Map View) ──────────────┤                  │    │
                             ├── F5 (POI Radius)│    │
F6 (Weather Escape) ────────┤                  │    │
                             │                  │    │
F7 (Experience Routes) ─────┘                  │    │
                                                │    │
F8 (Saved Trips) ──────────── F9 (Accounts) ──┤    │
                                                │    │
F10 (Offline Mode) ────────────────────────────┘    │
                                                     │
F11 (Car API + Stored POIs) ────────────────────────┘
```

### Dependency Chain

| Feature | Hard Dependencies | Soft Dependencies |
|---------|-------------------|-------------------|
| F1 Preferences | None | - |
| F2 Weather Replanning | None | F1 (prefer safe routes) |
| F3 Along-Route POIs | None | F4 (map viz) |
| F4 Map View | MapTiler key | F3, F5, F6 (overlays) |
| F5 POI Radius | Geolocation | F3 (shared model), F4 (map) |
| F6 Weather Escape | None | F4 (map), geolocation |
| F7 Experience Routes | None | F3 (photo spots) |
| F8 Saved Trips | Local persistence (Hive) | F9 (sync) |
| F9 Accounts | Backend auth | F8, F10 (sync targets) |
| F10 Offline Mode | Local persistence (Hive) | F9 (sync) |
| F11 Car + Stored POIs | F3 (POI model), backend car API | F9 (POI sync) |

---

## Implementation Groups

### Group A: Quick Wins (No Backend Changes)

Features that can be built with client-side logic on existing data:

1. **F1 Phase A**: Client-side route sorting by preferences
2. **F8 Phase A**: Local trip bookmarking with Hive
3. **F2 partial**: Highlight existing warnings more prominently in UI

Shared dependency: Add `hive` + `hive_flutter` to pubspec.

### Group B: POI Ecosystem

New backend subgraph needed, but features are cohesive:

1. **F5**: POI radius search (simplest, validates model)
2. **F3**: Along-route POIs (extends F5's model)
3. **F4**: Map view with POI layer

Shared dependency: POI model, geolocator, MapTiler key.

### Group C: Weather Intelligence

Extends the existing weather integration:

1. **F2**: Weather-aware replanning (extend RouteRecommendation)
2. **F6**: Weather escape (new query, new screen)
3. **F7**: Experience routes (time-aware scoring)

Shared dependency: Enhanced weather backend, sun position data.

### Group D: Persistence & Identity

Infrastructure features that enable sync:

1. **F10**: Offline cache layer
2. **F9**: Account system
3. **F8 Phase B**: Synced saved trips
4. **F11**: Stored POIs with sync

Shared dependency: Hive, auth provider, GraphQL mutations.

---

## New Package Dependencies

| Package | Version | Used By | Purpose |
|---------|---------|---------|---------|
| `hive` | ^2.2.3 | F8, F10, F11 | Local key-value storage |
| `hive_flutter` | ^1.1.0 | F8, F10, F11 | Flutter bindings for Hive |
| `geolocator` | ^11.0.0 | F5, F6 | Device location |
| `connectivity_plus` | ^6.0.0 | F10 | Network state detection |
| `shared_preferences` | ^2.2.0 | F1 | Simple preference storage |
| `maplibre_gl` | ^0.19.0 | F4 | Map rendering |

---

## New Feature Flags

```dart
// lib/core/config/feature_flags.dart
class FeatureFlags {
  // Existing
  static const bool popularRoutes = false;
  static const bool weatherInfo = true;
  static const bool mapView = false;

  // New
  static const bool routePreferences = false;   // F1
  static const bool weatherReplanning = false;   // F2
  static const bool contextualPois = false;      // F3
  static const bool nearbyPois = false;          // F5
  static const bool weatherEscape = false;       // F6
  static const bool experienceRoutes = false;    // F7
  static const bool savedTrips = false;          // F8
  static const bool accounts = false;            // F9
  static const bool offlineMode = false;         // F10
  static const bool carRouting = false;          // F11
}
```

---

## Open Questions

1. **POI data source**: Build own DB, use OpenStreetMap/Overpass, or partner with Swiss Tourism?
2. **Car routing provider**: Google Directions API, GraphHopper, or OSRM?
3. **Map tiles**: MapTiler (Swiss-optimized) vs Mapbox vs self-hosted?
4. **Auth provider**: Firebase, Supabase, or custom?
5. **Experience scoring**: How to seed initial scenic/photo data per route segment?
6. **Weather escape radius**: What's a reasonable max travel time default? 60 min? 90 min?
7. **Offline map tiles**: How much storage per region? Offer selective download?
8. **Carbon data**: Source for per-transport-type CO2 emissions in Switzerland?

---

## Appendix: Swiss-Specific Considerations

- **Föhn regions**: Distinct weather patterns north/south of Alps — critical for F6
- **SBB timetable structure**: Taktfahrplan (clockface scheduling) means same-minute departures hourly — good for saved trips
- **Mountain passes**: Seasonal closures, weather sensitivity — important for F2
- **Multi-language**: de/fr/it/en — all UI strings need localization
- **Accessibility**: Swiss disability law requires accessible transport info
- **Swiss coordinates**: LV95 (EPSG:2056) may be needed for some Swiss data sources alongside WGS84
