import 'package:safeentry/dto/user_type.dart';

class UserDTO {
  final String nome;
  final String email;
  final UserType tipoUsuario;
  final String? apartamento;
  final bool ativo;

  UserDTO({
    required this.nome,
    required this.email,
    required this.tipoUsuario,
    this.apartamento,
    required this.ativo,
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      nome: json['nome'],
      email: json['email'],
      tipoUsuario: UserType.fromJson(json['tipoUsuario']),
      apartamento: json['apartamento'],
      ativo: json['ativo'],
    );
  }
}