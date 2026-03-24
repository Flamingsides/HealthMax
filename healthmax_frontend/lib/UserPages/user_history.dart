import 'package:flutter/material.dart';
import 'user_bottomnavbar.dart'; 

class UserHistoryPage extends StatelessWidget {
  const UserHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8F9FA), 
      
      // PLACEHOLDER 
      body: Center(
        child: Text(
          "HISTORY",
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: Colors.black26, 
            letterSpacing: 4,
            fontFamily: "LexendExaNormal",
          ),
        ),
      ),

      // The currentIndex is 1 for History
      bottomNavigationBar: UserBottomNavBar(currentIndex: 1),
    );
  }
}