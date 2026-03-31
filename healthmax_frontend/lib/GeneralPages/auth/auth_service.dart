import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Register new account
  Future<AuthResponse?> register(
    String username,
    String email,
    String password,
    String mainGoal,
  ) async {
    try {
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {"display_name": username, "username": username},
      );

      await _supabase.from("users").insert({
        "id": authResponse.user?.id,
        "username": username,
        "email": email,
        "main_goal": mainGoal,
      });

      print("\nUser Registered: ");
      print(authResponse.user);
      print("\n");

      return authResponse;
    } catch (e) {
      print(e.toString());
      // Let caller handle this exception
      rethrow;
    }
  }

  Future<bool> isUserDetailsInitialised() async {
    if (_supabase.auth.currentUser != null) {
      final response = await _supabase
          .from("users")
          .select(
            "gender",
          ) // Gender field is only added after user details have been initialised
          .eq("id", _supabase.auth.currentUser!.id)
          .maybeSingle();

      return response?.isNotEmpty ?? false;
    }
    return false;
  }

  void initialiseUserDetails(
    String gender,
    DateTime dob,
    double height_cm,
    double weight_kg,
  ) async {
    if (_supabase.auth.currentUser != null) {
      await _supabase
          .from("users")
          .update({
            "gender": gender,
            "dob": dob.toIso8601String().split("T")[0],
            "height_cm": height_cm,
            "weight_kg": weight_kg,
            // total_points and created_at fields handled by database
          })
          .eq("id", _supabase.auth.currentUser!.id);
    } else {
      print("Cant initialise user since no current user");
    }
  }

  Future<AuthResponse> loginWithUsernameAndPassword(
    String username,
    String password,
  ) async {
    final email = await _supabase.rpc(
      "get_email_from_username",
      params: {'p_username': username},
    );
    // final email = await _supabase
    //     .from("users")
    //     .select("email")
    //     .eq("username", username)
    //     .maybeSingle();

    if (email == null || email.toString().isEmpty) {
      throw AuthException("Username not found! Register first.");
    }

    return await loginWithEmailAndPassword(email.toString(), password);
  }

  // Sign in with email and password
  Future<AuthResponse> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> logout() async {
    return await _supabase.auth.signOut();
  }

  // Get email
  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }
}
