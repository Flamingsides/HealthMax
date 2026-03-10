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
      height: 95,
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
          )
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
          unselectedItemColor: Colors.grey.shade400,
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          onTap: (index) => _handleNavigation(context, index),
          items: [
            _buildElegantNavItem(Icons.home_rounded, 'Home', activeColor, currentIndex == 0),
            _buildElegantNavItem(Icons.people_alt_outlined, 'Users', activeColor, currentIndex == 1),
            _buildElegantNavItem(Icons.analytics_outlined, 'Requests', activeColor, currentIndex == 2),
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

  // ---------- 3. UI COMPONENT HELPERS ----------
  BottomNavigationBarItem _buildElegantNavItem(IconData icon, String label, Color color, bool isActive) {
    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Icon(icon, size: 26),
              ),
              if (isActive)
                Positioned(
                  top: -7,
                  child: Container(
                    height: 5,
                    width: 35,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(1),
                        topRight: Radius.circular(1),
                        bottomLeft: Radius.circular(6),
                        bottomRight: Radius.circular(6),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
      label: label,
    );
  }
}