import 'package:flutter/material.dart';
import '../../../core/config/theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/logger.dart';
import '../../journey/domain/models/journey.dart';
import 'widgets/route_map.dart';

class MapScreen extends StatelessWidget {
  final Journey journey;

  const MapScreen({super.key, required this.journey});

  @override
  Widget build(BuildContext context) {
    AppLogger.screen('MapScreen', {
      'journey.id': journey.id,
      'journey.from': journey.from.name,
      'journey.from.coordinates':
          '${journey.from.coordinates.latitude}, ${journey.from.coordinates.longitude}',
      'journey.to': journey.to.name,
      'journey.to.coordinates':
          '${journey.to.coordinates.latitude}, ${journey.to.coordinates.longitude}',
      'journey.legs': journey.legs.length,
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Route Map')),
      body: Column(
        children: [
          // Journey summary
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
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
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              journey.from.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppTheme.secondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              journey.to.name,
                              style: const TextStyle(
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
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormatter.formatTimeRange(
                        journey.departure,
                        journey.arrival,
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormatter.formatDuration(journey.duration),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Map
          Expanded(child: RouteMap(journey: journey)),
        ],
      ),
    );
  }
}
