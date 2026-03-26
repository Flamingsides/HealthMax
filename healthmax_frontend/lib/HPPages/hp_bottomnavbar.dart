import 'package:flutter/material.dart';

class HPBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Color activeColor;

  const HPBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.activeColor,
  });

  // ---------- 1. MAIN BUILD METHOD ----------
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), // Matches user shadow
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      // SafeArea ensures it perfectly hugs the bottom of the screen
      child: SafeArea(
        child: SizedBox(
          height: 75, // Fixed height for perfect indicator alignment
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.home_rounded, 'Home', 0),
              _buildNavItem(context, Icons.people_alt_outlined, 'Users', 1),
              _buildNavItem(context, Icons.analytics_outlined, 'Requests', 2),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- 2. CUSTOM NAV ITEM BUILDER ----------
  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    bool isActive = currentIndex == index;

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
                  color: isActive ? activeColor : Colors.black, // Matches user text coloring
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? activeColor : Colors.black,
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
        Navigator.pushReplacementNamed(context, '/hp_home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/hp_users');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/hp_requests');
        break;
    }
  }
}