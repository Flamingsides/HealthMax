import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import 'user_bottomnavbar.dart';
import 'user_glassy_profile.dart';
import 'user_log_food.dart';
import 'calorie_provider.dart';

class UserCaloriePage extends StatefulWidget {
  const UserCaloriePage({super.key});

  @override
  State<UserCaloriePage> createState() => _UserCaloriePageState();
}

class _UserCaloriePageState extends State<UserCaloriePage> {
  final Color themeBlue = const Color(0xFF5A84F1);

  late ScrollController _scrollController;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    // ALL hardcoded data and manual math has been removed. 
    // The Provider handles all of this automatically now!
    
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset > 70 && !_isScrolled) {
        setState(() => _isScrolled = true);
      } else if (_scrollController.offset <= 70 && _isScrolled) {
        setState(() => _isScrolled = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    // --- THIS IS THE LIVE BRAIN ---
    final calorieData = Provider.of<CalorieProvider>(context);

    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = isDark ? Colors.white54 : Colors.grey.shade600;
    final dividerColor = Theme.of(context).dividerColor;

    final Color carbColor = const Color(0xFF2ED573);   
    final Color proteinColor = const Color(0xFFFFD93D); 
    final Color fatColor = themeBlue;             

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ==========================================
          // APP BAR
          // ==========================================
          SliverAppBar(
            automaticallyImplyLeading: false,
            backgroundColor: themeBlue,
            expandedHeight: 200.0,
            toolbarHeight: 90.0,
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 0.0,
            surfaceTintColor: Colors.transparent,
            
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: _isScrolled ? 1.0 : 0.0,
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0, top: 10.0),
                child: ShaderMask(
                  shaderCallback: (Rect bounds) => const LinearGradient(
                    begin: Alignment.centerLeft, end: Alignment.centerRight,
                    colors: [Colors.white, Colors.white, Colors.transparent], stops: [0.0, 0.85, 1.0], 
                  ).createShader(bounds),
                  blendMode: BlendMode.dstIn,
                  child: const Text("Calorie Intake.", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: "LexendExaNormal")),
                ),
              ),
            ),
            actions: const [Padding(padding: EdgeInsets.only(right: 30.0, top: 10.0), child: Center(child: UserGlassyProfile()))],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax, 
              background: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text("Calorie\nIntake.", style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: "LexendExaNormal", letterSpacing: -1.0, height: 1.1))]),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(30),
              child: Transform.translate(
                offset: const Offset(0, 1),
                child: Container(height: 31, width: double.infinity, decoration: BoxDecoration(color: bgColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(40)))),
              ),
            ),
          ),

          // ==========================================
          // SCROLLABLE BODY 
          // ==========================================
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 650),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    children: [
                      // --- TOP CARD: TODAY'S OVERVIEW ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                        decoration: BoxDecoration(
                          color: surfaceColor, 
                          borderRadius: BorderRadius.circular(30), 
                          border: isDark ? Border.all(color: dividerColor) : null,
                          boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))]
                        ),
                        child: Column(
                          children: [
                            Text("Today", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary, fontFamily: "LexendExaNormal")),
                            const SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                              children: [
                                // --- EATEN BUTTON ---
                                _buildClickableStat(
                                  label: "Eaten", 
                                  value: calorieData.totalEaten, // WIRED
                                  textPrimary: textPrimary, 
                                  textSecondary: textSecondary,
                                  onTap: () => _showEatenBreakdown(calorieData, isDark, surfaceColor, textPrimary, textSecondary, dividerColor),
                                ),
                                
                                // --- CIRCULAR GAUGE ---
                                SizedBox(
                                  width: 140, height: 140,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      CircularProgressIndicator(value: 1.0, strokeWidth: 12, color: isDark ? Colors.white10 : Colors.grey.shade100),
                                      TweenAnimationBuilder(
                                        // WIRED
                                        tween: Tween<double>(begin: 0, end: (calorieData.totalEaten / calorieData.targetCalories).clamp(0.0, 1.0)), 
                                        duration: const Duration(seconds: 2), curve: Curves.easeOutCubic,
                                        builder: (context, value, child) => CircularProgressIndicator(value: value, strokeWidth: 12, backgroundColor: Colors.transparent, valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF7A00)), strokeCap: StrokeCap.round),
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          // WIRED
                                          Text("${calorieData.leftCalories}", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textPrimary, fontFamily: "LexendExaNormal", letterSpacing: -1)),
                                          Text("kcal left.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textSecondary)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // --- BURNED BUTTON ---
                                _buildClickableStat(
                                  label: "Burned", 
                                  value: calorieData.burnedCalories, // WIRED
                                  textPrimary: textPrimary, 
                                  textSecondary: textSecondary,
                                  onTap: () => _showBurnedBreakdown(calorieData, isDark, surfaceColor, textPrimary, textSecondary, dividerColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --- BOTTOM ROW: BREAKDOWN & SUMMARY ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // LEFT CARD: INTAKE BREAKDOWN
                          Expanded(
                            flex: 5,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
                              decoration: BoxDecoration(
                                color: surfaceColor, borderRadius: BorderRadius.circular(30), 
                                border: isDark ? Border.all(color: dividerColor) : null,
                                boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))]
                              ),
                              child: Column(
                                children: [
                                  Text("Intake Breakdown", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: textPrimary, fontFamily: "LexendExaNormal"), textAlign: TextAlign.center),
                                  const SizedBox(height: 25),
                                  SizedBox(
                                    height: 140,
                                    child: PieChart(PieChartData(sectionsSpace: 0, centerSpaceRadius: 30, startDegreeOffset: 270, sections: _getMacroSections(calorieData))), // WIRED
                                  ),
                                  const SizedBox(height: 35),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildLegendItem(carbColor, "Carbohydrates", textPrimary),
                                          _buildLegendItem(proteinColor, "Protein", textPrimary),
                                          _buildLegendItem(fatColor, "Fats", textPrimary),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          
                          // RIGHT CARD: SUMMARY TEXTS
                          Expanded(
                            flex: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
                              decoration: BoxDecoration(
                                color: surfaceColor, borderRadius: BorderRadius.circular(30), 
                                border: isDark ? Border.all(color: dividerColor) : null,
                                boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))]
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(child: Text("Summary", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textPrimary, fontFamily: "LexendExaNormal"))),
                                  const SizedBox(height: 25),
                                  // WIRED
                                  _buildSummaryMacro("Carbohydrates", calorieData.totalCarbs.toInt(), calorieData.targetCarbs, textPrimary, textSecondary),
                                  const SizedBox(height: 20),
                                  _buildSummaryMacro("Protein", calorieData.totalProtein.toInt(), calorieData.targetProtein, textPrimary, textSecondary),
                                  const SizedBox(height: 20),
                                  _buildSummaryMacro("Fats", calorieData.totalFats.toInt(), calorieData.targetFats, textPrimary, textSecondary),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 120), 
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const UserLogFoodPage()));
          },
          backgroundColor: themeBlue, elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          label: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text("Log Food", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: "LexendExaNormal")),
          ),
        ),
      ),
      bottomNavigationBar: const UserBottomNavBar(currentIndex: 2), 
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================

  Widget _buildClickableStat({required String label, required int value, required Color textPrimary, required Color textSecondary, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        splashColor: themeBlue.withOpacity(0.1),
        highlightColor: themeBlue.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: textSecondary, fontSize: 13)),
                  const SizedBox(width: 4),
                  Icon(Icons.info_outline_rounded, size: 14, color: textSecondary.withOpacity(0.5)),
                ],
              ),
              const SizedBox(height: 5),
              Text("$value", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: textPrimary, fontFamily: "LexendExaNormal")),
              Text("kcal", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  // --- BOTTOM SHEETS ---

  void _showEatenBreakdown(CalorieProvider data, bool isDark, Color surfaceColor, Color textPrimary, Color textSecondary, Color dividerColor) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (context) => _buildBottomSheetLayout(
        title: "Today's Intake",
        isDark: isDark, surfaceColor: surfaceColor, textPrimary: textPrimary, dividerColor: dividerColor,
        content: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            ...data.calorieHistory.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(item.placeholderIcon, color: item.iconColor, size: 18),
                        const SizedBox(width: 10),
                        Text("${item.quantity}x ${item.foodName}", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary)),
                      ],
                    ),
                    Text("+ ${item.calories} kcal", style: TextStyle(fontSize: 15, color: textSecondary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            Divider(thickness: 1, color: dividerColor),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total Eaten", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, fontFamily: "LexendExaNormal", color: textPrimary)),
                Text("${data.totalEaten} kcal", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: themeBlue)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showBurnedBreakdown(CalorieProvider data, bool isDark, Color surfaceColor, Color textPrimary, Color textSecondary, Color dividerColor) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (context) => _buildBottomSheetLayout(
        title: "Activity Breakdown",
        isDark: isDark, surfaceColor: surfaceColor, textPrimary: textPrimary, dividerColor: dividerColor,
        content: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            // Row 1: Steps Data
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.directions_walk_rounded, color: Color(0xFFFF9F43), size: 18),
                      const SizedBox(width: 10),
                      Text("Walking (${data.currentSteps} steps)", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary)),
                    ],
                  ),
                  Text("- ${(data.currentSteps * 0.04).toInt()} kcal", style: TextStyle(fontSize: 15, color: textSecondary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            // Row 2: Workout Data
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.fitness_center_rounded, color: Color(0xFF2ED573), size: 18),
                      const SizedBox(width: 10),
                      Text("Active Workout", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary)),
                    ],
                  ),
                  Text("- ${data.workoutCalories} kcal", style: TextStyle(fontSize: 15, color: textSecondary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Divider(thickness: 1, color: dividerColor),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total Burned", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, fontFamily: "LexendExaNormal", color: textPrimary)),
                Text("${data.burnedCalories} kcal", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFFF7A00))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetLayout({required String title, required Widget content, required bool isDark, required Color surfaceColor, required Color textPrimary, required Color dividerColor}) {
    return Container(
      decoration: BoxDecoration(color: surfaceColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(35))),
      padding: const EdgeInsets.fromLTRB(30, 10, 30, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 30), decoration: BoxDecoration(color: dividerColor, borderRadius: BorderRadius.circular(10))),
          Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: "LexendExaNormal", color: textPrimary)),
          const SizedBox(height: 20),
          Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: dividerColor)), child: content),
          const SizedBox(height: 30),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: themeBlue, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))), child: const Text("Close", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: "LexendExaNormal")))),
        ],
      ),
    );
  }

  // --- MACRO CHARTS ---
  List<PieChartSectionData> _getMacroSections(CalorieProvider data) {
    double totalMacros = data.totalCarbs + data.totalProtein + data.totalFats;
    if (totalMacros == 0) totalMacros = 1; 

    const TextStyle titleStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: "LexendExaNormal");

    return [
      PieChartSectionData(color: const Color(0xFF2ED573), value: (data.totalCarbs / totalMacros) * 100, title: '${((data.totalCarbs / totalMacros) * 100).toInt()}%', radius: 35, titleStyle: titleStyle),
      PieChartSectionData(color: const Color(0xFFFFD93D), value: (data.totalProtein / totalMacros) * 100, title: '${((data.totalProtein / totalMacros) * 100).toInt()}%', radius: 35, titleStyle: titleStyle),
      PieChartSectionData(color: themeBlue, value: (data.totalFats / totalMacros) * 100, title: '${((data.totalFats / totalMacros) * 100).toInt()}%', radius: 35, titleStyle: titleStyle),
    ];
  }

  Widget _buildLegendItem(Color color, String label, Color textPrimary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: textPrimary.withOpacity(0.2), width: 1))),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(fontSize: 12, color: textPrimary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSummaryMacro(String label, int current, int target, Color textPrimary, Color textSecondary) {
    int remaining = target - current;
    if (remaining < 0) remaining = 0; 

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label :", style: TextStyle(fontSize: 12, color: textPrimary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        RichText(text: TextSpan(children: [TextSpan(text: "$current g", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textPrimary)), TextSpan(text: " / $remaining g remaining", style: TextStyle(fontSize: 10, color: textSecondary))])),
      ],
    );
  }
}