import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; 
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import 'AI_Features/ai_translator_service.dart';
import '../UserPages/hp_providers.dart'; 

class ManageHPPage extends StatefulWidget {
  const ManageHPPage({super.key});

  @override
  State<ManageHPPage> createState() => _ManageHPPageState();
}

class _ManageHPPageState extends State<ManageHPPage> {
  final Color userBlue = const Color(0xFF5A84F1);
  final Color actionGreen = const Color(0xFF2ED573);
  final Color actionRed = const Color(0xFFFF4757);

  bool _showConnected = true;
  String _searchQuery = ""; 

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    final hpProvider = Provider.of<HPProvider>(context);
    
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = isDark ? Colors.white54 : Colors.grey.shade600;
    final dividerColor = Theme.of(context).dividerColor;

    final displayList = hpProvider.providers.where((hp) {
      final matchesTab = hp.isConnected == _showConnected;
      final matchesSearch = hp.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesTab && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: userBlue, expandedHeight: 220.0, toolbarHeight: 70.0, pinned: true, elevation: 0, scrolledUnderElevation: 0.0, surfaceTintColor: Colors.transparent,
            leading: Padding(padding: const EdgeInsets.only(left: 15.0, top: 10.0), child: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22), onPressed: () => Navigator.pop(context))),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 60, 30, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(fit: BoxFit.scaleDown, child: Text(themeProvider.translate('manage'), style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: "LexendExaNormal", letterSpacing: -0.5, height: 1.1))),
                      FittedBox(fit: BoxFit.scaleDown, child: Text(themeProvider.translate('providers'), style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: "LexendExaNormal", letterSpacing: -0.5, height: 1.1))),
                    ],
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: Transform.translate(
                offset: const Offset(0, 1),
                child: Container(
                  width: double.infinity, decoration: BoxDecoration(color: bgColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(40))),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(30, 20, 30, 10),
                    child: Container(
                      height: 45, decoration: BoxDecoration(color: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade200, borderRadius: BorderRadius.circular(25)),
                      child: Row(
                        children: [
                          _buildTabToggle(themeProvider.translate('connected'), true, surfaceColor, textPrimary, isDark),
                          _buildTabToggle(themeProvider.translate('requests'), false, surfaceColor, textPrimary, isDark),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 50,
                    decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(25), border: Border.all(color: dividerColor), boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha:0.02), blurRadius: 8, offset: const Offset(0, 4))]),
                    child: TextField(
                      onChanged: (value) => setState(() => _searchQuery = value),
                      style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: themeProvider.translate('search_hp'), hintStyle: TextStyle(color: textSecondary, fontSize: 13), prefixIcon: Icon(Icons.search_rounded, color: userBlue),
                        border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  if (displayList.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Text(
                          _searchQuery.isNotEmpty ? "No providers found for '$_searchQuery'" : (_showConnected ? themeProvider.translate('no_connected_hp') : themeProvider.translate('no_pending_requests')),
                          style: TextStyle(color: textSecondary, fontWeight: FontWeight.bold), textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      padding: EdgeInsets.zero, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: displayList.length,
                      itemBuilder: (context, index) { 
                        return _buildHPCard(displayList[index], surfaceColor, textPrimary, textSecondary, dividerColor, isDark, themeProvider, hpProvider); 
                      },
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabToggle(String title, bool isConnectedTab, Color surfaceColor, Color textPrimary, bool isDark) {
    bool isActive = _showConnected == isConnectedTab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() { _showConnected = isConnectedTab; _searchQuery = ""; }),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: isActive ? surfaceColor : Colors.transparent, borderRadius: BorderRadius.circular(20), boxShadow: isActive && !isDark ? [BoxShadow(color: Colors.black.withValues(alpha:0.05), blurRadius: 4, offset: const Offset(0, 2))] : []),
          alignment: Alignment.center,
          child: FittedBox(fit: BoxFit.scaleDown, child: Text(title, style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.w600, color: isActive ? textPrimary : textPrimary.withValues(alpha:0.5), fontFamily: "LexendExaNormal", fontSize: 12))),
        ),
      ),
    );
  }

  Widget _buildHPCard(HPModel hp, Color surfaceColor, Color textPrimary, Color textSecondary, Color dividerColor, bool isDark, ThemeProvider theme, HPProvider hpProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        gradient: hp.isConnected ? LinearGradient(colors: isDark ? [userBlue.withValues(alpha:0.1), surfaceColor] : [userBlue.withValues(alpha:0.05), Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
        color: hp.isConnected ? null : surfaceColor,
        borderRadius: BorderRadius.circular(25), border: Border.all(color: hp.isConnected ? userBlue.withValues(alpha:0.3) : dividerColor), boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha:0.03), blurRadius: 10, offset: const Offset(0, 5))]
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: hp.isConnected ? () => _showHPDetailsSheet(hp, surfaceColor, textPrimary, textSecondary, dividerColor, isDark, theme) : null,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: hp.isConnected ? userBlue : (isDark ? Colors.white10 : Colors.grey.shade100), shape: BoxShape.circle),
                  child: Icon(Icons.local_hospital_rounded, size: 28, color: hp.isConnected ? Colors.white : textPrimary),
                ),
                const SizedBox(width: 15),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(hp.name, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: textPrimary))),
                      const SizedBox(height: 2),
                      Text(hp.address, style: TextStyle(fontSize: 10, color: textSecondary, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                      if (hp.isConnected) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4, runSpacing: 4,
                          children: hp.accessibleData.take(2).map((data) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: userBlue.withValues(alpha:0.15), borderRadius: BorderRadius.circular(6)),
                            child: Text(data, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: userBlue)),
                          )).toList()..addAll(hp.accessibleData.length > 2 ? [Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.grey.withValues(alpha:0.2), borderRadius: BorderRadius.circular(6)), child: Text("+${hp.accessibleData.length - 2}", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: textSecondary)))] : []),
                        ),
                      ]
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: hp.isConnected 
                      ? [
                          _buildSmallBtn(theme.translate('contact'), Icons.phone_rounded, actionGreen, Colors.black87, () {}, hasShadow: true),
                          const SizedBox(height: 8),
                          // --- AWAIT THE REVOKE CALL ---
                          _buildSmallBtn(theme.translate('remove'), Icons.delete_rounded, actionRed.withValues(alpha:0.1), actionRed, () async { 
                            try {
                              await hpProvider.revokeAccess(hp); 
                              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${hp.name} access revoked."), backgroundColor: actionRed)); 
                            } catch (e) {
                              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to revoke access."), backgroundColor: Colors.redAccent)); 
                            }
                          }),
                        ]
                      : [
                          _buildSmallBtn(theme.translate('request_to_connect'), Icons.add_circle_rounded, userBlue, Colors.white, () => _showConnectSheet(hp, hpProvider, surfaceColor, textPrimary, textSecondary, dividerColor, isDark, theme), hasShadow: true),
                        ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallBtn(String label, IconData icon, Color bgColor, Color textColor, VoidCallback onTap, {bool hasShadow = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        decoration: BoxDecoration(
          color: bgColor, 
          borderRadius: BorderRadius.circular(12),
          boxShadow: hasShadow ? [BoxShadow(color: bgColor.withValues(alpha:0.4), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: textColor), 
            const SizedBox(width: 4),
            Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 11, fontFamily: "LexendExaNormal")))),
          ],
        ),
      ),
    );
  }

  void _showHPDetailsSheet(HPModel hp, Color surfaceColor, Color textPrimary, Color textSecondary, Color dividerColor, bool isDark, ThemeProvider theme) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(color: surfaceColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(35))), padding: const EdgeInsets.fromLTRB(25, 10, 25, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 25), decoration: BoxDecoration(color: dividerColor, borderRadius: BorderRadius.circular(10)))),
            Row(
              children: [
                CircleAvatar(radius: 30, backgroundColor: userBlue.withValues(alpha:0.1), child: Icon(Icons.local_hospital_rounded, size: 30, color: userBlue)),
                const SizedBox(width: 15),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(hp.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textPrimary, fontFamily: "LexendExaNormal")), const SizedBox(height: 4), Row(children: [const Icon(Icons.check_circle_rounded, size: 14, color: Colors.green), const SizedBox(width: 4), Text("Actively Syncing", style: TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.bold))])])),
              ],
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey.shade50, borderRadius: BorderRadius.circular(15), border: Border.all(color: dividerColor)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Access Timeframe", style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.bold)), Text(hp.timeframe, style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w900))]),
                  Divider(color: dividerColor, height: 25),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Valid Until", style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.bold)), AiTranslatedText(hp.accessDate.replaceAll("Valid Until: ", ""), style: TextStyle(color: actionGreen, fontSize: 13, fontWeight: FontWeight.w900))]),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Text("DATA SHARED", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: textSecondary, letterSpacing: 1.5, fontFamily: "LexendExaNormal")),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: hp.accessibleData.map((data) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: userBlue.withValues(alpha:0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: userBlue.withValues(alpha:0.2))), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.check_rounded, size: 14, color: userBlue), const SizedBox(width: 6), Text(theme.translate(data), style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 12))]))).toList(),
            ),
            const SizedBox(height: 35),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0), child: Text(theme.translate('close'), style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w900, fontFamily: "LexendExaNormal"))))
          ],
        ),
      ),
    );
  }

  void _showConnectSheet(HPModel hp, HPProvider hpProvider, Color surfaceColor, Color textPrimary, Color textSecondary, Color dividerColor, bool isDark, ThemeProvider theme) {
    final List<String> availableData = ["Hearing Data", "Heart Rate", "Steps", "Blood Glucose", "Calories"];
    final List<String> selectedData = [];
    
    final List<String> amounts = List.generate(30, (i) => (i + 1).toString());
    final List<String> types = ["Day", "Week", "Month"];
    
    int selectedAmountIndex = 1; 
    int selectedTypeIndex = 0;   
    bool isSaving = false; // Add loading state

    String calculateExpiry() {
      DateTime now = DateTime.now();
      int amount = int.parse(amounts[selectedAmountIndex]);
      String typeStr = types[selectedTypeIndex];
      DateTime expiry = now;
      if (typeStr == "Day") expiry = now.add(Duration(days: amount));
      else if (typeStr == "Week") expiry = now.add(Duration(days: amount * 7));
      else if (typeStr == "Month") expiry = now.add(Duration(days: amount * 30));
      return "From today until ${expiry.day}/${expiry.month}/${expiry.year}";
    }

    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
          String expiryText = calculateExpiry();
          
          return Container(
            decoration: BoxDecoration(color: surfaceColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(35))),
            padding: EdgeInsets.fromLTRB(25, 10, 25, 30 + bottomPadding),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 25), decoration: BoxDecoration(color: dividerColor, borderRadius: BorderRadius.circular(10))),
                  Text(theme.translate('connect_to'), style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: "LexendExaNormal")),
                  const SizedBox(height: 10),
                  
                  Container(
                    width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: dividerColor)),
                    child: Column(children: [Text(hp.name, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textPrimary, fontFamily: "LexendExaNormal")), const SizedBox(height: 5), Text(hp.address, style: TextStyle(fontSize: 12, color: textSecondary), textAlign: TextAlign.center)]),
                  ),
                  const SizedBox(height: 25),

                  Align(alignment: Alignment.centerLeft, child: Text(theme.translate('select_data_accessed'), style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8, alignment: WrapAlignment.center,
                    children: availableData.map((data) {
                      final isSelected = selectedData.contains(data);
                      return ChoiceChip(
                        label: Text(theme.translate(data), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isSelected ? Colors.white : textPrimary)),
                        selected: isSelected, selectedColor: userBlue, backgroundColor: isDark ? Colors.white10 : Colors.grey.shade100, showCheckmark: false, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? userBlue : dividerColor)),
                        onSelected: (selected) { setModalState(() { selected ? selectedData.add(data) : selectedData.remove(data); }); },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),

                  Text(theme.translate('determine_timeframe'), style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),

                  Container(
                    height: 150, width: 250,
                    decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: dividerColor)),
                    child: Row(
                      children: [
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 40,
                            scrollController: FixedExtentScrollController(initialItem: selectedAmountIndex),
                            selectionOverlay: Container(
                              decoration: BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: userBlue.withValues(alpha:0.5), width: 2))),
                            ),
                            onSelectedItemChanged: (index) { setModalState(() => selectedAmountIndex = index); },
                            children: amounts.map((a) => Center(child: Text(a, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textPrimary, fontFamily: "LexendExaNormal")))).toList(),
                          ),
                        ),
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 40,
                            scrollController: FixedExtentScrollController(initialItem: selectedTypeIndex),
                            selectionOverlay: Container(
                              decoration: BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: userBlue.withValues(alpha:0.5), width: 2))),
                            ),
                            onSelectedItemChanged: (index) { setModalState(() => selectedTypeIndex = index); },
                            children: types.map((t) => Center(child: Text(theme.translate(t), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary, fontFamily: "LexendExaNormal")))).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  Text(expiryText, style: TextStyle(color: textSecondary, fontSize: 11)),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      // --- AWAIT THE DATABASE SAVE ---
                      onPressed: isSaving ? null : () async {
                        if (selectedData.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select at least one data type."), backgroundColor: Colors.redAccent)); return; }
                        
                        setModalState(() => isSaving = true);
                        try {
                          await hpProvider.grantAccess(
                            hp, 
                            selectedData, 
                            "${amounts[selectedAmountIndex]} ${types[selectedTypeIndex]}", 
                            "Valid Until: ${expiryText.split('until ')[1]}"
                          );
                          
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Successfully connected to ${hp.name}!"), backgroundColor: actionGreen, behavior: SnackBarBehavior.floating));
                          }
                        } catch (e) {
                          setModalState(() => isSaving = false);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to connect to provider."), backgroundColor: Colors.redAccent));
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: actionGreen, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      child: isSaving 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black87, strokeWidth: 2))
                        : Text(theme.translate('connect'), style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: "LexendExaNormal")),
                    ),
                  )
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}