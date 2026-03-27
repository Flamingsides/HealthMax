import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class UserGlassyProfile extends StatelessWidget {
  final VoidCallback? onTap;

  const UserGlassyProfile({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    const Color userBlue = Color(0xFF5A84F1); 
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return GestureDetector(
      onTap: onTap ?? () => Navigator.pushNamed(context, '/user_settings'),
      child: SizedBox(
        width: 55, // Increased bounding box for the larger circle
        height: 55,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // --- 1. THE MAIN GLASSY AVATAR (PERFECT CIRCLE) ---
            ClipOval( // Changed to ClipOval
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  width: 50, // Increased size back to normal
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle, // Changed back to circle
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 28, // Slightly larger icon to match the big circle
                  ),
                ),
              ),
            ),
            
            // --- 2. THE TINY SETTINGS COG ---
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: userBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: isDark ? bgColor : userBlue, width: 2.5), 
                ),
                child: const Icon(
                  Icons.settings_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}