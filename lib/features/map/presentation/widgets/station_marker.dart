import 'package:flutter/material.dart';
import '../../../../core/config/theme.dart';
import '../../../search/domain/models/station.dart';

class StationMarker extends StatelessWidget {
  final Station station;
  final bool isOrigin;

  const StationMarker({
    super.key,
    required this.station,
    this.isOrigin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOrigin ? AppTheme.primaryColor : AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOrigin ? Icons.trip_origin : Icons.location_on,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            station.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
