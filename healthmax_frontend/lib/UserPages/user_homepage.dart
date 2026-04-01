import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme_provider.dart';
import 'calorie_provider.dart';
import '../GeneralPages/health_providers.dart'; 
import 'user_statistic.dart';
import 'user_bottomnavbar.dart';
import 'user_glassy_profile.dart';
import 'AI_Features/ai_translator_service.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final Color userBlue = const Color(0xFF5A84F1);
  late ScrollController _scrollController;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset > 90 && !_isScrolled) {
        setState(() => _isScrolled = true);
      } else if (_scrollController.offset <= 90 && _isScrolled) {
        setState(() => _isScrolled = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _routeToStatistic(String metric) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, a1, a2) => UserStatisticPage(initialMetric: metric),
        transitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    // --- CONNECTED TO GLOBAL PROVIDERS ---
    final calorieData = Provider.of<CalorieProvider>(context);
    final healthData = Provider.of<HealthProvider>(context);

    final String liveUsername = Supabase.instance.client.auth.currentUser?.userMetadata?['username'] ?? "User";

    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = isDark ? Colors.white54 : Colors.grey.shade600;
    final dividerColor = Theme.of(context).dividerColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            backgroundColor: userBlue,
            expandedHeight: 220.0,
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
                    colors: [Colors.white, Colors.white, Colors.transparent],
                    stops: [0.0, 0.85, 1.0],
                  ).createShader(bounds),
                  blendMode: BlendMode.dstIn,
                  child: Text(
                    "${themeProvider.translate('hi')} $liveUsername!",
                    maxLines: 1, softWrap: false, overflow: TextOverflow.clip,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: "LexendExaNormal"),
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 30.0, top: 10.0),
                child: Center(child: UserGlassyProfile(onTap: () => Navigator.pushNamed(context, '/user_settings'))),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 25, 30, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          themeProvider.translate('hi'),
                          style: const TextStyle(fontSize: 45, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1, fontFamily: "LexendExaNormal"),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "$liveUsername!",
                          style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: "LexendExaNormal"),
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
                child: Container(height: 31, width: double.infinity, decoration: BoxDecoration(color: bgColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(40)))),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              color: bgColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: surfaceColor, borderRadius: BorderRadius.circular(35),
                        border: isDark ? Border.all(color: dividerColor) : null,
                        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 8))],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 3, 
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildMetric(
                                      icon: Icons.monitor_heart, color: const Color(0xFFFF6B6B),
                                      value: healthData.heartRate.toString(), unit: "bpm",
                                      status: themeProvider.translate(healthData.heartRateStatusKey),
                                      textPrimary: textPrimary, textSecondary: textSecondary,
                                      onTap: () => _routeToStatistic("Heart Rate"),
                                    ),
                                    const SizedBox(height: 15),
                                    _buildMetric(
                                      icon: Icons.bloodtype, color: const Color(0xFF4ECDC4),
                                      value: healthData.bloodGlucose.toString(), unit: "mg/dL",
                                      status: themeProvider.translate(healthData.bloodGlucoseStatusKey),
                                      textPrimary: textPrimary, textSecondary: textSecondary,
                                      onTap: () => _routeToStatistic("Blood Glucose"),
                                    ),
                                    const SizedBox(height: 15),
                                    _buildMetric(
                                      icon: Icons.hearing, color: const Color(0xFF45B7D1),
                                      value: healthData.envNoise.toString(), unit: "dB",
                                      status: themeProvider.translate(healthData.envNoiseStatusKey),
                                      textPrimary: textPrimary, textSecondary: textSecondary,
                                      onTap: () => _routeToStatistic("Env. Noise"),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(width: 10), 

                              Expanded(
                                flex: 2,
                                child: GestureDetector(
                                  onTap: () => _routeToStatistic("Steps"),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        CircularProgressIndicator(value: 1.0, strokeWidth: 10, color: isDark ? Colors.white10 : Colors.grey.shade100),
                                        TweenAnimationBuilder(
                                          tween: Tween<double>(begin: 0, end: (healthData.currentSteps / healthData.targetSteps).clamp(0.0, 1.0)),
                                          duration: const Duration(seconds: 1), curve: Curves.easeOutCubic,
                                          builder: (context, value, child) => CircularProgressIndicator(value: value, strokeWidth: 10, backgroundColor: Colors.transparent, valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF9F43)), strokeCap: StrokeCap.round),
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(themeProvider.translate('steps_label'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textSecondary)),
                                            ),
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(healthData.currentSteps.toString(), style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textPrimary, fontFamily: "LexendExaNormal", letterSpacing: -1)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(padding: const EdgeInsets.symmetric(vertical: 15), child: Divider(color: dividerColor, height: 1)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: Text("${themeProvider.translate('last_updated')} ${themeProvider.translate(healthData.lastUpdatedKey)}", style: TextStyle(color: textSecondary, fontSize: 12)))),
                              const SizedBox(width: 8),
                              AnimatedRotation(
                                turns: healthData.currentSteps % 2 == 0 ? 0.5 : 0.0,
                                duration: const Duration(milliseconds: 500),
                                child: Icon(Icons.sync, size: 16, color: userBlue),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Text(themeProvider.translate('quick_action'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textPrimary, fontFamily: "LexendExaNormal")),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 160,
                    child: ListView(
                      scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        _buildQuickActionCard(
                          icon: Icons.local_fire_department_rounded, iconBgColor: const Color(0xFFFFD93D),
                          title: themeProvider.translate('burned_calories'),
                          subtitle: "${calorieData.burnedCalories} ${themeProvider.translate('kcal_burned')}",
                          isProgress: true, surfaceColor: surfaceColor, textPrimary: textPrimary,
                          textSecondary: textSecondary, dividerColor: dividerColor, isDark: isDark, themeProvider: themeProvider,
                          onTap: () => Navigator.pushReplacementNamed(context, '/user_calorie'),
                        ),
                        const SizedBox(width: 15),
                        _buildQuickActionCard(
                          icon: Icons.calendar_month_rounded, iconBgColor: const Color(0xFF00D1FF),
                          title: "17 December 2026", subtitle: "Heart Appointment\nHospital 1",
                          isAppointment: true, surfaceColor: surfaceColor, textPrimary: textPrimary,
                          textSecondary: textSecondary, dividerColor: dividerColor, isDark: isDark, themeProvider: themeProvider,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Text(themeProvider.translate('feedback'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textPrimary, fontFamily: "LexendExaNormal")),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildFeedbackCard("Dr. Ahmad Syafiq", "Heart Rate consistency is looking excellent this week. Keep up the light cardio.", "10:30 AM", surfaceColor, textPrimary, textSecondary, dividerColor, userBlue, isDark),
                        _buildFeedbackCard("Nutritionist Sarah", "Your glucose levels have stabilized perfectly after we adjusted your dinner macros.", "Yesterday", surfaceColor, textPrimary, textSecondary, dividerColor, userBlue, isDark),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const UserBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildMetric({required IconData icon, required Color color, required String value, required String unit, required String status, required Color textPrimary, required Color textSecondary, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))]),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textPrimary, fontFamily: "LexendExaNormal")))),
                      const SizedBox(width: 4),
                      Text(unit, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(color: Colors.greenAccent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                    child: FittedBox(fit: BoxFit.scaleDown, child: Text(status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({required IconData icon, required Color iconBgColor, required String title, required String subtitle, bool isProgress = false, bool isAppointment = false, VoidCallback? onTap, required Color surfaceColor, required Color textPrimary, required Color textSecondary, required Color dividerColor, required bool isDark, required ThemeProvider themeProvider}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260, padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: dividerColor), boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5))]),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: Colors.black87, size: 35)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(fit: BoxFit.scaleDown, child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textPrimary))),
                  const SizedBox(height: 4),
                  FittedBox(fit: BoxFit.scaleDown, child: Text(subtitle, style: TextStyle(fontSize: 10, color: textSecondary, height: 1.2))),
                  if (isProgress) ...[const SizedBox(height: 8), LinearProgressIndicator(value: 0.6, backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200, valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD93D)), borderRadius: BorderRadius.circular(5), minHeight: 5)],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(String doctor, String message, String time, Color surfaceColor, Color textPrimary, Color textSecondary, Color dividerColor, Color userBlue, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: dividerColor), boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundColor: userBlue.withValues(alpha: 0.1), child: Icon(Icons.medical_services_rounded, color: userBlue, size: 20)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(doctor, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)))),
                    const SizedBox(width: 10),
                    Text(time, style: TextStyle(color: textSecondary, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 5),
                AiTranslatedText(message, style: TextStyle(color: textSecondary, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}