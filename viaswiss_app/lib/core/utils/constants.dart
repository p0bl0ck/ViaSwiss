class AppConstants {
  // Popular routes
  static const List<Map<String, String>> popularRoutes = [
    {'from': 'Zürich HB', 'to': 'Zermatt'},
    {'from': 'Zürich HB', 'to': 'St. Moritz'},
    {'from': 'Interlaken Ost', 'to': 'Jungfraujoch'},
    {'from': 'Luzern', 'to': 'Lugano'},
  ];

  // Error messages
  static const String networkError =
      'Network error. Please check your connection.';
  static const String unknownError = 'An unknown error occurred.';
  static const String noResultsFound = 'No results found.';
  static const String noJourneysFound = 'No journeys found for this route.';

  // Placeholders
  static const String searchStationPlaceholder = 'Search for a station...';
  static const String fromStationPlaceholder = 'From station';
  static const String toStationPlaceholder = 'To station';
}
