import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart'; 
import 'usermodel.dart';

class HPRequestSelected extends StatelessWidget {
  final UserModel user;

  const HPRequestSelected({super.key, required this.user});

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
    final textSecondary = isDark ? Colors.white54 : Colors.grey.shade600;
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
                backgroundColor: themePurple,
                expandedHeight: 250.0,
                toolbarHeight: 70.0,
                pinned: true,
                elevation: 0,
                scrolledUnderElevation: 0.0,
                surfaceTintColor: Colors.transparent,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 15.0, top: 10.0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 65, 30, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: "LexendExaNormal", letterSpacing: -0.5),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.watch_rounded, color: Colors.white70, size: 16),
                              const SizedBox(width: 6),
                              Text("Device: ${user.device}", style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${user.gender} | ${user.height.toInt()} cm | ${user.weight.toInt()} kg",
                            style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(30),
                  child: Transform.translate(
                    offset: const Offset(0, 1),
                    child: Container(height: 31, width: double.infinity, decoration: BoxDecoration(color: bgColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(35)))),
                  ),
                ),
              ),

              // --- MAIN BODY CONTENT ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("APPLICATION DETAILS", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: textSecondary, letterSpacing: 1.2, fontFamily: "LexendExaNormal")),
                      const SizedBox(height: 15),

                      // 1. Message from Patient
                      _buildInfoCard(
                        "Patient Note", 
                        "\"I would like to share my health data with your clinic to monitor my weekly progress and get feedback on my cardiovascular health.\"", 
                        Icons.format_quote_rounded, 
                        themePurple, surfaceColor, textPrimary, textSecondary, dividerColor, isDark
                      ),
                      const SizedBox(height: 20),

                      // 2. Data Permission Checklist
                      Text("DATA PERMISSIONS REQUESTED", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: textSecondary, letterSpacing: 1.2, fontFamily: "LexendExaNormal")),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: dividerColor),
                          boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 5))],
                        ),
                        child: Column(
                          children: [
                            _buildPermissionTile("Heart Rate Data", "Live & Historical", Icons.favorite_rounded, Colors.redAccent, textPrimary, textSecondary),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Divider(color: dividerColor, height: 1)),
                            _buildPermissionTile("Step Count & Activity", "Daily Tracking", Icons.directions_walk_rounded, Colors.orangeAccent, textPrimary, textSecondary),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Divider(color: dividerColor, height: 1)),
                            _buildPermissionTile("Glucose Levels", "Manual Logs", Icons.bloodtype_rounded, Colors.greenAccent, textPrimary, textSecondary),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Divider(color: dividerColor, height: 1)),
                            _buildPermissionTile("Calorie Intake", "Meal Estimates", Icons.restaurant_rounded, Colors.amber, textPrimary, textSecondary),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 3. Device Integration Status
                      _buildInfoCard(
                        "Integration Status", 
                        "Device (${user.device}) is ready to sync. Data will be transmitted securely via HealthMax API.", 
                        Icons.cloud_sync_rounded, 
                        Colors.blueAccent, surfaceColor, textPrimary, textSecondary, dividerColor, isDark
                      ),

                      const SizedBox(height: 160), // Room for bottom action bar
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ==========================================
          // 2. FLOATING DARK ACTION BAR (ACCEPT / REJECT)
          // ==========================================
          Positioned(
            bottom: 25, left: 20, right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C1E) : Colors.white, 
                borderRadius: BorderRadius.circular(35),
                border: isDark ? Border.all(color: dividerColor) : null,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1), blurRadius: 25, offset: const Offset(0, 10))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Add reject logic
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF4757).withValues(alpha: 0.1),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: const Color(0xFFFF4757).withValues(alpha: 0.3))),
                          ),
                          child: const Text("Reject", style: TextStyle(color: Color(0xFFFF4757), fontWeight: FontWeight.bold, fontSize: 15, fontFamily: "LexendExaNormal")),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Add accept logic
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themePurple,
                            elevation: 4,
                            shadowColor: themePurple.withValues(alpha: 0.4),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text("Accept", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, fontFamily: "LexendExaNormal")),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  
                  // Contact Action
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mail_outline_rounded, size: 16, color: textSecondary),
                        const SizedBox(width: 6),
                        Text("Contact for more information", style: TextStyle(color: textSecondary, fontWeight: FontWeight.bold, fontSize: 12, decoration: TextDecoration.underline)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // ==========================================
  // UI COMPONENT HELPERS
  // ==========================================

  Widget _buildInfoCard(String title, String content, IconData icon, Color iconColor, Color surfaceColor, Color textPrimary, Color textSecondary, Color dividerColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: dividerColor),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                const SizedBox(height: 6),
                Text(content, style: TextStyle(fontSize: 13, color: textSecondary, height: 1.4, fontStyle: title == "Patient Note" ? FontStyle.italic : FontStyle.normal)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionTile(String title, String subtitle, IconData icon, Color color, Color textPrimary, Color textSecondary) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
              Text(subtitle, style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: Colors.greenAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: const Text("Read Only", style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }
}