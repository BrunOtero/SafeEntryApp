import 'package:json_annotation/json_annotation.dart';

// part 'visitante_info.g.dart'; // Uncomment and run `flutter pub run build_runner build`

// @JsonSerializable()
class VisitanteInfo {
  final String nome;
  final String documento;
  final String? veiculo;

  VisitanteInfo({
    required this.nome,
    required this.documento,
    this.veiculo,
  });

  // factory VisitanteInfo.fromJson(Map<String, dynamic> json) => _$VisitanteInfoFromJson(json);
  // Map<String, dynamic> toJson() => _$VisitanteInfoToJson(this);
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