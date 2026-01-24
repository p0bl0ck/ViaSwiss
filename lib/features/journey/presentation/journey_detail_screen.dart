import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/feature_flags.dart';
import '../../../core/config/theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/logger.dart';
import '../domain/models/route_recommendation.dart';
import '../../weather/domain/models/weather.dart';
import 'widgets/leg_timeline.dart';

class JourneyDetailScreen extends StatelessWidget {
  final RouteRecommendation recommendation;

  const JourneyDetailScreen({
    super.key,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    final journey = recommendation.journey;
    final weather = recommendation.weather;
    final warnings = recommendation.warnings;
    final recommendationText = recommendation.recommendation;

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
      'weather.temperature': weather.temperature,
      'weather.condition': weather.condition.name,
      'warnings.count': warnings.length,
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

          // Scrollable content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Weather section
                _buildWeatherSection(weather),
                const SizedBox(height: 16),

                // Warnings section (if any)
                if (warnings.isNotEmpty) ...[
                  _buildWarningsSection(warnings),
                  const SizedBox(height: 16),
                ],

                // Recommendation section
                _buildRecommendationSection(recommendationText),
                const SizedBox(height: 16),

                // Journey Legs
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

  Widget _buildWeatherSection(Weather weather) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(
            _getWeatherIcon(weather.condition),
            size: 40,
            color: Colors.blue[700],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${weather.temperature.toStringAsFixed(0)}°C',
                  style: AppTheme.titleLarge.copyWith(
                    color: Colors.blue[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getConditionLabel(weather.condition),
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(Icons.water_drop, size: 16, color: Colors.blue[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${weather.precipitationProbability}%',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              if (weather.windSpeed != null)
                Row(
                  children: [
                    Icon(Icons.air, size: 16, color: Colors.blue[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${weather.windSpeed!.toStringAsFixed(0)} km/h',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarningsSection(List<String> warnings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: warnings.map((warning) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber[300]!),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.amber[700],
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  warning,
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.amber[900],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecommendationSection(String recommendationText) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: Colors.green[700],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              recommendationText,
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.green[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.clear:
        return Icons.wb_sunny;
      case WeatherCondition.partlyCloudy:
        return Icons.cloud_queue;
      case WeatherCondition.cloudy:
        return Icons.cloud;
      case WeatherCondition.rainy:
        return Icons.water_drop;
      case WeatherCondition.snowy:
        return Icons.ac_unit;
      case WeatherCondition.stormy:
        return Icons.flash_on;
      case WeatherCondition.foggy:
        return Icons.blur_on;
    }
  }

  String _getConditionLabel(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.clear:
        return 'Clear';
      case WeatherCondition.partlyCloudy:
        return 'Partly Cloudy';
      case WeatherCondition.cloudy:
        return 'Cloudy';
      case WeatherCondition.rainy:
        return 'Rainy';
      case WeatherCondition.snowy:
        return 'Snowy';
      case WeatherCondition.stormy:
        return 'Stormy';
      case WeatherCondition.foggy:
        return 'Foggy';
    }
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
