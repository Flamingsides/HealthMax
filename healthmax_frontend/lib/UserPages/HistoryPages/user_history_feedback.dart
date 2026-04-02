import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart'; 
import '../user_bottomnavbar.dart';
import '../user_glassy_profile.dart';
import 'user_history_calorie.dart'; 
import '../AI_Features/ai_translator_service.dart';
import '../feedback_provider.dart'; 

class UserHistoryFeedbackPage extends StatefulWidget {
  const UserHistoryFeedbackPage({super.key});
  @override
  State<UserHistoryFeedbackPage> createState() => _UserHistoryFeedbackPageState();
}

class _UserHistoryFeedbackPageState extends State<UserHistoryFeedbackPage> {
  final Color themeBlue = const Color(0xFF5A84F1);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final feedbackProvider = Provider.of<FeedbackProvider>(context); 
    
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = isDark ? Colors.white54 : Colors.grey.shade600;
    final dividerColor = Theme.of(context).dividerColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
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
                        Expanded(child: GestureDetector(onTap: () => Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, __, ___) => const UserHistoryCaloriePage(), transitionDuration: Duration.zero)), child: Container(margin: const EdgeInsets.all(3), color: Colors.transparent, alignment: Alignment.center, child: FittedBox(fit: BoxFit.scaleDown, child: Text(themeProvider.translate('calorie_intake'), style: TextStyle(fontWeight: FontWeight.w600, color: textSecondary, fontFamily: "LexendExaNormal", fontSize: 12)))))),
                        Expanded(child: Container(margin: const EdgeInsets.all(3), decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(30), boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha:0.04), blurRadius: 4, offset: const Offset(0, 2))]), alignment: Alignment.center, child: FittedBox(fit: BoxFit.scaleDown, child: Text(themeProvider.translate('feedback'), style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary, fontFamily: "LexendExaNormal", fontSize: 12))))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // --- EMPTY STATE UI CHECK ---
          if (feedbackProvider.feedbackHistory.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.monitor_heart_outlined, size: 80, color: textSecondary.withValues(alpha: 0.3)),
                    const SizedBox(height: 20),
                    Text("No Feedback Yet", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textPrimary, fontFamily: "LexendExaNormal")),
                    const SizedBox(height: 10),
                    Text("Connect a wearable device or health provider to receive personalized insights.", textAlign: TextAlign.center, style: TextStyle(color: textSecondary, height: 1.5)),
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
                    final feedback = feedbackProvider.feedbackHistory[index];
                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(25), border: isDark ? Border.all(color: dividerColor) : null, boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha:0.03), blurRadius: 8, offset: const Offset(0, 4))]),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start, 
                            children: [
                              CircleAvatar(backgroundColor: isDark ? Colors.white10 : Colors.black87, radius: 22, child: const Icon(Icons.local_hospital, color: Colors.white, size: 20)),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(child: Text(feedback.hospitalName, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textPrimary))),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(feedback.date, style: TextStyle(fontSize: 10, color: textSecondary)),
                                            const SizedBox(height: 2),
                                            Text(feedback.time, style: TextStyle(fontSize: 10, color: textSecondary)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    AiTranslatedText('"${feedback.message}"', style: TextStyle(fontSize: 12, color: textSecondary, height: 1.4)),
                                    const SizedBox(height: 15),
                                    Row(
                                      children: [
                                        const Text("Feedback on ", style: TextStyle(fontSize: 10, color: Colors.grey)),
                                        Text(themeProvider.translate(feedback.feedbackType), style: TextStyle(fontSize: 10, color: feedback.typeColor, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (index < feedbackProvider.feedbackHistory.length - 1) const SizedBox(height: 15), 
                      ],
                    );
                  },
                  childCount: feedbackProvider.feedbackHistory.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
      bottomNavigationBar: const UserBottomNavBar(currentIndex: 1),
    );
  }
}