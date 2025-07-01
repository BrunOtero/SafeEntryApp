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

// For serialization/deserialization with json_annotation
extension AgendamentoStatusExtension on AgendamentoStatus {
  String toJson() => name;
}