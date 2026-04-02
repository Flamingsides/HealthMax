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

  CalorieRecord.fromMap(Map<String, dynamic> map)
    : foodName = map['food_name'] ?? '',
      quantity = map['quantity'] ?? 1,
      protein = map['protein']?.toString() ?? '0',
      carbs = map['carbohydrates']?.toString() ?? '0',
      fats = map['fats']?.toString() ?? '0',
      calories = map['calories'] ?? 0,
      notes = map['notes'],
      confidence = _parseConfidence(map['confidence']),
      placeholderIcon = _icons[_random.nextInt(_icons.length)],
      iconColor = Color.fromARGB(255, _random.nextInt(256), _random.nextInt(256), _random.nextInt(256)),
      timestamp = map['logged_at'] != null ? DateTime.parse(map['logged_at']) : DateTime.now();

  void update({
    String? foodName, int? quantity, String? protein, String? carbs, String? fats,
    int? calories, String? notes, double? confidence, IconData? placeholderIcon, Color? iconColor, DateTime? timestamp,
  }) {
    if (foodName != null) this.foodName = foodName;
    if (quantity != null) this.quantity = quantity;
    if (protein != null) this.protein = protein;
    if (carbs != null) this.carbs = carbs;
    if (fats != null) this.fats = fats;
    if (calories != null) this.calories = calories;
    if (notes != null) this.notes = notes;
    if (confidence != null) this.confidence = _parseConfidence(confidence);
    if (placeholderIcon != null) this.placeholderIcon = placeholderIcon;
    if (iconColor != null) this.iconColor = iconColor;
    if (timestamp != null) this.timestamp = timestamp;
  }
}

class CalorieProvider extends ChangeNotifier {
  // --- STARTS EMPTY ---
  List<CalorieRecord> _calorieHistory = [];
  
  List<CalorieRecord> get calorieHistory => _calorieHistory;

  int targetCalories = 2000; 
  int targetCarbs = 250;
  int targetProtein = 100;
  int targetFats = 60;

  int currentSteps = 0;
  int workoutCalories = 0;

  int get burnedCalories => (currentSteps * 0.04).toInt() + workoutCalories;
  int get totalEaten => _calorieHistory.fold(0, (sum, item) => sum + item.calories);
  int get leftCalories => targetCalories - totalEaten + burnedCalories;

  double get totalCarbs => _calorieHistory.fold(0.0, (sum, item) => sum + double.parse(item.carbs.replaceAll('g', '').trim()));
  double get totalProtein => _calorieHistory.fold(0.0, (sum, item) => sum + double.parse(item.protein.replaceAll('g', '').trim()));
  double get totalFats => _calorieHistory.fold(0.0, (sum, item) => sum + double.parse(item.fats.replaceAll('g', '').trim()));

  // ========================================================
  // REAL DATABASE FETCH (Triggered by AuthGate)
  // ========================================================
  Future<void> fetchUserDataAndLogs() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      // 1. FETCH USER PROFILE FOR BMR CALCULATION
      final userData = await supabase.from('users').select().eq('id', user.id).maybeSingle();
      
      if (userData != null) {
        double weight = (userData['weight_kg'] ?? 70).toDouble();
        double height = (userData['height_cm'] ?? 170).toDouble();
        String gender = userData['gender'] ?? 'Male';
        String mainGoal = userData['main_goal'] ?? 'Maintain Weight';
        
        int age = 25; // Default fallback
        if (userData['dob'] != null) {
           DateTime dob = DateTime.parse(userData['dob']);
           age = DateTime.now().year - dob.year;
        }

        // Mifflin-St Jeor Equation for Base Metabolic Rate
        double bmr = (10 * weight) + (6.25 * height) - (5 * age);
        bmr += (gender.toLowerCase() == 'male') ? 5 : -161;

        // Total Daily Energy Expenditure (Assuming lightly active)
        double tdee = bmr * 1.375;

        // Adjust based on the user's specific goal from Supabase
        if (mainGoal == 'Lose Weight') tdee -= 500;
        else if (mainGoal == 'Build Muscle') tdee += 300;

        targetCalories = tdee.toInt();
        targetProtein = (weight * 2.2).toInt(); // High protein (2.2g per kg)
        targetFats = (tdee * 0.25 / 9).toInt(); // 25% of calories from fat
        targetCarbs = ((tdee - (targetProtein * 4) - (targetFats * 9)) / 4).toInt();
      }

      // 2. FETCH TODAY'S FOOD LOGS
      final today = DateTime.now().toIso8601String().split('T')[0];
      final logs = await supabase.from('food_logs').select()
          .eq('user_id', user.id)
          .gte('logged_at', '${today}T00:00:00Z')
          .lte('logged_at', '${today}T23:59:59Z')
          .order('logged_at', ascending: false);

      _calorieHistory = logs.map((log) => CalorieRecord.fromMap(log)).toList();
      notifyListeners();
    } catch (e) {
      print("Error fetching calorie data: $e");
    }
  }

  void clear() {
    _calorieHistory.clear(); currentSteps = 0; workoutCalories = 0; notifyListeners();
  }

  Future<void> addFoodRecord(CalorieRecord newRecord) async {
    _calorieHistory.insert(0, newRecord);
    notifyListeners(); // Instantly update UI

    try {
      final supabase = Supabase.instance.client;
      await supabase.from("food_logs").insert({
        "user_id": supabase.auth.currentUser!.id,
        "food_name": newRecord.foodName,
        "quantity": newRecord.quantity,
        "calories": newRecord.calories,
        "notes": newRecord.notes,
        "confidence": newRecord.confidence,
        "fats": double.parse(newRecord.fats.replaceAll('g', '').trim()),
        "protein": double.parse(newRecord.protein.replaceAll('g', '').trim()),
        "carbohydrates": double.parse(newRecord.carbs.replaceAll('g', '').trim()),
        "logged_at": newRecord.timestamp.toIso8601String(),
      });
    } catch (e) {
      _calorieHistory.remove(newRecord); // Rollback if database fails
      notifyListeners();
      rethrow; 
    }
  }
}