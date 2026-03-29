import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart'; 
import 'calorie_provider.dart'; 
import '../GeneralPages/auth_provider.dart'; 
import 'user_statistic.dart'; 
import 'user_bottomnavbar.dart'; 
import 'user_glassy_profile.dart'; 

// ==========================================
// MOCK DATA MODEL (PLACEHOLDER FOR SQL DB)
// ==========================================
class UserHealthData {
  
  final int heartRate;
  final String heartRateStatus;
  final int bloodGlucose;
  final String bloodGlucoseStatus;
  final int envNoise;
  final String envNoiseStatus;
  final int currentSteps;
  final int targetSteps;
  final String lastUpdated;

  UserHealthData({
    required this.heartRate,
    required this.heartRateStatus,
    required this.bloodGlucose,
    required this.bloodGlucoseStatus,
    required this.envNoise,
    required this.envNoiseStatus,
    required this.currentSteps,
    required this.targetSteps,
    required this.lastUpdated,
  });
}

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final Color userBlue = const Color(0xFF5A84F1);

  late ScrollController _scrollController;
  bool _isScrolled = false;

  late UserHealthData myData;

  @override
  void initState() {
    super.initState();
    
    // INITIALIZE MOCK DATA
    myData = UserHealthData(
      heartRate: 90,
      heartRateStatus: "Normal",
      bloodGlucose: 90,
      bloodGlucoseStatus: "Normal",
      envNoise: 65,
      envNoiseStatus: "Normal",
      currentSteps: 6789,
      targetSteps: 10000,
      lastUpdated: "1 minute ago",
    );

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
        pageBuilder: (context, animation1, animation2) => UserStatisticPage(initialMetric: metric),
        transitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    // --- LIVE PROVIDERS ---
    final calorieData = Provider.of<CalorieProvider>(context);
    final authData = Provider.of<AuthProvider>(context); // Get live Auth Data!
    final String liveUsername = authData.currentUsername ?? "User"; // Fallback if null

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
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.centerLeft, end: Alignment.centerRight,
                      colors: [Colors.white, Colors.white, Colors.transparent],
                      stops: [0.0, 0.85, 1.0], 
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: Text(
                    "Hi, $liveUsername!", // Dynamic Username!
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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Hi,", style: TextStyle(fontSize: 45, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1, fontFamily: "LexendExaNormal")),
                          Text("$liveUsername!", style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: "LexendExaNormal")), // Dynamic Username!
                        ],
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
                  height: 31, width: double.infinity,
                  decoration: BoxDecoration(color: bgColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40))),
                ),
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
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(35),
                        border: isDark ? Border.all(color: dividerColor) : null,
                        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 8))],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildMetric(
                                    icon: Icons.monitor_heart, color: const Color(0xFFFF6B6B),
                                    value: myData.heartRate.toString(), unit: "bpm", status: myData.heartRateStatus, title: "Heart Rate",
                                    textPrimary: textPrimary, textSecondary: textSecondary,
                                    onTap: () => _routeToStatistic("Heart Rate"), 
                                  ),
                                  const SizedBox(height: 15),
                                  _buildMetric(
                                    icon: Icons.bloodtype, color: const Color(0xFF4ECDC4),
                                    value: myData.bloodGlucose.toString(), unit: "mg / dL", status: myData.bloodGlucoseStatus, title: "Blood Glucose",
                                    textPrimary: textPrimary, textSecondary: textSecondary,
                                    onTap: () => _routeToStatistic("Blood Glucose"), 
                                  ),
                                  const SizedBox(height: 15),
                                  _buildMetric(
                                    icon: Icons.hearing, color: const Color(0xFF45B7D1),
                                    value: myData.envNoise.toString(), unit: "dB", status: myData.envNoiseStatus, title: "Env. Noise",
                                    textPrimary: textPrimary, textSecondary: textSecondary,
                                    onTap: () => _routeToStatistic("Env. Noise"), 
                                  ),
                                ],
                              ),
                              
                              GestureDetector(
                                onTap: () => _routeToStatistic("Steps"), 
                                child: SizedBox(
                                  width: 140, height: 140,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      CircularProgressIndicator(value: 1.0, strokeWidth: 10, color: isDark ? Colors.white10 : Colors.grey.shade100),
                                      TweenAnimationBuilder(
                                        tween: Tween<double>(begin: 0, end: (myData.currentSteps / myData.targetSteps).clamp(0.0, 1.0)), 
                                        duration: const Duration(seconds: 2), curve: Curves.easeOutCubic,
                                        builder: (context, value, child) {
                                          return CircularProgressIndicator(value: value, strokeWidth: 10, backgroundColor: Colors.transparent, valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF9F43)), strokeCap: StrokeCap.round);
                                        },
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text("Steps:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textSecondary)),
                                          Text(myData.currentSteps.toString(), style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textPrimary, fontFamily: "LexendExaNormal", letterSpacing: -1)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          Padding(padding: const EdgeInsets.symmetric(vertical: 15), child: Divider(color: dividerColor, height: 1)),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Last Updated : ${myData.lastUpdated}", style: TextStyle(color: textSecondary, fontSize: 12)),
                              const SizedBox(width: 8),
                              Icon(Icons.sync, size: 16, color: textSecondary),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Text("Quick Action", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textPrimary, fontFamily: "LexendExaNormal")),
                  ),
                  const SizedBox(height: 15),
                  
                  SizedBox(
                    height: 160, 
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        _buildQuickActionCard(
                          icon: Icons.local_fire_department_rounded, iconBgColor: const Color(0xFFFFD93D),
                          title: "Burned Calories",
                          subtitle: "${calorieData.burnedCalories} kcal burned today", 
                          isProgress: true,
                          surfaceColor: surfaceColor, textPrimary: textPrimary, textSecondary: textSecondary, dividerColor: dividerColor, isDark: isDark,
                          onTap: () => Navigator.pushReplacementNamed(context, '/user_calorie')
                        ),
                        const SizedBox(width: 15),
                        _buildQuickActionCard(
                          icon: Icons.calendar_month_rounded, iconBgColor: const Color(0xFF00D1FF),
                          title: "17 December 2026", subtitle: "Heart Appointment\nHospital 1", isAppointment: true,
                          surfaceColor: surfaceColor, textPrimary: textPrimary, textSecondary: textSecondary, dividerColor: dividerColor, isDark: isDark
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Text("Feedback", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textPrimary, fontFamily: "LexendExaNormal")),
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

  // ==========================================
  // HELPER WIDGETS
  // ==========================================

  Widget _buildMetric({
    required IconData icon, required Color color, required String value, required String unit, required String status,
    required String title, required Color textPrimary, required Color textSecondary, VoidCallback? onTap
  }) {
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textPrimary, fontFamily: "LexendExaNormal")),
                    const SizedBox(width: 4),
                    Text(unit, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(color: Colors.greenAccent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                  child: Text(status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon, required Color iconBgColor, required String title, required String subtitle, 
    bool isProgress = false, bool isAppointment = false, VoidCallback? onTap, 
    required Color surfaceColor, required Color textPrimary, required Color textSecondary, required Color dividerColor, required bool isDark
  }) {
    return GestureDetector(
      onTap: onTap, 
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: dividerColor),
          boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(15)),
              child: Icon(icon, color: Colors.black87, size: 35),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textPrimary)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 10, color: textSecondary, height: 1.2)),
                  if (isProgress) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.6,
                      backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD93D)),
                      borderRadius: BorderRadius.circular(5),
                      minHeight: 5,
                    ),
                  ],
                  if (isAppointment) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text("Cancel", style: TextStyle(fontSize: 11, color: Colors.red.shade400, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 15),
                        Text("Reschedule", style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ]
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dividerColor),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))],
      ),
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
                    Text(doctor, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                    Text(time, style: TextStyle(color: textSecondary, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 5),
                Text(message, style: TextStyle(color: textSecondary, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}