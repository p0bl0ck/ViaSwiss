import 'package:flutter/material.dart';
import '../../../../core/config/theme.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/models/station.dart';

class StationListItem extends StatelessWidget {
  final Station station;
  final VoidCallback onTap;

  const StationListItem({
    super.key,
    required this.station,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          const Icon(Icons.location_on, color: AppTheme.primaryColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  station.name,
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${station.coordinates.latitude.toStringAsFixed(4)}, ${station.coordinates.longitude.toStringAsFixed(4)}',
                  style: AppTheme.caption,
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
