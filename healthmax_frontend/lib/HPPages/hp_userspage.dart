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
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _displayedUsers = [];
  String _currentSort = 'A - Z';

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    String query = _searchController.text.toLowerCase();
    
    List<UserModel> filtered = MockData.activeUsers.where((user) {
      return user.fullName.toLowerCase().contains(query) || 
             user.username.toLowerCase().contains(query);
    }).toList();

    if (_currentSort == 'A - Z') {
      filtered.sort((a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
    } else if (_currentSort == 'Z - A') {
      filtered.sort((a, b) => b.fullName.toLowerCase().compareTo(a.fullName.toLowerCase()));
    }

    setState(() => _displayedUsers = filtered);
  }

  @override
  Widget build(BuildContext context) {
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
              SliverAppBar(
                automaticallyImplyLeading: false, backgroundColor: themePurple, expandedHeight: 150.0, toolbarHeight: 90.0, pinned: true, elevation: 0, scrolledUnderElevation: 0.0, surfaceTintColor: Colors.transparent,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, right: 10.0),
                    child: IconButton(icon: const Icon(Icons.sort_rounded, color: Colors.white, size: 28), onPressed: () => _showSortSheet(isDark, surfaceColor, textPrimary, dividerColor, themePurple, themeProvider)),
                  ),
                  Padding(padding: const EdgeInsets.only(right: 30.0, top: 10.0), child: Center(child: HPGlassyProfile(onTap: () => Navigator.pushNamed(context, '/hp_settings')))),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 20, 30, 0), 
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(themeProvider.translate('users'), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: "LexendExaNormal", letterSpacing: -1.0)),
                      ),
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(30),
                  child: Transform.translate(offset: const Offset(0, 1), child: Container(height: 31, width: double.infinity, decoration: BoxDecoration(color: bgColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(40))))),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 55,
                        decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: dividerColor), boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => _applyFilters(),
                          style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: themeProvider.translate('search_patients_hint'), hintStyle: TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                            prefixIcon: Icon(Icons.search_rounded, color: textSecondary), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(themeProvider.translate('active_patients'), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: textSecondary, letterSpacing: 1.2, fontFamily: "LexendExaNormal")),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: themePurple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                            child: Text("${themeProvider.translate('total')}: ${_displayedUsers.length}", style: TextStyle(color: themePurple, fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      Container(
                        padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
                        decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(30), border: Border.all(color: dividerColor), boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 8))]),
                        child: _displayedUsers.isEmpty 
                          ? Padding(padding: const EdgeInsets.all(30.0), child: Center(child: Text(themeProvider.translate('no_patients_found'), style: TextStyle(color: textSecondary, fontWeight: FontWeight.bold))))
                          : ListView.builder(
                              padding: EdgeInsets.zero, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: _displayedUsers.length,
                              itemBuilder: (context, index) { return _buildUserTile(_displayedUsers[index], bgColor, surfaceColor, textPrimary, textSecondary, dividerColor, themePurple, isDark, themeProvider); },
                            ),
                      ),
                      const SizedBox(height: 120), 
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: HPBottomNavBar(currentIndex: 1, activeColor: themePurple), 
    );
  }

  Widget _buildUserTile(UserModel user, Color bgColor, Color surfaceColor, Color textPrimary, Color textSecondary, Color dividerColor, Color themePurple, bool isDark, ThemeProvider theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: dividerColor)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
        leading: CircleAvatar(radius: 20, backgroundColor: isDark ? surfaceColor : Colors.white, child: Icon(Icons.person, size: 20, color: themePurple)),
        title: Text(user.fullName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textPrimary)),
        subtitle: Text("${theme.translate('device')}: ${user.device}", style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w600)),
        trailing: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: surfaceColor, shape: BoxShape.circle), child: Icon(Icons.arrow_forward_ios_rounded, size: 12, color: textPrimary)),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HPUserSelected(user: user))),
      ),
    );
  }

  void _showSortSheet(bool isDark, Color surfaceColor, Color textPrimary, Color dividerColor, Color themePurple, ThemeProvider theme) {
    final sortOptions = ['A - Z', 'Z - A'];
    
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(color: surfaceColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(35))), padding: const EdgeInsets.fromLTRB(30, 10, 30, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 30), decoration: BoxDecoration(color: dividerColor, borderRadius: BorderRadius.circular(10))),
            FittedBox(fit: BoxFit.scaleDown, child: Text(theme.translate('sort_patients'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: "LexendExaNormal", color: textPrimary))),
            const SizedBox(height: 20),
            Container(
              width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: dividerColor)), 
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: sortOptions.map((option) => ListTile(
                  onTap: () { setState(() { _currentSort = option; _applyFilters(); }); Navigator.pop(context); },
                  title: Text(option, style: TextStyle(color: textPrimary, fontWeight: _currentSort == option ? FontWeight.bold : FontWeight.normal)),
                  trailing: _currentSort == option ? Icon(Icons.check_circle_rounded, color: themePurple) : null,
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}