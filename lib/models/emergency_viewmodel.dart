import 'package:flutter/material.dart';
import 'dart:async';

class EmergencyViewModel extends ChangeNotifier {
  bool _isActive = false;
  DateTime? _lastCheckIn;
  DateTime? _emergencyTriggeredAt;
  String? _emergencyMessage;
  int _checkInIntervalSeconds = 5; // Default to 5 seconds for testing
  Timer? _checkTimer;

  bool get isActive => _isActive;
  DateTime? get lastCheckIn => _lastCheckIn;
  DateTime? get emergencyTriggeredAt => _emergencyTriggeredAt;
  String? get emergencyMessage => _emergencyMessage;
  int get checkInIntervalSeconds => _checkInIntervalSeconds;

  void setCheckInInterval(int seconds) {
    if (seconds >= 5) { // Minimum 5 seconds
      _checkInIntervalSeconds = seconds;
      notifyListeners();
    }
  }

  void toggleSafetyMode() {
    _isActive = !_isActive;
    if (_isActive) {
      _lastCheckIn = DateTime.now();
      _startEmergencyCheck();
    } else {
      _lastCheckIn = null;
      _emergencyTriggeredAt = null;
      _emergencyMessage = null;
      _stopEmergencyCheck();
    }
    notifyListeners();
  }

  void _startEmergencyCheck() {
    _stopEmergencyCheck(); // Stop any existing timer
    _checkTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      checkEmergency();
    });
  }

  void _stopEmergencyCheck() {
    _checkTimer?.cancel();
    _checkTimer = null;
  }

  void checkIn() {
    if (_isActive) {
      _lastCheckIn = DateTime.now();
      _emergencyTriggeredAt = null;
      _emergencyMessage = null;
      notifyListeners();
    }
  }

  void checkEmergency() {
    if (_isActive && _lastCheckIn != null) {
      final now = DateTime.now();
      final difference = now.difference(_lastCheckIn!);
      if (difference.inSeconds >= _checkInIntervalSeconds) {
        _emergencyTriggeredAt = now;
        _emergencyMessage = "I have reported to police with your location: 123 Main St, City";
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _stopEmergencyCheck();
    super.dispose();
  }
} 