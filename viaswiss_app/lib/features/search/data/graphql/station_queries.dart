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

const String getStationQuery = r'''
  query GetStation($id: ID!) {
    station(id: $id) {
      id
      name
      coordinates {
        latitude
        longitude
      }
    }
  }
''';
