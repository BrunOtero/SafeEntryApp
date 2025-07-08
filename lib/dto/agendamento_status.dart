import 'package:json_annotation/json_annotation.dart';

enum AgendamentoStatus {
  @JsonValue('pendente')
  pendente,
  @JsonValue('cancelado')
  cancelado,
  @JsonValue('expirado')
  expirado,
  @JsonValue('usado')
  usado,
}

extension AgendamentoStatusExtension on AgendamentoStatus {
  String toJson() => name;
}