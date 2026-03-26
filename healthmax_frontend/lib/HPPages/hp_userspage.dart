import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart'; 
import 'hp_bottomnavbar.dart';
import 'hp_glassy_profile.dart';
import 'usermodel.dart';
import 'hp_userselected.dart';

class HPUsersPage extends StatefulWidget {
  const HPUsersPage({super.key});

  @override
  State<HPUsersPage> createState() => _HPUsersPageState();
}

class _HPUsersPageState extends State<HPUsersPage> {
  // --- STATE & DATA ---
  final List<UserModel> _activeUsers = [
    UserModel(username: "john_d", fullName: "John Doe", gender: "M", height: 175, weight: 70, device: "Apple Watch S8"),
    UserModel(username: "jane_s", fullName: "Jane Smith", gender: "F", height: 165, weight: 58, device: "Fitbit Charge 5"),
    UserModel(username: "robert_k", fullName: "Robert King", gender: "M", height: 182, weight: 85, device: "Garmin Fenix 7"),
    UserModel(username: "emily_r", fullName: "Emily Rose", gender: "F", height: 170, weight: 62, device: "Oura Ring Gen3"),
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
                        "Users.",
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        "ACTIVE PATIENTS", 
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: textSecondary, letterSpacing: 1.2)
                      ),
                      const SizedBox(height: 15),

                      // Users List Container
                      Container(
                        padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: dividerColor),
                          boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
                        ),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _activeUsers.length,
                          itemBuilder: (context, index) {
                            return _buildUserTile(_activeUsers[index], bgColor, surfaceColor, textPrimary, textSecondary, dividerColor, themePurple, isDark);
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 120), // Bottom padding for NavBar
                    ],
                  ),
                ),
              ),
            ],
          ),

          // --- BOTTOM NAVIGATION BAR ---
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: HPBottomNavBar(currentIndex: 1, activeColor: themePurple), // Current index is 1 for Users
          ),
        ],
      ),
    );
  }

  // ==========================================
  // UI COMPONENT HELPERS
  // ==========================================
  Widget _buildUserTile(UserModel user, Color bgColor, Color surfaceColor, Color textPrimary, Color textSecondary, Color dividerColor, Color themePurple, bool isDark) {
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
          backgroundColor: isDark ? surfaceColor : Colors.white, 
          child: Icon(Icons.person, size: 20, color: themePurple),
        ),
        title: Text(user.fullName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textPrimary)),
        subtitle: Text("Device: ${user.device}", style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w600)),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: surfaceColor, shape: BoxShape.circle),
          child: Icon(Icons.arrow_forward_ios_rounded, size: 12, color: textPrimary),
        ),
        onTap: () {
          // Navigates to the selected user's detail page
          Navigator.push(context, MaterialPageRoute(builder: (context) => HPUserSelected(user: user)));
        },
      ),
    );
  }
}