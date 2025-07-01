// SafeEntry/App/lib/services/visit_service.dart
import 'package:dio/dio.dart';
import 'package:safeentry/services/auth_service.dart';
import 'package:safeentry/dto/agendamento_request.dart';
import 'package:safeentry/dto/agendamento_response.dart';
import 'package:safeentry/dto/visitante_info.dart';

class VisitService {
  final Dio _dio = Dio();
  final AuthService _authService = AuthService();
  static const String _baseUrl = 'http://localhost:0707/api/agendamentos'; // Visits service URL

  Future<AgendamentoResponse> createAppointment({
    required String visitorName,
    required String visitorDocument,
    String? visitorVehicle,
    required DateTime visitTime,
  }) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('User not authenticated.');
    }

    final visitorInfo = VisitanteInfo(
      nome: visitorName,
      documento: visitorDocument,
      veiculo: visitorVehicle,
    );

    final requestBody = AgendamentoRequest(
      dataHoraVisita: visitTime,
      visitante: visitorInfo,
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
        return AgendamentoResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to create appointment: ${response.data}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Appointment creation error: ${e.response?.data['message'] ?? e.response?.statusCode}');
      } else {
        throw Exception('Appointment creation error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error during appointment creation: $e');
    }
  }

  Future<List<AgendamentoResponse>> getMyAppointments() async {
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
            .map((e) => AgendamentoResponse.fromJson(e))
            .toList();
      } else {
        throw Exception('Failed to fetch appointments: ${response.data}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Fetch appointments error: ${e.response?.data['message'] ?? e.response?.statusCode}');
      } else {
        throw Exception('Fetch appointments error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error during fetching appointments: $e');
    }
  }

  Future<AgendamentoResponse> cancelAppointment(String appointmentId) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('User not authenticated.');
    }

    try {
      final response = await _dio.patch(
        '$_baseUrl/me/$appointmentId/cancel',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      if (response.statusCode == 200) {
        return AgendamentoResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to cancel appointment: ${response.data}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Cancellation error: ${e.response?.data['message'] ?? e.response?.statusCode}');
      } else {
        throw Exception('Cancellation error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error during cancellation: $e');
    }
  }

  // NOVO MÉTODO: Obter agendamento pelo QR Token
  Future<AgendamentoResponse> getAppointmentByQrToken(String qrToken) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('User not authenticated.');
    }

    try {
      // O endpoint é /api/agendamentos/qr/{qrToken}
      final response = await _dio.get(
        '$_baseUrl/qr/$qrToken',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      if (response.statusCode == 200) {
        return AgendamentoResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch appointment by QR token: ${response.data}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // Erros 4xx, como 404 (Not Found), serão tratados aqui
        throw Exception('QR Token lookup error: ${e.response?.data['message'] ?? e.response?.statusCode}');
      } else {
        throw Exception('QR Token lookup error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error during QR token lookup: $e');
    }
  }
}