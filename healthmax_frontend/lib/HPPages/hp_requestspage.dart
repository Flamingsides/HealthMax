import 'dart:ui';
import 'package:flutter/material.dart';
import 'hp_bottomnavbar.dart';
import 'hp_glassy_profile.dart';
import 'usermodel.dart';
import 'hp_requestselected.dart';

class HPRequestsPage extends StatefulWidget {
  const HPRequestsPage({super.key});

  @override
  State<HPRequestsPage> createState() => _HPRequestsPageState();
}

class _HPRequestsPageState extends State<HPRequestsPage> {
  // --- STATE & DATA ---
  bool _isExpanded = false;

  final List<UserModel> _newRequests = [
    UserModel(username: "diana_p", fullName: "Diana Prince", gender: "F", height: 168, weight: 60, device: "Garmin Venu 3"),
    UserModel(username: "ethan_h", fullName: "Ethan Hunt", gender: "M", height: 178, weight: 80, device: "Apple Watch Ultra"),
    UserModel(username: "clark_k", fullName: "Clark Kent", gender: "M", height: 190, weight: 95, device: "Fitbit Sense 2"),
    UserModel(username: "bruce_w", fullName: "Bruce Wayne", gender: "M", height: 188, weight: 85, device: "Oura Ring Gen3"),
    UserModel(username: "selina_k", fullName: "Selina Kyle", gender: "F", height: 170, weight: 55, device: "Apple Watch S9"),
  ];

  // ---------- 1. MAIN BUILD METHOD (The Page Skeleton) ----------
  @override
  Widget build(BuildContext context) {
    const Color themeColor = Color(0xFF8E33FF);

    return Scaffold(
      backgroundColor: themeColor,
      body: Stack(
        children: [
          // A. TOP BACKGROUND LAYER (Header Text)
          Positioned(
            top: 80, left: 25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Requests.", 
                  style: TextStyle(fontSize: 55, fontWeight: FontWeight.bold, color: Colors.white, height: 2.0)),
              ],
            ),
          ),

          // B. TOP BACKGROUND LAYER (Profile Widget)
          Positioned(
            top: 75, right: 25,
            child: HPGlassyProfile(onTap: () {}),
          ),

          // C. MAIN CONTENT LAYER (White Container)
          Column(
            children: [
              const SizedBox(height: 220), // Spacer to push container below header text
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // SECTION 1: Patient Applications
                        _buildSectionLabel("PATIENT APPLICATIONS"),
                        
                        // SECTION 2: Expandable Request List with Glassy Blur
                        _buildExpandableRequestList(themeColor),

                        // SECTION 3: Visual Divider
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                          child: Divider(thickness: 0.5),
                        ),

                        // SECTION 4: Feedback/Consultation Area
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                          child: _buildFeedbackContainer(themeColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // D. NAVIGATION LAYER (Bottom Bar)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: HPBottomNavBar(currentIndex: 2, activeColor: themeColor),
          ),
        ],
      ),
    );
  }

  // ---------- 2. UI COMPONENT HELPERS (In order of appearance) ----------
  // Helper: Section Label
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 25, 30, 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1.2)),
      ),
    );
  }

  // Helper: The Expandable List with the Blur Effect
  Widget _buildExpandableRequestList(Color themeColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      height: _isExpanded ? 400 : 180, 
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // List Content
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50, 
              borderRadius: BorderRadius.circular(25),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: ListView.builder(
                physics: _isExpanded ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 80), 
                itemCount: _newRequests.length,
                itemBuilder: (context, index) => _buildRequestTile(_newRequests[index]),
              ),
            ),
          ),

          // Glassy Blur Badge
          Positioned(
            bottom: 10,
            child: GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.6), 
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_isExpanded ? "SHOW LESS" : "5 PENDING", 
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        const SizedBox(width: 8),
                        Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper: Individual Request Row
  Widget _buildRequestTile(UserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15), 
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(radius: 14, backgroundColor: Colors.grey.shade50, child: const Icon(Icons.person_outline, size: 14, color: Colors.grey)),
        title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HPRequestSelected(user: user))),
      ),
    );
  }

  // Helper: Dark Consultation Section
  Widget _buildFeedbackContainer(Color themeColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(35)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.chat_bubble_outline, color: Colors.greenAccent, size: 20),
              SizedBox(width: 12),
              Text("Consultation Desk", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _feedbackAvatar("Adam", "HP"),
                _feedbackAvatar("Sarah", "GL"),
                _feedbackAvatar("Mike", "HR"),
                const CircleAvatar(radius: 20, backgroundColor: Colors.white10, child: Text("+5", style: TextStyle(color: Colors.white, fontSize: 10))),
              ],
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: const Text("Process Feedbacks", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
          )
        ],
      ),
    );
  }

  // Helper: Avatar for the Consultation section
  Widget _feedbackAvatar(String name, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Column(
        children: [
          CircleAvatar(radius: 20, backgroundColor: Colors.white10, child: Text(label, style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold))),
          const SizedBox(height: 6),
          Text(name, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }
}