import 'package:json_annotation/json_annotation.dart';

class EntradaRequest {
  final String qrToken;
  final String? observacoes;

  EntradaRequest({
    required this.qrToken,
    this.observacoes,
  });

  factory EntradaRequest.fromJson(Map<String, dynamic> json) {
    return EntradaRequest(
      qrToken: json['qrToken'],
      observacoes: json['observacoes'],
    );
  }
  Map<String, dynamic> toJson() => {
        'qrToken': qrToken,
        'observacoes': observacoes,
      };
}