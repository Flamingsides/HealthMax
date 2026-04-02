import 'package:flutter/material.dart';

class HealthProvider extends ChangeNotifier {
  // --- INITIAL ZERO STATE ---
  int heartRate = 0;
  int bloodGlucose = 0;
  int envNoise = 0;
  int currentSteps = 0;
  int targetSteps = 10000;
  
  String heartRateStatusKey = "no_data";
  String bloodGlucoseStatusKey = "no_data";
  String envNoiseStatusKey = "no_data";
  String lastUpdatedKey = "never";

  bool get hasDeviceConnected => currentSteps > 0 || heartRate > 0;

  // --- TRIGGERED WHEN A DEVICE IS CONNECTED ---
  void connectDevice() {
    heartRate = 72;
    bloodGlucose = 92;
    envNoise = 45;
    currentSteps = 8843;
    
    heartRateStatusKey = "normal";
    bloodGlucoseStatusKey = "optimal";
    envNoiseStatusKey = "safe";
    lastUpdatedKey = "just_now";
    
    notifyListeners();
  }

  void disconnectAll() {
    heartRate = 0; bloodGlucose = 0; envNoise = 0; currentSteps = 0;
    heartRateStatusKey = "no_data"; bloodGlucoseStatusKey = "no_data"; envNoiseStatusKey = "no_data"; lastUpdatedKey = "never";
    notifyListeners();
  }
}