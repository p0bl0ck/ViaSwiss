import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../search/domain/models/station.dart';
import 'transport.dart';

part 'leg.freezed.dart';
part 'leg.g.dart';

@freezed
sealed class Leg with _$Leg {
  const factory Leg({
    required Station from,
    required Station to,
    required DateTime departure,
    required DateTime arrival,
    String? platform,
    required Transport transport,
    int? delay, // in minutes
  }) = _Leg;

  factory Leg.fromJson(Map<String, dynamic> json) => _$LegFromJson(json);
}
