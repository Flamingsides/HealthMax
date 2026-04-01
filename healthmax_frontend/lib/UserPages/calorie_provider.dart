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
    this.foodName,
    this.quantity,
    this.protein,
    this.carbs,
    this.fats,
    this.calories,
    this.placeholderIcon,
    this.iconColor,
    this.timestamp, {
    this.notes, // optional named params at the end
    String? confidence,
    r,
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
      iconColor = Color.fromARGB(
        255,
        _random.nextInt(256),
        _random.nextInt(256),
        _random.nextInt(256),
      ),
      timestamp = map['logged_at'] != null
          ? DateTime.parse(map['logged_at'])
          : DateTime.now();

  void update({
    String? foodName,
    int? quantity,
    String? protein,
    String? carbs,
    String? fats,
    int? calories,
    String? notes,
    double? confidence,
    IconData? placeholderIcon,
    Color? iconColor,
    DateTime? timestamp,
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
  // Mock data updated with slightly different timestamps so sorting is obvious
  List<CalorieRecord> _calorieHistory = [];
  CalorieProvider() {
    initialiseCalorieHistory();
  }

  List<CalorieRecord> get calorieHistory => _calorieHistory;

  final int targetCalories = 2500;
  final int targetCarbs = 300;
  final int targetProtein = 120;
  final int targetFats = 70;

  final int currentSteps = 8843;
  final int workoutCalories = 150;

  int get burnedCalories => (currentSteps * 0.04).toInt() + workoutCalories;

  int get totalEaten =>
      _calorieHistory.fold(0, (sum, item) => sum + item.calories);
  int get leftCalories => targetCalories - totalEaten + burnedCalories;

  double get totalCarbs => _calorieHistory.fold(
    0.0,
    (sum, item) => sum + double.parse(item.carbs.replaceAll('g', '').trim()),
  );
  double get totalProtein => _calorieHistory.fold(
    0.0,
    (sum, item) => sum + double.parse(item.protein.replaceAll('g', '').trim()),
  );
  double get totalFats => _calorieHistory.fold(
    0.0,
    (sum, item) => sum + double.parse(item.fats.replaceAll('g', '').trim()),
  );

  void initialiseCalorieHistory() {
    _calorieHistory = [
      CalorieRecord(
        "Burger",
        1,
        "25g",
        "40g",
        "15g",
        375,
        Icons.lunch_dining,
        Colors.orange,
        DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      CalorieRecord(
        "Salad",
        1,
        "5g",
        "10g",
        "3g",
        90,
        Icons.eco,
        Colors.green,
        DateTime.now().subtract(const Duration(hours: 2)),
      ),
      CalorieRecord(
        "Nasi Kandar",
        1,
        "35g",
        "80g",
        "25g",
        720,
        Icons.rice_bowl,
        Colors.redAccent,
        DateTime.now().subtract(const Duration(hours: 5)),
      ),
      CalorieRecord(
        "Apple",
        3,
        "1.8g",
        "75g",
        "0.9g",
        145,
        Icons.apple,
        Colors.red,
        DateTime.now().subtract(const Duration(days: 1)),
      ),
      CalorieRecord(
        "Oatmeal",
        1,
        "10g",
        "45g",
        "5g",
        250,
        Icons.breakfast_dining,
        Colors.brown,
        DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      ),
    ];
  }

  void clear() {
    _calorieHistory.clear();
    initialiseCalorieHistory();
    notifyListeners();
  }

  void addFoodRecordWithoutDBUpdate(CalorieRecord newRecord) async {
    _calorieHistory.insert(0, newRecord);
    notifyListeners();
  }

  Future<void> addFoodRecord(CalorieRecord newRecord) async {
    _calorieHistory.insert(0, newRecord);
    notifyListeners();

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
        "carbohydrates": double.parse(
          newRecord.carbs.replaceAll('g', '').trim(),
        ),
        "logged_at": newRecord.timestamp.toIso8601String(),
      });
    } catch (e) {
      // 3. If insert fails, roll back the local state
      _calorieHistory.remove(newRecord);
      notifyListeners();
      rethrow; // let the caller handle the error
    }
  }
}
