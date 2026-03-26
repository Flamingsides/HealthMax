import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart'; // Ensure this path points correctly to your theme provider!

class UserBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Color activeColor = const Color(0xFF5A84F1); 

  const UserBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  // ---------- 1. MAIN BUILD METHOD ----------
  @override
  Widget build(BuildContext context) {
    // Listen to the theme provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Dynamically grab colors based on the theme
    final bgColor = Theme.of(context).colorScheme.surface; // White in light mode, Dark Grey in dark mode
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.08);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      // SafeArea ensures it doesn't overlap with the iPhone home bar / Android gestures
      child: SafeArea(
        child: SizedBox(
          height: 75, // Fixed height for the interactive area
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.home_filled, 'Home', 0, isDark),
              _buildNavItem(context, Icons.book, 'History', 1, isDark),
              _buildNavItem(context, Icons.restaurant, 'Calorie', 2, isDark),
              _buildNavItem(context, Icons.bar_chart, 'Statistics', 3, isDark),
              _buildNavItem(context, Icons.track_changes_rounded, 'Target', 4, isDark),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- 2. CUSTOM NAV ITEM BUILDER ----------
  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index, bool isDark) {
    bool isActive = currentIndex == index;
    
    // Dynamic text/icon color for unselected items
    final defaultColor = isDark ? Colors.white54 : Colors.black87;

    return Expanded(
      child: GestureDetector(
        onTap: () => _handleNavigation(context, index),
        behavior: HitTestBehavior.opaque, // Makes the whole expanded area clickable
        child: Stack(
          alignment: Alignment.center,
          children: [
            // --- THE FIXED TOP INDICATOR ---
            if (isActive)
              Positioned(
                top: 0, // Locks it exactly to the top edge of the white container
                child: Container(
                  height: 5,
                  width: 40,
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            
            // --- ICON AND TEXT ---
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 5), // Slight push down so it doesn't hit the indicator
                Icon(
                  icon,
                  size: 28,
                  color: isActive ? activeColor : defaultColor, // Uses dynamic default color
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? activeColor : defaultColor, // Uses dynamic default color
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

  // ---------- 3. NAVIGATION LOGIC ----------
  void _handleNavigation(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/user_homepage');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/user_history');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/user_calorie');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/user_statistic');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/user_target');
        break;
    }
  }
}