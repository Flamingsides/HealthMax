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

// --- CENTRAL MOCK DATA HUB ---
// This ensures the numbers on the Homepage perfectly match the lists!
class MockData {
  static List<UserModel> activeUsers = [
    UserModel(username: "john_d", fullName: "John Doe", gender: "M", height: 175, weight: 70, device: "Apple Watch S8"),
    UserModel(username: "jane_s", fullName: "Jane Smith", gender: "F", height: 165, weight: 58, device: "Fitbit Charge 5"),
    UserModel(username: "robert_k", fullName: "Robert King", gender: "M", height: 182, weight: 85, device: "Garmin Fenix 7"),
    UserModel(username: "emily_r", fullName: "Emily Rose", gender: "F", height: 170, weight: 62, device: "Oura Ring Gen3"),
  ];

  static List<UserModel> pendingRequests = [
    UserModel(username: "diana_p", fullName: "Diana Prince", gender: "F", height: 168, weight: 60, device: "Garmin Venu 3"),
    UserModel(username: "ethan_h", fullName: "Ethan Hunt", gender: "M", height: 178, weight: 80, device: "Apple Watch Ultra"),
    UserModel(username: "clark_k", fullName: "Clark Kent", gender: "M", height: 190, weight: 95, device: "Fitbit Sense 2"),
    UserModel(username: "bruce_w", fullName: "Bruce Wayne", gender: "M", height: 188, weight: 85, device: "Oura Ring Gen3"),
    UserModel(username: "selina_k", fullName: "Selina Kyle", gender: "F", height: 170, weight: 55, device: "Apple Watch S9"),
  ];
}