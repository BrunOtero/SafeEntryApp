import 'package:json_annotation/json_annotation.dart';

class EntradaResponse {
  final String id;
  final String agendamentoId;
  final String porteiroId;
  @JsonKey(name: 'dataHoraEntrada')
  final DateTime dataHoraEntrada;
  final String? observacoes;

  EntradaResponse({
    required this.id,
    required this.agendamentoId,
    required this.porteiroId,
    required this.dataHoraEntrada,
    this.observacoes,
  });

  factory EntradaResponse.fromJson(Map<String, dynamic> json) {
    return EntradaResponse(
      id: json['id'],
      agendamentoId: json['agendamentoId'],
      porteiroId: json['porteiroId'],
      dataHoraEntrada: DateTime.parse(json['dataHoraEntrada']),
      observacoes: json['observacoes'],
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'agendamentoId': agendamentoId,
        'porteiroId': porteiroId,
        'dataHoraEntrada': dataHoraEntrada.toIso8601String(),
        'observacoes': observacoes,
      };
}