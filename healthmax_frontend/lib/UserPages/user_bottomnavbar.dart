import 'package:flutter/material.dart';

class UserBottomNavBar extends StatelessWidget {
  final int currentIndex;
  
  // Using the specific blue color from your screenshot
  final Color activeColor = const Color(0xFF5A84F1); 

  const UserBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  // ---------- 1. MAIN BUILD METHOD ----------
  @override
  Widget build(BuildContext context) {
    return Container(
      // FIX: Removed "height: 95" so the navbar can dynamically adapt 
      // to the device's bottom Safe Area without overflowing.
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.white,
          selectedItemColor: activeColor,
          unselectedItemColor: Colors.black,
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900, fontFamily: "LexendExaNormal"),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontFamily: "LexendExaNormal"),
          onTap: (index) => _handleNavigation(context, index),
          items: [
            _buildNavItem(Icons.home_filled, 'Home', currentIndex == 0),
            _buildNavItem(Icons.book, 'History', currentIndex == 1),
            _buildNavItem(Icons.restaurant, 'Calorie', currentIndex == 2),
            _buildNavItem(Icons.bar_chart, 'Statistics', currentIndex == 3),
            _buildNavItem(Icons.track_changes_rounded, 'Target', currentIndex == 4),
          ],
        ),
      ),
    );
  }

  // ---------- 2. NAVIGATION LOGIC ----------
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

  // ---------- 3. UI COMPONENT HELPERS ----------
  BottomNavigationBarItem _buildNavItem(IconData icon, String label, bool isActive) {
    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              Padding(
                // FIX: Reduced top padding from 15.0 to 10.0 and icon size to 28 
                // to prevent internal overflow while keeping the premium look.
                padding: const EdgeInsets.only(top: 10.0, bottom: 4.0),
                child: Icon(icon, size: 28), 
              ),
              if (isActive)
                Positioned(
                  top: -7, // FIX: Adjusted offset so it stays pinned to the top edge
                  child: Container(
                    height: 6,
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
            ],
          ),
        ],
      ),
      label: label,
    );
  }
}