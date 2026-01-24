import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/logger.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_widget.dart';
import '../providers/journey_providers.dart';
import 'widgets/journey_card.dart';

class JourneyResultsScreen extends ConsumerWidget {
  final String fromId;
  final String fromName;
  final String toId;
  final String toName;
  final DateTime departureTime;

  const JourneyResultsScreen({
    super.key,
    required this.fromId,
    required this.fromName,
    required this.toId,
    required this.toName,
    required this.departureTime,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = JourneySearchParams(
      fromId: fromId,
      toId: toId,
      departureTime: departureTime,
    );

    final recommendations = ref.watch(routeRecommendationsProvider(params));

    AppLogger.screen('JourneyResultsScreen', {
      'fromId': fromId,
      'fromName': fromName,
      'toId': toId,
      'toName': toName,
      'departureTime': departureTime.toIso8601String(),
      'journeys': recommendations.when(
        data: (list) => '${list.length} journeys found',
        loading: () => 'loading...',
        error: (e, _) => 'error: $e',
      ),
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journey Results'),
      ),
      body: Column(
        children: [
          // Route info header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.trip_origin,
                            size: 16,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              fromName,
                              style: AppTheme.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppTheme.secondaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              toName,
                              style: AppTheme.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Journey list
          Expanded(
            child: recommendations.when(
              data: (recommendationList) {
                if (recommendationList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.train,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppConstants.noJourneysFound,
                          style: AppTheme.bodyLarge.copyWith(
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: recommendationList.length,
                  itemBuilder: (context, index) {
                    final recommendation = recommendationList[index];
                    return JourneyCard(
                      journey: recommendation.journey,
                      onTap: () {
                        context.push('/journey-detail', extra: recommendation);
                      },
                    );
                  },
                );
              },
              loading: () => const LoadingIndicator(
                message: 'Searching for journeys...',
              ),
              error: (error, stack) => AppErrorWidget(
                message: error.toString(),
                onRetry: () {
                  ref.invalidate(routeRecommendationsProvider(params));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
