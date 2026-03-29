import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../theme_provider.dart'; 

class HPGlassyProfile extends StatelessWidget {
  final VoidCallback? onTap;

  const HPGlassyProfile({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    // --- HP SIGNATURE PURPLE THEME ---
    const Color hpPurple = Color(0xFF8E33FF); 
    
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return GestureDetector(
      onTap: onTap ?? () => Navigator.pushNamed(context, '/hp_settings'),
      child: SizedBox(
        width: 55, 
        height: 55,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            ClipOval( 
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  width: 50, 
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle, 
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 26), 
                ),
              ),
            ),
            
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: hpPurple,
                  shape: BoxShape.circle,
                  border: Border.all(color: isDark ? bgColor : hpPurple, width: 2.5), 
                ),
                child: const Icon(Icons.settings_rounded, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}