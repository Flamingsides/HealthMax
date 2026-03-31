import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http; // Developer will uncomment this!

// --- DATA MODELS (Map directly to PostgreSQL tables) ---
class TargetItem {
  String title;
  String description;
  int currentValue;
  int targetValue;
  int duration;
  String unit;
  int rewardPoints;

  TargetItem({
    required this.title,
    required this.description,
    required this.currentValue,
    required this.targetValue,
    required this.duration,
    required this.unit,
    required this.rewardPoints,
  });
  double get progress => (currentValue / targetValue).clamp(0.0, 1.0);
  bool get isCompleted => currentValue >= targetValue;
}

class RankingUser {
  final int rank;
  final String name;
  final int score;
  final bool isCurrentUser;

  RankingUser(this.rank, this.name, this.score, {this.isCurrentUser = false});
}

class MainGoal {
  String title;
  String targetValue;
  double aiProgress; // e.g., 0.65 for 65%
  String aiInsightText;

  MainGoal({
    required this.title,
    required this.targetValue,
    required this.aiProgress,
    required this.aiInsightText,
  });
}

// --- THE PROVIDER (API LAYER) ---
class GoalProvider extends ChangeNotifier {
  bool isLoading = false;

  // 1. Data State
  int userScore = 1234;
  MainGoal mainGoal = MainGoal(
    title: "N/A",
    targetValue: "N/A",
    aiProgress: 0.0,
    aiInsightText: "",
  );
  List<TargetItem> targets = [];
  List<RankingUser> topRankings = [];
  RankingUser currentUserRank = RankingUser(
    42,
    "Tengku Adam",
    1234,
    isCurrentUser: true,
  );

  GoalProvider() {
    fetchDashboardData(); // Automatically loads data when app starts
  }

  // ========================================================
  // 🚀 FAST-API INTEGRATION METHODS (For the Developer)
  // ========================================================

  Future<void> fetchDashboardData() async {
    isLoading = true;
    notifyListeners();

    try {
      // TODO: DEVELOPER - Replace with actual FastAPI GET request
      // final response = await http.get(Uri.parse('https://your-fastapi-url.com/api/user/target-dashboard'));
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   // Map JSON to variables here...
      // }

      // --- MOCK DELAY (Simulating database fetch) ---
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock Data Population
      mainGoal = MainGoal(
        title: "Lose Weight",
        targetValue: "60 kg",
        aiProgress: 0.65,
        aiInsightText:
            "Based on your calorie deficit over the last 7 days, you are on track to hit your goal by next month!",
      );

      targets = [
        TargetItem(
          title: "Steps",
          description: "Achieve 10,000 steps in 5 Days.",
          currentValue: 8843,
          targetValue: 10000,
          duration: 5,
          unit: "steps",
          rewardPoints: 123,
        ),
        TargetItem(
          title: "Calorie Balance",
          description:
              "Maintain a Net Calorie deficit of 1,000 kcal for 10 days.",
          currentValue: 1000,
          targetValue: 1000,
          duration: 10,
          unit: "kcal",
          rewardPoints: 550,
        ),
      ];

      topRankings = [
        RankingUser(1, "Suhaib", 3450),
        RankingUser(2, "Abdul", 3120),
      ];
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMainGoal(String newTitle, String newTarget) async {
    // Optimistic UI Update (Update screen instantly)
    mainGoal.title = newTitle;
    mainGoal.targetValue = newTarget;
    notifyListeners();

    try {
      // TODO: DEVELOPER - Replace with FastAPI POST/PUT request
      // await http.post(
      //   Uri.parse('https://your-fastapi-url.com/api/user/main-goal'),
      //   body: jsonEncode({'title': newTitle, 'target': newTarget}),
      //   headers: {'Content-Type': 'application/json'},
      // );
    } catch (e) {
      print("Failed to update PostgreSQL: $e");
      // If API fails, you could revert the UI change here
    }
  }
}
