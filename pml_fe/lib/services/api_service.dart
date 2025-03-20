import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      "http://192.168.1.5:3000/cooking-assistant"; // Change to backend URL

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
  static Future<String> interactWithAssistant(
    String username,
    String message,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/interact-cooking"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "userMessage": message}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["reply"];
    } else {
      throw Exception("Failed to interact with assistant.");
    }
  }

  static Future<Map<String, dynamic>> getConversationHistory(
    String username,
  ) async {
    final response = await http.get(
      Uri.parse("$baseUrl/get-conversation-history?username=$username"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load conversation history");
    }
  }

  static Future<Map<String, dynamic>> createRecipe(
    String username,
    String recipeName,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/create-recipe"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "recipeName": recipeName}),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create recipe");
    }
  }

  // Get list of recipes
  static Future<List<dynamic>> getRecipes(String username) async {
    final response = await http.get(
      Uri.parse("$baseUrl/get-recipes?username=$username"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to get recipes");
    }
  }

  // Delete a recipe
  static Future<void> deleteRecipe(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/delete-recipe/$id"));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete recipe");
    }
  }

  // companion services
  // ✅ Create Virtual Companion
  static Future<Map<String, dynamic>> createCompanion(String username) async {
    final response = await http.post(
      Uri.parse("$baseUrl/create-companion"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create companion.");
    }
  }

  // ✅ Send Message to Virtual Companion
  static Future<String> interactWithCompanion(
    String username,
    String message,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/interact-companion"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "userMessage": message}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["reply"];
    } else {
      throw Exception("Failed to interact with companion.");
    }
  }

  // ✅ Get Conversation History (Companion)
  static Future<Map<String, dynamic>> getCompanionHistory(
    String username,
  ) async {
    final response = await http.get(
      Uri.parse("$baseUrl/companion-history?username=$username"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load companion conversation history");
    }
  }
}
