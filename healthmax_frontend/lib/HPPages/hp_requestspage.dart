import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart'; 
import 'hp_bottomnavbar.dart';
import 'hp_glassy_profile.dart';
import 'usermodel.dart'; // Implemented MockData
import 'hp_requestselected.dart';
import 'hp_feedback_desk.dart';

class HPRequestsPage extends StatefulWidget {
  const HPRequestsPage({super.key});

  @override
  State<HPRequestsPage> createState() => _HPRequestsPageState();
}

class _HPRequestsPageState extends State<HPRequestsPage> {
  // --- STATE & DATA ---
  bool _isExpanded = false;
  final List<UserModel> _newRequests = MockData.pendingRequests; // Wired directly to MockData!

  @override
  Widget build(BuildContext context) {
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
                expandedHeight: 150.0, // FIX 5: Decreased height
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
                      padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
                      child: const Text(
                        "Requests.",
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: "LexendExaNormal", letterSpacing: -1.0),
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
                    // --- FIX 5: MODERN SEARCH BAR ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: dividerColor),
                          boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: TextField(
                          style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: "Filter pending applications...",
                            hintStyle: TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                            prefixIcon: Icon(Icons.filter_list_rounded, color: textSecondary),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("PATIENT APPLICATIONS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: textSecondary, letterSpacing: 1.2, fontFamily: "LexendExaNormal")),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: const Color(0xFFF59E0B).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                            child: Text("${_newRequests.length} Pending", style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    
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
          ],
      ),
      bottomNavigationBar: HPBottomNavBar(currentIndex: 2, activeColor: themePurple), 
    );
  }

  // ==========================================
  // UI COMPONENT HELPERS
  // ==========================================

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
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 8))],
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
                      color: themePurple.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                      boxShadow: [BoxShadow(color: themePurple.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))],
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
    final containerColor = isDark ? surfaceColor : const Color(0xFF1A1A1A);
    // Grab the live list!
    final feedbackList = MockData.feedbackRequests;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: containerColor, 
        borderRadius: BorderRadius.circular(30),
        border: isDark ? Border.all(color: dividerColor) : null,
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8), 
                decoration: BoxDecoration(color: Colors.greenAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), 
                child: const Icon(Icons.chat_bubble_outline, color: Colors.greenAccent, size: 20),
              ),
              const SizedBox(width: 15),
              const Text("Consultation Desk", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: "LexendExaNormal")),
            ],
          ),
          const SizedBox(height: 25),
          
          // --- DYNAMIC AVATAR LIST ---
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                if (feedbackList.isEmpty)
                  const Text("No pending feedbacks.", style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic)),
                
                // Maps the first 3 requests to Avatars
                ...feedbackList.take(3).map((req) {
                  return _feedbackAvatar(req.user.fullName.split(" ")[0], req.label, req.color);
                }),
                
                // Calculates the exact +X badge automatically
                if (feedbackList.length > 3)
                  Container(
                    width: 45, height: 45,
                    margin: const EdgeInsets.only(bottom: 22), // Align with avatars
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), shape: BoxShape.circle, border: Border.all(color: Colors.white24)),
                    child: Center(child: Text("+${feedbackList.length - 3}", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          
          ElevatedButton(
            onPressed: () {
               // Routes flawlessly to the desk!
               Navigator.push(context, MaterialPageRoute(builder: (context) => const HPFeedbackDeskPage()));
            },
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

  Widget _feedbackAvatar(String name, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          Container(
            width: 45, height: 45,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), shape: BoxShape.circle),
            child: Center(child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}