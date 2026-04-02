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
  IconData placeholderIcon;
  Color iconColor;
  DateTime timestamp;

  CalorieRecord(
    this.foodName, this.quantity, this.protein, this.carbs, this.fats, this.calories,
    this.placeholderIcon, this.iconColor, this.timestamp, {
    this.notes, String? confidence, r,
  }) : confidence = _parseConfidence(confidence);

  static double? _parseConfidence(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString().replaceAll('%', '').trim());
  }

  // --- CONNECTED TO DB COLUMNS ---
  CalorieRecord.fromMap(Map<String, dynamic> map)
    : foodName = map['food_name'] ?? '',
      quantity = map['quantity'] ?? 1,
      protein = map['proteins']?.toString() ?? '0', // Uses 'proteins' from DB
      carbs = map['carbohydrates']?.toString() ?? '0',
      fats = map['fats']?.toString() ?? '0',
      calories = map['calories'] ?? 0,
      notes = map['notes'],
      confidence = _parseConfidence(map['confidence']),
      placeholderIcon = _icons[_random.nextInt(_icons.length)],
      iconColor = Color.fromARGB(255, _random.nextInt(256), _random.nextInt(256), _random.nextInt(256)),
      timestamp = map['logged_at'] != null ? DateTime.parse(map['logged_at']) : DateTime.now();
}

class CalorieProvider extends ChangeNotifier {
  List<CalorieRecord> _calorieHistory = [];
  List<CalorieRecord> get calorieHistory => _calorieHistory;

  // Total stats pulled from user_food_stats table
  int _totalEaten = 0;
  double _totalCarbs = 0.0;
  double _totalProtein = 0.0;
  double _totalFats = 0.0;

  int get totalEaten => _totalEaten;
  double get totalCarbs => _totalCarbs;
  double get totalProtein => _totalProtein;
  double get totalFats => _totalFats;

  // Dynamic Targets
  int targetCalories = 2000; 
  int targetCarbs = 250;
  int targetProtein = 100;
  int targetFats = 60;

  int currentSteps = 0;
  int workoutCalories = 0;

  int get burnedCalories => (currentSteps * 0.04).toInt() + workoutCalories;
  int get leftCalories => targetCalories - totalEaten + burnedCalories;

  // ========================================================
  // REAL DATABASE FETCH 
  // ========================================================
  Future<void> fetchUserDataAndLogs() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      // 1. CALCULATE TARGETS (BMR)
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

        double bmr = (10 * weight) + (6.25 * height) - (5 * age);
        bmr += (gender.toLowerCase() == 'male') ? 5 : -161;
        double tdee = bmr * 1.375;

        if (mainGoal == 'Lose Weight') tdee -= 500;
        else if (mainGoal == 'Build Muscle') tdee += 300;

        targetCalories = tdee.toInt();
        targetProtein = (weight * 2.2).toInt(); 
        targetFats = (tdee * 0.25 / 9).toInt(); 
        targetCarbs = ((tdee - (targetProtein * 4) - (targetFats * 9)) / 4).toInt();
      }

      // 2. FETCH TOTAL STATS FROM `user_food_stats`
      final statsData = await supabase.from('user_food_stats').select().eq('user_id', user.id).maybeSingle();
      if (statsData != null) {
        _totalEaten = (statsData['total_calories'] ?? 0).toInt();
        _totalCarbs = (statsData['total_carbohydrates'] ?? 0).toDouble();
        _totalProtein = (statsData['total_proteins'] ?? 0).toDouble();
        _totalFats = (statsData['total_fats'] ?? 0).toDouble();
      } else {
        _totalEaten = 0; _totalCarbs = 0.0; _totalProtein = 0.0; _totalFats = 0.0;
      }

      // 3. FETCH ALL LOGS FROM `food_logs`
      final logs = await supabase.from('food_logs').select().eq('user_id', user.id).order('logged_at', ascending: false);
      _calorieHistory = logs.map((log) => CalorieRecord.fromMap(log)).toList();
      
      notifyListeners();
    } catch (e) {
      print("Error fetching calorie data: $e");
    }
  }

  void clear() {
    _calorieHistory.clear(); _totalEaten = 0; _totalCarbs = 0.0; _totalProtein = 0.0; _totalFats = 0.0;
    currentSteps = 0; workoutCalories = 0; notifyListeners();
  }

  // ========================================================
  // REAL DATABASE WRITE 
  // ========================================================
  Future<void> addFoodRecord(CalorieRecord newRecord) async {
    // 1. Instantly Update UI (Optimistic Update)
    _calorieHistory.insert(0, newRecord);
    _totalEaten += newRecord.calories;
    _totalCarbs += double.parse(newRecord.carbs.replaceAll('g', '').trim());
    _totalProtein += double.parse(newRecord.protein.replaceAll('g', '').trim());
    _totalFats += double.parse(newRecord.fats.replaceAll('g', '').trim());
    notifyListeners(); 

    // 2. Sync with Backend
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Insert into food_logs
      await supabase.from("food_logs").insert({
        "user_id": user.id,
        "food_name": newRecord.foodName,
        "quantity": newRecord.quantity,
        "calories": newRecord.calories,
        "notes": newRecord.notes,
        "confidence": newRecord.confidence,
        "fats": double.parse(newRecord.fats.replaceAll('g', '').trim()),
        "proteins": double.parse(newRecord.protein.replaceAll('g', '').trim()), // Matches DB 'proteins'
        "carbohydrates": double.parse(newRecord.carbs.replaceAll('g', '').trim()),
        "logged_at": newRecord.timestamp.toIso8601String(),
      });

      // Upsert into user_food_stats
      await supabase.from("user_food_stats").upsert({
        "user_id": user.id,
        "total_calories": _totalEaten,
        "total_proteins": _totalProtein,
        "total_fats": _totalFats,
        "total_carbohydrates": _totalCarbs,
      });

    } catch (e) {
      print("Error saving food log: $e");
    }
  }
}