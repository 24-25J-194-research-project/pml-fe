import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

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
        _nameController.text = data['name'] ?? '';
        _locationController.text = data['location'] ?? '';
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
        "name": _nameController.text,
        "location": _locationController.text,
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
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Manage User Profile",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            // ✅ User Details Section
            Text(
              "Your details",
              style: GoogleFonts.bebasNeue(fontSize: 24, color: Colors.black87),
            ),
            Container(
              padding: EdgeInsets.all(12),

              child: Column(
                children: [
                  SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ Lottie Animation on the Left Side
                      Lottie.asset(
                        'assets/animations/profile.json',
                        // height: 140,
                        width: 120,
                      ),
                      SizedBox(width: 12),

                      // ✅ Name and Home Location Fields on the Right Side
                      Expanded(
                        child: Column(
                          children: [
                            TextField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: "Name",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                            TextField(
                              controller: _locationController,
                              decoration: InputDecoration(
                                labelText: "Home Location",
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
                ],
              ),
            ),
            SizedBox(height: 20),
            // ✅ Health Conditions Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "perosnal health",
                  style: GoogleFonts.bebasNeue(
                    fontSize: 24,
                    color: Colors.black87,
                  ),
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
              "emergency contact details",
              style: GoogleFonts.bebasNeue(fontSize: 24, color: Colors.black87),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Lottie.asset(
                  'assets/animations/family.json', // Placeholder animation
                  height: 180,
                  width: 120,
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
                  "save profile details",
                  style: GoogleFonts.bebasNeue(
                    fontSize: 24,
                    color: Colors.white,
                  ),
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
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔹 Title
                  Text(
                    "Add Health Condition",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),

                  // 🔹 Lottie Animation
                  Lottie.asset(
                    'assets/animations/health.json',
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 16),

                  // 🔹 Text Field
                  TextField(
                    controller: _healthConditionController,
                    decoration: InputDecoration(
                      hintText: "Enter health condition",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // 🔹 Add Button
                  ElevatedButton(
                    onPressed: () {
                      _addHealthCondition();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Add",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
