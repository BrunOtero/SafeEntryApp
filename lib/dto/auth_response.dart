class AuthResponse {
  final String token;
  final String tipoUsuario;
  final String email;
  final String nome;

  AuthResponse({
    required this.token,
    required this.tipoUsuario,
    required this.email,
    required this.nome,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      tipoUsuario: json['tipoUsuario'],
      email: json['email'],
      nome: json['nome'],
    );
  }
}