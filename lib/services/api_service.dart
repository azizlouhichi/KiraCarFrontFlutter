// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  final String? token;

  ApiService({this.token});

  Future<dynamic> _sendRequest({
    required String method,
    required String endpoint,
    dynamic data,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final defaultHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      http.Response response;
      switch (method) {
        case 'GET':
          response =
              await http.get(url, headers: {...defaultHeaders, ...?headers});
          break;
        case 'POST':
          response = await http.post(
            url,
            headers: {...defaultHeaders, ...?headers},
            body: json.encode(data),
          );
          break;
        case 'PUT':
          response = await http.put(
            url,
            headers: {...defaultHeaders, ...?headers},
            body: json.encode(data),
          );
          break;
        case 'PATCH':
          response = await http.patch(
            url,
            headers: {...defaultHeaders, ...?headers},
            body: json.encode(data),
          );
          break;
        case 'DELETE':
          response =
              await http.delete(url, headers: {...defaultHeaders, ...?headers});
          break;
        default:
          throw Exception('Unsupported HTTP method');
      }

      return _handleResponse(response);
    } catch (e) {
      throw Exception('API request failed: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = json.decode(utf8.decode(response.bodyBytes));

    if (statusCode >= 200 && statusCode < 300) {
      return responseBody;
    } else {
      throw Exception(
        'API request failed with status $statusCode: ${responseBody['detail'] ?? responseBody}',
      );
    }
  }

  // Authentication Endpoints
  Future<dynamic> signup(Map<String, dynamic> userData) async {
    return await _sendRequest(
      method: 'POST',
      endpoint: 'signup/',
      data: userData,
    );
  }

  Future<dynamic> login(String username, String password) async {
    return await _sendRequest(
      method: 'POST',
      endpoint: 'token/',
      data: {'username': username, 'password': password},
    );
  }

  Future<dynamic> refreshToken(String refreshToken) async {
    return await _sendRequest(
      method: 'POST',
      endpoint: 'token/refresh/',
      data: {'refresh': refreshToken},
    );
  }

  // User Endpoints
  Future<dynamic> getUsers() async {
    return await _sendRequest(method: 'GET', endpoint: 'utilisateurs/');
  }

  Future<dynamic> getUser(int id) async {
    return await _sendRequest(method: 'GET', endpoint: 'utilisateurs/$id/');
  }

  Future<dynamic> updateUser(int id, Map<String, dynamic> userData) async {
    return await _sendRequest(
      method: 'PUT',
      endpoint: 'utilisateurs/$id/',
      data: userData,
    );
  }

  Future<dynamic> partialUpdateUser(
      int id, Map<String, dynamic> userData) async {
    return await _sendRequest(
      method: 'PATCH',
      endpoint: 'utilisateurs/$id/',
      data: userData,
    );
  }

  Future<dynamic> deleteUser(int id) async {
    return await _sendRequest(method: 'DELETE', endpoint: 'utilisateurs/$id/');
  }

  // Car (Voiture) Endpoints
  Future<dynamic> getCars() async {
    return await _sendRequest(method: 'GET', endpoint: 'voitures/');
  }

  Future<dynamic> createCar(Map<String, dynamic> carData) async {
    return await _sendRequest(
      method: 'POST',
      endpoint: 'voitures/',
      data: carData,
    );
  }

  Future<dynamic> getCar(int id) async {
    return await _sendRequest(method: 'GET', endpoint: 'voitures/$id/');
  }

  Future<dynamic> updateCar(int id, Map<String, dynamic> carData) async {
    return await _sendRequest(
      method: 'PUT',
      endpoint: 'voitures/$id/',
      data: carData,
    );
  }

  Future<dynamic> partialUpdateCar(int id, Map<String, dynamic> carData) async {
    return await _sendRequest(
      method: 'PATCH',
      endpoint: 'voitures/$id/',
      data: carData,
    );
  }

  Future<dynamic> deleteCar(int id) async {
    return await _sendRequest(method: 'DELETE', endpoint: 'voitures/$id/');
  }

  // Reservation Endpoints
  Future<dynamic> getReservations() async {
    return await _sendRequest(method: 'GET', endpoint: 'reservations/');
  }

  Future<dynamic> getUserReservations() async {
    return await _sendRequest(
      method: 'GET',
      endpoint: 'reservations/mes_reservations/',
    );
  }

  Future<dynamic> createReservation(
      Map<String, dynamic> reservationData) async {
    return await _sendRequest(
      method: 'POST',
      endpoint: 'reservations/',
      data: reservationData,
    );
  }

  Future<dynamic> getReservation(int id) async {
    return await _sendRequest(method: 'GET', endpoint: 'reservations/$id/');
  }

  Future<dynamic> updateReservation(
      int id, Map<String, dynamic> reservationData) async {
    return await _sendRequest(
      method: 'PUT',
      endpoint: 'reservations/$id/',
      data: reservationData,
    );
  }

  Future<dynamic> partialUpdateReservation(
    int id,
    Map<String, dynamic> reservationData,
  ) async {
    return await _sendRequest(
      method: 'PATCH',
      endpoint: 'reservations/$id/',
      data: reservationData,
    );
  }

  Future<dynamic> deleteReservation(int id) async {
    return await _sendRequest(method: 'DELETE', endpoint: 'reservations/$id/');
  }

  Future<dynamic> cancelReservationByAgencyOrAdmin(int id) async {
    return await _sendRequest(
      method: 'POST',
      endpoint: 'reservations/$id/annuler_par_agence_ou_admin/',
    );
  }

  Future<dynamic> confirmReservation(int id) async {
    return await _sendRequest(
      method: 'POST',
      endpoint: 'reservations/$id/confirmer/',
    );
  }
}
