import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- DATA MODELS ---
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
  int rewardPoints;
  bool isCompleted;

  TargetItem({
    required this.title, required this.description, required this.progress,
    required this.currentValue, required this.targetValue, required this.unit,
    required this.rewardPoints, required this.isCompleted,
  });
}

class RankingUser {
  int rank;
  String name;
  int score;
  bool isCurrentUser;

  RankingUser({required this.rank, required this.name, required this.score, required this.isCurrentUser});
}

// ==========================================
// SUPABASE-READY GOAL PROVIDER
// ==========================================
class GoalProvider extends ChangeNotifier {
  bool isLoading = true;
  
  // Default Empty State
  MainGoal mainGoal = MainGoal(title: "N/A", targetValue: "N/A", aiProgress: 0.0, aiInsightText: "Syncing with AI...");
  
  int userScore = 1250;
  List<TargetItem> targets = [];
  List<RankingUser> topRankings = [];
  late RankingUser currentUserRank;

  final _supabase = Supabase.instance.client;

  GoalProvider() {
    _initDummyRankings();
    fetchUserGoal(); // Automatically pull from Supabase when app starts!
  }

  void _initDummyRankings() {
    topRankings = [
      RankingUser(rank: 1, name: "Sarah M.", score: 2400, isCurrentUser: false),
      RankingUser(rank: 2, name: "David L.", score: 2150, isCurrentUser: false),
      RankingUser(rank: 3, name: "Emma W.", score: 1900, isCurrentUser: false),
    ];
    currentUserRank = RankingUser(rank: 42, name: "You", score: 1250, isCurrentUser: true);
    
    targets = [
      TargetItem(title: "Morning Walk", description: "Walk 5000 steps before 12 PM", progress: 0.8, currentValue: 4000, targetValue: 5000, unit: "steps", rewardPoints: 50, isCompleted: false),
      TargetItem(title: "Hydration", description: "Drink 2L of water", progress: 1.0, currentValue: 2, targetValue: 2, unit: "L", rewardPoints: 20, isCompleted: true),
    ];
  }

  // --- FETCH FROM SUPABASE ---
  Future<void> fetchUserGoal() async {
    isLoading = true;
    notifyListeners();

    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        // Query the public 'users' table to find this specific user's main goal
        final response = await _supabase.from('users').select('main_goal').eq('id', user.id).maybeSingle();
        
        String fetchedGoal = "Lose Weight"; // Fallback if they haven't set one yet
        
        if (response != null && response['main_goal'] != null) {
           fetchedGoal = response['main_goal'];
        }

        _setDynamicGoalData(fetchedGoal);
      } else {
         _setDynamicGoalData("Lose Weight"); // Fallback for guest/mock state
      }
    } catch (e) {
      print("Supabase Fetch Error: $e");
      _setDynamicGoalData("Lose Weight");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // --- UPDATE TO SUPABASE ---
  Future<void> updateMainGoal(String title, String targetValue) async {
    // 1. Update UI Immediately for a snappy experience
    _setDynamicGoalData(title);
    mainGoal.targetValue = targetValue; // Override with user's specific typed value
    notifyListeners();

    // 2. Save silently to backend
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase.from('users').update({'main_goal': title}).eq('id', user.id);
      }
    } catch (e) {
      print("Failed to update goal in Supabase: $e");
    }
  }

  // --- DYNAMIC AI INSIGHT LOGIC ---
  void _setDynamicGoalData(String goalTitle) {
    String targetVal = "10,000 steps";
    double prog = 0.5;
    String insight = "Analyzing your habits...";

    if (goalTitle == "Lose Weight") {
       targetVal = "5 kg";
       prog = 0.42;
       insight = "Caloric deficit is consistent. AI predicts you will hit your milestone in 3 weeks if you maintain this pace.";
    } else if (goalTitle == "More Steps") {
       targetVal = "10,000 steps/day";
       prog = 0.85;
       insight = "Great pacing! You are averaging 8.5k steps this week. A quick 15-minute evening walk will secure your daily goal.";
    } else if (goalTitle == "Less Sugar") {
       targetVal = "Under 25g/day";
       prog = 0.90;
       insight = "Excellent! You have cut sugar spikes by 40% this week. Keep avoiding those late-night processed snacks.";
    } else if (goalTitle == "Build Muscle") {
       targetVal = "Gain 2 kg";
       prog = 0.30;
       insight = "Protein intake is optimal, but sleep quality dropped. AI suggests 8 hours of sleep for better muscle recovery.";
    }

    mainGoal = MainGoal(
      title: goalTitle,
      targetValue: targetVal,
      aiProgress: prog,
      aiInsightText: insight,
    );
  }
}