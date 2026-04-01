import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart'; 
import '../GeneralPages/auth_provider.dart'; 

class HPSettingsPage extends StatelessWidget {
  const HPSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    // --- GET LIVE HP USERNAME ---
    final authData = Provider.of<AuthProvider>(context);
    final String liveUsername = authData.currentUsername ?? "Doctor"; 

    // --- HP SIGNATURE PURPLE THEME ---
    const Color hpPurple = Color(0xFF8E33FF); 
    
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
          // ==========================================
          // SLIVER APP BAR & PROFILE HEADER
          // ==========================================
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
                        border: Border.all(color: hpPurple.withValues(alpha: 0.5), width: 2),
                        boxShadow: [BoxShadow(color: hpPurple.withValues(alpha: 0.15), blurRadius: 20, spreadRadius: 5)],
                      ),
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: surfaceColor,
                        child: const Icon(Icons.medical_services_rounded, size: 50, color: hpPurple),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      liveUsername, 
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textPrimary, fontFamily: "LexendExaNormal", letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Healthcare Provider", 
                      style: TextStyle(fontSize: 13, color: textSecondary, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ==========================================
          // MAIN SETTINGS CONTENT
          // ==========================================
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(25, 30, 25, 50),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, -5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(themeProvider.translate('clinic_preferences'), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: textSecondary, letterSpacing: 1.5, fontFamily: "LexendExaNormal")),
                  const SizedBox(height: 15),
                  
                  Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: dividerColor),
                    ),
                    child: Column(
                      children: [
                        // --- MISSING LANGUAGE SELECTION ADDED HERE ---
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          leading: Icon(Icons.language_rounded, color: textPrimary.withValues(alpha: 0.8), size: 22),
                          title: Text(themeProvider.translate('language'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textPrimary)),
                          trailing: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: themeProvider.currentLanguage,
                              dropdownColor: surfaceColor,
                              icon: Icon(Icons.keyboard_arrow_down_rounded, color: textSecondary, size: 18),
                              style: TextStyle(color: hpPurple, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: "LexendExaNormal"),
                              items: const [
                                DropdownMenuItem(value: 'en', child: Text("English")),
                                DropdownMenuItem(value: 'ms', child: Text("Bahasa Melayu")),
                                DropdownMenuItem(value: 'zh', child: Text("中文")),
                                DropdownMenuItem(value: 'ta', child: Text("தமிழ்")),
                              ],
                              onChanged: (String? newValue) {
                                if (newValue != null) themeProvider.changeLanguage(newValue);
                              },
                            ),
                          ),
                        ),
                        _buildDivider(dividerColor),
                        
                        // --- MISSING FONT SIZE SLIDER ADDED HERE ---
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  children: [
                                    Icon(Icons.format_size_rounded, color: textPrimary.withValues(alpha: 0.8), size: 22),
                                    const SizedBox(width: 15),
                                    Text(themeProvider.translate('font_size'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textPrimary)),
                                  ],
                                ),
                              ),
                              Slider(
                                value: themeProvider.fontScale,
                                min: 0.8, 
                                max: 1.5, 
                                divisions: 7,
                                activeColor: hpPurple,
                                inactiveColor: hpPurple.withValues(alpha: 0.2),
                                label: "${(themeProvider.fontScale * 100).toInt()}%",
                                onChanged: (value) => themeProvider.updateFontScale(value),
                              ),
                            ],
                          ),
                        ),
                        _buildDivider(dividerColor),

                        _buildProfileOption(Icons.local_hospital_outlined, themeProvider.translate('clinic_info'), themeProvider.translate('verified'), textPrimary, hpPurple),
                        _buildDivider(dividerColor),
                        _buildProfileOption(Icons.notifications_none_rounded, themeProvider.translate('alerts_notifications'), themeProvider.translate('urgent_only'), textPrimary, textSecondary),
                        _buildDivider(dividerColor),
                        _buildProfileOption(Icons.people_alt_outlined, themeProvider.translate('patient_data_access'), themeProvider.translate('manage'), textPrimary, hpPurple),
                        _buildDivider(dividerColor),
                        
                        SwitchListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                          secondary: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: textPrimary.withValues(alpha: 0.8), size: 22),
                          title: Text(themeProvider.translate('dark_mode'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textPrimary)),
                          value: isDark,
                          activeColor: hpPurple,
                          inactiveTrackColor: Colors.grey.shade300,
                          onChanged: (value) {
                            Provider.of<ThemeProvider>(context, listen: false).toggleTheme(value);
                          },
                        ),
                        
                        _buildDivider(dividerColor),
                        _buildProfileOption(Icons.security_outlined, themeProvider.translate('security'), "", textPrimary, textSecondary),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 35),
                  
                  Text(themeProvider.translate('actions'), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: textSecondary, letterSpacing: 1.5, fontFamily: "LexendExaNormal")),
                  const SizedBox(height: 15),

                  _buildActionButton(
                    label: themeProvider.translate('generate_clinic_report'), 
                    icon: Icons.analytics_outlined, 
                    bgColor: hpPurple.withValues(alpha: 0.1), 
                    textColor: hpPurple, 
                    onTap: () {}
                  ),
                  const SizedBox(height: 12),

                  _buildActionButton(
                    label: themeProvider.translate('log_out'), 
                    icon: Icons.logout_rounded, 
                    bgColor: const Color(0xFFFF4B4B).withValues(alpha: 0.1), 
                    textColor: const Color(0xFFFF4B4B),
                    onTap: () => _showLogoutConfirmation(context, surfaceColor, textPrimary, textSecondary, dividerColor, themeProvider)
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // UI COMPONENT HELPERS
  // ==========================================

  Widget _buildDivider(Color dividerColor) {
    return Divider(height: 1, thickness: 1, color: dividerColor, indent: 20, endIndent: 20);
  }

  Widget _buildProfileOption(IconData icon, String title, String value, Color textPrimary, Color valueColor, {VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: textPrimary.withValues(alpha: 0.8), size: 22),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textPrimary, height: 1.3), maxLines: 2, overflow: TextOverflow.visible),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value.isNotEmpty) Text(value, style: TextStyle(color: valueColor, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios, color: textPrimary.withValues(alpha: 0.2), size: 14),
        ],
      ),
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required Color bgColor, required Color textColor, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: textColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 13, fontFamily: "LexendExaNormal")),
              ),
            ),
            const SizedBox(width: 10),
            Icon(icon, color: textColor, size: 20),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, Color surfaceColor, Color textPrimary, Color textSecondary, Color dividerColor, ThemeProvider theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25), side: BorderSide(color: dividerColor)),
        title: Text(theme.translate('log_out'), style: TextStyle(fontWeight: FontWeight.w900, color: textPrimary, fontFamily: "LexendExaNormal")),
        content: Text("Are you sure you want to log out of the Provider Portal?", style: TextStyle(color: textSecondary, height: 1.5)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("CANCEL", style: TextStyle(color: textSecondary, fontWeight: FontWeight.bold))),
          ElevatedButton(
            onPressed: () {
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