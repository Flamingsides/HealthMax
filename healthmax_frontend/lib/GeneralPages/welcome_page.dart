import 'package:flutter/material.dart';
import 'start_pages_base.dart'; 
import '../UserPages/registration_intro.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  // ==========================================
  // 1. HP ROUTING & THEME (BRIGHT AURORA)
  // ==========================================
  
  BoxDecoration get _hpDecoration => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF4EE2EC), // Glowing light cyan
        Color(0xFF00B4DB), // Vibrant mid cyan
        Color(0xFF0083B0), // Rich ocean blue (not gloomy!)
      ],
    ),
  );

  WidgetBuilder _getHPRegistrationPage(String route) {
    return (context) => RegistrationPage(
      loginPage: (context) => LoginPage(
        homeRoute: route,
        registrationPage: _getHPRegistrationPage(route),
        decoration: _hpDecoration,
      ),
      postRegistration: (context) => LoginPage(
        homeRoute: route,
        registrationPage: _getHPRegistrationPage(route),
        decoration: _hpDecoration,
      ),
    );
  }

  Widget _buildHPStartPage() {
    return StartPage(
      heading1: "CARE",
      heading2: "Beyond Clinic",
      homeRoute: "/hp_home",
      decoration: _hpDecoration, 
      loginPage: (context) => LoginPage(
        homeRoute: "/hp_home",
        registrationPage: _getHPRegistrationPage("/hp_home"),
        decoration: _hpDecoration,
      ),
      registrationPage: _getHPRegistrationPage("/hp_home"),
    );
  }

  // ==========================================
  // 2. USER ROUTING & THEME (VIBRANT INDIGO)
  // ==========================================

  BoxDecoration get _userDecoration => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFA6B1E1), // Soft, airy periwinkle
        Color(0xFF6A75D9), // Vibrant indigo
        Color(0xFF4C55B5), // Deep rich purple (not black!)
      ],
    ),
  );

  Widget _buildUserStartPage() {
    return StartPage(
      heading1: "WELLNESS",
      heading2: "BEGINS HERE",
      homeRoute: "/user_homepage",
      decoration: _userDecoration, 
      loginPage: (context) => LoginPage(
        homeRoute: "/user_homepage",
        decoration: _userDecoration,
        registrationPage: (context) => const RegistrationIntro(), 
      ),
      registrationPage: (context) => const RegistrationIntro(), 
    );
  }

  // ==========================================
  // 3. MAIN BUILD METHOD (LIGHT & FRESH)
  // ==========================================
  @override
  Widget build(BuildContext context) {
    final Color brandHighlight = const Color(0xFF00D1FF); 
    
    // THE FIX: Restored the light, welcoming background!
    final Color gradientStart = const Color(0xFF8A98E8); 
    final Color gradientEnd = const Color(0xFF5D34EC);   

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [gradientStart, gradientEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(), 

              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: brandHighlight.withValues(alpha: 0.15),
                  boxShadow: [
                    BoxShadow(color: brandHighlight.withValues(alpha: 0.3), blurRadius: 40, spreadRadius: 10),
                  ],
                ),
                child: Icon(Icons.monitor_heart_outlined, size: 65, color: brandHighlight),
              ),
              const SizedBox(height: 35),

              const Text(
                "WELCOME TO",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white70,
                  letterSpacing: 4.0,
                  fontFamily: "LexendExaNormal",
                ),
              ),
              const SizedBox(height: 5),
              
              Text(
                "HealthMax.",
                style: TextStyle(
                  fontSize: 55, 
                  fontWeight: FontWeight.w900,
                  color: Colors.white, // Changed back to white so it pops on the light blue background!
                  letterSpacing: -2.0,
                  fontFamily: "LexendExaNormal",
                  shadows: [
                    Shadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 5)),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              
              const Text(
                "Your Virtual Health Companion",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),

              const Spacer(), 

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: [
                    _buildRoleButton(
                      context, 
                      title: "User", 
                      textColor: gradientEnd, 
                      targetPage: _buildUserStartPage(),
                    ),
                    // --- ELEGANT USER EXPLANATION ---
                    const SizedBox(height: 10),
                    const Text(
                      "Track your personal health, nutrition, and daily fitness goals.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12, 
                        color: Colors.white70, 
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    _buildRoleButton(
                      context, 
                      title: "Healthcare Provider", 
                      textColor: const Color(0xFF0083B0), 
                      targetPage: _buildHPStartPage(),
                    ),
                    // --- ELEGANT HP EXPLANATION ---
                    const SizedBox(height: 10),
                    const Text(
                      "Monitor patient data, review analytics, and provide clinical feedback.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12, 
                        color: Colors.white70, 
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60), 
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(BuildContext context, {required String title, required Color textColor, required Widget targetPage}) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => targetPage));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, 
        foregroundColor: textColor, 
        minimumSize: const Size(double.infinity, 65), 
        elevation: 10,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
      ),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.2, fontFamily: "LexendExaNormal"),
      ),
    );
  }
}