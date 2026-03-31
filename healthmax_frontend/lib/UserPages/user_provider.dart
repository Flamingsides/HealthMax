import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? _username;
  String? _gender;
  DateTime? _dob;
  double? _weight;
  String? _weightUnit;
  double? _height;
  String? _heightUnit;

  // Getter
  String? get username => _username;
  String? get gender => _gender;
  DateTime? get dob => _dob;
  double? get weight => _weight;
  String? get weightUnit => _weightUnit;
  double? get height => _height;
  String? get heightUnit => _heightUnit;

  void setUsername(String username) {
    _username = username;
    notifyListeners();
  }

  void setGender(String gender) {
    _gender = gender;
    notifyListeners();
  }

  void setDob(DateTime dob) {
    _dob = dob;
    notifyListeners();
  }

  void setWeight(double weight) {
    _weight = weight;
    notifyListeners();
  }

  void setWeightUnit(String unit) {
    _weightUnit = unit;
    notifyListeners();
  }

  void setHeight(double height) {
    _height = height;
    notifyListeners();
  }

  void setHeightUnit(String unit) {
    _heightUnit = unit;
    notifyListeners();
  }

  void clear() {
    _username = null;
    _gender = null;
    _dob = null;
    _weight = null;
    _weightUnit = null;
    _height = null;
    _heightUnit = null;
    notifyListeners();
  }
}
