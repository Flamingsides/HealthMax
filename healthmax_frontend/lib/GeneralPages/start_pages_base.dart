import 'package:flutter/material.dart' hide BackButton;
import 'package:healthmax_frontend/GeneralPages/auth/auth_service.dart';
import 'package:healthmax_frontend/UserPages/registration_intro.dart';
import 'package:healthmax_frontend/UserPages/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'helper_widgets.dart'; // Your custom UI widgets
import '../GeneralPages/auth_provider.dart'; // Note: Adjust this path if your AuthProvider is saved elsewhere!

// ==========================================
// 1. START PAGE (Role Selection Gateway)
// ==========================================
class StartPage extends StatelessWidget {
  final String heading1;
  final String heading2;
  final WidgetBuilder loginPage;
  final WidgetBuilder registrationPage;
  final BoxDecoration? decoration;
  final VoidCallback? onLoginSuccess;
  final String homeRoute;

  const StartPage({
    super.key,
    required this.heading1,
    required this.heading2,
    required this.loginPage,
    required this.registrationPage,
    required this.homeRoute,
    this.decoration,
    this.onLoginSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Screen(
      bgDecoration: decoration,
      child: ListView(
        children: [
          BackButton(),
          const SizedBox(height: 100),
          Text(
            heading1,
            style: const TextStyle(
              fontSize: 45,
              fontFamily: "LexendTeraNormal",
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            heading2,
            style: const TextStyle(
              fontSize: 30,
              fontFamily: "LexendMegaNormal",
              color: Color.fromARGB(255, 249, 234, 67),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 300),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomButton(
                label: "LOGIN",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: loginPage),
                  );
                },
                buttonStyle: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  padding: const EdgeInsets.all(5),
                ),
                textColor: Colors.black87,
              ),
              const SizedBox(height: 20),
              CustomButton(
                label: "REGISTER",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: registrationPage),
                  );
                },
                buttonStyle: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  padding: const EdgeInsets.all(5),
                ),
                textColor: Colors.black87,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. REGISTRATION PAGE (API Ready)
// ==========================================
class RegistrationPage extends StatefulWidget {
  final WidgetBuilder postRegistration;
  final WidgetBuilder loginPage;
  final String role; // "user" or "hp"

