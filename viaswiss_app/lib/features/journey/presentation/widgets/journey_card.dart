import 'package:flutter/material.dart';
import '../../../../core/config/theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/models/journey.dart';

class JourneyCard extends StatelessWidget {
  final Journey journey;
  final VoidCallback onTap;

  const JourneyCard({
    super.key,
    required this.journey,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time and stations
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormatter.formatDateTime(journey.departure),
                      style: AppTheme.titleLarge.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      journey.from.name,
                      style: AppTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormatter.formatDuration(journey.duration),
                    style: AppTheme.caption,
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormatter.formatDateTime(journey.arrival),
                      style: AppTheme.titleLarge.copyWith(
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      journey.to.name,
                      style: AppTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Transfers and scenic score
          Row(
            children: [
              _buildInfoChip(
                icon: Icons.swap_horiz,
                label: journey.transfers == 0
                    ? 'Direct'
                    : '${journey.transfers} transfer${journey.transfers > 1 ? 's' : ''}',
              ),
              const SizedBox(width: 8),
              if (journey.scenicScore != null)
                _buildInfoChip(
                  icon: Icons.landscape,
                  label: 'Scenic ${(journey.scenicScore! * 100).toInt()}%',
                  color: AppTheme.secondaryColor,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? AppTheme.primaryColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color ?? AppTheme.primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color ?? AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
