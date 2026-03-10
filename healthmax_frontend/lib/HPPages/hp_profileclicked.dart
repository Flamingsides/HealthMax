import 'package:flutter/material.dart';

class HPProfileClicked extends StatelessWidget {
  const HPProfileClicked({super.key});

  // ---------- 1. MAIN BUILD METHOD ----------
  @override
  Widget build(BuildContext context) {
    const Color themeColor = Color(0xFF8E33FF);

    return Scaffold(
      backgroundColor: themeColor,
      body: Stack(
        children: [
          // A. TOP LAYER: NAVIGATION
          Positioned(
            top: 60,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          Column(
            children: [
              const SizedBox(height: 100),
              
              // B. TOP LAYER: BRANDING & AVATAR
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 2),
                ),
                child: const CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white10,
                  child: Icon(Icons.apartment_rounded, size: 50, color: Colors.white),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Hospital 1",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const Text(
                "Medical Portal Administrator",
                style: TextStyle(fontSize: 13, color: Colors.white70, letterSpacing: 0.5),
              ),
              const SizedBox(height: 35),

              // C. MIDDLE LAYER: SETTINGS CONTENT
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(25, 30, 25, 0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(45), 
                      topRight: Radius.circular(45)
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("PREFERENCES", 
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1.5)),
                        const SizedBox(height: 10),
                        
                        _buildProfileOption(Icons.account_circle_outlined, "Account Information", "", () {}),
                        _buildProfileOption(Icons.language_rounded, "Language", "English", () {}),
                        _buildProfileOption(Icons.format_size_rounded, "Font Size", "Medium", () {}),
                        _buildProfileOption(Icons.palette_outlined, "Theme", "Light", () {}),
                        _buildProfileOption(Icons.bar_chart_rounded, "Data Presentation", "Spine Chart", () {}),
                        _buildProfileOption(Icons.security_outlined, "Privacy & Access", "", () {}),
                        
                        const SizedBox(height: 30),
                        const Text("ACTIONS", 
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1.5)),
                        const SizedBox(height: 15),

                        // Action Buttons
                        _buildActionButton(
                          label: "EXPORT PORTAL DATA", 
                          icon: Icons.share_rounded, 
                          color: const Color(0xFF00D1FF), 
                          onTap: () => _handleExport(context)
                        ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          label: "LOG OUT", 
                          icon: Icons.logout_rounded, 
                          color: const Color(0xFFFF4B4B), 
                          onTap: () => _showLogoutConfirmation(context)
                        ),
                        
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- 2. UI COMPONENT HELPERS ----------

  // Helper: List Item for Settings
  Widget _buildProfileOption(IconData icon, String title, String value, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.black87, size: 22),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      trailing: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(value, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, color: Colors.black12, size: 14),
        ],
      ),
    );
  }

  // Helper: Large Styled Action Button
  Widget _buildActionButton({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
            Icon(icon, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  // ---------- 3. LOGIC & DIALOG HELPERS ----------

  void _handleExport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Preparing medical records for export..."), behavior: SnackBarBehavior.floating),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Confirm Logout", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to exit the Hospital Portal?"),
        actions: [
          // Cancel: Returns the user to the profile page
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4B4B),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("LOGOUT", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}