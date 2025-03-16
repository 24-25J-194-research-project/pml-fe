import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _emergencyContactNameController =
      TextEditingController();
  final TextEditingController _emergencyContactEmailController =
      TextEditingController();
  List<String> _healthConditions = [];
  final TextEditingController _healthConditionController =
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
        _healthConditions =
            (data['healthConditions'] as String?)?.split(',') ?? [];
        _emergencyContactNameController.text =
            data['emergencyContactName'] ?? '';
        _emergencyContactEmailController.text =
            data['emergencyContactEmail'] ?? '';
      });
    }
  }

  // ✅ Save profile data to backend
  void _saveProfileData() async {
    final response = await http.post(
      Uri.parse(
        'http://10.0.2.2:3000/cooking-assistant/user/update-health-conditions',
      ),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": "user1",
        "healthConditions": _healthConditions.join(','),
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

  // ✅ Add health condition
  void _addHealthCondition() {
    String condition = _healthConditionController.text.trim();
    if (condition.isNotEmpty && !_healthConditions.contains(condition)) {
      setState(() {
        _healthConditions.add(condition);
        _healthConditionController.clear();
      });
    }
  }

  // ✅ Remove health condition
  void _removeHealthCondition(int index) {
    setState(() {
      _healthConditions.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ User Details Section
            Center(
              child: Column(
                children: [
                  // Text(
                  //   "User Details",
                  //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  // ),
                  SizedBox(height: 8),
                  Lottie.asset(
                    'assets/animations/cooking.json', // Placeholder animation
                    height: 100,
                    width: 100,
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
            SizedBox(height: 40),
            // ✅ Health Conditions Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Health Conditions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline, size: 28),
                  onPressed: () => _showAddHealthConditionDialog(),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _healthConditions.map((condition) {
                    return Chip(
                      label: Text(condition),
                      deleteIcon: Icon(Icons.close, size: 18),
                      onDeleted:
                          () => _removeHealthCondition(
                            _healthConditions.indexOf(condition),
                          ),
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  }).toList(),
            ),

            SizedBox(height: 40),

            // ✅ Emergency Contact Section
            Text(
              "Emergency Contact",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Lottie.asset(
                  'assets/animations/cooking.json', // Placeholder animation
                  height: 100,
                  width: 100,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      TextField(
                        controller: _emergencyContactNameController,
                        decoration: InputDecoration(
                          labelText: "Name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: _emergencyContactEmailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 50),

            // ✅ Save Button
            ElevatedButton(
              onPressed: _saveProfileData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Center(
                child: Text(
                  "Save Details",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Dialog for adding health condition
  Future<void> _showAddHealthConditionDialog() async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Add Health Condition"),
            content: TextField(
              controller: _healthConditionController,
              decoration: InputDecoration(hintText: "Enter health condition"),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _addHealthCondition();
                  Navigator.of(context).pop();
                },
                child: Text("Add"),
              ),
            ],
          ),
    );
  }
}
