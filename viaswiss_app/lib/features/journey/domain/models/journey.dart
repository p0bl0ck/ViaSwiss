import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../search/domain/models/station.dart';
import 'leg.dart';

part 'journey.freezed.dart';
part 'journey.g.dart';

@freezed
class Journey with _$Journey {
  const factory Journey({
    required String id,
    required Station from,
    required Station to,
    required DateTime departure,
    required DateTime arrival,
    required int duration, // in minutes
    required int transfers,
    required List<Leg> legs,
    double? scenicScore,
  }) = _Journey;

  factory Journey.fromJson(Map<String, dynamic> json) =>
      _$JourneyFromJson(json);
}
