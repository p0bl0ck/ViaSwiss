import 'package:freezed_annotation/freezed_annotation.dart';

part 'transport.freezed.dart';
part 'transport.g.dart';

enum TransportType {
  @JsonValue('IC')
  ic,
  @JsonValue('IR')
  ir,
  @JsonValue('RE')
  re,
  @JsonValue('S')
  s,
  @JsonValue('ICE')
  ice,
  @JsonValue('EC')
  ec,
  @JsonValue('BUS')
  bus,
  @JsonValue('TRAM')
  tram,
}

@freezed
class Transport with _$Transport {
  const factory Transport({
    required TransportType type,
    required String number,
    required String operator,
    String? line,
  }) = _Transport;

  factory Transport.fromJson(Map<String, dynamic> json) =>
      _$TransportFromJson(json);
}
