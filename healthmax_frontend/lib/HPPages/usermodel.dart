import 'package:flutter/material.dart';

class UserModel {
  final String username;
  final String fullName;
  final String gender;
  final double height;
  final double weight;
  final String device;
  final int heartRate; 
  final String patientNote; 
  final String timeframe;
  final List<String> requestedData; 

  UserModel({
    required this.username,
    required this.fullName,
    required this.gender,
    required this.height,
    required this.weight,
    required this.device,
    this.heartRate = 0,
    this.patientNote = '',
    this.timeframe = '',
    this.requestedData = const [], // Default to empty
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
      requestedData: List<String>.from(data['requested_data'] ?? []),
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
class MockData {
  static List<UserModel> activeUsers = [
    UserModel(username: "peter_p", fullName: "Peter Parker", gender: "M", height: 178, weight: 76, device: "Apple Watch SE"),
    UserModel(username: "tony_s", fullName: "Tony Stark", gender: "M", height: 185, weight: 82, device: "StarkTech Arc Band"),
    UserModel(username: "bruce_b", fullName: "Bruce Banner", gender: "M", height: 175, weight: 80, device: "Garmin Instinct 2"), 
    UserModel(username: "steve_r", fullName: "Steve Rogers", gender: "M", height: 188, weight: 95, device: "Fitbit Charge 6"),
    UserModel(username: "natasha_r", fullName: "Natasha Romanoff", gender: "F", height: 170, weight: 60, device: "Oura Ring Gen3"),
    UserModel(username: "wanda_m", fullName: "Wanda Maximoff", gender: "F", height: 168, weight: 58, device: "Apple Watch S9"),
    UserModel(username: "barry_a", fullName: "Barry Allen", gender: "M", height: 180, weight: 78, device: "Garmin Forerunner 965"),
    UserModel(username: "arthur_c", fullName: "Arthur Curry", gender: "M", height: 193, weight: 110, device: "Suunto Ocean Dive"),
    UserModel(username: "ororo_m", fullName: "Ororo Munroe", gender: "F", height: 175, weight: 65, device: "Apple Watch Ultra 2"),
    UserModel(username: "matt_m", fullName: "Matt Murdock", gender: "M", height: 182, weight: 85, device: "Fitbit Sense 2"),
  ];

  static List<UserModel> pendingRequests = [
    UserModel(username: "diana_p", fullName: "Diana Prince", gender: "F", height: 168, weight: 60, device: "Garmin Venu 3", requestedData: ['Heart Rate', 'Steps', 'Calories']),
    UserModel(username: "ethan_h", fullName: "Ethan Hunt", gender: "M", height: 178, weight: 80, device: "Apple Watch Ultra", requestedData: ['Heart Rate', 'Steps', 'Oxygen Saturation', 'Sleep']),
    UserModel(username: "clark_k", fullName: "Clark Kent", gender: "M", height: 190, weight: 95, device: "Fitbit Sense 2", requestedData: ['Steps', 'Calories']),
    UserModel(username: "bruce_w", fullName: "Bruce Wayne", gender: "M", height: 188, weight: 85, device: "Oura Ring Gen3", requestedData: ['Heart Rate', 'Sleep', 'Blood Pressure']),
    UserModel(username: "selina_k", fullName: "Selina Kyle", gender: "F", height: 170, weight: 55, device: "Apple Watch S9", requestedData: ['Glucose Level', 'Calories', 'Steps']),
  ];

  static List<FeedbackRequest> feedbackRequests = [
    FeedbackRequest(activeUsers[2], "Heart Rate", "10 mins ago", const Color(0xFFFF4757), "HR"),
    FeedbackRequest(activeUsers[1], "Glucose Level", "1 hour ago", const Color(0xFF4ECDC4), "GL"), 
    FeedbackRequest(activeUsers[0], "Steps", "3 hours ago", const Color(0xFFFF9F43), "ST"), 
    FeedbackRequest(activeUsers[4], "Calories", "5 hours ago", const Color(0xFFFFD93D), "CAL"), 
    FeedbackRequest(activeUsers[3], "Heart Rate", "1 day ago", const Color(0xFFFF4757), "HR"), 
    FeedbackRequest(activeUsers[5], "Env. Noise", "1 day ago", const Color(0xFF45B7D1), "EN"), 
    FeedbackRequest(activeUsers[6], "Steps", "2 days ago", const Color(0xFFFF9F43), "ST"), 
    FeedbackRequest(activeUsers[7], "Calories", "2 days ago", const Color(0xFFFFD93D), "CAL"), 
    FeedbackRequest(activeUsers[8], "Glucose Level", "3 days ago", const Color(0xFF4ECDC4), "GL"), 
  ];
}