import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class HPBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Color activeColor;

  const HPBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final bgColor = Theme.of(context).colorScheme.surface; 
    final shadowColor = isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.08);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 75,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.home_rounded, 'Home', 0, isDark),
              _buildNavItem(context, Icons.people_alt_outlined, 'Users', 1, isDark),
              _buildNavItem(context, Icons.analytics_outlined, 'Requests', 2, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index, bool isDark) {
    bool isActive = currentIndex == index;
    final defaultColor = isDark ? Colors.white54 : Colors.black87;

    return Expanded(
      child: GestureDetector(
        onTap: () => _handleNavigation(context, index),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // --- FIXED: Locked strictly to the top edge ---
            if (isActive)
              Positioned(
                top: 0,
                child: Container(
                  height: 5,
                  width: 40,
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(6), bottomRight: Radius.circular(6)),
                    boxShadow: [BoxShadow(color: activeColor.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 5),
                Icon(icon, size: 28, color: isActive ? activeColor : defaultColor),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? activeColor : defaultColor,
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
                    fontFamily: "LexendExaNormal",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == currentIndex) return;
    switch (index) {
      case 0: Navigator.pushReplacementNamed(context, '/hp_home'); break;
      case 1: Navigator.pushReplacementNamed(context, '/hp_users'); break;
      case 2: Navigator.pushReplacementNamed(context, '/hp_requests'); break;
    }
  }
}