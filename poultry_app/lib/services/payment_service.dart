import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  static Future<String?> createPayment(String userId) async {
    try {
      final url = Uri.parse(
          "https://us-central1-poultry-pro.cloudfunctions.net/createPayment");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "amount": 2500,
          "userId": userId,
        }),
      );

      print("RESPONSE: ${response.body}");

      final data = jsonDecode(response.body);

      if (data["response_code"] == "00") {
        return data["response_text"]; // 🔥 URL paiement
      }

      return null;
    } catch (e) {
      print("ERROR PAYMENT: $e");
      return null;
    }
  }
}