import 'package:json_annotation/json_annotation.dart';

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