class UserModel {
  // ---------- 1. PROPERTIES ----------
  final String username;
  final String fullName;
  final String gender;
  final double height;
  final double weight;
  final String device;
  final int heartRate; // For mock/live bpm display

  // ---------- 2. CONSTRUCTORS & FACTORIES ----------
  UserModel({
    required this.username,
    required this.fullName,
    required this.gender,
    required this.height,
    required this.weight,
    required this.device,
    this.heartRate = 0,
  });

  // Factory to convert Database/Map data to this Object
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

  // ---------- 3. UI HELPERS ----------
  
  // Helper for the UI string: "M | 175 cm | 75 kg"
  String get infoString => "$gender | ${height.toInt()} cm | ${weight.toInt()} kg";
}