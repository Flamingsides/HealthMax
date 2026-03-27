import 'package:flutter/material.dart';

// We moved your data model here so it can be shared everywhere!
class CalorieRecord {
  final String foodName;
  final int quantity;
  final String protein;
  final String carbs;
  final String fats;
  final int calories;
  final IconData placeholderIcon;
  final Color iconColor;

  CalorieRecord(this.foodName, this.quantity, this.protein, this.carbs, this.fats, this.calories, this.placeholderIcon, this.iconColor);
}

class CalorieProvider extends ChangeNotifier {
  // 1. The Central Data List (Starts with your mock data)
  final List<CalorieRecord> _calorieHistory = [
    CalorieRecord("Burger", 1, "25g", "40g", "15g", 375, Icons.lunch_dining, Colors.orange),
    CalorieRecord("Salad", 1, "5g", "10g", "3g", 90, Icons.eco, Colors.green),
    CalorieRecord("Nasi Kandar", 1, "35g", "80g", "25g", 720, Icons.rice_bowl, Colors.redAccent),
    CalorieRecord("Apple", 3, "1.8g", "75g", "0.9g", 145, Icons.apple, Colors.red),
    CalorieRecord("Oatmeal", 1, "10g", "45g", "5g", 250, Icons.breakfast_dining, Colors.brown),
  ];

  List<CalorieRecord> get calorieHistory => _calorieHistory;

  // 2. Targets & Activity Constants
  final int targetCalories = 2500;
  final int targetCarbs = 300;
  final int targetProtein = 120;
  final int targetFats = 70;
  
  final int currentSteps = 8843; 
  final int workoutCalories = 150; 
  
  int get burnedCalories => (currentSteps * 0.04).toInt() + workoutCalories;

  // 3. Dynamic Math Calculations
  int get totalEaten => _calorieHistory.fold(0, (sum, item) => sum + item.calories);
  int get leftCalories => targetCalories - totalEaten + burnedCalories;
  
  double get totalCarbs => _calorieHistory.fold(0.0, (sum, item) => sum + double.parse(item.carbs.replaceAll('g', '').trim()));
  double get totalProtein => _calorieHistory.fold(0.0, (sum, item) => sum + double.parse(item.protein.replaceAll('g', '').trim()));
  double get totalFats => _calorieHistory.fold(0.0, (sum, item) => sum + double.parse(item.fats.replaceAll('g', '').trim()));

  // 4. The Magic "Add" Function
  void addFoodRecord(CalorieRecord newRecord) {
    _calorieHistory.insert(0, newRecord); // Puts the newest food at the very top
    notifyListeners(); // Tells the entire app to redraw the charts and history!
  }
}