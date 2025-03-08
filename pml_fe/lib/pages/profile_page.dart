import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _healthConditionsController =
      TextEditingController();
  String _healthConditions = '';

  @override
  void initState() {
    super.initState();
    _loadHealthConditions();
  }

  // Load health conditions from backend
  void _loadHealthConditions() async {
    final response = await http.get(
      Uri.parse(
        'http://10.0.2.2:3000/cooking-assistant/user/health-conditions?username=user1',
      ),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _healthConditions = data['healthConditions'] ?? '';
        _healthConditionsController.text = _healthConditions;
      });
    }
  }

  // Save health conditions to MongoDB
  void _saveHealthConditions() async {
    final response = await http.post(
      Uri.parse(
        'http://10.0.2.2:3000/cooking-assistant/user/update-health-conditions',
      ),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": "user1",
        "healthConditions": _healthConditionsController.text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _healthConditions = _healthConditionsController.text;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Health Conditions Saved")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to save")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Health Conditions", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            TextField(
              controller: _healthConditionsController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "E.g., Diabetes, High BP, Lactose Intolerance",
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveHealthConditions,
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
