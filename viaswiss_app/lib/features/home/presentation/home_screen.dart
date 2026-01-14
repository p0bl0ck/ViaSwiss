import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme.dart';
import '../../../core/utils/constants.dart';
import '../../../shared/widgets/app_button.dart';
import '../../home/providers/home_providers.dart';
import 'widgets/station_search_field.dart';
import 'widgets/popular_routes_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedStations = ref.watch(selectedStationsProvider);
    final departureTime = ref.watch(departureTimeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ViaSwiss'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Plan Your Swiss Journey',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Discover scenic routes with real-time weather',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Search section
                const Text(
                  'Where to?',
                  style: AppTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                // From station
                StationSearchField(
                  label: 'From',
                  station: selectedStations.from,
                  onTap: () => context.push('/search-station?isFrom=true'),
                ),
                const SizedBox(height: 12),

                // Swap button
                Center(
                  child: IconButton(
                    icon: const Icon(Icons.swap_vert),
                    onPressed: () {
                      ref.read(selectedStationsProvider.notifier).swapStations();
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // To station
                StationSearchField(
                  label: 'To',
                  station: selectedStations.to,
                  onTap: () => context.push('/search-station?isFrom=false'),
                ),
                const SizedBox(height: 24),

                // Departure time
                InkWell(
                  onTap: () async {
                    final now = DateTime.now();
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: departureTime ?? now,
                      firstDate: now,
                      lastDate: now.add(const Duration(days: 365)),
                    );

                    if (selectedDate != null && context.mounted) {
                      final selectedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(departureTime ?? now),
                      );

                      if (selectedTime != null) {
                        final combinedDateTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                        ref.read(departureTimeProvider.notifier).state =
                            combinedDateTime;
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: AppTheme.primaryColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Departure',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                departureTime != null
                                    ? '${departureTime.day}/${departureTime.month}/${departureTime.year} ${departureTime.hour.toString().padLeft(2, '0')}:${departureTime.minute.toString().padLeft(2, '0')}'
                                    : 'Now',
                                style: AppTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Search button
                AppButton(
                  text: 'Search Journeys',
                  icon: Icons.search,
                  onPressed: selectedStations.from != null &&
                          selectedStations.to != null
                      ? () {
                          context.push(
                            '/journey-results?fromId=${selectedStations.from!.id}&fromName=${Uri.encodeComponent(selectedStations.from!.name)}&toId=${selectedStations.to!.id}&toName=${Uri.encodeComponent(selectedStations.to!.name)}&departureTime=${(departureTime ?? DateTime.now()).toIso8601String()}',
                          );
                        }
                      : null,
                ),
                const SizedBox(height: 40),

                // Popular routes
                const PopularRoutesSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
