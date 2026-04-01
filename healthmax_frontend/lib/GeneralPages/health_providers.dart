import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class HealthProvider extends ChangeNotifier {
  // Global Live Metrics
  int heartRate = 82;
  String heartRateStatusKey = "status_normal";
  
  int bloodGlucose = 90;
  String bloodGlucoseStatusKey = "status_normal";
  
  int envNoise = 45;
  String envNoiseStatusKey = "status_quiet";
  
  int currentSteps = 6789; 
  int targetSteps = 10000;
  
  String lastUpdatedKey = "live_syncing";

  Timer? _liveDataTimer;
  Timer? _stepsTimer;
  final Random _random = Random();

  HealthProvider() {
    _startLiveDataEngine();
  }

  void _startLiveDataEngine() {
    // 1. FAST TIMER: Updates Heart Rate & Noise every 3 seconds
    _liveDataTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      heartRate = 75 + _random.nextInt(15);
      envNoise = 40 + _random.nextInt(25);
      notifyListeners(); // Tells all pages to update instantly!
    });

    // 2. SLOW TIMER: Increases steps every 8 seconds
    _stepsTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      currentSteps += _random.nextInt(3);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _liveDataTimer?.cancel();
    _stepsTimer?.cancel();
    super.dispose();
  }
}