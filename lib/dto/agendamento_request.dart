import 'package:json_annotation/json_annotation.dart';
import 'package:safeentry/dto/visitante_info.dart';

// part 'agendamento_request.g.dart'; // Uncomment and run `flutter pub run build_runner build`

// @JsonSerializable()
class AgendamentoRequest {
  @JsonKey(name: 'dataHoraVisita')
  final DateTime dataHoraVisita;
  final VisitanteInfo visitante;

  AgendamentoRequest({
    required this.dataHoraVisita,
    required this.visitante,
  });

  // factory AgendamentoRequest.fromJson(Map<String, dynamic> json) => _$AgendamentoRequestFromJson(json);
  // Map<String, dynamic> toJson() => _$AgendamentoRequestToJson(this);
  factory AgendamentoRequest.fromJson(Map<String, dynamic> json) {
    return AgendamentoRequest(
      dataHoraVisita: DateTime.parse(json['dataHoraVisita']),
      visitante: VisitanteInfo.fromJson(json['visitante']),
    );
  }
  Map<String, dynamic> toJson() => {
        'dataHoraVisita': dataHoraVisita.toIso8601String(),
        'visitante': visitante.toJson(),
      };
}