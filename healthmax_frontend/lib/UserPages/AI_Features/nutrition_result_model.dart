import 'dart:convert';
import 'package:flutter/foundation.dart';

class NutritionResult {
  final String label;
  final int servings;
  final List<FoodItem> foods;
  final int totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final String confidence;
  final String notes;

  NutritionResult({
    required this.label,
    required this.servings,
    required this.foods,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.confidence,
    required this.notes,
  });

  static NutritionResult _parseJsonInBackground(String jsonStr) {
    final map = jsonDecode(jsonStr);
    return NutritionResult(
      label: map["label"],
      servings: map["servings"],
      foods: (map["foods"] as List).map((food) => FoodItem.fromMap(food)).toList(),
      totalCalories: (map["total_calories_kcal"] ?? 0).toInt(),
      totalProtein: (map["total_protein_g"] ?? 0).toDouble(),
      totalCarbs: (map["total_carbs_g"] ?? 0).toDouble(),
      totalFat: (map["total_fat_g"] ?? 0).toDouble(),
      confidence: (map["confidence"] ?? "00.0%"),
      notes: map["notes"] ?? "None",
    );
  }

  // 2. Use compute() to run it on a background thread!
  static Future<NutritionResult> fromJsonAsync(String jsonStr) async {
    return await compute(_parseJsonInBackground, jsonStr);
  }
}

class FoodItem {
  final String name;
  final String amount;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;

  FoodItem({
    required this.name,
    required this.amount,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory FoodItem.fromMap(Map map) => FoodItem(
    name: map["name"] ?? "Unknown Food",
    amount: map["amount"] ?? "Uncertain Amount",
    calories: (map["calories_kcal"] ?? 0).toInt(),
    protein: (map["protein_g"] ?? 0).toDouble(),
    carbs: (map["carbs_g"] ?? 0).toDouble(),
    fat: (map["fat_g"] ?? 0.0).toDouble(),
  );
}
