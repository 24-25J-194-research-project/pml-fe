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

  final TextEditingController _emergencyContactNameController =
      TextEditingController();
  final TextEditingController _emergencyContactEmailController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // ✅ Load profile data from backend
  void _loadProfileData() async {
    final response = await http.get(
      Uri.parse(
        'http://10.0.2.2:3000/cooking-assistant/user/health-conditions?username=user1',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _healthConditionsController.text = data['healthConditions'] ?? '';
        _emergencyContactNameController.text =
            data['emergencyContactName'] ?? '';
        _emergencyContactEmailController.text =
            data['emergencyContactEmail'] ?? '';
      });
    }
  }

  // ✅ Save data to backend
  void _saveProfileData() async {
    final response = await http.post(
      Uri.parse(
        'http://10.0.2.2:3000/cooking-assistant/user/update-health-conditions',
      ),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": "user1",
        "healthConditions": _healthConditionsController.text,
        "emergencyContactName": _emergencyContactNameController.text,
        "emergencyContactEmail": _emergencyContactEmailController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Profile updated successfully!")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update profile")));
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
            TextField(controller: _healthConditionsController),

            SizedBox(height: 20),

            Text("Emergency Contact Name", style: TextStyle(fontSize: 18)),
            TextField(controller: _emergencyContactNameController),

            SizedBox(height: 20),

            Text("Emergency Contact Email", style: TextStyle(fontSize: 18)),
            TextField(controller: _emergencyContactEmailController),

            SizedBox(height: 20),
            ElevatedButton(onPressed: _saveProfileData, child: Text("Save")),
          ],
        ),
      ),
    );
  }
}
