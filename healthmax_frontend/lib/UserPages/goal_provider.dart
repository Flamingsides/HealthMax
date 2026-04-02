import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainGoal { 
  String title; String targetValue; double aiProgress; String aiInsightText; 
  MainGoal({required this.title, required this.targetValue, required this.aiProgress, required this.aiInsightText}); 
}

class TargetItem { 
  String? id; 
  String title; String description; double progress; int currentValue; int targetValue; String unit; bool isCompleted; 
  
  TargetItem({
    this.id, required this.title, required this.description, required this.progress, 
    required this.currentValue, required this.targetValue, required this.unit, required this.isCompleted
  }); 
  
  int get earnedPoints { 
    if (currentValue >= targetValue) return 100; 
    if (currentValue >= (targetValue / 2)) return 50; 
    return 0; 
  } 
}

class RankingUser { 
  final int rank; final String name; final int score; final bool isCurrentUser; 
  RankingUser(this.rank, this.name, this.score, this.isCurrentUser); 
}

class GoalProvider extends ChangeNotifier {
  bool isLoading = false;
  int userScore = 0;

  MainGoal mainGoal = MainGoal(title: "N/A", targetValue: "N/A", aiProgress: 0.0, aiInsightText: "Set a main health goal to let AI personalize your experience.");
  List<TargetItem> targets = [];
  List<RankingUser> allRankings = [];
  
  RankingUser get currentUserRank {
    int index = allRankings.indexWhere((u) => u.isCurrentUser);
    int rank = index != -1 ? index + 1 : 0; 
    return RankingUser(rank, "You", userScore, true);
  }

  Future<void> fetchGoalData() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final userData = await supabase.from('users').select('total_points, main_goal').eq('id', user.id).maybeSingle();
      
      if (userData != null) {
        userScore = userData['total_points'] ?? 0;
        String mGoal = userData['main_goal'] ?? "N/A";
        
        mainGoal.title = mGoal;
        mainGoal.targetValue = "Optimal"; 
        mainGoal.aiProgress = 0.0;
        mainGoal.aiInsightText = (mGoal == "N/A" || mGoal.isEmpty) 
            ? "Set a main health goal to let AI personalize your experience." 
            : "AI is gathering data to track your $mGoal progress over time.";
      }

      final targetData = await supabase.from('user_targets').select().eq('user_id', user.id);
      
      targets = targetData.map((t) => TargetItem(
        id: t['id'],
        title: t['title'],
        description: t['description'],
        progress: (t['current_value'] / t['target_value']).clamp(0.0, 1.0),
        currentValue: t['current_value'],
        targetValue: t['target_value'],
        unit: t['unit'],
        isCompleted: t['is_completed'],
      )).toList();

