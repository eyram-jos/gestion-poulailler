import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  static const String backendBaseUrl =
      'https://gestion-poulailler.onrender.com';

  static Future<String?> createPayment(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$backendBaseUrl/create-payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
        }),
      );

      print('PAYMENT STATUS: ${response.statusCode}');
      print('PAYMENT BODY: ${response.body}');

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);

      if (data['success'] == true && data['url'] != null) {
        return data['url'].toString();
      }

      return null;
    } catch (e) {
      print('ERROR PAYMENT: $e');
      return null;
    }
  }
}