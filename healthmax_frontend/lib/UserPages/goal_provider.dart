import 'package:flutter/material.dart';

class MainGoal {
  String title;
  String targetValue;
  double aiProgress;
  String aiInsightText;

  MainGoal({
    required this.title,
    required this.targetValue,
    required this.aiProgress,
    required this.aiInsightText,
  });
}

class TargetItem {
  String title;
  String description;
  double progress;
  int currentValue;
  int targetValue;
  String unit;
  bool isCompleted;

  TargetItem({
    required this.title,
    required this.description,
    required this.progress,
    required this.currentValue,
    required this.targetValue,
    required this.unit,
    required this.isCompleted,
  });

  // --- AUTOMATED POINT CALCULATOR ---
  int get earnedPoints {
    if (currentValue >= targetValue) return 100; // Full target achieved
    if (currentValue >= (targetValue / 2)) return 50; // Half target achieved
    return 0;
  }
}

class RankingUser {
  final int rank;
  final String name;
  final int score;
  final bool isCurrentUser;

  RankingUser(this.rank, this.name, this.score, this.isCurrentUser);
}

class GoalProvider extends ChangeNotifier {
  bool isLoading = false;
  
  // DYNAMIC SCORE: Base score (1250) + Automated Earned Points
  int get userScore => 1250 + targets.fold<int>(0, (sum, item) => sum + item.earnedPoints);

  MainGoal mainGoal = MainGoal(
    title: "N/A",
    targetValue: "N/A",
    aiProgress: 0.0,
    aiInsightText: "Set a main health goal to let AI personalize your experience.",
  );

  List<TargetItem> targets = [];

  // --- LEADERBOARD DATA ---
  List<RankingUser> allRankings = [
    RankingUser(1, "Alex Fitness", 3400, false),
    RankingUser(2, "Sarah Connor", 2900, false),
    RankingUser(3, "John Doe", 2100, false),
    RankingUser(4, "Mike Taylor", 2050, false),
    RankingUser(5, "Emma Watson", 1900, false),
    RankingUser(6, "David Lee", 1850, false),
    RankingUser(7, "Chris P.", 1800, false),
    RankingUser(8, "Anna K.", 1750, false),
    RankingUser(9, "Tom Hardy", 1700, false),
    RankingUser(10, "Lisa M.", 1650, false),
  ];
  
  // Dynamically applies the live userScore to the leaderboard!
  RankingUser get currentUserRank => RankingUser(42, "You", userScore, true);

  void updateMainGoal(String title, String targetValue) {
    mainGoal.title = title;
    mainGoal.targetValue = targetValue;
    mainGoal.aiProgress = 0.0;
    
    if (title == "N/A" || title.isEmpty) {
      mainGoal.title = "N/A";
      mainGoal.aiInsightText = "Set a main health goal to let AI personalize your experience.";
      targets = []; 
    } else {
      mainGoal.aiInsightText = "AI is gathering data to track your $title progress over time.";
      _generateSubTargets(title); 
    }
    notifyListeners();
  }

  void addTarget(TargetItem newTarget) {
    targets.add(newTarget);
    notifyListeners();
  }

  void editTarget(int index, TargetItem updatedTarget) {
    if (index >= 0 && index < targets.length) {
      targets[index] = updatedTarget;
      notifyListeners();
    }
  }

  void deleteTarget(int index) {
    if (index >= 0 && index < targets.length) {
      targets.removeAt(index);
      notifyListeners();
    }
  }

  void _generateSubTargets(String goalTitle) {
    if (goalTitle == "Lose Weight") {
      targets = [
        TargetItem(title: "Calorie Deficit", description: "Stay under your daily calorie limit.", progress: 0.7, currentValue: 1400, targetValue: 2000, unit: "kcal", isCompleted: false),
        TargetItem(title: "Cardio", description: "Complete a 30 min cardio session.", progress: 1.0, currentValue: 30, targetValue: 30, unit: "min", isCompleted: true),
      ];
    } else if (goalTitle == "More Steps") {
      targets = [
        TargetItem(title: "Daily Steps", description: "Walk 10,000 steps today.", progress: 0.5, currentValue: 5000, targetValue: 10000, unit: "steps", isCompleted: false),
        TargetItem(title: "Active Minutes", description: "Stay active for at least 45 minutes.", progress: 0.8, currentValue: 36, targetValue: 45, unit: "min", isCompleted: false),
      ];
    } else if (goalTitle == "Build Muscle") {
      targets = [
        TargetItem(title: "Protein Intake", description: "Hit your daily protein goal.", progress: 0.8, currentValue: 120, targetValue: 150, unit: "g", isCompleted: false),
        TargetItem(title: "Strength Training", description: "Complete weight lifting session.", progress: 0.0, currentValue: 0, targetValue: 1, unit: "session", isCompleted: false),
      ];
    } else if (goalTitle == "Less Sugar") {
      targets = [
        TargetItem(title: "Sugar Limit", description: "Keep added sugar under 30g.", progress: 0.3, currentValue: 10, targetValue: 30, unit: "g", isCompleted: false),
        TargetItem(title: "Hydration", description: "Drink 8 glasses of water.", progress: 1.0, currentValue: 8, targetValue: 8, unit: "glasses", isCompleted: true),
      ];
    } else {
      targets = [];
    }
  }
}