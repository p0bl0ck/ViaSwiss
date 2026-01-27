import 'package:flutter/material.dart';
import '../../../../core/config/theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/models/leg.dart';
import '../../domain/models/transport.dart';

class LegTimeline extends StatelessWidget {
  final Leg leg;

  const LegTimeline({super.key, required this.leg});

  Color _getTransportColor(TransportType type) {
    switch (type) {
      case TransportType.ic:
      case TransportType.ice:
        return AppTheme.icColor;
      case TransportType.ir:
      case TransportType.ec:
        return AppTheme.irColor;
      case TransportType.re:
        return AppTheme.reColor;
      case TransportType.s:
        return AppTheme.sColor;
      case TransportType.bus:
      case TransportType.tram:
        return Colors.orange;
    }
  }

  String _getTransportLabel(Transport transport) {
    return '${transport.type.name.toUpperCase()} ${transport.number}';
  }

  @override
  Widget build(BuildContext context) {
    final transportColor = _getTransportColor(leg.transport.type);
    final duration = leg.arrival.difference(leg.departure).inMinutes;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line and dots
          Column(
            children: [
              // Departure dot
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: transportColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
              // Line
              Container(width: 4, height: 80, color: transportColor),
              // Arrival dot
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: transportColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Leg details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Departure
                Row(
                  children: [
                    Text(
                      DateFormatter.formatDateTime(leg.departure),
                      style: AppTheme.titleLarge.copyWith(
                        color: transportColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (leg.platform != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Pl. ${leg.platform}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (leg.delay != null && leg.delay! > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          '+${leg.delay} min',
                          style: const TextStyle(
                            color: AppTheme.errorColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  leg.from.name,
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // Transport info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: transportColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: transportColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.train, color: transportColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getTransportLabel(leg.transport),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: transportColor,
                              ),
                            ),
                            Text(
                              leg.transport.operator,
                              style: AppTheme.caption,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        DateFormatter.formatDuration(duration),
                        style: AppTheme.caption.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Arrival
                Text(
                  DateFormatter.formatDateTime(leg.arrival),
                  style: AppTheme.titleLarge.copyWith(color: transportColor),
                ),
                const SizedBox(height: 4),
                Text(
                  leg.to.name,
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
