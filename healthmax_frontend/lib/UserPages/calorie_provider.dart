import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CalorieRecord {
  static final _random = Random();
  static final _icons = [
    Icons.free_breakfast,
    Icons.breakfast_dining,
    Icons.lunch_dining,
    Icons.food_bank,
    Icons.dinner_dining,
  ];
  String foodName;
  int quantity;
  String protein;
  String carbs;
  String fats;
  int calories;
  String? notes;
  double? confidence;
 late IconData placeholderIcon;
 late Color iconColor;
  DateTime timestamp;

  // ========================================================
  // DETERMINISTIC GENERATORS (Always consistent based on name!)
  // ========================================================
  static IconData _getDeterministicIcon(String name) {
    final icons = [
      Icons.restaurant_rounded,
      Icons.local_pizza_rounded,
      Icons.fastfood_rounded,
      Icons.local_cafe_rounded,
      Icons.lunch_dining_rounded,
      Icons.dinner_dining_rounded,
      Icons.bakery_dining_rounded,
      Icons.icecream_rounded,
      Icons.set_meal_rounded,
      Icons.ramen_dining_rounded,
    ];
    int hash = name.trim().toLowerCase().hashCode.abs();
    return icons[hash % icons.length];
  }

  static Color _getDeterministicColor(String name) {
    final colors = [
      const Color(0xFF5A84F1), // Blue
      const Color(0xFFFF9F43), // Orange
      const Color(0xFF2ED573), // Green
      const Color(0xFFFF4757), // Red
      const Color(0xFF8E33FF), // Purple
      const Color(0xFF1DD1A1), // Mint
      const Color(0xFFFF7A00), // Deep Orange
      const Color(0xFF00A8FF), // Light Blue
    ];
    int hash = name.trim().toLowerCase().hashCode.abs();
    return colors[hash % colors.length];
  }

  CalorieRecord(
    this.foodName, this.quantity, this.protein, this.carbs, this.fats, this.calories,
    IconData ignoredIcon, Color ignoredColor, this.timestamp, {
    this.notes, String? confidence, r,
  }) : confidence = _parseConfidence(confidence) {
    placeholderIcon = _getDeterministicIcon(foodName);
    iconColor = _getDeterministicColor(foodName);
  }

  static double? _parseConfidence(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString().replaceAll('%', '').trim());
  }

  CalorieRecord.fromMap(Map<String, dynamic> map)
    : foodName = map['food_name'] ?? '',
      quantity = map['quantity'] ?? 1,
      protein = map['proteins']?.toString() ?? '0', 
      carbs = map['carbohydrates']?.toString() ?? '0',
      fats = map['fats']?.toString() ?? '0',
      calories = map['calories'] ?? 0,
      notes = map['notes'],
      confidence = _parseConfidence(map['confidence']),
      timestamp = map['logged_at'] != null ? DateTime.parse(map['logged_at']) : DateTime.now() {
        placeholderIcon = _getDeterministicIcon(foodName);
        iconColor = _getDeterministicColor(foodName);
      }
}

class CalorieProvider extends ChangeNotifier {
  List<CalorieRecord> _calorieHistory = [];
  List<CalorieRecord> get calorieHistory => _calorieHistory;

  int get totalEaten => _calorieHistory.fold(0, (sum, item) => sum + item.calories);
  
  double get totalCarbs => _calorieHistory.fold(0.0, (sum, item) => 
      sum + (double.tryParse(item.carbs.replaceAll('g', '').trim()) ?? 0.0));
      
  double get totalProtein => _calorieHistory.fold(0.0, (sum, item) => 
      sum + (double.tryParse(item.protein.replaceAll('g', '').trim()) ?? 0.0));
      
  double get totalFats => _calorieHistory.fold(0.0, (sum, item) => 
      sum + (double.tryParse(item.fats.replaceAll('g', '').trim()) ?? 0.0));

  int targetCalories = 2000; 
  int targetCarbs = 250;
  int targetProtein = 100;
  int targetFats = 60;

  int currentSteps = 0;
  int workoutCalories = 0; // Handled dynamically now!

  int get burnedCalories => (currentSteps * 0.04).toInt() + workoutCalories;
  int get leftCalories => targetCalories - totalEaten + burnedCalories;