      await _refreshLeaderboard(user.id);

    } catch (e) {
      print("Error fetching goals: $e");
    }
  }

  Future<void> _refreshLeaderboard(String userId) async {
    final leaderData = await Supabase.instance.client.from('users').select('id, username, total_points').order('total_points', ascending: false).limit(10);
    
    allRankings.clear();
    for (int i = 0; i < leaderData.length; i++) {
       bool isMe = leaderData[i]['id'] == userId; 
       allRankings.add(RankingUser(i + 1, isMe ? "You" : (leaderData[i]['username'] ?? 'User'), leaderData[i]['total_points'] ?? 0, isMe));
    }
    notifyListeners();
  }

  Future<void> _updateUserScore(int pointsDifference, String userId) async {
    if (pointsDifference == 0) return;
    
    userScore += pointsDifference;
    notifyListeners(); 

    try {
      await Supabase.instance.client.from('users').update({'total_points': userScore}).eq('id', userId);
      await _refreshLeaderboard(userId);
    } catch (e) {
      print("Failed to sync new score to DB: $e");
    }
  }

  Future<void> updateMainGoal(String title, String targetValue) async {
    mainGoal.title = title; mainGoal.targetValue = targetValue; mainGoal.aiProgress = 0.0;
    if (title == "N/A" || title.isEmpty) {
      mainGoal.title = "N/A"; mainGoal.aiInsightText = "Set a main health goal to let AI personalize your experience."; 
    } else {
      mainGoal.aiInsightText = "AI is gathering data to track your $title progress over time."; 
    }
    notifyListeners();

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try { 
      await supabase.from('users').update({'main_goal': title}).eq('id', user.id); 
      if (title != "N/A" && targets.isEmpty) {
        await _generateAndSaveSubTargets(title, user.id);
      }
    } 
    catch (e) { print("Failed to save main goal: $e"); }
  }

  Future<void> _generateAndSaveSubTargets(String goalTitle, String userId) async {
    List<TargetItem> generated = [];
    
    if (goalTitle == "Lose Weight") {
      generated = [
        TargetItem(title: "Calorie Deficit", description: "Stay under your daily calorie limit.", progress: 0.0, currentValue: 0, targetValue: 2000, unit: "kcal", isCompleted: false),
        TargetItem(title: "Cardio", description: "Complete a cardio session.", progress: 0.0, currentValue: 0, targetValue: 300, unit: "kcal", isCompleted: false),
      ];
    } else if (goalTitle == "More Steps") {
      generated = [
        TargetItem(title: "Daily Steps", description: "Walk 10,000 steps today.", progress: 0.0, currentValue: 0, targetValue: 10000, unit: "steps", isCompleted: false),
      ];
    } else if (goalTitle == "Build Muscle") {
      generated = [
        TargetItem(title: "Protein Intake", description: "Hit your daily protein goal.", progress: 0.0, currentValue: 0, targetValue: 150, unit: "g", isCompleted: false),
        TargetItem(title: "Strength Training", description: "Complete weight lifting session.", progress: 0.0, currentValue: 0, targetValue: 1, unit: "session", isCompleted: false),
      ];
    } else if (goalTitle == "Less Sugar") {
      generated = [
        TargetItem(title: "Sugar Limit", description: "Keep added sugar under 30g.", progress: 0.0, currentValue: 0, targetValue: 30, unit: "g", isCompleted: false),
      ];
    }

    for (var target in generated) { addTarget(target); }
  }

  // --- UPDATED: Secure database saving with rollbacks ---
  Future<void> addTarget(TargetItem newTarget) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception("User not found");

    try {
      final response = await Supabase.instance.client.from('user_targets').insert({
        'user_id': user.id, 'title': newTarget.title, 'description': newTarget.description, 'current_value': newTarget.currentValue,
        'target_value': newTarget.targetValue, 'unit': newTarget.unit, 'is_completed': newTarget.isCompleted,
      }).select().single();

      newTarget.id = response['id']; 
      targets.add(newTarget);
      await _updateUserScore(newTarget.earnedPoints, user.id);
      notifyListeners();
    } catch (e) {
      print("Failed to save target: $e");
      rethrow; // Tosses the error to the UI
    }
  }

  Future<void> editTarget(int index, TargetItem updatedTarget) async {
    if (index < 0 || index >= targets.length) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    int oldPoints = targets[index].earnedPoints;
    targets[index] = updatedTarget; 
    int newPoints = updatedTarget.earnedPoints;
    int pointsDifference = newPoints - oldPoints;

    await _updateUserScore(pointsDifference, user.id);
    notifyListeners();

    final targetId = updatedTarget.id;
    if (targetId == null) return; 
    try {
      await Supabase.instance.client.from('user_targets').update({
        'title': updatedTarget.title, 'description': updatedTarget.description, 'current_value': updatedTarget.currentValue,
        'target_value': updatedTarget.targetValue, 'unit': updatedTarget.unit, 'is_completed': updatedTarget.isCompleted,
      }).eq('id', targetId);
    } catch (e) { 
      print("Failed to update target: $e"); 
      rethrow;
    }
  }

  Future<void> deleteTarget(int index) async {
    if (index < 0 || index >= targets.length) return;
    final user = Supabase.instance.client.auth.currentUser;
    final target = targets[index];
    final targetId = target.id;
    
    int pointsToDeduct = -target.earnedPoints;
    targets.removeAt(index); 
    notifyListeners();

    if (user != null) await _updateUserScore(pointsToDeduct, user.id);
    
    if (targetId == null) return;
    try { 
      await Supabase.instance.client.from('user_targets').delete().eq('id', targetId); 
    } catch (e) { 
      print("Failed to delete target: $e"); 
      rethrow;
    }
  }
}