import 'package:flutter/material.dart' hide BackButton;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:healthmax_frontend/GeneralPages/auth/auth_service.dart';
import 'package:healthmax_frontend/UserPages/registration_intro.dart'; // <-- Intro Page Imported
import 'package:healthmax_frontend/UserPages/user_provider.dart';

import 'helper_widgets.dart'; 
import '../GeneralPages/auth_provider.dart'; 
import '../theme_provider.dart'; 

import 'package:healthmax_frontend/UserPages/calorie_provider.dart';
import 'package:healthmax_frontend/UserPages/goal_provider.dart';
import 'package:healthmax_frontend/GeneralPages/health_providers.dart';
import 'package:healthmax_frontend/UserPages/hp_providers.dart';
import 'package:healthmax_frontend/UserPages/feedback_provider.dart';

// ==========================================
// 1. START PAGE
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
    final theme = Provider.of<ThemeProvider>(context); 

    return Screen(
      bgDecoration: decoration,
      child: ListView(
        children: [
          const BackButton(),
          const SizedBox(height: 100),
          Text(
            theme.translate(heading1), 
            style: const TextStyle(fontSize: 45, fontFamily: "LexendTeraNormal", fontWeight: FontWeight.w900, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          Text(
            theme.translate(heading2), 
            style: const TextStyle(fontSize: 30, fontFamily: "LexendMegaNormal", color: Color.fromARGB(255, 249, 234, 67)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 300),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomButton(
                label: theme.translate('LOGIN'), 
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: loginPage)),
                buttonStyle: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, padding: const EdgeInsets.all(5)),
                textColor: Colors.black87,
              ),
              const SizedBox(height: 20),
              CustomButton(
                label: theme.translate('REGISTER'), 
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: registrationPage)),
                buttonStyle: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, padding: const EdgeInsets.all(5)),
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
// 2. REGISTRATION PAGE
// ==========================================
class RegistrationPage extends StatefulWidget {
  final WidgetBuilder postRegistration;
  final WidgetBuilder loginPage;
  final String role; 

  const RegistrationPage({super.key, required this.loginPage, required this.postRegistration, required this.role});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isSupabaseLoading = false; 

  @override
  void dispose() {
    _usernameCtrl.dispose(); _emailCtrl.dispose(); _passwordCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  void register() async {
    final username = _usernameCtrl.text;
    final email = _emailCtrl.text;
    final password = _passwordCtrl.text;
    final confirmPassword = _confirmCtrl.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields!"), backgroundColor: Colors.redAccent));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match!"), backgroundColor: Colors.redAccent));
      return;
    }

    if (widget.role == "user") {
      setState(() => _isSupabaseLoading = true);
      try {
        final authService = AuthService();
        final response = await authService.register(username, email, password, "N/A");

        if (response == null || response.user == null) throw const AuthException("Registration failed");
        
        if (mounted) {
          context.read<UserProvider>().setUsername(username);
          
          // ==========================================
          // THE FIX: Route directly to the Intro Page
          // ==========================================
          Navigator.pushAndRemoveUntil(
            context, 
            MaterialPageRoute(builder: (_) => const RegistrationIntro()), 
            (_) => false
          );
        }
      } on AuthException catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Registration Failed: ${e.message}"), backgroundColor: Colors.redAccent));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Registration Failed: ${e.toString()}"), backgroundColor: Colors.redAccent));
      } finally {
        if (mounted) setState(() => _isSupabaseLoading = false);
      }
    } else {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success = await authProvider.registerBaseAccount(username, email, password, widget.role);
      if (success && mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: widget.postRegistration), (_) => false);
      else if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("HP Registration Failed!"), backgroundColor: Colors.redAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Provider.of<ThemeProvider>(context); 

    return Screen(
      bgDecoration: bgGradientHP, 
      child: ListView(
        children: [
          const BackButton(),
          const SizedBox(height: 50),
          CustomHeading1(text: theme.translate("Hello!")),
          const SizedBox(height: 3),
          CustomHeading2(text: theme.translate("Register to get started!")),
          const SizedBox(height: 30),

          _buildTextField(theme.translate("Username"), _usernameCtrl, false), const SizedBox(height: 20),
          _buildTextField(theme.translate("Email"), _emailCtrl, false), const SizedBox(height: 20),
          _buildTextField(theme.translate("Password"), _passwordCtrl, true), const SizedBox(height: 20),
          _buildTextField(theme.translate("Confirm Password"), _confirmCtrl, true), const SizedBox(height: 50),

          (_isSupabaseLoading || authProvider.isLoading)
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : CustomShortButton(label: theme.translate("REGISTER"), width: 200, onPressed: register),
          CustomQuestionLink(
            question: theme.translate("Already have an account?"),
            linkText: theme.translate("Login now!"),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: widget.loginPage)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, bool isPassword) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: TextField(
        controller: controller, obscureText: isPassword,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hint, hintStyle: const TextStyle(color: Colors.white54),
          filled: true, fillColor: Colors.white.withValues(alpha: 0.1),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        ),
      ),
    );
  }
}

