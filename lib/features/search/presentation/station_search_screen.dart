import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme.dart';
import '../../../core/utils/constants.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../home/providers/home_providers.dart';
import '../providers/station_providers.dart';
import 'widgets/station_list_item.dart';

class StationSearchScreen extends ConsumerStatefulWidget {
  final bool isFromStation;

  const StationSearchScreen({
    super.key,
    required this.isFromStation,
  });

  @override
  ConsumerState<StationSearchScreen> createState() =>
      _StationSearchScreenState();
}

class _StationSearchScreenState extends ConsumerState<StationSearchScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(stationSearchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isFromStation ? 'From Station' : 'To Station'),
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: AppConstants.searchStationPlaceholder,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(stationSearchQueryProvider.notifier)
                              .setQuery('');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                ref.read(stationSearchQueryProvider.notifier).setQuery(value);
              },
            ),
          ),

          // Results
          Expanded(
            child: searchResults.when(
              data: (stations) {
                if (stations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.length < 2
                              ? 'Enter at least 2 characters to search'
                              : AppConstants.noResultsFound,
                          style: AppTheme.bodyLarge.copyWith(
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: stations.length,
                  itemBuilder: (context, index) {
                    final station = stations[index];
                    return StationListItem(
                      station: station,
                      onTap: () {
                        if (widget.isFromStation) {
                          ref
                              .read(selectedStationsProvider.notifier)
                              .setFromStation(station);
                        } else {
                          ref
                              .read(selectedStationsProvider.notifier)
                              .setToStation(station);
                        }
                        context.pop();
                      },
                    );
                  },
                );
              },
              loading: () => const LoadingIndicator(
                message: 'Searching stations...',
              ),
              error: (error, stack) => AppErrorWidget(
                message: error.toString(),
                onRetry: () {
                  ref.invalidate(stationSearchResultsProvider);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
