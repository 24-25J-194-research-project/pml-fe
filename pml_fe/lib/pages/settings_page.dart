import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _historyMode = false;
  bool _healthConsiderations = false;
  bool _timers = false;
  bool _guardianAlert = false;

  @override
  void initState() {
    super.initState();
    _loadSettings(); // Load settings from SharedPreferences when page loads
  }

  // Load settings from SharedPreferences
  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _historyMode = prefs.getBool('historyMode') ?? false;
      _healthConsiderations = prefs.getBool('healthConsiderations') ?? false;
      _timers = prefs.getBool('timers') ?? false;
      _guardianAlert = prefs.getBool('guardianAlert') ?? false;
    });
  }

  // Save settings to SharedPreferences
  void _saveSettings(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    setState(() {
      if (key == 'historyMode') _historyMode = value;
      if (key == 'healthConsiderations') _healthConsiderations = value;
      if (key == 'timers') _timers = value;
      if (key == 'guardianAlert') _guardianAlert = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          // ✅ History Mode Switch
          SwitchListTile(
            title: Text("History Mode"),
            subtitle: Text("Show full conversation like a chat"),
            value: _historyMode,
            onChanged: (value) {
              _saveSettings('historyMode', value);
            },
          ),
          // ✅ Health Considerations Switch
          SwitchListTile(
            title: Text("Health Considerations"),
            subtitle: Text("Enable health recommendations"),
            value: _healthConsiderations,
            onChanged: (value) {
              _saveSettings('healthConsiderations', value);
            },
          ),
          // ✅ Timers Switch
          SwitchListTile(
            title: Text("Timers"),
            subtitle: Text("Enable cooking timers"),
            value: _timers,
            onChanged: (value) {
              _saveSettings('timers', value);
            },
          ),
          // ✅ Guardian Alert Switch
          SwitchListTile(
            title: Text("Guardian Alert"),
            subtitle: Text("Enable alerts for guardians"),
            value: _guardianAlert,
            onChanged: (value) {
              _saveSettings('guardianAlert', value);
            },
          ),
        ],
      ),
    );
  }
}