// ==========================================
// 3. LOGIN PAGE 
// ==========================================
class LoginPage extends StatefulWidget {
  final WidgetBuilder registrationPage;
  final BoxDecoration? decoration;
  final VoidCallback? onLoginSuccess;
  final String homeRoute;
  final String role; 

  const LoginPage({super.key, required this.registrationPage, required this.homeRoute, required this.role, this.decoration, this.onLoginSuccess});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoggingIn = false;

  @override
  void dispose() { _usernameCtrl.dispose(); _passwordCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final theme = Provider.of<ThemeProvider>(context); 

    return Screen(
      bgDecoration: widget.decoration,
      child: ListView(
        children: [
          const BackButton(),
          const SizedBox(height: 50),
          CustomHeading1(text: theme.translate("Welcome")),
          CustomHeading1(text: theme.translate("back!")),
          const SizedBox(height: 10),
          CustomHeading2(text: theme.translate("Glad to see you again!")),
          const SizedBox(height: 30),

          _buildTextField(theme.translate("Username"), _usernameCtrl, false), const SizedBox(height: 20),
          _buildTextField(theme.translate("Password"), _passwordCtrl, true), const SizedBox(height: 50),

          (auth.isLoading || _isLoggingIn)
              ? const Center(child: Column(
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 10),
                    Text("Syncing with Cloud...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                  ],
                ))
              : CustomShortButton(
                  label: theme.translate("LOGIN"),
                  width: 200,
                  onPressed: () async {
                    if (_usernameCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields!"), backgroundColor: Colors.redAccent)); return;
                    }

                    if (widget.role == "user") {
                      setState(() => _isLoggingIn = true);
                      AuthService authService = AuthService();
                      try {
                        AuthResponse response = await authService.loginWithUsernameAndPassword(_usernameCtrl.text, _passwordCtrl.text);
                        if (response.user == null) throw const AuthException("Login failed! Check credentials.");

                        if (await authService.isUserDetailsInitialised()) {
                          if (mounted) {
                            await Future.wait([
                              context.read<CalorieProvider>().fetchUserDataAndLogs(),
                              context.read<HealthProvider>().checkDeviceAndStartMock(), 
                              context.read<GoalProvider>().fetchGoalData(),
                              context.read<HPProvider>().fetchHPConnections(),
                              context.read<FeedbackProvider>().fetchFeedback(),
                            ]);

                            Navigator.pushNamedAndRemoveUntil(context, widget.homeRoute, (route) => false);
                          }
                        } else {
                          // Falls back to Intro if they closed app midway through registration
                          if (mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistrationIntro()));
                        }
                      } on AuthException catch (e) {
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent));
                      } catch (e) {
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent));
                      } finally {
                        if (mounted) setState(() => _isLoggingIn = false);
                      }
                    } else {
                      bool success = await auth.login(_usernameCtrl.text, _passwordCtrl.text, widget.role);
                      if (success && mounted) {
                        if (widget.onLoginSuccess != null) widget.onLoginSuccess!();
                        else Navigator.pushNamedAndRemoveUntil(context, widget.homeRoute, (route) => false);
                      } else if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid Credentials!"), backgroundColor: Colors.redAccent));
                    }
                  },
                ),
          CustomQuestionLink(
            question: theme.translate("Don't have an account?"),
            linkText: theme.translate("Register Now!"),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: widget.registrationPage)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, bool isPassword) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: TextField(
        controller: controller, obscureText: isPassword,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hint, hintStyle: const TextStyle(color: Colors.white54),
          filled: true, fillColor: Colors.white.withValues(alpha: 0.1),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        ),
      ),
    );
  }
}