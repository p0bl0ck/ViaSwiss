import 'package:flutter/material.dart';
import '../../../../core/config/theme.dart';
import '../../../../core/utils/constants.dart';
import '../../../../shared/widgets/app_card.dart';

class PopularRoutesSection extends StatelessWidget {
  const PopularRoutesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Routes',
          style: AppTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ...AppConstants.popularRoutes.map((route) {
          return AppCard(
            onTap: () {
              // TODO: Implement quick search for popular route
              // For now, just show a snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Searching ${route['from']} to ${route['to']}...',
                  ),
                ),
              );
            },
            child: Row(
              children: [
                const Icon(
                  Icons.train,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route['from']!,
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.arrow_downward,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              route['to']!,
                              style: AppTheme.bodyMedium.copyWith(
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
