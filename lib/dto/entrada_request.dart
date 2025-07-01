import 'package:json_annotation/json_annotation.dart';

// part 'entrada_request.g.dart'; // Uncomment and run `flutter pub run build_runner build`

// @JsonSerializable()
class EntradaRequest {
  final String qrToken;
  final String? observacoes;

  EntradaRequest({
    required this.qrToken,
    this.observacoes,
  });

  // factory EntradaRequest.fromJson(Map<String, dynamic> json) => _$EntradaRequestFromJson(json);
  // Map<String, dynamic> toJson() => _$EntradaRequestToJson(this);
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