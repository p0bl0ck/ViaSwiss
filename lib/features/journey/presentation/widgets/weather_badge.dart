import 'package:flutter/material.dart';
import '../../../../core/config/theme.dart';
import '../../../weather/domain/models/weather.dart';

class WeatherBadge extends StatelessWidget {
  final Weather weather;

  const WeatherBadge({
    super.key,
    required this.weather,
  });

  IconData _getWeatherIcon(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.clear:
        return Icons.wb_sunny;
      case WeatherCondition.partlyCloudy:
        return Icons.cloud_queue;
      case WeatherCondition.cloudy:
        return Icons.cloud;
      case WeatherCondition.rainy:
        return Icons.water_drop;
      case WeatherCondition.snowy:
        return Icons.ac_unit;
      case WeatherCondition.stormy:
        return Icons.thunderstorm;
      case WeatherCondition.foggy:
        return Icons.foggy;
    }
  }

  Color _getWeatherColor(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.clear:
        return AppTheme.sunnyColor;
      case WeatherCondition.partlyCloudy:
        return AppTheme.cloudyColor;
      case WeatherCondition.cloudy:
        return AppTheme.cloudyColor;
      case WeatherCondition.rainy:
        return AppTheme.rainyColor;
      case WeatherCondition.snowy:
        return Colors.blue;
      case WeatherCondition.stormy:
        return Colors.deepPurple;
      case WeatherCondition.foggy:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getWeatherColor(weather.condition);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getWeatherIcon(weather.condition),
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '${weather.temperature.toStringAsFixed(0)}°C',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${weather.precipitationProbability}%',
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
