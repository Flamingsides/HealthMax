import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme_provider.dart';
import 'calorie_provider.dart';
import '../GeneralPages/health_providers.dart'; 
import 'hp_providers.dart'; 
import 'feedback_provider.dart'; 
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
  final Color userPurple = const Color(0xFF8E33FF);
  
  late ScrollController _scrollController;
  bool _isScrolled = false;

  // --- NEW: Appointment State ---
  Map<String, dynamic>? _upcomingAppointment;
  bool _isLoadingAppointment = true;

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
    
    // Fetch appointment on load
    _fetchUpcomingAppointment();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // --- NEW: Fetch Logic from Supabase ---
  Future<void> _fetchUpcomingAppointment() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    
    try {
      final response = await Supabase.instance.client
          .from('book_appointment')
          .select()
          .eq('user_id', user.id)
          .inFilter('status', ['Pending', 'Confirmed']) // Only show active ones
          .order('appointment_date', ascending: true)
          .order('appointment_time', ascending: true)
          .limit(1)
          .maybeSingle();
          
      if (mounted) {
        setState(() {
          _upcomingAppointment = response;
          _isLoadingAppointment = false;
        });
      }
    } catch (e) {
      print("Error fetching appointment: $e");
      if (mounted) setState(() => _isLoadingAppointment = false);
    }
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
    
    final calorieData = Provider.of<CalorieProvider>(context);
    final healthData = Provider.of<HealthProvider>(context);
    final hpData = Provider.of<HPProvider>(context);
    final feedbackData = Provider.of<FeedbackProvider>(context);

    final String liveUsername = Supabase.instance.client.auth.currentUser?.userMetadata?['username'] ?? "User";

    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = isDark ? Colors.white54 : Colors.grey.shade600;
    final dividerColor = Theme.of(context).dividerColor;

    final double dynamicAppBarHeight = 220.0 * themeProvider.fontScale.clamp(1.0, 1.3);
    final double dynamicQuickActionHeight = 160.0 * themeProvider.fontScale.clamp(1.0, 1.4);

    bool hrActive = healthData.hasDeviceConnected && healthData.activeMetrics.contains('Heart Rate');
    bool glucoseActive = healthData.hasDeviceConnected && healthData.activeMetrics.contains('Blood Glucose');
    bool noiseActive = healthData.hasDeviceConnected && healthData.activeMetrics.contains('Env. Noise');
    bool stepsActive = healthData.hasDeviceConnected && healthData.activeMetrics.contains('Steps');

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            backgroundColor: userBlue,
            expandedHeight: dynamicAppBarHeight,
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        themeProvider.translate('hi'),
                        style: TextStyle(fontSize: 45 * themeProvider.fontScale, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1, fontFamily: "LexendExaNormal"),
                      ),
                      Text(
                        "$liveUsername!",
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 35 * themeProvider.fontScale, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: "LexendExaNormal"),
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
                  
                  // ==========================================
                  // NEW: DYNAMIC APPOINTMENT REMINDER BANNER
                  // ==========================================
                  if (_upcomingAppointment != null)
                    _buildAppointmentReminder(_upcomingAppointment!, isDark, themeProvider),

                  // Original Top Padding if Banner isn't there
                  if (_upcomingAppointment == null) const SizedBox(height: 10),

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
                                      icon: Icons.monitor_heart, color: hrActive ? const Color(0xFFFF6B6B) : Colors.grey.shade400,
                                      value: hrActive ? healthData.heartRate.toString() : "--", unit: hrActive ? "bpm" : "",
                                      status: hrActive ? themeProvider.translate(healthData.heartRateStatusKey) : "Not Connected",
                                      textPrimary: hrActive ? textPrimary : textSecondary, textSecondary: textSecondary,
                                      onTap: () => _routeToStatistic("Heart Rate"),
                                    ),
                                    const SizedBox(height: 15),
                                    _buildMetric(
                                      icon: Icons.bloodtype, color: glucoseActive ? const Color(0xFF4ECDC4) : Colors.grey.shade400,
                                      value: glucoseActive ? healthData.bloodGlucose.toString() : "--", unit: glucoseActive ? "mg/dL" : "",
                                      status: glucoseActive ? themeProvider.translate(healthData.bloodGlucoseStatusKey) : "Not Connected",
                                      textPrimary: glucoseActive ? textPrimary : textSecondary, textSecondary: textSecondary,
                                      onTap: () => _routeToStatistic("Blood Glucose"),
                                    ),
                                    const SizedBox(height: 15),
                                    _buildMetric(
                                      icon: Icons.hearing, color: noiseActive ? const Color(0xFF45B7D1) : Colors.grey.shade400,
                                      value: noiseActive ? healthData.envNoise.toString() : "--", unit: noiseActive ? "dB" : "",
                                      status: noiseActive ? themeProvider.translate(healthData.envNoiseStatusKey) : "Not Connected",
                                      textPrimary: noiseActive ? textPrimary : textSecondary, textSecondary: textSecondary,
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
                                          tween: Tween<double>(begin: 0, end: stepsActive ? (healthData.currentSteps / healthData.targetSteps).clamp(0.0, 1.0) : 0.0),
                                          duration: const Duration(seconds: 1), curve: Curves.easeOutCubic,
                                          builder: (context, value, child) => CircularProgressIndicator(value: value, strokeWidth: 10, backgroundColor: Colors.transparent, valueColor: AlwaysStoppedAnimation<Color>(stepsActive ? const Color(0xFFFF9F43) : Colors.grey), strokeCap: StrokeCap.round),
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
                                              child: Text(stepsActive ? healthData.currentSteps.toString() : "--", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: stepsActive ? textPrimary : textSecondary, fontFamily: "LexendExaNormal", letterSpacing: -1)),
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
                              Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: Text("${themeProvider.translate('last_updated')} ${healthData.hasDeviceConnected ? themeProvider.translate(healthData.lastUpdatedKey) : 'Never'}", style: TextStyle(color: textSecondary, fontSize: 12)))),
                              const SizedBox(width: 8),
                              AnimatedRotation(
                                turns: healthData.currentSteps % 2 == 0 ? 0.5 : 0.0,
                                duration: const Duration(milliseconds: 500),
                                child: Icon(Icons.sync, size: 16, color: healthData.hasDeviceConnected ? userBlue : Colors.grey),
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
                    height: dynamicQuickActionHeight, 
                    child: ListView(
                      scrollDirection: Axis.horizontal, 
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        _buildQuickActionCard(
                          icon: Icons.calendar_month_rounded, iconBgColor: const Color(0xFF00D1FF),
                          title: "Book Appointment", 
                          subtitle: "Schedule a checkup\nwith your provider", 
                          isAppointment: true, surfaceColor: surfaceColor, textPrimary: textPrimary,
                          textSecondary: textSecondary, dividerColor: dividerColor, isDark: isDark, themeProvider: themeProvider,
                          onTap: () => _showBookAppointmentSheet(hpData, surfaceColor, textPrimary, textSecondary, dividerColor, isDark, userBlue),
                        ),
                        const SizedBox(width: 15),
                        _buildQuickActionCard(
                          icon: Icons.local_fire_department_rounded, iconBgColor: const Color(0xFFFFD93D),
                          title: themeProvider.translate('burned_calories'),
                          subtitle: "${calorieData.burnedCalories} ${themeProvider.translate('kcal_burned')}",
                          isProgress: false, 
                          surfaceColor: surfaceColor, textPrimary: textPrimary,
                          textSecondary: textSecondary, dividerColor: dividerColor, isDark: isDark, themeProvider: themeProvider,
                          onTap: () => Navigator.pushReplacementNamed(context, '/user_calorie'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(themeProvider.translate('feedback'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textPrimary, fontFamily: "LexendExaNormal")),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(context, '/user_history'),
                          child: Text("View All", style: TextStyle(color: userBlue, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: feedbackData.feedbackHistory.isEmpty 
                    ? Container(
                        width: double.infinity, padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey.shade100, borderRadius: BorderRadius.circular(20), border: Border.all(color: dividerColor)),
                        child: Column(
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded, size: 40, color: textSecondary.withValues(alpha: 0.5)),
                            const SizedBox(height: 10),
                            Text("No Feedback Yet", style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary)),
                            const SizedBox(height: 5),
                            Text("Feedback from your healthcare providers will appear here.", textAlign: TextAlign.center, style: TextStyle(color: textSecondary, fontSize: 12)),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          ...feedbackData.feedbackHistory.take(3).map((f) => 
                            _buildFeedbackCard(f.hospitalName, f.message, "${f.date} • ${f.time}", surfaceColor, textPrimary, textSecondary, dividerColor, f.typeColor, isDark)
                          ),
                        ],
                      ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const UserBottomNavBar(currentIndex: 0),
    );
  }

  // --- NEW: APPOINTMENT REMINDER UI ---
  Widget _buildAppointmentReminder(Map<String, dynamic> appointment, bool isDark, ThemeProvider theme) {
    String dateRaw = appointment['appointment_date'];
    String timeRaw = appointment['appointment_time'].toString().substring(0, 5); // Grabs "HH:MM"
    String provider = appointment['provider_name'];
    String status = appointment['status'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [userBlue, userPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: userBlue.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Upcoming Appointment", style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text("$provider", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: "LexendExaNormal")),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text("$dateRaw • $timeRaw", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: status == 'Confirmed' ? Colors.greenAccent : Colors.orangeAccent,
                borderRadius: BorderRadius.circular(12)
              ),
              child: Text(status, style: const TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
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
                    decoration: BoxDecoration(color: status == "Not Connected" ? Colors.grey.withValues(alpha: 0.2) : Colors.greenAccent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                    child: FittedBox(fit: BoxFit.scaleDown, child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: status == "Not Connected" ? Colors.grey : Colors.green))),
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
        width: 260 * themeProvider.fontScale.clamp(1.0, 1.2),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: dividerColor), boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5))]),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: Colors.black87, size: 35)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15 * themeProvider.fontScale, color: textPrimary)),
                  const SizedBox(height: 4),
                  Text(subtitle, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10 * themeProvider.fontScale, color: textSecondary, height: 1.2)),
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
      constraints: const BoxConstraints(minHeight: 80), 
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: dividerColor), boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundColor: userBlue.withValues(alpha: 0.1), child: Icon(Icons.medical_services_rounded, color: userBlue, size: 20)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(doctor, maxLines: 2, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary))),
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

  void _showBookAppointmentSheet(HPProvider hpData, Color surfaceColor, Color textPrimary, Color textSecondary, Color dividerColor, bool isDark, Color themeBlue) {
    if (hpData.connectedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please connect to a Healthcare Provider in Settings first!"), backgroundColor: Colors.redAccent));
      return;
    }

    String selectedHp = hpData.providers.firstWhere((hp) => hp.isConnected).name;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);
    final TextEditingController reasonCtrl = TextEditingController();
    bool isSaving = false;

    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
          return Container(
            decoration: BoxDecoration(color: surfaceColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(35))), 
            padding: EdgeInsets.fromLTRB(25, 10, 25, 30 + bottomPadding),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 25), decoration: BoxDecoration(color: dividerColor, borderRadius: BorderRadius.circular(10)))),
                  Text("Book Appointment", style: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: "LexendExaNormal")),
                  const SizedBox(height: 25),

                  Text("Select Provider", style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15), decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedHp, isExpanded: true, dropdownColor: surfaceColor,
                        icon: Icon(Icons.keyboard_arrow_down_rounded, color: textPrimary),
                        onChanged: (v) { if (v != null) setModalState(() => selectedHp = v); },
                        items: hpData.providers.where((hp) => hp.isConnected).map((hp) => DropdownMenuItem(value: hp.name, child: Text(hp.name, style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)))).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Date", style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () async {
                                final d = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                                if (d != null) setModalState(() => selectedDate = d);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("${selectedDate.day}/${selectedDate.month}/${selectedDate.year}", style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
                                    Icon(Icons.calendar_today_rounded, size: 16, color: textSecondary),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Time", style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () async {
                                final t = await showTimePicker(context: context, initialTime: selectedTime);
                                if (t != null) setModalState(() => selectedTime = t);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(selectedTime.format(context), style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
                                    Icon(Icons.access_time_rounded, size: 16, color: textSecondary),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Text("Details / Reason", style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reasonCtrl, maxLines: 3, style: TextStyle(color: textPrimary, fontSize: 13),
                    decoration: InputDecoration(filled: true, fillColor: isDark ? Colors.white10 : Colors.grey.shade100, hintText: "E.g. Routine checkup, experiencing chest pain...", hintStyle: TextStyle(color: textSecondary), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none), contentPadding: const EdgeInsets.all(15)),
                  ),

                  const SizedBox(height: 35),
                  SizedBox(width: double.infinity, child: ElevatedButton(
                    onPressed: isSaving ? null : () async { 
                      if (reasonCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please provide a reason."), backgroundColor: Colors.redAccent));
                        return;
                      }

                      setModalState(() => isSaving = true);
                      
                      final String dateStr = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
                      final String timeStr = "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00";

                      try {
                        final user = Supabase.instance.client.auth.currentUser;
                        if (user != null) {
                          await Supabase.instance.client.from('book_appointment').insert({
                            'user_id': user.id,
                            'provider_name': selectedHp,
                            'appointment_date': dateStr,
                            'appointment_time': timeStr,
                            'reason': reasonCtrl.text,
                            'status': 'Pending'
                          });
                        }
                        
                        if (context.mounted) {
                          Navigator.pop(context); 
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Appointment Requested with $selectedHp!"), backgroundColor: Colors.green));
                          
                          // --- NEW: Refresh to show banner instantly ---
                          _fetchUpcomingAppointment();
                        }
                      } catch (e) {
                         setModalState(() => isSaving = false);
                         if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to book appointment: $e"), backgroundColor: Colors.redAccent));
                      }
                    }, 
                    style: ElevatedButton.styleFrom(backgroundColor: themeBlue, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), 
                    child: isSaving 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Confirm Booking", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900, fontFamily: "LexendExaNormal"))
                  ))
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}