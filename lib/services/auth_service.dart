import 'package:firebase_auth/firebase_auth.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Login com e-mail/senha
  Future<String?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Obter token JWT
      String? token = await userCredential.user?.getIdToken();
      return token;
    } catch (e) {
      throw Exception('Erro no login: $e');
    }
  }

  // Verificar token JWT
  static Map<String, dynamic>? decodeToken(String token) {
    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
