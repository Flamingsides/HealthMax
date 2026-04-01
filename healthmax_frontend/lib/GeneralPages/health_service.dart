import 'dart:io'; // Needed to check if we are on Android
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart'; // The Gatekeeper!

class HealthService {
  final Health _health = Health();

  HealthDataType? _mapMetric(String metric) {
    switch (metric) {
      case 'Heart Rate': return HealthDataType.HEART_RATE;
      case 'Steps': return HealthDataType.STEPS;
      case 'Calories': return HealthDataType.ACTIVE_ENERGY_BURNED;
      case 'Blood Glucose': return HealthDataType.BLOOD_GLUCOSE;
      default: return null;
    }
  }

  // --- NEW: Bulletproof Permission Request ---
  Future<bool> _requestPermissions(HealthDataType type) async {
    try {
      if (Platform.isAndroid) {
        // 1. Android requires basic physical activity tracking enabled first
        var activityStatus = await Permission.activityRecognition.request();
        print("Gatekeeper (Activity Recognition) Status: $activityStatus");
        
        // (The configure line was removed here because Health Connect is now default!)
      }

      // 2. Ask Health Connect / Apple Health for specific data
      bool authorized = await _health.requestAuthorization(
        [type], 
        permissions: [HealthDataAccess.READ]
      );
      print("Health API Authorized: $authorized");
      return authorized;
      
    } catch (e) {
      print("Permission Check Error: $e");
      return false;
    }
  }

  Future<double> fetchTodayAggregate(String metric) async {
    final type = _mapMetric(metric);
    if (type == null) return 0.0;

    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    
    try {
      bool authorized = await _requestPermissions(type);
      if (!authorized) return 0.0;

      if (type == HealthDataType.STEPS) {
        int? steps = await _health.getTotalStepsInInterval(midnight, now);
        return (steps ?? 0).toDouble();
      } else {
         List<HealthDataPoint> points = await _health.getHealthDataFromTypes(types: [type], startTime: midnight, endTime: now);
         if (points.isEmpty) return 0.0;

         double sum = 0;
         for (var p in points) sum += double.tryParse(p.value.toString()) ?? 0.0;

         if (type == HealthDataType.ACTIVE_ENERGY_BURNED) return sum;
         return sum / points.length;
      }
    } catch (e) {
      print("Health API Error: $e");
      return 0.0;
    }
  }

  Future<List<double>> fetchHourlyData(String metric) async {
    List<double> hourlyData = List.filled(24, 0.0);
    final type = _mapMetric(metric);
    if (type == null) return hourlyData;

    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    try {
      bool authorized = await _requestPermissions(type);
      if (!authorized) return hourlyData;

      List<HealthDataPoint> points = await _health.getHealthDataFromTypes(types: [type], startTime: midnight, endTime: now);

      if (type == HealthDataType.STEPS || type == HealthDataType.ACTIVE_ENERGY_BURNED) {
        for (var point in points) {
          int hour = point.dateFrom.hour;
          hourlyData[hour] += double.tryParse(point.value.toString()) ?? 0.0;
        }
      } else {
        List<int> counts = List.filled(24, 0);
        for (var point in points) {
          int hour = point.dateFrom.hour;
          hourlyData[hour] += double.tryParse(point.value.toString()) ?? 0.0;
          counts[hour]++;
        }
        for (int i = 0; i < 24; i++) {
          if (counts[i] > 0) hourlyData[i] /= counts[i];
        }
      }
    } catch (e) {
      print("Health API Error: $e");
    }
    return hourlyData;
  }
}