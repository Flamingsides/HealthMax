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

  // ========================================================
  // REAL DATABASE FETCH (Triggered by AuthGate)
  // ========================================================
  Future<void> fetchHealthData() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final today = DateTime.now().toIso8601String().split('T')[0];
    try {
      final metrics = await supabase.from('health_metrics').select()
          .eq('user_id', user.id)
          .eq('date', today);

      if (metrics.isEmpty) {
         // NEW USER: No data for today. Ensure everything is 0.
         isConnected = false;
         heartRate = 0; bloodGlucose = 0; envNoise = 0; currentSteps = 0;
         heartRateStatusKey = "no_data"; bloodGlucoseStatusKey = "no_data"; envNoiseStatusKey = "no_data";
      } else {
         isConnected = true;
         lastUpdatedKey = "just_now";
         
         for (var m in metrics) {
            String type = m['metric_type'];
            // Handles both JSON arrays or direct integers based on your schema
            int val = (m['data_points'] is List) ? (m['data_points'] as List).last : (int.tryParse(m['data_points'].toString()) ?? 0);
            
            if (type == 'Heart Rate') { heartRate = val; heartRateStatusKey = "status_normal"; }
            if (type == 'Steps') currentSteps = val;
            if (type == 'Blood Glucose') { bloodGlucose = val; bloodGlucoseStatusKey = "status_normal"; }
            if (type == 'Env. Noise') { envNoise = val; envNoiseStatusKey = "status_quiet"; }
         }
      }
      notifyListeners();
    } catch (e) {
      print("Error fetching health metrics: $e");
    }
  }

  void disconnectAll() {
    isConnected = false;
    heartRate = 0; bloodGlucose = 0; envNoise = 0; currentSteps = 0;
    heartRateStatusKey = "no_data"; bloodGlucoseStatusKey = "no_data"; envNoiseStatusKey = "no_data"; lastUpdatedKey = "never";
    notifyListeners();
  }
}