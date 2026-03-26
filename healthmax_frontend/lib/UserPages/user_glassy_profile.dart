import 'dart:ui';
import 'package:flutter/material.dart';
import 'user_settings.dart';

class UserGlassyProfile extends StatelessWidget {
  final VoidCallback? onTap;

  const UserGlassyProfile({super.key, this.onTap});

  // ---------- 1. MAIN BUILD METHOD ----------
  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Ensure this route is registered in your main.dart!
              Navigator.pushNamed(context, '/user_settings');
            },
            child: _buildGlassyContainer(),
          ),
        ),
      ),
    );
  }

  // ---------- 2. GLASSY UI STYLING ----------
  Widget _buildGlassyContainer() {
    return Container(
      height: 65,
      width: 65,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.2),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: const Icon(
        Icons.person_outline,
        size: 35,
        color: Colors.white,
      ),
    );
  }
}