import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart'; // Ensure this path is correct
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

  @override
  Widget build(BuildContext context) {
    // ==========================================
    // DYNAMIC THEME VARIABLES
    // ==========================================
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final themePurple = Theme.of(context).primaryColor;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = isDark ? Colors.white54 : Colors.grey;
    final dividerColor = Theme.of(context).dividerColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // --- PREMIUM SLIVER APP BAR ---
              SliverAppBar(
                automaticallyImplyLeading: false,
                backgroundColor: themePurple,
                expandedHeight: 200.0,
                toolbarHeight: 90.0,
                pinned: true,
                elevation: 0,
                scrolledUnderElevation: 0.0,
                surfaceTintColor: Colors.transparent,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 30.0, top: 10.0),
                    child: Center(child: HPGlassyProfile(onTap: () => Navigator.pushNamed(context, '/hp_settings'))),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 40, 30, 0),
                      child: const Text(
                        "Requests.",
                        style: TextStyle(fontSize: 45, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: "LexendExaNormal", letterSpacing: -1.0, height: 1.1),
                      ),
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(30),
                  child: Transform.translate(
                    offset: const Offset(0, 1),
                    child: Container(
                      height: 31, 
                      width: double.infinity, 
                      decoration: BoxDecoration(color: bgColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(40)))
                    ),
                  ),
                ),
              ),

              // --- MAIN BODY CONTENT ---
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel("PATIENT APPLICATIONS", textSecondary),
                    
                    _buildExpandableRequestList(themePurple, surfaceColor, bgColor, textPrimary, isDark, dividerColor),

                    const SizedBox(height: 35),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: _buildFeedbackContainer(surfaceColor, isDark, dividerColor),
                    ),

                    const SizedBox(height: 120), // Bottom padding for NavBar
                  ],
                ),
              ),
            ],
          ),

          // --- BOTTOM NAVIGATION BAR ---
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: HPBottomNavBar(currentIndex: 2, activeColor: themePurple),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // UI COMPONENT HELPERS
  // ==========================================

  Widget _buildSectionLabel(String label, Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 10, 30, 15),
      child: Text(
        label, 
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: textSecondary, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildExpandableRequestList(Color themePurple, Color surfaceColor, Color bgColor, Color textPrimary, bool isDark, Color dividerColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      height: _isExpanded ? 420 : 200, 
      margin: const EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: dividerColor),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: ListView.builder(
              physics: _isExpanded ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 80), 
              itemCount: _newRequests.length,
              itemBuilder: (context, index) => _buildRequestTile(_newRequests[index], bgColor, surfaceColor, textPrimary, isDark, dividerColor, themePurple),
            ),
          ),

          // Glassy Blur Badge
          Positioned(
            bottom: 15,
            child: GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    decoration: BoxDecoration(
                      color: themePurple.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                      boxShadow: [BoxShadow(color: themePurple.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isExpanded ? "SHOW LESS" : "${_newRequests.length} PENDING", 
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, fontFamily: "LexendExaNormal", letterSpacing: 0.5),
                        ),
                        const SizedBox(width: 8),
                        Icon(_isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 20),
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

  Widget _buildRequestTile(UserModel user, Color bgColor, Color surfaceColor, Color textPrimary, bool isDark, Color dividerColor, Color themePurple) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: bgColor, 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dividerColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
        leading: CircleAvatar(
          radius: 20, 
          backgroundColor: surfaceColor, 
          child: Icon(Icons.person, size: 20, color: themePurple),
        ),
        title: Text(user.fullName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textPrimary)),
        subtitle: Text("Device: ${user.device}", style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.grey.shade600, fontWeight: FontWeight.w600)),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: surfaceColor, shape: BoxShape.circle),
          child: Icon(Icons.arrow_forward_ios_rounded, size: 12, color: textPrimary),
        ),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HPRequestSelected(user: user))),
      ),
    );
  }

  Widget _buildFeedbackContainer(Color surfaceColor, bool isDark, Color dividerColor) {
    // Keep this card distinct by forcing a dark elegant look, or matching the surface in dark mode
    final containerColor = isDark ? surfaceColor : const Color(0xFF1A1A1A);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: containerColor, 
        borderRadius: BorderRadius.circular(30),
        border: isDark ? Border.all(color: dividerColor) : null,
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8), 
                decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), 
                child: const Icon(Icons.chat_bubble_outline, color: Colors.greenAccent, size: 20),
              ),
              const SizedBox(width: 15),
              const Text("Consultation Desk", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: "LexendExaNormal")),
            ],
          ),
          const SizedBox(height: 25),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _feedbackAvatar("Adam", "HP"),
                _feedbackAvatar("Sarah", "GL"),
                _feedbackAvatar("Mike", "HR"),
                Container(
                  width: 45, height: 45,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle, border: Border.all(color: Colors.white24)),
                  child: const Center(child: Text("+5", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                ),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: const Text("Process Feedbacks", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: "LexendExaNormal")),
          )
        ],
      ),
    );
  }

  Widget _feedbackAvatar(String name, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          Container(
            width: 45, height: 45,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
            child: Center(child: Text(label, style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}