import 'package:json_annotation/json_annotation.dart';
import 'package:safeentry/dto/agendamento_status.dart';
import 'package:safeentry/dto/visitante_info.dart';

// part 'agendamento_response.g.dart'; // Uncomment and run `flutter pub run build_runner build`

// @JsonSerializable()
class AgendamentoResponse {
  final String id;
  final String moradorId;
  @JsonKey(name: 'dataHoraVisita')
  final DateTime dataHoraVisita;
  final VisitanteInfo visitante;
  final String qrToken;
  final bool usado;
  final AgendamentoStatus status;
  @JsonKey(name: 'criadoEm')
  final DateTime criadoEm;

  AgendamentoResponse({
    required this.id,
    required this.moradorId,
    required this.dataHoraVisita,
    required this.visitante,
    required this.qrToken,
    required this.usado,
    required this.status,
    required this.criadoEm,
  });

  // factory AgendamentoResponse.fromJson(Map<String, dynamic> json) => _$AgendamentoResponseFromJson(json);
  // Map<String, dynamic> toJson() => _$AgendamentoResponseToJson(this);
  factory AgendamentoResponse.fromJson(Map<String, dynamic> json) {
    return AgendamentoResponse(
      id: json['id'],
      moradorId: json['moradorId'],
      dataHoraVisita: DateTime.parse(json['dataHoraVisita']),
      visitante: VisitanteInfo.fromJson(json['visitante']),
      qrToken: json['qrToken'],
      usado: json['usado'],
      status: AgendamentoStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AgendamentoStatus.pendente, // Default or error handling
      ),
      criadoEm: DateTime.parse(json['criadoEm']),
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'moradorId': moradorId,
        'dataHoraVisita': dataHoraVisita.toIso8601String(),
        'visitante': visitante.toJson(),
        'qrToken': qrToken,
        'usado': usado,
        'status': status.toJson(),
        'criadoEm': criadoEm.toIso8601String(),
      };
}