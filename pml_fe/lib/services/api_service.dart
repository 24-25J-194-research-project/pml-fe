import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:3000/cooking-assistant"; // Change to backend URL

  // Create Assistant for User
  static Future<Map<String, dynamic>> createAssistant(String username) async {
    final response = await http.post(
      Uri.parse("$baseUrl/create"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create assistant.");
    }
  }

  // Send Message to Assistant
  static Future<String> interactWithAssistant(String username, String message) async {
    final response = await http.post(
      Uri.parse("$baseUrl/interact-cooking"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "userMessage": message,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["reply"];
    } else {
      throw Exception("Failed to interact with assistant.");
    }
  }
}