  const RegistrationPage({
    super.key,
    required this.loginPage,
    required this.postRegistration,
    required this.role,
  });

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  // Removed the global AuthService variable so it doesn't conflict with AuthProvider
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isSupabaseLoading = false; // Local loading state for Supabase

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void register() async {
    final username = _usernameCtrl.text;
    final email = _emailCtrl.text;
    final password = _passwordCtrl.text;
    final confirmPassword = _confirmCtrl.text;

    // Presence check
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Double entry check
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (widget.role == "user") {
      // ==========================================
      // 1. USER REGISTRATION (SUPABASE)
      // ==========================================
      setState(() => _isSupabaseLoading = true);
      
      try {
        final authService = AuthService();
        final response = await authService.register(username, email, password, "Lose Weight");
        
        if (response == null || response.user == null) {
          throw const AuthException("Registration failed");
        }

        if (mounted) {
          context.read<UserProvider>().setUsername(username);

          // THE FIX: Use widget.postRegistration instead of hardcoding the User intro page!
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: widget.postRegistration),
            (_) => false,
          );
        }
      } on AuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Registration Failed: ${e.message}"), backgroundColor: Colors.redAccent));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Registration Failed: ${e.toString()}"), backgroundColor: Colors.redAccent));
        }
      } finally {
        if (mounted) setState(() => _isSupabaseLoading = false);
      }
      
    } else {
      // ==========================================
      // 2. HP REGISTRATION (FASTAPI / PROVIDER)
      // ==========================================
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      bool success = await authProvider.registerBaseAccount(username, email, password, widget.role);

      if (success && mounted) {
        // THE FIX: Route to the HP specific post-registration page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: widget.postRegistration),
          (_) => false,
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("HP Registration Failed!"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Screen(
      bgDecoration: bgGradientHP, // Replace with dynamic widget.decoration if needed
      child: ListView(
        children: [
          BackButton(),
          const SizedBox(height: 50),
          const CustomHeading1(text: "Hello!"),
          const SizedBox(height: 3),
          const CustomHeading2(text: "Register to get started!"),
          const SizedBox(height: 30),

          _buildTextField("Username", _usernameCtrl, false),
          const SizedBox(height: 20),
          _buildTextField("Email", _emailCtrl, false),
          const SizedBox(height: 20),
          _buildTextField("Password", _passwordCtrl, true),
          const SizedBox(height: 20),
          _buildTextField("Confirm Password", _confirmCtrl, true),
          const SizedBox(height: 50),

          // Check both loading states so the UI doesn't freeze!
          (_isSupabaseLoading || authProvider.isLoading)
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : CustomShortButton(
                  label: "Register",
                  width: 200,
                  onPressed: register,
                ),
          CustomQuestionLink(
            question: "Already have an account?",
            linkText: "Login now!",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: widget.loginPage),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    TextEditingController controller,
    bool isPassword,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 20,
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. LOGIN PAGE (API Ready)
// ==========================================
class LoginPage extends StatefulWidget {
  final WidgetBuilder registrationPage;
  final BoxDecoration? decoration;
  final VoidCallback? onLoginSuccess;
  final String homeRoute;
  final String role; // "user" or "hp"

  const LoginPage({
    super.key,
    required this.registrationPage,
    required this.homeRoute,
    required this.role,
    this.decoration,
    this.onLoginSuccess,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Screen(
      bgDecoration: widget.decoration,
      child: ListView(
        children: [
          BackButton(),
          const SizedBox(height: 50),
          const CustomHeading1(text: "Welcome"),
          const CustomHeading1(text: "back!"),
          const SizedBox(height: 10),
          const CustomHeading2(text: "Glad to see you again!"),
          const SizedBox(height: 30),

          _buildTextField("Username", _usernameCtrl, false),
          const SizedBox(height: 20),
          _buildTextField("Password", _passwordCtrl, true),
          const SizedBox(height: 50),

          auth.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : CustomShortButton(
                  label: "Login",
                  width: 200,
                  onPressed: () async {
                    // 1. Validate fields
                    if (_usernameCtrl.text.isEmpty ||
                        _passwordCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please fill all fields!"),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    bool success = false;
                    if (widget.role == "user") {
                      // TODO: Enable Supabase login
                      AuthService auth = AuthService();
                      try {
                        AuthResponse response = await auth
                            .loginWithUsernameAndPassword(
                              _usernameCtrl.text,
                              _passwordCtrl.text,
                            );

                        if (response.user == null) {
                          print(response.toString());
                          throw AuthException(
                            "Login failed! Check credentials.",
                          );
                        }

                        if (await auth.isUserDetailsInitialised()) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            widget.homeRoute,
                            (route) => false,
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RegistrationIntro(),
                            ),
                          );
                        }
                      } on AuthException catch (e) {
                        print(e.toString());
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.message),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }
                    } else {
                      // 2. Call FastAPI Provider
                      success = await auth.login(
                        _usernameCtrl.text,
                        _passwordCtrl.text,
                        widget.role,
                      );

                      // 3. Route on Success
                      if (success && mounted) {
                        if (widget.onLoginSuccess != null) {
                          widget.onLoginSuccess!();
                        } else {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            widget.homeRoute,
                            (route) => false,
                          );
                        }
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Invalid Credentials!"),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    }
                  },
                ),
          CustomQuestionLink(
            question: "Don't have an account?",
            linkText: "Register Now!",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: widget.registrationPage),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    TextEditingController controller,
    bool isPassword,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 20,
          ),
        ),
      ),
    );
  }
}
