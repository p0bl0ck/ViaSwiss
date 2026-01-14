const String getJourneysQuery = r'''
  query GetJourneys($from: ID!, $to: ID!, $departureTime: String, $limit: Int) {
    journeys(from: $from, to: $to, departureTime: $departureTime, limit: $limit) {
      id
      from {
        id
        name
        coordinates {
          latitude
          longitude
        }
      }
      to {
        id
        name
        coordinates {
          latitude
          longitude
        }
      }
      departure
      arrival
      duration
      transfers
      scenicScore
      legs {
        from {
          id
          name
          coordinates {
            latitude
            longitude
          }
        }
        to {
          id
          name
          coordinates {
            latitude
            longitude
          }
        }
        departure
        arrival
        platform
        transport {
          type
          number
          operator
          line
        }
        delay
      }
    }
  }
''';

const String getRouteRecommendationsQuery = r'''
  query GetRouteRecommendations($from: ID!, $to: ID!, $departureTime: String) {
    routeRecommendations(from: $from, to: $to, departureTime: $departureTime) {
      journey {
        id
        from {
          id
          name
          coordinates {
            latitude
            longitude
          }
        }
        to {
          id
          name
          coordinates {
            latitude
            longitude
          }
        }
        departure
        arrival
        duration
        transfers
        scenicScore
        legs {
          from {
            id
            name
            coordinates {
              latitude
              longitude
            }
          }
          to {
            id
            name
            coordinates {
              latitude
              longitude
            }
          }
          departure
          arrival
          platform
          transport {
            type
            number
            operator
            line
          }
          delay
        }
      }
      weather {
        location {
          latitude
          longitude
        }
        temperature
        condition
        precipitationProbability
        windSpeed
        timestamp
        forecast {
          timestamp
          temperature
          condition
          precipitationProbability
        }
      }
      warnings
      recommendation
    }
  }
''';
