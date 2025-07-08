import 'package:json_annotation/json_annotation.dart';

class VisitServiceAgendamentoResponse {
  final String id;
  final String moradorId;
  @JsonKey(name: 'dataHoraVisita')
  final DateTime dataHoraVisita;
  final VisitanteInfo visitante;
  final String qrToken;
  final bool usado;
  final String status;
  @JsonKey(name: 'criadoEm')
  final DateTime criadoEm;

  VisitServiceAgendamentoResponse({
    required this.id,
    required this.moradorId,
    required this.dataHoraVisita,
    required this.visitante,
    required this.qrToken,
    required this.usado,
    required this.status,
    required this.criadoEm,
  });

  factory VisitServiceAgendamentoResponse.fromJson(Map<String, dynamic> json) {
    return VisitServiceAgendamentoResponse(
      id: json['id'],
      moradorId: json['moradorId'],
      dataHoraVisita: DateTime.parse(json['dataHoraVisita']),
      visitante: VisitanteInfo.fromJson(json['visitante']),
      qrToken: json['qrToken'],
      usado: json['usado'],
      status: json['status'],
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
        'status': status,
        'criadoEm': criadoEm.toIso8601String(),
      };
}

class VisitanteInfo {
  final String nome;
  final String documento;
  final String? veiculo;

  VisitanteInfo({
    required this.nome,
    required this.documento,
    this.veiculo,
  });

  factory VisitanteInfo.fromJson(Map<String, dynamic> json) {
    return VisitanteInfo(
      nome: json['nome'],
      documento: json['documento'],
      veiculo: json['veiculo'],
    );
  }
  Map<String, dynamic> toJson() => {
        'nome': nome,
        'documento': documento,
        'veiculo': veiculo,
      };
}