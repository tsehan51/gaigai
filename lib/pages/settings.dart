import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/emergency_viewmodel.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<Map<String, String>> _emergencyContacts = [];
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EmergencyViewModel>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Safety Mode Settings
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Safety Mode Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (viewModel.isActive) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Check-in Interval',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'How often you need to check in to confirm your safety',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: viewModel.checkInIntervalSeconds.toDouble(),
                                min: 5,
                                max: 300,
                                divisions: 59,
                                label: '${viewModel.checkInIntervalSeconds} seconds',
                                onChanged: (value) => viewModel.setCheckInInterval(value.toInt()),
                              ),
                            ),
                            Text('${viewModel.checkInIntervalSeconds}s'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Auto-Start Safety Mode'),
                    subtitle: const Text('Automatically start safety mode at scheduled times'),
                    value: viewModel.autoStartEnabled,
                    onChanged: (value) => viewModel.toggleAutoStart(value),
                  ),
                  SwitchListTile(
                    title: const Text('Emergency Alerts'),
                    subtitle: const Text('Notify emergency contacts if check-in is missed'),
                    value: viewModel.emergencyAlertsEnabled,
                    onChanged: (value) => viewModel.toggleEmergencyAlerts(value),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Emergency Contacts
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Emergency Contacts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'These contacts will be notified in case of emergency',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 8),
                ..._emergencyContacts.map((contact) => ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(contact['name'] ?? ''),
                  subtitle: Text(contact['phone'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _emergencyContacts.remove(contact);
                      });
                    },
                  ),
                )),
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.add),
                  ),
                  title: const Text('Add Emergency Contact'),
                  onTap: _showAddContactDialog,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Safety Preferences
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Safety Preferences',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Location Sharing'),
                  subtitle: const Text('Share your location with emergency contacts'),
                  value: viewModel.locationSharingEnabled,
                  onChanged: (value) => viewModel.toggleLocationSharing(value),
                ),
                SwitchListTile(
                  title: const Text('Travel Alerts'),
                  subtitle: const Text('Get alerts about safety in your travel destination'),
                  value: viewModel.travelAlertsEnabled,
                  onChanged: (value) => viewModel.toggleTravelAlerts(value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Emergency Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _nameController.clear();
              _phoneController.clear();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty &&
                  _phoneController.text.isNotEmpty) {
                setState(() {
                  _emergencyContacts.add({
                    'name': _nameController.text,
                    'phone': _phoneController.text,
                  });
                });
                Navigator.pop(context);
                _nameController.clear();
                _phoneController.clear();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
} 