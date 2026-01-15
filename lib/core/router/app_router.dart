import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/search/presentation/station_search_screen.dart';
import '../../features/journey/presentation/journey_results_screen.dart';
import '../../features/journey/presentation/journey_detail_screen.dart';
import '../../features/map/presentation/map_screen.dart';
import '../../features/journey/domain/models/journey.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/search-station',
        name: 'searchStation',
        builder: (context, state) {
          final isFrom = state.uri.queryParameters['isFrom'] == 'true';
          return StationSearchScreen(isFromStation: isFrom);
        },
      ),
      GoRoute(
        path: '/journey-results',
        name: 'journeyResults',
        builder: (context, state) {
          final fromId = state.uri.queryParameters['fromId']!;
          final fromName = state.uri.queryParameters['fromName']!;
          final toId = state.uri.queryParameters['toId']!;
          final toName = state.uri.queryParameters['toName']!;
          final departureTime = state.uri.queryParameters['departureTime'];

          return JourneyResultsScreen(
            fromId: fromId,
            fromName: fromName,
            toId: toId,
            toName: toName,
            departureTime: departureTime != null
                ? DateTime.parse(departureTime)
                : DateTime.now(),
          );
        },
      ),
      GoRoute(
        path: '/journey-detail',
        name: 'journeyDetail',
        builder: (context, state) {
          final journey = state.extra as Journey;
          return JourneyDetailScreen(journey: journey);
        },
      ),
      GoRoute(
        path: '/map',
        name: 'map',
        builder: (context, state) {
          final journey = state.extra as Journey;
          return MapScreen(journey: journey);
        },
      ),
    ],
  );
});
