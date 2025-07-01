import 'package:dio/dio.dart';
import 'package:safeentry/services/auth_service.dart';
import 'package:safeentry/dto/entrada_request.dart';
import 'package:safeentry/dto/entrada_response.dart';
// Import for response details

class GateService {
  final Dio _dio = Dio();
  final AuthService _authService = AuthService();
  static const String _baseUrl = 'http://localhost:1404/api/entradas'; // Gate service URL

  Future<EntradaResponse> registerEntry({
    required String qrToken,
    String? observacoes,
  }) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('User not authenticated.');
    }

    final requestBody = EntradaRequest(
      qrToken: qrToken,
      observacoes: observacoes,
    );

    try {
      final response = await _dio.post(
        _baseUrl,
        data: requestBody.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      if (response.statusCode == 201) {
        return EntradaResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to register entry: ${response.data}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Entry registration error: ${e.response?.data['message'] ?? e.response?.statusCode}');
      } else {
        throw Exception('Entry registration error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error during entry registration: $e');
    }
  }

  Future<List<EntradaResponse>> getMyEntries() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('User not authenticated.');
    }

    try {
      final response = await _dio.get(
        '$_baseUrl/me',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => EntradaResponse.fromJson(e))
            .toList();
      } else {
        throw Exception('Failed to fetch entries: ${response.data}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Fetch entries error: ${e.response?.data['message'] ?? e.response?.statusCode}');
      } else {
        throw Exception('Fetch entries error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error during fetching entries: $e');
    }
  }
}