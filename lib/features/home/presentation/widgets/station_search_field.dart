import 'package:flutter/material.dart';
import '../../../../core/config/theme.dart';
import '../../../../core/utils/constants.dart';
import '../../../search/domain/models/station.dart';

class StationSearchField extends StatelessWidget {
  final String label;
  final Station? station;
  final VoidCallback onTap;

  const StationSearchField({
    super.key,
    required this.label,
    required this.station,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              label == 'From' ? Icons.trip_origin : Icons.location_on,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    station?.name ??
                        (label == 'From'
                            ? AppConstants.fromStationPlaceholder
                            : AppConstants.toStationPlaceholder),
                    style: AppTheme.bodyLarge.copyWith(
                      color: station == null ? Colors.grey : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
