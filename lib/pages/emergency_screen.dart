import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/emergency_viewmodel.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EmergencyViewModel>();
    final hasEmergency = viewModel.emergencyTriggeredAt != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
        title: const Text(
          'Emergency',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency Status Card
            Card(
              color: hasEmergency ? Colors.red.shade50 : Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          hasEmergency ? Icons.warning : Icons.check_circle,
                          color: hasEmergency ? Colors.red : Colors.green,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          hasEmergency ? 'Emergency Active' : 'No Active Emergency',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: hasEmergency ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                    if (hasEmergency) ...[
                      const SizedBox(height: 16),
                      _buildEmergencyInfoRow(
                        'Emergency Triggered',
                        DateFormat('MMM dd, yyyy HH:mm').format(viewModel.emergencyTriggeredAt!),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        viewModel.emergencyMessage ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Safety Mode Controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Safety Mode',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Switch(
                          value: viewModel.isActive,
                          onChanged: (_) => viewModel.toggleSafetyMode(),
                        ),
                      ],
                    ),
                    if (viewModel.isActive) ...[
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: viewModel.checkIn,
                        child: const Text('Check In'),
                      ),
                      const SizedBox(height: 8),
                      _buildEmergencyInfoRow(
                        'Last Check-in',
                        viewModel.lastCheckIn != null
                            ? DateFormat('MMM dd, yyyy HH:mm').format(viewModel.lastCheckIn!)
                            : 'Not checked in yet',
                      ),
                      const SizedBox(height: 4),
                      _buildEmergencyInfoRow(
                        'Check-in Interval',
                        '${viewModel.checkInIntervalSeconds} seconds',
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
} 