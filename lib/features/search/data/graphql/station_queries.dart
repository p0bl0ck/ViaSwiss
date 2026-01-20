const String searchStationsQuery = r'''
  query SearchStations($query: String!, $limit: Int) {
    searchStations(query: $query, limit: $limit) {
      id
      name
      coordinates {
        latitude
        longitude
      }
    }
  }
''';
