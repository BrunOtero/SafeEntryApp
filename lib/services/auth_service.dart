import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safeentry/dto/auth_request.dart';
import 'package:safeentry/dto/auth_response.dart';
import 'package:safeentry/dto/register_request.dart';

class AuthService {
  final Dio _dio = Dio();
  static const String _baseUrl = 'http://localhost:1012/api/auth'; // Auth service URL

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/login',
        data: AuthRequest(email: email, password: password).toJson(),
      );
      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data);
        await _saveAuthData(authResponse.token, authResponse.tipoUsuario);
        return authResponse;
      } else {
        throw Exception('Failed to login: ${response.data}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Login error: ${e.response?.data['message'] ?? e.response?.statusCode}');
      } else {
        throw Exception('Login error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error during login: $e');
    }
  }

  Future<void> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/register',
        data: request.toJson(),
      );
      if (response.statusCode == 201) {
        return;
      } else {
        throw Exception('Failed to register: ${response.data}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Registration error: ${e.response?.data['message'] ?? e.response?.statusCode}');
      } else {
        throw Exception('Registration error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error during registration: $e');
    }
  }

  Future<void> _saveAuthData(String token, String userType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    await prefs.setString('user_type', userType);
    final decodedToken = JwtDecoder.decode(token);
    await prefs.setString('user_id', decodedToken['userId']);
    await prefs.setString('user_name', decodedToken['name'] ?? '');
    await prefs.setString('user_email', decodedToken['sub'] ?? '');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_type');
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_type');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    if (token == null) {
      return false;
    }
    return !JwtDecoder.isExpired(token);
  }
}