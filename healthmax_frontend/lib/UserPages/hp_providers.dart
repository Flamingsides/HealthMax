import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HPModel {
  String? id; // Database ID
  final String name;
  final String address;
  bool isConnected;
  String accessDate;
  List<String> accessibleData;
  String timeframe;

  HPModel({this.id, required this.name, required this.address, required this.isConnected, required this.accessDate, required this.accessibleData, required this.timeframe});
}

class HPProvider extends ChangeNotifier {
  List<HPModel> providers = [
    HPModel(name: "Hospital 1", address: "123 Medical Center Blvd, Suite 100", isConnected: false, accessDate: "", accessibleData: [], timeframe: "None"),
    HPModel(name: "Hospital 2", address: "456 Health Way, Building B", isConnected: false, accessDate: "", accessibleData: [], timeframe: "None"),
    HPModel(name: "Hospital 3", address: "789 Care Ave, Floor 3", isConnected: false, accessDate: "", accessibleData: [], timeframe: "None"),
    HPModel(name: "Clinic A", address: "101 Wellness Drive", isConnected: false, accessDate: "", accessibleData: [], timeframe: "None"),
    HPModel(name: "Dr. Sarah's Cardiology", address: "Private Clinic, Block A", isConnected: false, accessDate: "", accessibleData: [], timeframe: "None"),
  ];

  int get connectedCount => providers.where((hp) => hp.isConnected).length;

  // --- FETCH FROM DATABASE ---
  Future<void> fetchHPConnections() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await supabase.from('user_hp_connections').select().eq('user_id', user.id);
      
      // Reset all to disconnected first
      for (var hp in providers) { hp.isConnected = false; hp.accessibleData = []; hp.accessDate = ""; hp.timeframe = "None"; }

      // Map database rows to our list
      for (var row in data) {
        final existingHP = providers.firstWhere((hp) => hp.name == row['hospital_name'], orElse: () => providers[0]);
        existingHP.id = row['id'];
        existingHP.isConnected = true;
        existingHP.accessibleData = List<String>.from(row['access_data'] ?? []);
        existingHP.timeframe = row['timeframe'] ?? "None";
        existingHP.accessDate = row['expiry_date'] ?? "";
        
        providers.remove(existingHP);
        providers.insert(0, existingHP);
      }
      notifyListeners();
    } catch (e) { print("Error fetching HP data: $e"); }
  }

  // --- WRITE TO DATABASE ---
  Future<void> grantAccess(HPModel hp, List<String> data, String timeframe, String expiryDate) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    // Update UI Instantly
    hp.isConnected = true; hp.accessibleData = List.from(data); hp.timeframe = timeframe; hp.accessDate = expiryDate;
    providers.remove(hp); providers.insert(0, hp);
    notifyListeners();

    try {
      final response = await supabase.from('user_hp_connections').insert({
        'user_id': user.id, 'hospital_name': hp.name, 'access_data': data, 'timeframe': timeframe, 'expiry_date': expiryDate
      }).select().single();
      hp.id = response['id'];
    } catch (e) { print("Failed to grant HP access: $e"); }
  }

  // --- DELETE FROM DATABASE ---
  Future<void> revokeAccess(HPModel hp) async {
    if (hp.id == null) return;

    // Update UI Instantly
    hp.isConnected = false; hp.accessibleData = []; hp.timeframe = "None"; hp.accessDate = "";
    providers.sort((a, b) {
      if (a.isConnected && !b.isConnected) return -1;
      if (!a.isConnected && b.isConnected) return 1;
      return a.name.compareTo(b.name);
    });
    notifyListeners();

    try { await Supabase.instance.client.from('user_hp_connections').delete().eq('id', hp.id!); hp.id = null; } 
    catch (e) { print("Failed to revoke HP access: $e"); }
  }
}