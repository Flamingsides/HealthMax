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
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;

    try {
      // 1. Fetch fields that are ONLY filled out at the END of the questionnaire
      final data = await Supabase.instance.client
          .from('users')
          .select('gender, height_cm, weight_kg') // Select specific required fields
          .eq('id', user.id)
          .maybeSingle(); 

      // 2. If the row doesn't exist at all, they aren't registered.
      if (data == null) return false;

      // 3. THE CATCH: If the row exists, but the questionnaire data is empty/null/0,
      // it means they pressed back before finishing!
      if (data['gender'] == null || 
          data['height_cm'] == null || data['height_cm'] == 0 ||
          data['weight_kg'] == null || data['weight_kg'] == 0) {
        return false; 
      }

      // 4. Row exists AND has real data = Fully Registered!
      return true; 
      
    } catch (e) {
      print("Error checking registration status: $e");
      return false;
    }
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

  Future<bool> isRegistered() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;

    try {
      // Checks if the user actually completed the questions and saved to the DB
      final response = await Supabase.instance.client
          .from('users')
          .select('id') 
          .eq('id', user.id)
          .maybeSingle();

      return response != null; // Returns TRUE if finished, FALSE if incomplete
    } catch (e) {
      return false;
    }
  }
}
