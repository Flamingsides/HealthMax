import 'package:flutter/material.dart';

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
    return Container(
      height: 95,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Softer, premium shadow
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.white,
          selectedItemColor: activeColor,
          unselectedItemColor: Colors.grey.shade400,
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, fontFamily: "LexendExaNormal"),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, fontFamily: "LexendExaNormal"),
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
                padding: const EdgeInsets.only(top: 10.0, bottom: 4.0),
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
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
                      boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 3))],
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