import 'package:flutter/material.dart';
import 'package:healthmax_frontend/UserPages/registration_questions.dart';
import '../GeneralPages/helper_widgets.dart';

class RegistrationIntro extends StatelessWidget {
  const RegistrationIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8E33FF), // themePurple
              Color(0xFF5A84F1), // themeBlue
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Universal Back Button
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15.0, top: 10.0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Header
                      const Text(
                        "Start your\nWellness Journey",
                        style: TextStyle(
                          fontFamily: "LexendExaNormal",
                          fontWeight: FontWeight.w900,
                          fontSize: 38,
                          color: Colors.white,
                          height: 1.2,
                          letterSpacing: -1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "Everything you need to reach your goals, all in one place.",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 50),

                      // Dynamic Native UI Floating Cards (Replaces Static Images)
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 15,
                        runSpacing: 20,
                        children: [
                          _buildFeatureCard("Move.", Icons.directions_run_rounded, const Color(0xFF5A84F1), -0.05),
                          _buildFeatureCard("Track.", Icons.bar_chart_rounded, const Color(0xFFFF9F43), 0.05),
                          _buildFeatureCard("Plan.", Icons.calendar_month_rounded, const Color(0xFFFF6B6B), -0.02),
                          _buildFeatureCard("Rest.", Icons.battery_charging_full_rounded, const Color(0xFFFFD93D), 0.04),
                          _buildFeatureCard("Balance.", Icons.restaurant_rounded, const Color(0xFF2ED573), -0.01),
                        ],
                      ),
                      
                      const SizedBox(height: 70),

                      // Start Button Navigating to RegistrationGender
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegistrationGender()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF8E33FF),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 10,
                          shadowColor: Colors.black.withValues(alpha: 0.2),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Let's Go",
                              style: TextStyle(
                                fontSize: 18, 
                                fontWeight: FontWeight.w900, 
                                fontFamily: "LexendExaNormal", 
                                letterSpacing: 0.5
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.arrow_forward_ios_rounded, size: 20),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build the floating UI cards
  Widget _buildFeatureCard(String title, IconData icon, Color color, double rotation) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
                fontFamily: "LexendExaNormal"
              ),
            ),
          ],
        ),
      ),
    );
  }
}