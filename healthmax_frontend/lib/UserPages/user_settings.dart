import 'package:flutter/material.dart';
import 'package:healthmax_frontend/GeneralPages/auth/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // --- NEW IMPORT ---
import '../theme_provider.dart';
import 'manage_devices.dart'; 

class UserSettingsPage extends StatelessWidget {
  const UserSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    // ==========================================
    // THE FIX: Pulling Live Username from Supabase
    // ==========================================
    final supabase = Supabase.instance.client;
    final String liveUsername = supabase.auth.currentUser?.userMetadata?['username'] ?? "User";

    const Color userBlue = Color(0xFF5A84F1);

    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color surfaceColor = Theme.of(context).colorScheme.surface;
    final Color textPrimary = Theme.of(context).colorScheme.onSurface;
    final Color textSecondary = isDark ? const Color(0xFFA1A1AA) : Colors.grey.shade600;
    final Color dividerColor = Theme.of(context).dividerColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: bgColor,
            expandedHeight: 280.0,
            toolbarHeight: 70.0,
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 0.0,
            surfaceTintColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.only(left: 15.0, top: 10.0),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 22),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: userBlue.withValues(alpha:0.5), width: 2),
                        boxShadow: [BoxShadow(color: userBlue.withValues(alpha:0.15), blurRadius: 20, spreadRadius: 5)],
                      ),
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: surfaceColor,
                        child: const Icon(Icons.person_rounded, size: 55, color: userBlue),
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // --- DYNAMIC USERNAME DISPLAYED HERE ---
                    Text(liveUsername, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textPrimary, fontFamily: "LexendExaNormal", letterSpacing: -0.5)),
                    
                    const SizedBox(height: 4),
                    Text("HealthMax Premium Member", style: TextStyle(fontSize: 13, color: textSecondary, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(25, 30, 25, 50),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha:0.03), blurRadius: 20, offset: const Offset(0, -5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("PREFERENCES", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: textSecondary, letterSpacing: 1.5, fontFamily: "LexendExaNormal")),
                  const SizedBox(height: 15),

                  Container(
                    decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(25), border: Border.all(color: dividerColor)),
                    child: Column(
                      children: [
                        _buildProfileOption(Icons.account_circle_outlined, "Account Information", "", textPrimary, textSecondary),
                        _buildDivider(dividerColor),
                        _buildProfileOption(Icons.notifications_none_rounded, "Notifications", "On", textPrimary, textSecondary),
                        _buildDivider(dividerColor),
                        _buildProfileOption(Icons.medical_services_outlined, "Manage Healthcare Providers", "1 Connected", textPrimary, userBlue),
                        _buildDivider(dividerColor),
                        
                        _buildProfileOption(Icons.watch_rounded, "Connected Devices", "Manage", textPrimary, userBlue, 
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageDevicesPage()))
                        ),
                        
                        _buildDivider(dividerColor),
                        _buildProfileOption(Icons.track_changes_rounded, "Health Goals", "Weight Loss", textPrimary, textSecondary,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Redirecting to Goal Editor..."), backgroundColor: Color(0xFF8E33FF), behavior: SnackBarBehavior.floating));
                          },
                        ),
                        _buildDivider(dividerColor),

                        SwitchListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                          secondary: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: textPrimary.withValues(alpha:0.8), size: 22),
                          title: Text("Dark Mode", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textPrimary)),
                          value: isDark,
                          activeColor: userBlue,
                          inactiveTrackColor: Colors.grey.shade300,
                          onChanged: (value) => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(value),
                        ),

                        _buildDivider(dividerColor),
                        _buildProfileOption(Icons.security_outlined, "Privacy & Security", "", textPrimary, textSecondary),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),
                  Text("ACTIONS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: textSecondary, letterSpacing: 1.5, fontFamily: "LexendExaNormal")),
                  const SizedBox(height: 15),

                  _buildActionButton(label: "VERIFY EMAIL", icon: Icons.mark_email_read_rounded, bgColor: const Color(0xFFF59E0B).withValues(alpha:0.1), textColor: const Color(0xFFF59E0B), onTap: () {}),
                  const SizedBox(height: 12),
                  _buildActionButton(label: "EXPORT HEALTH DATA", icon: Icons.ios_share_rounded, bgColor: userBlue.withValues(alpha:0.1), textColor: userBlue, onTap: () => _handleExport(context, userBlue)),
                  const SizedBox(height: 12),
                  _buildActionButton(label: "LOG OUT", icon: Icons.logout_rounded, bgColor: const Color(0xFFFF4B4B).withValues(alpha:0.1), textColor: const Color(0xFFFF4B4B), onTap: () => _showLogoutConfirmation(context, surfaceColor, textPrimary, textSecondary, dividerColor)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPERS ---
  Widget _buildDivider(Color dividerColor) => Divider(height: 1, thickness: 1, color: dividerColor, indent: 20, endIndent: 20);

  Widget _buildProfileOption(IconData icon, String title, String value, Color textPrimary, Color valueColor, {VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: textPrimary.withValues(alpha:0.8), size: 22),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textPrimary)),
      trailing: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(value, style: TextStyle(color: valueColor, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios, color: textPrimary.withValues(alpha:0.2), size: 14),
        ],
      ),
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required Color bgColor, required Color textColor, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: textColor.withValues(alpha:0.2))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 13, fontFamily: "LexendExaNormal")),
            Icon(icon, color: textColor, size: 20),
          ],
        ),
      ),
    );
  }

  void _handleExport(BuildContext context, Color userBlue) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Preparing your health records...", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), backgroundColor: userBlue, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))));
  }

  void _showLogoutConfirmation(BuildContext context, Color surfaceColor, Color textPrimary, Color textSecondary, Color dividerColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25), side: BorderSide(color: dividerColor)),
        title: Text("Confirm Logout", style: TextStyle(fontWeight: FontWeight.w900, color: textPrimary, fontFamily: "LexendExaNormal")),
        content: Text("Are you sure you want to log out of HealthMax?", style: TextStyle(color: textSecondary, height: 1.5)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("CANCEL", style: TextStyle(color: textSecondary, fontWeight: FontWeight.bold))),
          ElevatedButton(
            onPressed: () {
              final auth = AuthService();
              auth.logout();
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF4B4B), elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            child: const Text("LOGOUT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}