  Future<void> fetchUserDataAndLogs() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final userData = await supabase.from('users').select().eq('id', user.id).maybeSingle();
      if (userData != null) {
        double weight = (userData['weight_kg'] ?? 70).toDouble();
        double height = (userData['height_cm'] ?? 170).toDouble();
        String gender = userData['gender'] ?? 'Male';
        String mainGoal = userData['main_goal'] ?? 'Maintain Weight';
        int age = 25; 
        if (userData['dob'] != null) {
           DateTime dob = DateTime.parse(userData['dob']);
           age = DateTime.now().year - dob.year;
        }

        double heightInMeters = height / 100;
        double bmi = weight / (heightInMeters * heightInMeters);

        double bmr = (10 * weight) + (6.25 * height) - (5 * age);
        bmr += (gender.toLowerCase() == 'male') ? 5 : -161;
        double tdee = bmr * 1.375;

        if (mainGoal == 'Lose Weight') {
          tdee -= 500;
        } else if (mainGoal == 'Build Muscle') {
          tdee += 300;
        } else if (mainGoal == 'N/A' || mainGoal == 'Maintain Weight') {
          if (bmi > 25.0) tdee -= 500; 
          else if (bmi < 18.5) tdee += 300; 
        }

        targetCalories = tdee.toInt();
        targetProtein = (weight * 2.2).toInt(); 
        targetFats = (tdee * 0.25 / 9).toInt(); 
        targetCarbs = ((tdee - (targetProtein * 4) - (targetFats * 9)) / 4).toInt();
      }

      final today = DateTime.now().toIso8601String().split('T')[0];
      final logs = await supabase.from('food_logs').select()
          .eq('user_id', user.id)
          .gte('logged_at', '${today}T00:00:00Z')
          .lte('logged_at', '${today}T23:59:59Z')
          .order('logged_at', ascending: false);
          
      _calorieHistory = logs.map((log) => CalorieRecord.fromMap(log)).toList();
      
      await _syncStatsToDatabase();
      await syncWorkoutCalories(); // Sync active targets

      notifyListeners();
    } catch (e) {
      print("Error fetching calorie data: $e");
    }
  }

  // --- NEW: FETCHES ACTIVE CALORIE TARGETS TO ADD TO BURNED ---
  Future<void> syncWorkoutCalories() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final targetsData = await supabase.from('user_targets').select('current_value, unit').eq('user_id', user.id);

      int totalWorkoutCals = 0;
      for (var t in targetsData) {
        String unit = (t['unit'] ?? '').toString().toLowerCase();
        if (unit.contains('kcal') || unit.contains('cal')) {
          totalWorkoutCals += (t['current_value'] as num?)?.toInt() ?? 0;
        }
      }

      workoutCalories = totalWorkoutCals;
      notifyListeners();
    } catch (e) {
      print("Error syncing workout calories: $e");
    }
  }

  void clear() {
    _calorieHistory.clear(); currentSteps = 0; workoutCalories = 0; notifyListeners();
  }

  Future<void> addFoodRecord(CalorieRecord newRecord) async {
    _calorieHistory.insert(0, newRecord);
    notifyListeners(); 

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("User not authenticated.");

      await supabase.from("food_logs").insert({
        "user_id": user.id,
        "food_name": newRecord.foodName,
        "quantity": newRecord.quantity,
        "calories": newRecord.calories,
        "notes": newRecord.notes,
        "confidence": newRecord.confidence,
        "fats": double.tryParse(newRecord.fats.replaceAll('g', '').trim()) ?? 0,
        "proteins": double.tryParse(newRecord.protein.replaceAll('g', '').trim()) ?? 0, 
        "carbohydrates": double.tryParse(newRecord.carbs.replaceAll('g', '').trim()) ?? 0,
        "logged_at": newRecord.timestamp.toIso8601String(),
      });

      await _syncStatsToDatabase();
    } catch (e) {
      _calorieHistory.remove(newRecord);
      notifyListeners();
      rethrow; 
    }
  }

  Future<void> _syncStatsToDatabase() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final existingStats = await supabase.from("user_food_stats").select().eq("user_id", user.id).maybeSingle();
      
      if (existingStats != null) {
        await supabase.from("user_food_stats").update({
          "total_calories": totalEaten,
          "total_proteins": totalProtein,
          "total_fats": totalFats,
          "total_carbohydrates": totalCarbs,
        }).eq("user_id", user.id);
      } else {
        await supabase.from("user_food_stats").insert({
          "user_id": user.id,
          "total_calories": totalEaten,
          "total_proteins": totalProtein,
          "total_fats": totalFats,
          "total_carbohydrates": totalCarbs,
        });
      }
    } catch(e) {
        print("Failed to sync stats: $e");
    }
  }
}