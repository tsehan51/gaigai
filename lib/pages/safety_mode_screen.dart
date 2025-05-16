import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/emergency_viewmodel.dart';
import 'dart:async';

class SafetyModeScreen extends StatefulWidget {
  const SafetyModeScreen({super.key});

  @override
  State<SafetyModeScreen> createState() => _SafetyModeScreenState();
}

class _SafetyModeScreenState extends State<SafetyModeScreen> {
  Timer? _countdownTimer;
  String _countdownText = '';

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final viewModel = context.read<EmergencyViewModel>();

      if (!viewModel.isActive || viewModel.lastCheckIn == null) {
        setState(() {
          _countdownText = '';
        });
        return;
      }

      final nextCheckIn = viewModel.lastCheckIn!.add(
        Duration(seconds: viewModel.checkInIntervalSeconds),
      );
      final now = DateTime.now();
      final remaining = nextCheckIn.difference(now).inSeconds;

      setState(() {
        if (remaining <= 0) {
          _countdownText = 'Overdue!';
        } else {
          _countdownText = '$remaining seconds remaining';
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EmergencyViewModel>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Safety Mode',
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
            // Safety Mode Toggle Card
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Switch(
                          value: viewModel.isActive,
                          onChanged: (_) {
                            viewModel.toggleSafetyMode();
                            if (viewModel.isActive) {
                              _startCountdown();
                            }
                          },
                        ),
                      ],
                    ),
                    if (viewModel.isActive) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Safety mode is active. Please check in regularly to confirm your safety.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Check-in Interval Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Check-in Interval',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: viewModel.checkInIntervalSeconds.toDouble(),
                            min: 5,
                            max: 300,
                            divisions: 59,
                            label: '${viewModel.checkInIntervalSeconds} seconds',
                            onChanged: (value) {
                              viewModel.setCheckInInterval(value.toInt());
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${viewModel.checkInIntervalSeconds}s',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Check-in Card
            if (viewModel.isActive)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Check-in Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          viewModel.checkIn();
                          _startCountdown();
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          'Check In Now',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        'Last Check-in',
                        viewModel.lastCheckIn != null
                            ? DateFormat('MMM dd, yyyy HH:mm:ss').format(viewModel.lastCheckIn!)
                            : 'Not checked in yet',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Check-in Interval',
                        '${viewModel.checkInIntervalSeconds} seconds',
                      ),
                      if (viewModel.lastCheckIn != null) ...[
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Next Check-in Due',
                          _countdownText,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Emergency Status Card
            if (viewModel.emergencyTriggeredAt != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.red),
                          const SizedBox(width: 8),
                          const Text(
                            'Emergency Alert',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        viewModel.emergencyMessage ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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