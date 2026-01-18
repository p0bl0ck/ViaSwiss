import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/feature_flags.dart';
import '../../../core/config/theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/logger.dart';
import '../../../shared/widgets/app_button.dart';
import '../domain/models/journey.dart';
import 'widgets/leg_timeline.dart';

class JourneyDetailScreen extends StatelessWidget {
  final Journey journey;

  const JourneyDetailScreen({
    super.key,
    required this.journey,
  });

  @override
  Widget build(BuildContext context) {
    AppLogger.screen('JourneyDetailScreen', {
      'journey.id': journey.id,
      'journey.from': journey.from.name,
      'journey.to': journey.to.name,
      'journey.departure': journey.departure.toIso8601String(),
      'journey.arrival': journey.arrival.toIso8601String(),
      'journey.duration': '${journey.duration} min',
      'journey.transfers': journey.transfers,
      'journey.legs': journey.legs.length,
      'journey.scenicScore': journey.scenicScore,
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journey Details'),
        actions: [
          if (FeatureFlags.mapView)
            IconButton(
              icon: const Icon(Icons.map),
              onPressed: () {
                context.push('/map', extra: journey);
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Journey summary header
          Container(
            padding: const EdgeInsets.all(24),
            color: AppTheme.primaryColor,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Departure',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormatter.formatDateTime(journey.departure),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          journey.from.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Arrival',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormatter.formatDateTime(journey.arrival),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          journey.to.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildInfoItem(
                      Icons.access_time,
                      DateFormatter.formatDuration(journey.duration),
                    ),
                    const SizedBox(width: 24),
                    _buildInfoItem(
                      Icons.swap_horiz,
                      journey.transfers == 0
                          ? 'Direct'
                          : '${journey.transfers} transfer${journey.transfers > 1 ? 's' : ''}',
                    ),
                    if (journey.scenicScore != null) ...[
                      const SizedBox(width: 24),
                      _buildInfoItem(
                        Icons.landscape,
                        '${(journey.scenicScore! * 100).toInt()}% scenic',
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Legs timeline
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Journey Legs',
                  style: AppTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ...journey.legs.map((leg) => LegTimeline(leg: leg)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
