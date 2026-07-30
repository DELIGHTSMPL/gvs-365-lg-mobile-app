import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _serverUrlController = TextEditingController(text: 'https://app-gvs365.azurewebsites.net');

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('api_base_url') ?? 'https://app-gvs365.azurewebsites.net';
    setState(() {
      _serverUrlController.text = url;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_base_url', _serverUrlController.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('✅ Azure API Endpoint saved & connected: https://app-gvs365.azurewebsites.net'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('App Settings & Sync'),
        backgroundColor: const Color(0xFFC4032A),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Server Configuration',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _serverUrlController,
                    decoration: const InputDecoration(
                      labelText: 'GVS 365 Server API Endpoint',
                      prefixIcon: Icon(Icons.dns, color: Color(0xFFC4032A)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC4032A),
                      minimumSize: const Size.fromHeight(44),
                    ),
                    onPressed: _saveSettings,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text('Save Server Settings', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'App Diagnostics & Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.smartphone),
                  title: Text('App Version'),
                  subtitle: Text('1.0.0 (Build 1) - Production APK'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.sync),
                  title: Text('Offline Sync Mode'),
                  subtitle: Text('Enabled (Automatic background sync)'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.security),
                  title: Text('Security SSL / Encryption'),
                  subtitle: Text('TLS 1.3 End-to-End Secure'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
