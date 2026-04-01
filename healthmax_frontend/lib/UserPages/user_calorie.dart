import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset > 70 && !_isScrolled)
        setState(() => _isScrolled = true);
      else if (_scrollController.offset <= 70 && _isScrolled)
        setState(() => _isScrolled = false);
    });

    // _fetchNutrientData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchNutrientData() async {
    final supabase = Supabase.instance.client;
    // final nutrientData = await supabase
    //     .from("user_food_stats")
    //     .select(
    //       "total_calories, total_protein, total_fats, total_carbohydrates",
    //     )
    //     .eq("user_id", supabase.auth.currentUser!.id)
    //     .maybeSingle();

    final foodLogs = await supabase
        .from("food_logs")
        .select("food_name, calories, fats, protein, carbohydrates, logged_at")
        .eq("user_id", supabase.auth.currentUser!.id);

    if (!mounted) return;

    if (foodLogs.isNotEmpty) {
      final calorieData = Provider.of<CalorieProvider>(context, listen: false);
      for (final log in foodLogs) {
        calorieData.addFoodRecord(CalorieRecord.fromMap(log));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
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
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.white, Colors.white, Colors.transparent],
                    stops: [0.0, 0.85, 1.0],
                  ).createShader(bounds),
                  blendMode: BlendMode.dstIn,
                  child: Text(
                    themeProvider.translate('calorie_intake'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontFamily: "LexendExaNormal",
                    ),
                  ),
                ),
              ),
            ),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 30.0, top: 10.0),
                child: Center(child: UserGlassyProfile()),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          themeProvider
                              .translate('calorie_intake')
                              .replaceFirst(' ', '\n'),
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontFamily: "LexendExaNormal",
                            letterSpacing: -1.0,
                            height: 1.1,
                          ),
                        ),
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
                child: Container(
                  height: 31,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(40),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 650),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    children: [
                      // --- OVERVIEW CARD ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 30,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(30),
                          border: isDark
                              ? Border.all(color: dividerColor)
                              : null,
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              themeProvider.translate('today'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                                fontFamily: "LexendExaNormal",
                              ),
                            ),
                            const SizedBox(height: 25),

                            // ==========================================
                            // NEW RESPONSIVE GAUGE ROW
                            // ==========================================
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: _buildClickableStat(
                                    label: themeProvider.translate('eaten'),
                                    value: calorieData.totalEaten,
                                    textPrimary: textPrimary,
                                    textSecondary: textSecondary,
                                    onTap: () => _showEatenBreakdown(
                                      calorieData,
                                      isDark,
                                      surfaceColor,
                                      textPrimary,
                                      textSecondary,
                                      dividerColor,
                                      themeProvider,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        CircularProgressIndicator(
                                          value: 1.0,
                                          strokeWidth: 12,
                                          color: isDark
                                              ? Colors.white10
                                              : Colors.grey.shade100,
                                        ),
                                        TweenAnimationBuilder(
                                          tween: Tween<double>(
                                            begin: 0,
                                            end:
                                                (calorieData.totalEaten /
                                                        calorieData
                                                            .targetCalories)
                                                    .clamp(0.0, 1.0),
                                          ),
                                          duration: const Duration(seconds: 2),
                                          curve: Curves.easeOutCubic,
                                          builder: (context, value, child) =>
                                              CircularProgressIndicator(
                                                value: value,
                                                strokeWidth: 12,
                                                backgroundColor:
                                                    Colors.transparent,
                                                valueColor:
                                                    const AlwaysStoppedAnimation<
                                                      Color
                                                    >(Color(0xFFFF7A00)),
                                                strokeCap: StrokeCap.round,
                                              ),
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                "${calorieData.leftCalories}",
                                                style: TextStyle(
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.w900,
                                                  color: textPrimary,
                                                  fontFamily: "LexendExaNormal",
                                                  letterSpacing: -1,
                                                ),
                                              ),
                                            ),
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                themeProvider.translate(
                                                  'kcal_left',
                                                ),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: textSecondary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: _buildClickableStat(
                                    label: themeProvider.translate('burned'),
                                    value: calorieData.burnedCalories,
                                    textPrimary: textPrimary,
                                    textSecondary: textSecondary,
                                    onTap: () => _showBurnedBreakdown(
                                      calorieData,
                                      isDark,
                                      surfaceColor,
                                      textPrimary,
                                      textSecondary,
                                      dividerColor,
                                      themeProvider,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // --- BREAKDOWN & SUMMARY ROW ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 25,
                                horizontal: 15,
                              ),
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                borderRadius: BorderRadius.circular(30),
                                border: isDark
                                    ? Border.all(color: dividerColor)
                                    : null,
                                boxShadow: isDark
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.04,
                                          ),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                              ),
                              child: Column(
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      themeProvider.translate(
                                        'intake_breakdown',
                                      ),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        color: textPrimary,
                                        fontFamily: "LexendExaNormal",
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 25),
                                  SizedBox(
                                    height: 140,
                                    child: PieChart(
                                      PieChartData(
                                        sectionsSpace: 0,
                                        centerSpaceRadius: 30,
                                        startDegreeOffset: 270,
                                        sections: _getMacroSections(
                                          calorieData,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 35),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 10.0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildLegendItem(
                                            carbColor,
                                            themeProvider.translate(
                                              'carbohydrates',
                                            ),
                                            textPrimary,
                                          ),
                                          _buildLegendItem(
                                            proteinColor,
                                            themeProvider.translate('protein'),
                                            textPrimary,
                                          ),
                                          _buildLegendItem(
                                            fatColor,
                                            themeProvider.translate('fats'),
                                            textPrimary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            flex: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 25,
                                horizontal: 15,
                              ),
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                borderRadius: BorderRadius.circular(30),
                                border: isDark
                                    ? Border.all(color: dividerColor)
                                    : null,
                                boxShadow: isDark
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.04,
                                          ),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        themeProvider.translate('summary'),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          color: textPrimary,
                                          fontFamily: "LexendExaNormal",
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 25),
                                  _buildSummaryMacro(
                                    themeProvider.translate('carbohydrates'),
                                    calorieData.totalCarbs.toInt(),
                                    calorieData.targetCarbs,
                                    textPrimary,
                                    textSecondary,
                                    themeProvider,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildSummaryMacro(
                                    themeProvider.translate('protein'),
                                    calorieData.totalProtein.toInt(),
                                    calorieData.targetProtein,
                                    textPrimary,
                                    textSecondary,
                                    themeProvider,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildSummaryMacro(
                                    themeProvider.translate('fats'),
                                    calorieData.totalFats.toInt(),
                                    calorieData.targetFats,
                                    textPrimary,
                                    textSecondary,
                                    themeProvider,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 120,
                      ), // ← moved outside the Row, at the Column level
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
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserLogFoodPage()),
          ),
          backgroundColor: themeBlue,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          label: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              themeProvider.translate('log_food'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: "LexendExaNormal",
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const UserBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildClickableStat({
    required String label,
    required int value,
    required Color textPrimary,
    required Color textSecondary,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        splashColor: themeBlue.withValues(alpha: 0.1),
        highlightColor: themeBlue.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: textSecondary.withValues(alpha: 0.5),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "$value",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: textPrimary,
                    fontFamily: "LexendExaNormal",
                  ),
                ),
              ),
              Text(
                "kcal",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- BOTTOM SHEETS ---
  void _showEatenBreakdown(
    CalorieProvider data,
    bool isDark,
    Color surfaceColor,
    Color textPrimary,
    Color textSecondary,
    Color dividerColor,
    ThemeProvider theme,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildBottomSheetLayout(
        title: theme.translate('eaten'),
        isDark: isDark,
        surfaceColor: surfaceColor,
        textPrimary: textPrimary,
        dividerColor: dividerColor,
        themeProvider: theme,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...data.calorieHistory.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FIXED: Replaced standard Row with an Expanded Row
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(item.placeholderIcon, color: item.iconColor, size: 18), 
                          const SizedBox(width: 10), 
                          Expanded(child: Text("${item.quantity}× ${item.foodName}", maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary)))
                        ]
                      )
                    ),
                    const SizedBox(width: 10),
                    Text("+ ${item.calories} kcal", style: TextStyle(fontSize: 15, color: textSecondary, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }),
            Divider(thickness: 1, color: dividerColor),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(child: Text(theme.translate('eaten'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, fontFamily: "LexendExaNormal", color: textPrimary))),
                Text("${data.totalEaten} kcal", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: themeBlue)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showBurnedBreakdown(
    CalorieProvider data,
    bool isDark,
    Color surfaceColor,
    Color textPrimary,
    Color textSecondary,
    Color dividerColor,
    ThemeProvider theme,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildBottomSheetLayout(
        title: theme.translate('burned'),
        isDark: isDark,
        surfaceColor: surfaceColor,
        textPrimary: textPrimary,
        dividerColor: dividerColor,
        themeProvider: theme,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.directions_walk_rounded, color: Color(0xFFFF9F43), size: 18), 
                        const SizedBox(width: 10), 
                        Expanded(child: Text("Walk (${data.currentSteps})", maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary)))
                      ]
                    )
                  ),
                  const SizedBox(width: 10),
                  Text("- ${(data.currentSteps * 0.04).toInt()} kcal", style: TextStyle(fontSize: 15, color: textSecondary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.fitness_center_rounded, color: Color(0xFF2ED573), size: 18), 
                        const SizedBox(width: 10), 
                        Expanded(child: Text("Workout", maxLines: 2, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary)))
                      ]
                    )
                  ),
                  const SizedBox(width: 10),
                  Text("- ${data.workoutCalories} kcal", style: TextStyle(fontSize: 15, color: textSecondary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Divider(thickness: 1, color: dividerColor),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(child: Text(theme.translate('burned'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, fontFamily: "LexendExaNormal", color: textPrimary))),
                const Text("320 kcal", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFFF7A00))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetLayout({
    required String title,
    required Widget content,
    required bool isDark,
    required Color surfaceColor,
    required Color textPrimary,
    required Color dividerColor,
    required ThemeProvider themeProvider,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
      ),
      padding: const EdgeInsets.fromLTRB(30, 10, 30, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 30),
            decoration: BoxDecoration(
              color: dividerColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: "LexendExaNormal",
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: dividerColor),
            ),
            child: content,
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeBlue,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                themeProvider.translate('close'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: "LexendExaNormal",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- MACRO CHARTS ---
  List<PieChartSectionData> _getMacroSections(CalorieProvider data) {
    double totalMacros = data.totalCarbs + data.totalProtein + data.totalFats;
    if (totalMacros == 0) totalMacros = 1;
    const TextStyle titleStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontFamily: "LexendExaNormal",
    );

    return [
      PieChartSectionData(
        color: const Color(0xFF2ED573),
        value: (data.totalCarbs / totalMacros) * 100,
        title: '${((data.totalCarbs / totalMacros) * 100).toInt()}%',
        radius: 35,
        titleStyle: titleStyle,
      ),
      PieChartSectionData(
        color: const Color(0xFFFFD93D),
        value: (data.totalProtein / totalMacros) * 100,
        title: '${((data.totalProtein / totalMacros) * 100).toInt()}%',
        radius: 35,
        titleStyle: titleStyle,
      ),
      PieChartSectionData(
        color: themeBlue,
        value: (data.totalFats / totalMacros) * 100,
        title: '${((data.totalFats / totalMacros) * 100).toInt()}%',
        radius: 35,
        titleStyle: titleStyle,
      ),
    ];
  }

  Widget _buildLegendItem(Color color, String label, Color textPrimary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: textPrimary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMacro(
    String label,
    int current,
    int target,
    Color textPrimary,
    Color textSecondary,
    ThemeProvider theme,
  ) {
    int remaining = target - current;
    if (remaining < 0) remaining = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "$label :",
            style: TextStyle(
              fontSize: 12,
              color: textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "$current g",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                TextSpan(
                  text: " / $remaining g ${theme.translate('remaining')}",
                  style: TextStyle(fontSize: 10, color: textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
