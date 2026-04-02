import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart'; 
import '../user_bottomnavbar.dart';
import '../user_glassy_profile.dart';
import 'user_history_feedback.dart'; 
import '../calorie_provider.dart';
import '../AI_Features/ai_translator_service.dart';

class UserHistoryCaloriePage extends StatefulWidget {
  const UserHistoryCaloriePage({super.key});
  @override
  State<UserHistoryCaloriePage> createState() => _UserHistoryCaloriePageState();
}

class _UserHistoryCaloriePageState extends State<UserHistoryCaloriePage> {
  final Color themeBlue = const Color(0xFF5A84F1);

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

    List<CalorieRecord> sortedHistory = List.from(calorieData.calorieHistory);
    
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // --- PULL TO REFRESH ADDED HERE ---
          RefreshIndicator(
            onRefresh: () async {
              await Provider.of<CalorieProvider>(context, listen: false).fetchUserDataAndLogs();
            },
            color: themeBlue,
            backgroundColor: surfaceColor,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(), // Allows pull-to-refresh even if list is short
              slivers: [
                SliverAppBar(
                  automaticallyImplyLeading: false, backgroundColor: themeBlue, expandedHeight: 200.0, toolbarHeight: 90.0, pinned: true, elevation: 0, scrolledUnderElevation: 0.0, surfaceTintColor: Colors.transparent,
                  actions: const [Padding(padding: EdgeInsets.only(right: 30.0, top: 10.0), child: Center(child: UserGlassyProfile()))],
                  title: Padding(padding: const EdgeInsets.only(left: 15.0), child: FittedBox(fit: BoxFit.scaleDown, child: Text(themeProvider.translate('history'), style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: "LexendExaNormal", letterSpacing: -1.0, height: 1.1)))),
                  flexibleSpace: const FlexibleSpaceBar(collapseMode: CollapseMode.parallax, background: SizedBox.shrink()),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(60), 
                    child: Container(
                      height: 60, width: double.infinity, decoration: BoxDecoration(color: bgColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40))),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(30, 10, 30, 10), 
                        child: Container(
                          height: 40, decoration: BoxDecoration(color: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade200, borderRadius: BorderRadius.circular(30)),
                          child: Row(
                            children: [
                              Expanded(child: Container(margin: const EdgeInsets.all(3), decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(30), boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))]), alignment: Alignment.center, child: FittedBox(fit: BoxFit.scaleDown, child: Text(themeProvider.translate('calorie_intake'), style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary, fontFamily: "LexendExaNormal", fontSize: 12))))),
                              Expanded(child: GestureDetector(onTap: () => Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, __, ___) => const UserHistoryFeedbackPage(), transitionDuration: Duration.zero)), child: Container(margin: const EdgeInsets.all(3), color: Colors.transparent, alignment: Alignment.center, child: FittedBox(fit: BoxFit.scaleDown, child: Text(themeProvider.translate('feedback'), style: TextStyle(fontWeight: FontWeight.w600, color: textSecondary, fontFamily: "LexendExaNormal", fontSize: 12)))))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                if (sortedHistory.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fastfood_outlined, size: 80, color: textSecondary.withValues(alpha: 0.3)),
                          const SizedBox(height: 20),
                          Text("No Food Logged Yet", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textPrimary, fontFamily: "LexendExaNormal")),
                          const SizedBox(height: 10),
                          Text("Start tracking your meals to see your daily calorie intake history.\n(Pull down to refresh database)", textAlign: TextAlign.center, style: TextStyle(color: textSecondary, height: 1.5)),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = sortedHistory[index];
                          return Column(
                            children: [
                              InkWell(
                                onTap: () => _showDetailSheet(item.foodName, "${themeProvider.translate('detailed_breakdown')} ${item.foodName}.", isDark, surfaceColor, textPrimary, textSecondary, dividerColor, themeProvider),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(height: 70, width: 70, decoration: BoxDecoration(color: item.iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)), child: Icon(item.placeholderIcon, size: 35, color: item.iconColor)),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: AiTranslatedText(item.foodName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary, fontFamily: "LexendExaNormal")))),
                                                const SizedBox(width: 10),
                                                Text("Qty : ${item.quantity}", style: TextStyle(fontSize: 11, color: textSecondary)),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Expanded(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text("${themeProvider.translate('protein')} : ${item.protein}", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textPrimary)))),
                                                Expanded(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text("${themeProvider.translate('carbohydrates')} : ${item.carbs}", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textPrimary)))),
                                              ],
                                            ),
                                            const SizedBox(height: 5),
                                            FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text("${themeProvider.translate('fats')} : ${item.fats}", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textPrimary))),
                                            const SizedBox(height: 8),
                                            Align(alignment: Alignment.centerRight, child: FittedBox(fit: BoxFit.scaleDown, child: Text("${item.calories} kcal", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textPrimary)))),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (index < sortedHistory.length - 1) Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Divider(color: dividerColor, thickness: 1)),
                            ],
                          );
                        },
                        childCount: sortedHistory.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)), 
              ],
            ),
          ),
          
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 130, width: double.infinity, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [bgColor, bgColor.withValues(alpha: 0.8), bgColor.withValues(alpha: 0.0)], stops: const [0.0, 0.5, 1.0])),
              child: Align(
                alignment: Alignment.bottomRight, 
                child: Padding(
                  padding: const EdgeInsets.only(right: 25.0, bottom: 20.0), 
                  child: Container(
                    height: 48, decoration: BoxDecoration(color: themeBlue, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: themeBlue.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 6))]),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () => _showCalorieBreakdownSheet(sortedHistory, calorieData.totalEaten, isDark, surfaceColor, textPrimary, dividerColor, themeProvider),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Row(
                            mainAxisSize: MainAxisSize.min, 
                            children: [
                              const Icon(Icons.local_fire_department, color: Colors.white, size: 20), const SizedBox(width: 8),
                              FittedBox(fit: BoxFit.scaleDown, child: Text("Total: ${calorieData.totalEaten} kcal", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13, fontFamily: "LexendExaNormal"))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const UserBottomNavBar(currentIndex: 1),
    );
  }

  void _showDetailSheet(String title, String description, bool isDark, Color surfaceColor, Color textPrimary, Color textSecondary, Color dividerColor, ThemeProvider theme) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (context) => _buildBottomSheetLayout(title, AiTranslatedText(description, style: TextStyle(color: textSecondary, height: 1.5, fontSize: 14)), isDark, surfaceColor, textPrimary, dividerColor, theme),
    );
  }

  void _showCalorieBreakdownSheet(List<CalorieRecord> dataList, int total, bool isDark, Color surfaceColor, Color textPrimary, Color dividerColor, ThemeProvider theme) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (context) => _buildBottomSheetLayout(
        theme.translate('daily_breakdown'),
        Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            ...dataList.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AiTranslatedText("${item.quantity}x ${item.foodName}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary))
                    ),
                    const SizedBox(width: 10),
                    Text("+ ${item.calories} kcal", style: TextStyle(fontSize: 16, color: textPrimary.withValues(alpha: 0.7), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            Divider(thickness: 1, color: dividerColor),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(child: Text(theme.translate('total_intake'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, fontFamily: "LexendExaNormal", color: textPrimary))),
                const SizedBox(width: 10),
                Text("$total kcal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: themeBlue)),
              ],
            ),
          ],
        ),
        isDark, surfaceColor, textPrimary, dividerColor, theme
      ),
    );
  }

  Widget _buildBottomSheetLayout(String title, Widget content, bool isDark, Color surfaceColor, Color textPrimary, Color dividerColor, ThemeProvider theme) {
    return Container(
      decoration: BoxDecoration(color: surfaceColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(35))), padding: const EdgeInsets.fromLTRB(30, 10, 30, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 30), decoration: BoxDecoration(color: dividerColor, borderRadius: BorderRadius.circular(10))),
          FittedBox(fit: BoxFit.scaleDown, child: AiTranslatedText(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: "LexendExaNormal", color: textPrimary))),
          const SizedBox(height: 20),
          Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: dividerColor)), child: content),
          const SizedBox(height: 30),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: themeBlue, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))), child: Text(theme.translate('close'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: "LexendExaNormal")))),
        ],
      ),
    );
  }
}