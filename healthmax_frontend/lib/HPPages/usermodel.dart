import 'package:flutter/material.dart';

class UserModel {
  final String username;
  final String fullName;
  final String gender;
  final double height;
  final double weight;
  final String device;
  final int heartRate; 

  UserModel({
    required this.username,
    required this.fullName,
    required this.gender,
    required this.height,
    required this.weight,
    required this.device,
    this.heartRate = 0,
  });


  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      username: data['username'] ?? '',
      fullName: data['full_name'] ?? 'User',
      gender: data['gender'] ?? 'N/A',
      height: (data['height_cm'] ?? 0).toDouble(),
      weight: (data['weight_kg'] ?? 0).toDouble(),
      device: data['device_name'] ?? 'No Device',
      heartRate: data['heart_rate'] ?? 0,
    );
  }

  String get infoString => "$gender | ${height.toInt()} cm | ${weight.toInt()} kg";
}

class FeedbackRequest {
  final UserModel user;
  final String metric;
  final String timeAgo;
  final Color color;
  final String label;

  FeedbackRequest(this.user, this.metric, this.timeAgo, this.color, this.label);
}

// --- CENTRAL MOCK DATA HUB ---
// This ensures the numbers on the Homepage perfectly match the lists!
class MockData {
  static List<UserModel> activeUsers = [
    UserModel(username: "peter_p", fullName: "Peter Parker", gender: "M", height: 178, weight: 76, device: "Apple Watch SE"),
    UserModel(username: "tony_s", fullName: "Tony Stark", gender: "M", height: 185, weight: 82, device: "StarkTech Arc Band"),
    UserModel(username: "bruce_b", fullName: "Bruce Banner", gender: "M", height: 175, weight: 80, device: "Garmin Instinct 2"), // Gotta track that HR!
    UserModel(username: "steve_r", fullName: "Steve Rogers", gender: "M", height: 188, weight: 95, device: "Fitbit Charge 6"),
    UserModel(username: "natasha_r", fullName: "Natasha Romanoff", gender: "F", height: 170, weight: 60, device: "Oura Ring Gen3"),
    UserModel(username: "wanda_m", fullName: "Wanda Maximoff", gender: "F", height: 168, weight: 58, device: "Apple Watch S9"),
    UserModel(username: "barry_a", fullName: "Barry Allen", gender: "M", height: 180, weight: 78, device: "Garmin Forerunner 965"),
    UserModel(username: "arthur_c", fullName: "Arthur Curry", gender: "M", height: 193, weight: 110, device: "Suunto Ocean Dive"),
    UserModel(username: "ororo_m", fullName: "Ororo Munroe", gender: "F", height: 175, weight: 65, device: "Apple Watch Ultra 2"),
    UserModel(username: "matt_m", fullName: "Matt Murdock", gender: "M", height: 182, weight: 85, device: "Fitbit Sense 2"),
  ];

  static List<UserModel> pendingRequests = [
    UserModel(username: "diana_p", fullName: "Diana Prince", gender: "F", height: 168, weight: 60, device: "Garmin Venu 3"),
    UserModel(username: "ethan_h", fullName: "Ethan Hunt", gender: "M", height: 178, weight: 80, device: "Apple Watch Ultra"),
    UserModel(username: "clark_k", fullName: "Clark Kent", gender: "M", height: 190, weight: 95, device: "Fitbit Sense 2"),
    UserModel(username: "bruce_w", fullName: "Bruce Wayne", gender: "M", height: 188, weight: 85, device: "Oura Ring Gen3"),
    UserModel(username: "selina_k", fullName: "Selina Kyle", gender: "F", height: 170, weight: 55, device: "Apple Watch S9"),
  ];

  static List<FeedbackRequest> feedbackRequests = [
    FeedbackRequest(activeUsers[2], "Heart Rate", "10 mins ago", const Color(0xFFFF4757), "HR"), // Bruce Banner
    FeedbackRequest(activeUsers[1], "Glucose Level", "1 hour ago", const Color(0xFF2ED573), "GL"), // Tony Stark
    FeedbackRequest(activeUsers[0], "Steps", "3 hours ago", const Color(0xFFFF9F43), "ST"), // Peter Parker
    FeedbackRequest(activeUsers[4], "Calories", "5 hours ago", const Color(0xFF5A84F1), "CAL"), // Natasha Romanoff
    FeedbackRequest(activeUsers[3], "Heart Rate", "1 day ago", const Color(0xFFFF4757), "HR"), // Steve Rogers
  ];
}