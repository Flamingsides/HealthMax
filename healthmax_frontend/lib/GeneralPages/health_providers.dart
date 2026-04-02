import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HealthProvider extends ChangeNotifier {
  int heartRate = 0; String heartRateStatusKey = "no_data";
  int bloodGlucose = 0; String bloodGlucoseStatusKey = "no_data";
  int envNoise = 0; String envNoiseStatusKey = "no_data";
  int currentSteps = 0; int targetSteps = 10000;
  String lastUpdatedKey = "never";
  
  bool isConnected = false;
  bool get hasDeviceConnected => isConnected;

  // --- NEW: Tracks exactly WHICH metrics the user permitted ---
  Set<String> activeMetrics = {};

  Timer? _liveDataTimer;
  Timer? _stepsTimer;
  final Random _random = Random();

  Future<void> checkDeviceAndStartMock() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from('user_devices')
          .select('is_active, permissions_granted')
          .eq('user_id', user.id);

      bool hasActiveDevice = false;
      activeMetrics.clear(); // Reset metrics

      // Loop through all devices and collect the permitted metrics
      for (var device in response) {
        if (device['is_active'] == true) {
          hasActiveDevice = true;
          List<dynamic> perms = device['permissions_granted'] ?? [];
          for (var p in perms) {
            activeMetrics.add(p.toString());
          }
        }
      }

      if (hasActiveDevice) {
        if (!isConnected) {
          isConnected = true;
          _startMockDataEngine();
        } else {
          notifyListeners(); 
        }
      } else {
        disconnectAll();
      }
    } catch (e) {
      print("Error checking devices: $e");
    }
  }

  void _startMockDataEngine() {
    _liveDataTimer?.cancel();
    _stepsTimer?.cancel();

    heartRate = 72; bloodGlucose = 95; envNoise = 45; currentSteps = 4320;
    heartRateStatusKey = "status_normal"; bloodGlucoseStatusKey = "status_normal"; 
    envNoiseStatusKey = "status_quiet"; lastUpdatedKey = "live_syncing";
    notifyListeners();

    _liveDataTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      heartRate = 70 + _random.nextInt(15);
      envNoise = 40 + _random.nextInt(25);
      notifyListeners();
    });

    _stepsTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      currentSteps += _random.nextInt(5);
      notifyListeners();
    });
  }

  void disconnectAll() {
    isConnected = false;
    activeMetrics.clear(); // Clear all permissions
    _liveDataTimer?.cancel();
    _stepsTimer?.cancel();
    
    heartRate = 0; bloodGlucose = 0; envNoise = 0; currentSteps = 0;
    heartRateStatusKey = "no_data"; bloodGlucoseStatusKey = "no_data"; 
    envNoiseStatusKey = "no_data"; lastUpdatedKey = "never";
    notifyListeners();
  }

  @override
  void dispose() {
    _liveDataTimer?.cancel();
    _stepsTimer?.cancel();
    super.dispose();
  }
}