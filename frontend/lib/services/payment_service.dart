import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'api_config.dart';
import 'storage_service.dart';

class PaymentService {
  static dynamic _safeJsonDecode(http.Response response) {
    try {
      return jsonDecode(response.body);
    } catch (e) {
      if (kDebugMode) {
        print('[ERROR] Failed to parse response as JSON: ${e.toString()}');
      }
      throw FormatException('Invalid response from server: ${e.toString()}');
    }
  }

  // Get wallet balance
  static Future<Map<String, dynamic>> getWalletBalance() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return {'success': false, 'message': 'No auth token'};

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/payments/wallet'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      ).timeout(ApiConfig.connectionTimeout);

      final data = _safeJsonDecode(response);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Add funds to wallet
  static Future<Map<String, dynamic>> addFunds(double amount, String methodId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return {'success': false, 'message': 'No auth token'};

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/payments/wallet/add-funds'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'amount': amount, 'payment_method_id': methodId}),
      ).timeout(ApiConfig.connectionTimeout);

      final data = _safeJsonDecode(response);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Get payment methods
  static Future<Map<String, dynamic>> getPaymentMethods() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return {'success': false, 'message': 'No auth token'};

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/payments/methods'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      ).timeout(ApiConfig.connectionTimeout);

      final data = _safeJsonDecode(response);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Add mock payment method
  static Future<Map<String, dynamic>> addPaymentMethod(String cardToken, String last4, String brand) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return {'success': false, 'message': 'No auth token'};

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/payments/methods'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'cardToken': cardToken, 'last4': last4, 'brand': brand}),
      ).timeout(ApiConfig.connectionTimeout);

      final data = _safeJsonDecode(response);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}
