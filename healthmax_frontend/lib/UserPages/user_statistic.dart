import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import 'user_bottomnavbar.dart';
import 'user_glassy_profile.dart'; 
import '../GeneralPages/supabase_health_service.dart';
import 'calorie_provider.dart';
import '../GeneralPages/health_providers.dart'; 

class UserStatisticPage extends StatefulWidget {
  final String initialMetric;
  const UserStatisticPage({super.key, this.initialMetric = 'Heart Rate'});

  @override
  State<UserStatisticPage> createState() => _UserStatisticPageState();
}

class _UserStatisticPageState extends State<UserStatisticPage> {
  final Color userBlue = const Color(0xFF5A84F1);
  late ScrollController _scrollController;
  bool _isScrolled = false;

  late String selectedMetric;
  String selectedTimeframe = 'Day'; 
  bool _isSyncing = false;
  List<double>? _liveHourlyData; 

  final Map<String, Color> metricColors = {
    'Heart Rate': const Color(0xFFFF6B6B), 'Steps': const Color(0xFFFF9F43),
    'Calories': const Color(0xFFFFD93D), 'Blood Glucose': const Color(0xFF4ECDC4), 'Env. Noise': const Color(0xFF45B7D1),
  };

  @override
  void initState() {
    super.initState();
    selectedMetric = widget.initialMetric;
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset > 90 && !_isScrolled) setState(() => _isScrolled = true);
      else if (_scrollController.offset <= 90 && _isScrolled) setState(() => _isScrolled = false);
    });
    _loadDataFromCloud(selectedMetric);
  }

  Future<void> _loadDataFromCloud(String metric) async {
    if (!mounted) return;
    setState(() => _isSyncing = true);
    final cloudService = SupabaseHealthService();
    List<double>? cloudData = await cloudService.fetchDataFromCloud(metric);
    
    if (cloudData != null && mounted) {
      setState(() {
        _liveHourlyData = cloudData;
        selectedTimeframe = 'Day'; 
      });
    } else {
      setState(() => _liveHourlyData = null);
    }
    if (mounted) setState(() => _isSyncing = false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _getGraphType() => (selectedMetric == 'Steps' || selectedMetric == 'Calories') ? 'Bar' : 'Spline';
  double _getMaxX() => {'Day': 23.0, 'Week': 6.0, 'Month': 3.0, 'Year': 11.0}[selectedTimeframe] ?? 6.0;
  double _getIntervalX() => selectedTimeframe == 'Day' ? 6 : (selectedTimeframe == 'Year' ? 3 : 1);
  double _getMinY() => selectedMetric == 'Heart Rate' ? 50 : 0;
  double _getMaxY() => {'Heart Rate': 150.0, 'Steps': 15000.0, 'Calories': 3500.0, 'Blood Glucose': 150.0, 'Env. Noise': 100.0}[selectedMetric] ?? 150.0;
  double _getIntervalY() => {'Heart Rate': 25.0, 'Steps': 5000.0, 'Calories': 1000.0, 'Blood Glucose': 50.0, 'Env. Noise': 25.0}[selectedMetric] ?? 25.0;

  List<double> _getRawData(HealthProvider hp, CalorieProvider cp) {
    // --- FLATLINE CHECK (If no device connected, return 0 for everything) ---
    if (!hp.hasDeviceConnected) {
       return List.generate(24, (index) => 0.0);
    }

    if (selectedTimeframe == 'Day' && _liveHourlyData != null) {
      List<double> updatedCloud = List.from(_liveHourlyData!);
      int currentHour = DateTime.now().hour;
      if (selectedMetric == 'Heart Rate') updatedCloud[currentHour] = hp.heartRate.toDouble();
      else if (selectedMetric == 'Steps') updatedCloud[currentHour] = hp.currentSteps.toDouble();
      else if (selectedMetric == 'Calories') updatedCloud[currentHour] = cp.burnedCalories.toDouble();
      else if (selectedMetric == 'Blood Glucose') updatedCloud[currentHour] = hp.bloodGlucose.toDouble();
      else if (selectedMetric == 'Env. Noise') updatedCloud[currentHour] = hp.envNoise.toDouble();
      return updatedCloud;
    }
    
    List<double> baseData = [];
    if (selectedMetric == 'Heart Rate') baseData = [72, 75, 78, 80, 85, 90, 88, 92, 85, 82, 78, 75, 76, 79, 81, 88, 95, 90, 85, 80, 77, 74, 72, 75];
    else if (selectedMetric == 'Steps') baseData = [0, 0, 0, 0, 0, 500, 2500, 5000, 6500, 8000, 9500, 11000, 12500, 14000, 14000, 14000, 14500, 15000, 15000, 15000, 15000, 15000, 15000, 15000]; 
    else if (selectedMetric == 'Calories') baseData = [80, 80, 80, 80, 80, 150, 400, 600, 850, 1100, 1400, 1800, 2100, 2300, 2400, 2450, 2700, 2800, 2800, 2800, 2800, 2800, 2800, 2800];
    else if (selectedMetric == 'Blood Glucose') baseData = [90, 92, 89, 88, 85, 95, 110, 105, 98, 95, 92, 108, 120, 115, 100, 95, 92, 110, 105, 98, 95, 92, 90, 88];
    else if (selectedMetric == 'Env. Noise') baseData = [35, 35, 35, 35, 40, 55, 70, 75, 80, 85, 80, 75, 70, 65, 60, 75, 80, 85, 75, 60, 50, 45, 40, 35];
    
    int requiredLength = (_getMaxX() + 1).toInt();
    List<double> finalData = baseData.sublist(0, requiredLength);
    
    if (selectedTimeframe == 'Day' && _liveHourlyData == null) {
      if (selectedMetric == 'Heart Rate') finalData[finalData.length - 1] = hp.heartRate.toDouble();
      else if (selectedMetric == 'Steps') finalData[finalData.length - 1] = hp.currentSteps.toDouble();
      else if (selectedMetric == 'Calories') finalData[finalData.length - 1] = cp.burnedCalories.toDouble();
      else if (selectedMetric == 'Blood Glucose') finalData[finalData.length - 1] = hp.bloodGlucose.toDouble();
      else if (selectedMetric == 'Env. Noise') finalData[finalData.length - 1] = hp.envNoise.toDouble();
    }
    return finalData;
  }

  String _getAverageValue(HealthProvider hp, CalorieProvider cp) {
    if (!hp.hasDeviceConnected) return "0"; // Show 0 if no device
    if (selectedMetric == 'Heart Rate') return "${hp.heartRate} bpm";
    if (selectedMetric == 'Steps') return "${hp.currentSteps}";
    if (selectedMetric == 'Calories') return "${cp.burnedCalories} kcal";
    if (selectedMetric == 'Blood Glucose') return "${hp.bloodGlucose} mg/dL";
    if (selectedMetric == 'Env. Noise') return "${hp.envNoise} dB";
    return "";
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    final healthData = Provider.of<HealthProvider>(context);
    final calorieData = Provider.of<CalorieProvider>(context);

    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = isDark ? Colors.white54 : Colors.grey.shade600;
    final dividerColor = Theme.of(context).dividerColor;
    final currentColor = metricColors[selectedMetric] ?? userBlue;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController, physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false, backgroundColor: currentColor,
                expandedHeight: 220.0, toolbarHeight: 90.0, pinned: true, elevation: 0,
                scrolledUnderElevation: 0.0, surfaceTintColor: Colors.transparent,
                actions: [Padding(padding: const EdgeInsets.only(right: 30.0, top: 10.0), child: Center(child: UserGlassyProfile(onTap: () => Navigator.pushNamed(context, '/user_settings'))))],
                title: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250), opacity: _isScrolled ? 1.0 : 0.0, 
                  child: Padding(padding: const EdgeInsets.only(top: 10.0), child: Text(themeProvider.translate(selectedMetric), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: "LexendExaNormal"))),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 60, 30, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(fit: BoxFit.scaleDown, child: Text(themeProvider.translate('statistics'), style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: "LexendExaNormal", letterSpacing: -0.5, height: 1.1))),
                        ],
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(selectedTimeframe == 'Day' ? themeProvider.translate('live_record') : themeProvider.translate('latest_record'), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: textSecondary, letterSpacing: 1.2, fontFamily: "LexendExaNormal")),
                                const SizedBox(height: 8),
                                FittedBox(fit: BoxFit.scaleDown, child: Text(themeProvider.translate(selectedMetric), style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textPrimary, fontFamily: "LexendExaNormal", letterSpacing: -0.5))),
                              ],
                            ),
                          ),
                          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: currentColor.withValues(alpha:0.15), shape: BoxShape.circle), child: Icon(_getIconForMetric(selectedMetric), color: currentColor, size: 28))
                        ],
                      ),
                      const SizedBox(height: 30),

                      Container(
                        padding: const EdgeInsets.fromLTRB(15, 20, 20, 15),
                        decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(30), border: Border.all(color: dividerColor), boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha:0.04), blurRadius: 15, offset: const Offset(0, 8))]),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: _buildDropdown(['Heart Rate', 'Steps', 'Calories', 'Blood Glucose', 'Env. Noise'], selectedMetric, (v) { if (v != null) { setState(() { selectedMetric = v; }); _loadDataFromCloud(v); }}, surfaceColor, textPrimary, isDark, themeProvider)),
                                const SizedBox(width: 10),
                                Expanded(child: _buildDropdown(['Day', 'Week', 'Month', 'Year'], selectedTimeframe, (v) => setState(() { selectedTimeframe = v!; }), surfaceColor, textPrimary, isDark, themeProvider)),
                              ],
                            ),
                            const SizedBox(height: 30),
                            SizedBox(height: 220, child: _getGraphType() == 'Spline' ? _buildSplineChart(currentColor, textSecondary, dividerColor, healthData, calorieData) : _buildBarChart(currentColor, textSecondary, dividerColor, healthData, calorieData)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: _isSyncing || !healthData.hasDeviceConnected ? null : () async {
                            setState(() => _isSyncing = true);
                            bool success = await SupabaseHealthService().generateAndPushData(selectedMetric);
                            if (success) {
                              await _loadDataFromCloud(selectedMetric);
                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(themeProvider.translate('cloud_sync_complete'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), backgroundColor: currentColor, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))));
                            } else {
                              setState(() => _isSyncing = false);
                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(themeProvider.translate('failed_to_connect')), backgroundColor: Colors.red));
                            }
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(color: currentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: currentColor.withValues(alpha: 0.3))),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _isSyncing ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: currentColor, strokeWidth: 2)) : Icon(Icons.cloud_sync_rounded, size: 16, color: currentColor),
                                const SizedBox(width: 8),
                                Text(_isSyncing ? themeProvider.translate('syncing') : themeProvider.translate('sync_cloud_data'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: currentColor)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Text(themeProvider.translate('data_breakdown'), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: textSecondary, letterSpacing: 1.2, fontFamily: "LexendExaNormal")),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(child: _buildStatCard(selectedTimeframe == 'Day' ? themeProvider.translate('todays_record') : themeProvider.translate('daily_avg'), _getAverageValue(healthData, calorieData), isDark ? currentColor : currentColor.withValues(alpha:0.8), isDark ? currentColor.withValues(alpha:0.1) : currentColor.withValues(alpha:0.05), textPrimary)),
                          const SizedBox(width: 15),
                          Expanded(child: _buildStatCard(themeProvider.translate('status'), _liveHourlyData != null ? "Supabase" : "Mock", isDark ? Colors.lightBlueAccent : Colors.blue.shade800, isDark ? Colors.blue.withValues(alpha:0.1) : Colors.blue.shade50, textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 140), 
                    ],
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 130, padding: const EdgeInsets.fromLTRB(25, 50, 25, 20),
              decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [bgColor, bgColor.withValues(alpha:0.95), bgColor.withValues(alpha:0.0)], stops: const [0.0, 0.65, 1.0])),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: _actionBtn(themeProvider.translate('compare_data'), isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE), Icons.compare_arrows_rounded, isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E3A8A), onTap: () {})),
                  const SizedBox(width: 15),
                  Expanded(child: _actionBtn(themeProvider.translate('request_feedback'), isDark ? Color.lerp(currentColor, Colors.black, 0.7)! : Color.lerp(currentColor, Colors.white, 0.85)!, Icons.chat_bubble_rounded, currentColor, onTap: () {})),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const UserBottomNavBar(currentIndex: 3), 
    );
  }

  Widget _buildSplineChart(Color currentColor, Color textSecondary, Color dividerColor, HealthProvider hp, CalorieProvider cp) {
    List<double> rawData = _getRawData(hp, cp);
    return ClipRect(child: LineChart(LineChartData(gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: dividerColor, strokeWidth: 1)), titlesData: _buildTitlesData(textSecondary), borderData: FlBorderData(show: false), minX: 0, maxX: _getMaxX(), minY: _getMinY(), maxY: _getMaxY(), lineBarsData: [LineChartBarData(spots: List.generate(rawData.length, (index) => FlSpot(index.toDouble(), rawData[index])), isCurved: true, curveSmoothness: 0.35, color: currentColor, barWidth: 3.5, isStrokeCapRound: true, dotData: FlDotData(show: selectedTimeframe != 'Day', getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: currentColor, strokeWidth: 1.5, strokeColor: Theme.of(context).colorScheme.surface)), belowBarData: BarAreaData(show: true, color: currentColor.withValues(alpha:0.1)))]), duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic));
  }

  Widget _buildBarChart(Color currentColor, Color textSecondary, Color dividerColor, HealthProvider hp, CalorieProvider cp) {
    List<double> rawData = _getRawData(hp, cp);
    return ClipRect(child: BarChart(BarChartData(gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: dividerColor, strokeWidth: 1)), titlesData: _buildTitlesData(textSecondary), borderData: FlBorderData(show: false), maxY: _getMaxY(), barGroups: List.generate(rawData.length, (index) => BarChartGroupData(x: index, barRods: [BarChartRodData(toY: rawData[index], color: currentColor, width: selectedTimeframe == 'Day' ? 6 : 16, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)), backDrawRodData: BackgroundBarChartRodData(show: true, toY: _getMaxY(), color: currentColor.withValues(alpha:0.1)))],))), duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic));
  }

  FlTitlesData _buildTitlesData(Color textSecondary) {
    return FlTitlesData(show: true, rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: _getIntervalX(), getTitlesWidget: (value, meta) { final style = TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textSecondary); int v = value.toInt(); if (selectedTimeframe == "Day") { if (v % 6 == 0) return Padding(padding: const EdgeInsets.only(top: 10), child: Text('${v.toString().padLeft(2, '0')}:00', style: style)); } else if (selectedTimeframe == "Week") { const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']; if (v >= 0 && v < days.length) return Padding(padding: const EdgeInsets.only(top: 10), child: Text(days[v], style: style)); } else if (selectedTimeframe == "Month") { if (v >= 0 && v < 4) return Padding(padding: const EdgeInsets.only(top: 10), child: Text('Wk ${v + 1}', style: style)); } else if (selectedTimeframe == "Year") { const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']; if (v % 3 == 0 && v >= 0 && v < months.length) return Padding(padding: const EdgeInsets.only(top: 10), child: Text(months[v], style: style)); } return const SizedBox.shrink(); })), leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: _getIntervalY(), reservedSize: 35, getTitlesWidget: (value, meta) { if (value == _getMinY() || value == _getMaxY()) return const SizedBox.shrink(); String text = selectedMetric == 'Steps' ? '${(value / 1000).toInt()}k' : value.toInt().toString(); return Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textSecondary)); })));
  }

  Widget _actionBtn(String label, Color col, IconData icon, Color textColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap, 
      child: Container(
        height: 55, padding: const EdgeInsets.symmetric(horizontal: 10), 
        decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(20), border: Border.all(color: textColor.withValues(alpha:0.2))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: textColor), const SizedBox(width: 6),
            Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: textColor, fontFamily: "LexendExaNormal")))),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String val, ValueChanged<String?> onChanged, Color surfaceColor, Color textPrimary, bool isDark, ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: val, isExpanded: true, dropdownColor: surfaceColor,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: textPrimary, size: 16),
          selectedItemBuilder: (BuildContext context) { return items.map<Widget>((String item) => Align(alignment: Alignment.centerLeft, child: FittedBox(fit: BoxFit.scaleDown, child: Text(theme.translate(item), style: TextStyle(fontWeight: FontWeight.w900, color: textPrimary, fontSize: 11, fontFamily: "LexendExaNormal"))))).toList(); },
          onChanged: onChanged,
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(theme.translate(i), style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 12)))).toList(),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color titleColor, Color bgColor, Color textPrimary) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(25), border: Border.all(color: titleColor.withValues(alpha:0.2))),
      child: Column(
        children: [
          FittedBox(fit: BoxFit.scaleDown, child: Text(title, style: TextStyle(color: titleColor, fontWeight: FontWeight.bold, fontSize: 12))),
          const SizedBox(height: 8),
          FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: textPrimary, fontFamily: "LexendExaNormal"))),
        ],
      ),
    );
  }

  IconData _getIconForMetric(String metric) {
    if (metric == 'Steps') return Icons.directions_walk_rounded;
    if (metric == 'Calories') return Icons.local_fire_department_rounded;
    if (metric == 'Blood Glucose') return Icons.bloodtype_rounded;
    if (metric == 'Env. Noise') return Icons.hearing_rounded;
    return Icons.favorite_rounded;
  }
}