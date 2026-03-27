import 'package:flutter/material.dart';

class CalorieRecord {
  final String foodName;
  final int quantity;
  final String protein;
  final String carbs;
  final String fats;
  final int calories;
  final IconData placeholderIcon;
  final Color iconColor;
  final DateTime timestamp; // NEW: Added time tracking for sorting!

  CalorieRecord(this.foodName, this.quantity, this.protein, this.carbs, this.fats, this.calories, this.placeholderIcon, this.iconColor, this.timestamp);
}

class CalorieProvider extends ChangeNotifier {
  // Mock data updated with slightly different timestamps so sorting is obvious
  final List<CalorieRecord> _calorieHistory = [
    CalorieRecord("Burger", 1, "25g", "40g", "15g", 375, Icons.lunch_dining, Colors.orange, DateTime.now().subtract(const Duration(minutes: 5))),
    CalorieRecord("Salad", 1, "5g", "10g", "3g", 90, Icons.eco, Colors.green, DateTime.now().subtract(const Duration(hours: 2))),
    CalorieRecord("Nasi Kandar", 1, "35g", "80g", "25g", 720, Icons.rice_bowl, Colors.redAccent, DateTime.now().subtract(const Duration(hours: 5))),
    CalorieRecord("Apple", 3, "1.8g", "75g", "0.9g", 145, Icons.apple, Colors.red, DateTime.now().subtract(const Duration(days: 1))),
    CalorieRecord("Oatmeal", 1, "10g", "45g", "5g", 250, Icons.breakfast_dining, Colors.brown, DateTime.now().subtract(const Duration(days: 1, hours: 4))),
  ];

  List<CalorieRecord> get calorieHistory => _calorieHistory;

  final int targetCalories = 2500;
  final int targetCarbs = 300;
  final int targetProtein = 120;
  final int targetFats = 70;
  
  final int currentSteps = 8843; 
  final int workoutCalories = 150; 
  
  int get burnedCalories => (currentSteps * 0.04).toInt() + workoutCalories;

  int get totalEaten => _calorieHistory.fold(0, (sum, item) => sum + item.calories);
  int get leftCalories => targetCalories - totalEaten + burnedCalories;
  
  double get totalCarbs => _calorieHistory.fold(0.0, (sum, item) => sum + double.parse(item.carbs.replaceAll('g', '').trim()));
  double get totalProtein => _calorieHistory.fold(0.0, (sum, item) => sum + double.parse(item.protein.replaceAll('g', '').trim()));
  double get totalFats => _calorieHistory.fold(0.0, (sum, item) => sum + double.parse(item.fats.replaceAll('g', '').trim()));

  void addFoodRecord(CalorieRecord newRecord) {
    _calorieHistory.insert(0, newRecord); 
    notifyListeners(); 
  }
}