const String getWeatherQuery = r'''
  query GetWeather($latitude: Float!, $longitude: Float!) {
    weather(latitude: $latitude, longitude: $longitude) {
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
  }
''';
