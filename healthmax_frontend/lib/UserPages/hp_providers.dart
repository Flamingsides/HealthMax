import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HPModel {
  String? id; 
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
      for (var hp in providers) { hp.isConnected = false; hp.accessibleData = []; hp.accessDate = ""; hp.timeframe = "None"; hp.id = null; }

      // Map database rows to our list
      for (var row in data) {
        int index = providers.indexWhere((hp) => hp.name == row['hospital_name']);
        
        if (index != -1) {
          providers[index].id = row['id'];
          providers[index].isConnected = true;
          // Safely parse the database Array/JSON into a Dart List<String>
          providers[index].accessibleData = (row['access_data'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
          providers[index].timeframe = row['timeframe'] ?? "None";
          providers[index].accessDate = row['expiry_date'] ?? "";
          
          // Move connected HP to the top of the list
          var connectedHP = providers.removeAt(index);
          providers.insert(0, connectedHP);
        }
      }
      notifyListeners();
    } catch (e) { 
      print("Error fetching HP data: $e"); 
    }
  }

  // --- WRITE TO DATABASE ---
  Future<void> grantAccess(HPModel hp, List<String> data, String timeframe, String expiryDate) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("User not logged in.");

    // Optimistic UI Update
    hp.isConnected = true; hp.accessibleData = List.from(data); hp.timeframe = timeframe; hp.accessDate = expiryDate;
    providers.remove(hp); providers.insert(0, hp);
    notifyListeners();

    try {
      final response = await supabase.from('user_hp_connections').insert({
        'user_id': user.id, 
        'hospital_name': hp.name, 
        'access_data': data, 
        'timeframe': timeframe, 
        'expiry_date': expiryDate
      }).select().single();
      
      hp.id = response['id']; // Save the DB's UUID
    } catch (e) { 
      // Rollback UI if database rejects it
      hp.isConnected = false; hp.accessibleData = []; hp.timeframe = "None"; hp.accessDate = "";
      providers.remove(hp); providers.add(hp); // Move back down
      notifyListeners();
      print("Failed to grant HP access: $e"); 
      rethrow; 
    }
  }

  // --- DELETE FROM DATABASE (AUTO-CLEANUP FIX) ---
  Future<void> revokeAccess(HPModel hp) async {
    if (hp.id == null) return;
    String originalId = hp.id!;
    final user = Supabase.instance.client.auth.currentUser;

    // Optimistic UI Update
    hp.isConnected = false; hp.accessibleData = []; hp.timeframe = "None"; hp.accessDate = "";
    providers.sort((a, b) {
      if (a.isConnected && !b.isConnected) return -1;
      if (!a.isConnected && b.isConnected) return 1;
      return a.name.compareTo(b.name);
    });
    notifyListeners();

    try { 
      // 1. Clean up "Orphaned" appointments tied to this specific provider
      if (user != null) {
        await Supabase.instance.client.from('book_appointment')
            .delete()
            .eq('user_id', user.id)
            .eq('provider_name', hp.name)
            .inFilter('status', ['Pending', 'Confirmed']);
      }

      // 2. Delete the actual HP connection
      await Supabase.instance.client.from('user_hp_connections').delete().eq('id', originalId); 
      hp.id = null; 
    } catch (e) { 
      // Rollback UI
      hp.id = originalId; hp.isConnected = true;
      notifyListeners();
      print("Failed to revoke HP access: $e"); 
      rethrow;
    }
  }
}