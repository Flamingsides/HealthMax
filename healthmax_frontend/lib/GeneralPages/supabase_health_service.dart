import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseHealthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Random _random = Random();

  /// 1. PUSH TO SUPABASE
  /// This simulates gathering data and saving it to the cloud DB
  Future<bool> generateAndPushData(String metric) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // Create a date string for today (e.g., "2024-04-01")
      final todayStr = DateTime.now().toIso8601String().split('T')[0];

      // Generate realistic mock data for all 24 hours
      Map<String, dynamic> jsonData = {};
      for (int i = 0; i < 24; i++) {
        String hourKey = i.toString().padLeft(2, '0') + ":00";
        
        if (metric == 'Steps') jsonData[hourKey] = (_random.nextDouble() * 1500).toInt();
        else if (metric == 'Calories') jsonData[hourKey] = (_random.nextDouble() * 150).toInt();
        else if (metric == 'Heart Rate') jsonData[hourKey] = 60 + (_random.nextDouble() * 40).toInt();
        else if (metric == 'Blood Glucose') jsonData[hourKey] = 80 + (_random.nextDouble() * 40).toInt();
        else jsonData[hourKey] = 40 + (_random.nextDouble() * 30).toInt();
      }

      // Check if a row already exists for today's metric
      final existingData = await _supabase
          .from('health_metrics')
          .select()
          .eq('user_id', user.id)
          .eq('metric_type', metric)
          .eq('date', todayStr)
          .maybeSingle();

      if (existingData == null) {
        // Insert new row
        await _supabase.from('health_metrics').insert({
          'user_id': user.id,
          'metric_type': metric,
          'date': todayStr,
          'data_points': jsonData,
        });
      } else {
        // Update existing row
        await _supabase.from('health_metrics').update({
          'data_points': jsonData,
        }).eq('id', existingData['id']);
      }

      return true;
    } catch (e) {
      print("Supabase Push Error: $e");
      return false;
    }
  }

  /// 2. PULL FROM SUPABASE
  /// This fetches the JSON from the cloud and turns it into a 24-item list for the graph
  Future<List<double>?> fetchDataFromCloud(String metric) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final todayStr = DateTime.now().toIso8601String().split('T')[0];

      final response = await _supabase
          .from('health_metrics')
          .select('data_points')
          .eq('user_id', user.id)
          .eq('metric_type', metric)
          .eq('date', todayStr)
          .maybeSingle();

      if (response == null || response['data_points'] == null) {
        return null; // No data exists for today in the cloud yet
      }

      Map<String, dynamic> jsonMap = response['data_points'];
      List<double> hourlyData = List.filled(24, 0.0);

      // Map the JSON dictionary back to the 24-hour array index
      for (int i = 0; i < 24; i++) {
        String hourKey = i.toString().padLeft(2, '0') + ":00";
        if (jsonMap.containsKey(hourKey)) {
          hourlyData[i] = (jsonMap[hourKey] as num).toDouble();
        }
      }

      return hourlyData;
    } catch (e) {
      print("Supabase Pull Error: $e");
      return null;
    }
  }
}