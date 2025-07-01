import 'package:safeentry/dto/user_type.dart';

class RegisterRequest {
  final String nome;
  final String email;
  final String senha;
  final UserType tipoUsuario;
  final String? apartamento;

  RegisterRequest({
    required this.nome,
    required this.email,
    required this.senha,
    required this.tipoUsuario,
    this.apartamento,
  });

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'email': email,
        'senha': senha,
        'tipoUsuario': tipoUsuario.toJson(),
        'apartamento': apartamento,
      };
}