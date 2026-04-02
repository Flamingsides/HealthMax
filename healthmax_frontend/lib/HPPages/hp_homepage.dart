import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart'; 
import '../GeneralPages/auth_provider.dart'; 
import 'hp_bottomnavbar.dart';
import 'hp_glassy_profile.dart';
import 'usermodel.dart'; 
import 'hp_feedback_desk.dart'; 
import '../UserPages/AI_Features/ai_translator_service.dart';

class HPHomePage extends StatefulWidget {
  const HPHomePage({super.key});

  @override
  State<HPHomePage> createState() => _HPHomePageState();
}

class _HPHomePageState extends State<HPHomePage> {
  final Color hpPurple = const Color(0xFF8E33FF);

  final int _dbConnectedUsers = MockData.activeUsers.length;

  late ScrollController _scrollController;
  bool _isScrolled = false;

  String selectedMetric = 'Heart Rate';
  String selectedTimeframe = 'Day';

  final Map<String, Color> metricColors = {
    'Heart Rate': const Color(0xFFFF6B6B), 
    'Steps': const Color(0xFFFF9F43),
    'Calories': const Color(0xFFFFD93D), 
    'Blood Glucose': const Color(0xFF4ECDC4), 
    'Env. Noise': const Color(0xFF45B7D1),
  };

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset > 90 && !_isScrolled) setState(() => _isScrolled = true);
      else if (_scrollController.offset <= 90 && _isScrolled) setState(() => _isScrolled = false);
    });
  }

  @override
  void dispose() { _scrollController.dispose(); super.dispose(); }

  // ==========================================
  // DYNAMIC GRAPH LOGIC (Ported from User Side)
  // ==========================================
  String _getGraphType() => (selectedMetric == 'Steps' || selectedMetric == 'Calories') ? 'Bar' : 'Spline';
  double _getMaxX() => {'Day': 23.0, 'Week': 6.0, 'Month': 3.0, 'Year': 11.0}[selectedTimeframe] ?? 6.0;
  double _getIntervalX() => selectedTimeframe == 'Day' ? 6 : (selectedTimeframe == 'Year' ? 3 : 1);
  double _getMinY() => selectedMetric == 'Heart Rate' ? 50 : 0;
  double _getMaxY() => {'Heart Rate': 150.0, 'Steps': 15000.0, 'Calories': 3500.0, 'Blood Glucose': 150.0, 'Env. Noise': 100.0}[selectedMetric] ?? 150.0;
  double _getIntervalY() => {'Heart Rate': 25.0, 'Steps': 5000.0, 'Calories': 1000.0, 'Blood Glucose': 50.0, 'Env. Noise': 25.0}[selectedMetric] ?? 25.0;

  List<double> _getRawData({bool isCompare = false}) {
    List<double> baseData = [];
    if (selectedMetric == 'Heart Rate') baseData = [72, 75, 78, 80, 85, 90, 88, 92, 85, 82, 78, 75, 76, 79, 81, 88, 95, 90, 85, 80, 77, 74, 72, 75];
    else if (selectedMetric == 'Steps') baseData = [0, 0, 0, 0, 0, 500, 2500, 5000, 6500, 8000, 9500, 11000, 12500, 14000, 14000, 14000, 14500, 15000, 15000, 15000, 15000, 15000, 15000, 15000]; 
    else if (selectedMetric == 'Calories') baseData = [80, 80, 80, 80, 80, 150, 400, 600, 850, 1100, 1400, 1800, 2100, 2300, 2400, 2450, 2700, 2800, 2800, 2800, 2800, 2800, 2800, 2800];
    else if (selectedMetric == 'Blood Glucose') baseData = [90, 92, 89, 88, 85, 95, 110, 105, 98, 95, 92, 108, 120, 115, 100, 95, 92, 110, 105, 98, 95, 92, 90, 88];
    else if (selectedMetric == 'Env. Noise') baseData = [35, 35, 35, 35, 40, 55, 70, 75, 80, 85, 80, 75, 70, 65, 60, 75, 80, 85, 75, 60, 50, 45, 40, 35];
    
    if (isCompare) baseData = baseData.map((e) => e * 0.85).toList();

    int requiredLength = (_getMaxX() + 1).toInt();
    if (selectedTimeframe == 'Day') return baseData.sublist(0, 24);
    if (selectedTimeframe == 'Week') return baseData.sublist(6, 13);
    if (selectedTimeframe == 'Month') return baseData.sublist(0, 4);
    if (selectedTimeframe == 'Year') return baseData.sublist(0, 12);
    return baseData.sublist(0, requiredLength);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final authData = Provider.of<AuthProvider>(context);
    final String liveUsername = authData.currentUsername ?? "Clinic"; 

    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = isDark ? Colors.white54 : Colors.grey.shade600;
    final dividerColor = Theme.of(context).dividerColor;
    final currentColor = metricColors[selectedMetric] ?? hpPurple;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false, backgroundColor: hpPurple, expandedHeight: 220.0, toolbarHeight: 90.0, pinned: true, elevation: 0, scrolledUnderElevation: 0.0, surfaceTintColor: Colors.transparent,
                title: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250), opacity: _isScrolled ? 1.0 : 0.0, 
                  child: Padding(padding: const EdgeInsets.only(left: 15.0, top: 10.0), child: ShaderMask(shaderCallback: (Rect bounds) => const LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Colors.white, Colors.white, Colors.transparent], stops: [0.0, 0.85, 1.0]).createShader(bounds), blendMode: BlendMode.dstIn, child: Text("${themeProvider.translate('hi')} $liveUsername", maxLines: 1, softWrap: false, overflow: TextOverflow.clip, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: "LexendExaNormal")))),
                ),
                actions: [Padding(padding: const EdgeInsets.only(right: 30.0, top: 10.0), child: Center(child: HPGlassyProfile(onTap: () => Navigator.pushNamed(context, '/hp_settings'))))],
                flexibleSpace: FlexibleSpaceBar(collapseMode: CollapseMode.parallax, background: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(30, 25, 30, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [FittedBox(fit: BoxFit.scaleDown, child: Text(themeProvider.translate('hi'), style: const TextStyle(fontSize: 45, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1, fontFamily: "LexendExaNormal"))), FittedBox(fit: BoxFit.scaleDown, child: Text("$liveUsername.", style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: "LexendExaNormal")))])))),
                bottom: PreferredSize(preferredSize: const Size.fromHeight(30), child: Transform.translate(offset: const Offset(0, 1), child: Container(height: 31, width: double.infinity, decoration: BoxDecoration(color: bgColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(40)))))),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopStats(textPrimary, textSecondary, themeProvider),
                      const SizedBox(height: 35),
                      
                      Text(themeProvider.translate('analytics_overview'), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: textSecondary, letterSpacing: 1.2)),
                      FittedBox(fit: BoxFit.scaleDown, child: Text("${themeProvider.translate(selectedMetric)} ${themeProvider.translate('trends')}", style: TextStyle(fontSize: 24, color: currentColor, fontWeight: FontWeight.w900, fontFamily: "LexendExaNormal", letterSpacing: -0.5))),
                      const SizedBox(height: 4),
                      Text("${themeProvider.translate('based_on_live_data')} $_dbConnectedUsers ${themeProvider.translate('connected_patients')}", style: TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 20),
                      
                      // --- DYNAMIC GRAPH WRAPPER ---
                      Container(
                        padding: const EdgeInsets.fromLTRB(15, 20, 20, 15),
                        decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(30), border: Border.all(color: dividerColor), boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha:0.04), blurRadius: 15, offset: const Offset(0, 8))]),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: _dropdown(['Heart Rate', 'Steps', 'Calories', 'Blood Glucose', 'Env. Noise'], selectedMetric, (v) => setState(() => selectedMetric = v!), surfaceColor, textPrimary, isDark, themeProvider, isMetric: true)),
                                const SizedBox(width: 10),
                                Expanded(child: _dropdown(['Day', 'Week', 'Month', 'Year'], selectedTimeframe, (v) => setState(() => selectedTimeframe = v!), surfaceColor, textPrimary, isDark, themeProvider, isMetric: false)),
                              ],
                            ),
                            const SizedBox(height: 30),
                            SizedBox(height: 220, child: _getGraphType() == 'Spline' ? _buildSplineChart(currentColor, textSecondary, dividerColor) : _buildBarChart(currentColor, textSecondary, dividerColor)),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 35),
                      Text("PENDING FEEDBACK", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: textSecondary, letterSpacing: 1.2)),
                      const SizedBox(height: 15),
                      
                      // --- LIVE FEEDBACK LIST ---
                      if (MockData.feedbackRequests.isEmpty)
                        Container(padding: const EdgeInsets.all(30), decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey.shade100, borderRadius: BorderRadius.circular(20)), alignment: Alignment.center, child: Text("No pending feedback requests.", style: TextStyle(color: textSecondary, fontWeight: FontWeight.bold)))
                      else
                        ...MockData.feedbackRequests.take(3).map((req) => _buildPendingFeedbackTile(req, surfaceColor, textPrimary, textSecondary, dividerColor, isDark)),
                      
                      const SizedBox(height: 35),
                      _buildSystemHealthCard(themeProvider),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // --- BOTTOM ACTIONS ---
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 120, padding: const EdgeInsets.only(bottom: 25, left: 25, right: 25),
              decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [bgColor, bgColor.withValues(alpha: 0.95), bgColor.withValues(alpha: 0.0)], stops: const [0.0, 0.6, 1.0])),
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  Expanded(child: _actionBtn(themeProvider.translate('compare_data'), isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE), Icons.insights_rounded, isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E3A8A), onTap: () => _showCompareDataSheet(currentColor, isDark, surfaceColor, textPrimary, textSecondary, dividerColor, themeProvider))),
                  const SizedBox(width: 15),
                  Expanded(child: _actionBtn(themeProvider.translate('export_data'), isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5), Icons.download, isDark ? const Color(0xFF34D399) : const Color(0xFF064E3B), onTap: () => _showExportDialog(surfaceColor, textPrimary, textSecondary, themeProvider))),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: HPBottomNavBar(currentIndex: 0, activeColor: hpPurple),
    );
  }

 // ==========================================
  // GRAPH BUILDERS (Fixed Animation Syntax)
  // ==========================================
  Widget _buildSplineChart(Color currentColor, Color textSecondary, Color dividerColor) {
    List<double> rawData = _getRawData();
    return ClipRect(
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: dividerColor, strokeWidth: 1)), 
          titlesData: _buildTitlesData(textSecondary), borderData: FlBorderData(show: false), 
          minX: 0, maxX: _getMaxX(), minY: _getMinY(), maxY: _getMaxY(), 
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(rawData.length, (index) => FlSpot(index.toDouble(), rawData[index])), 
              isCurved: true, curveSmoothness: 0.35, color: currentColor, barWidth: 3.5, isStrokeCapRound: true, 
              dotData: FlDotData(show: selectedTimeframe != 'Day', getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: currentColor, strokeWidth: 1.5, strokeColor: Theme.of(context).colorScheme.surface)), 
              belowBarData: BarAreaData(show: true, color: currentColor.withValues(alpha:0.1))
            )
          ]
        ), 
        // FIXED SYNTAX HERE:
        duration: const Duration(milliseconds: 500), 
        curve: Curves.easeOutCubic
      )
    );
  }

  Widget _buildBarChart(Color currentColor, Color textSecondary, Color dividerColor) {
    List<double> rawData = _getRawData();
    return ClipRect(
      child: BarChart(
        BarChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: dividerColor, strokeWidth: 1)), 
          titlesData: _buildTitlesData(textSecondary), borderData: FlBorderData(show: false), maxY: _getMaxY(), 
          barGroups: List.generate(rawData.length, (index) => BarChartGroupData(x: index, barRods: [BarChartRodData(toY: rawData[index], color: currentColor, width: selectedTimeframe == 'Day' ? 6 : 16, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)), backDrawRodData: BackgroundBarChartRodData(show: true, toY: _getMaxY(), color: currentColor.withValues(alpha:0.1)))]))
        ), 
        // FIXED SYNTAX HERE:
        duration: const Duration(milliseconds: 500), 
        curve: Curves.easeOutCubic
      )
    );
  }

  Widget _buildMiniChart(List<double> data, Color lineColor, Color dividerColor) {
    if (_getGraphType() == 'Spline') {
      return LineChart(
        LineChartData(gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: dividerColor, strokeWidth: 1)), titlesData: const FlTitlesData(show: false), borderData: FlBorderData(show: false), minX: 0, maxX: _getMaxX(), minY: _getMinY(), maxY: _getMaxY(), lineBarsData: [LineChartBarData(spots: List.generate(data.length, (index) => FlSpot(index.toDouble(), data[index])), isCurved: true, color: lineColor, barWidth: 3, isStrokeCapRound: true, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: true, color: lineColor.withValues(alpha:0.1)))]),
        duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic
      );
    } else {
      return BarChart(
        BarChartData(gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: dividerColor, strokeWidth: 1)), titlesData: const FlTitlesData(show: false), borderData: FlBorderData(show: false), maxY: _getMaxY(), barGroups: List.generate(data.length, (index) => BarChartGroupData(x: index, barRods: [BarChartRodData(toY: data[index], color: lineColor, width: selectedTimeframe == 'Day' ? 4 : 8, borderRadius: const BorderRadius.vertical(top: Radius.circular(2)))]))),
        duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic
      );
    }
  }

  FlTitlesData _buildTitlesData(Color textSecondary) {
    return FlTitlesData(show: true, rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: _getIntervalX(), getTitlesWidget: (value, meta) { final style = TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textSecondary); int v = value.toInt(); if (selectedTimeframe == "Day") { if (v % 6 == 0) return Padding(padding: const EdgeInsets.only(top: 10), child: Text('${v.toString().padLeft(2, '0')}:00', style: style)); } else if (selectedTimeframe == "Week") { const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']; if (v >= 0 && v < days.length) return Padding(padding: const EdgeInsets.only(top: 10), child: Text(days[v], style: style)); } else if (selectedTimeframe == "Month") { if (v >= 0 && v < 4) return Padding(padding: const EdgeInsets.only(top: 10), child: Text('Wk ${v + 1}', style: style)); } else if (selectedTimeframe == "Year") { const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']; if (v % 3 == 0 && v >= 0 && v < months.length) return Padding(padding: const EdgeInsets.only(top: 10), child: Text(months[v], style: style)); } return const SizedBox.shrink(); })), leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: _getIntervalY(), reservedSize: 35, getTitlesWidget: (value, meta) { if (value == _getMinY() || value == _getMaxY()) return const SizedBox.shrink(); String text = selectedMetric == 'Steps' ? '${(value / 1000).toInt()}k' : value.toInt().toString(); return Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textSecondary)); })));
  }

  // ==========================================
  // UI HELPERS
  // ==========================================
  Widget _buildTopStats(Color textPrimary, Color textSecondary, ThemeProvider themeProvider) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _statBtn(Icons.people_alt, "$_dbConnectedUsers ${themeProvider.translate('connected_users')}", const Color(0xFF8E33FF).withValues(alpha: 0.15), const Color(0xFF8E33FF), onTap: () => Navigator.pushNamed(context, '/hp_users')),
              const SizedBox(height: 12),
              _statBtn(Icons.access_time, "${MockData.pendingRequests.length} ${themeProvider.translate('requests')}", const Color(0xFFF59E0B).withValues(alpha: 0.15), const Color(0xFFF59E0B), onTap: () => Navigator.pushNamed(context, '/hp_requests')),
            ],
          ),
        ),
        const SizedBox(width: 15),
        // --- NEW: CONSULT DESK COUNTER ---
        Expanded(
          child: _statBtn(
            Icons.forum_rounded, 
            "${MockData.feedbackRequests.length}\nConsult Desk",
            const Color(0xFF4ECDC4).withValues(alpha: 0.5), Colors.black87, isLarge: true,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HPFeedbackDeskPage())),
          ),
        ),
      ],
    );
  }

  Widget _statBtn(IconData icon, String text, Color bgColor, Color textColor, {bool isLarge = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: isLarge ? 132 : 60), 
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: textColor.withValues(alpha: 0.2))),
        child: isLarge
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: textColor, size: 30), const SizedBox(height: 8),
                  FittedBox(fit: BoxFit.scaleDown, child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: textColor, height: 1.2))),
                ],
              )
            : Row(
                children: [
                  Icon(icon, size: 22, color: textColor), const SizedBox(width: 12),
                  Expanded(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(text, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: textColor, height: 1.2)))),
                ],
              ),
      ),
    );
  }

  Widget _actionBtn(String label, Color col, IconData icon, Color textColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap, 
      child: Container(
        height: 55, decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(20), border: Border.all(color: textColor.withValues(alpha: 0.2))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: textColor), const SizedBox(width: 8),
            Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: textColor, fontFamily: "LexendExaNormal")))),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingFeedbackTile(FeedbackRequest req, Color surfaceColor, Color textPrimary, Color textSecondary, Color dividerColor, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HPFeedbackDeskPage())),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: dividerColor), boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: req.color.withValues(alpha: 0.15), shape: BoxShape.circle), child: Icon(Icons.analytics_outlined, size: 18, color: req.color)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(req.user.fullName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textPrimary)),
                  const SizedBox(height: 4),
                  Text("Needs review: ${req.metric}", style: TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: textSecondary, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemHealthCard(ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: const Color(0xFF8E33FF).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(25), border: Border.all(color: const Color(0xFF8E33FF).withValues(alpha: 0.3))),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF8E33FF).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.cloud_done, color: Color(0xFF8E33FF))),
          const SizedBox(width: 15),
          Expanded(child: Text(theme.translate('system_health_ok'), style: const TextStyle(color: Color(0xFF8E33FF), fontSize: 12, height: 1.4, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _dropdown(List<String> items, String val, ValueChanged<String?> onChanged, Color surfaceColor, Color textPrimary, bool isDark, ThemeProvider theme, {required bool isMetric}) {
    final dropBg = isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: dropBg, borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: val, dropdownColor: surfaceColor, isExpanded: true,
          icon: Icon(isMetric ? Icons.keyboard_arrow_down_rounded : Icons.calendar_today_outlined, color: textPrimary, size: 16),
          selectedItemBuilder: (BuildContext context) { return items.map<Widget>((String item) => Align(alignment: Alignment.centerLeft, child: FittedBox(fit: BoxFit.scaleDown, child: Text(theme.translate(item), style: TextStyle(fontWeight: FontWeight.w900, color: textPrimary, fontSize: 12, fontFamily: "LexendExaNormal"))))).toList(); },
          onChanged: onChanged,
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(theme.translate(i), style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 13)))).toList(),
        ),
      ),
    );
  }

  // ==========================================
  // COMPARE DATA & EXPORT DIALOG
  // ==========================================
void _showCompareDataSheet(Color currentColor, bool isDark, Color surfaceColor, Color textPrimary, Color textSecondary, Color dividerColor, ThemeProvider theme) {
    DateTime date1 = DateTime.now().subtract(const Duration(days: 1));
    DateTime date2 = DateTime.now();
    bool isCompared = false;
    bool isCalculating = false;
    
    List<double> mockData1 = [];
    List<double> mockData2 = [];
    double avg1 = 0;
    double avg2 = 0;
    String aiAnalysisText = "";

    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
          return Container(
            height: MediaQuery.of(context).size.height * 0.85, 
            decoration: BoxDecoration(color: surfaceColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(35))), padding: EdgeInsets.fromLTRB(25, 10, 25, 20 + bottomPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 25), decoration: BoxDecoration(color: dividerColor, borderRadius: BorderRadius.circular(10)))),
                Text("Compare $selectedTimeframe Data", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: "LexendExaNormal", color: textPrimary)), 
                const SizedBox(height: 5),
                Text("Metric: $selectedMetric", style: TextStyle(fontSize: 14, color: currentColor, fontWeight: FontWeight.bold)),
                const SizedBox(height: 25),
                
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final d = await showDatePicker(context: context, initialDate: date1, firstDate: DateTime(2020), lastDate: DateTime.now());
                          if (d != null) setModalState(() { date1 = d; isCompared = false; });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
                          child: Column(children: [Text("Date 1", style: TextStyle(color: textSecondary, fontSize: 11)), const SizedBox(height: 5), Text("${date1.day}/${date1.month}/${date1.year}", style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold))]),
                        ),
                      ),
                    ),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Icon(Icons.compare_arrows_rounded, color: textSecondary)),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final d = await showDatePicker(context: context, initialDate: date2, firstDate: DateTime(2020), lastDate: DateTime.now());
                          if (d != null) setModalState(() { date2 = d; isCompared = false; });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
                          child: Column(children: [Text("Date 2", style: TextStyle(color: textSecondary, fontSize: 11)), const SizedBox(height: 5), Text("${date2.day}/${date2.month}/${date2.year}", style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold))]),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (!isCompared && !isCalculating)
                  SizedBox(width: double.infinity, child: ElevatedButton(
                    onPressed: () async {
                      setModalState(() => isCalculating = true);
                      await Future.delayed(const Duration(seconds: 2)); 

                      final random = Random();
                      int base = selectedMetric == 'Steps' ? 300 : (selectedMetric == 'Calories' ? 80 : 65);
                      int variance = selectedMetric == 'Steps' ? 1000 : (selectedMetric == 'Calories' ? 150 : 25);
                      
                      mockData1 = List.generate((_getMaxX() + 1).toInt(), (index) => (base + random.nextInt(variance)).toDouble());
                      mockData2 = List.generate((_getMaxX() + 1).toInt(), (index) => (base + random.nextInt(variance)).toDouble());
                      
                      avg1 = mockData1.reduce((a, b) => a + b) / mockData1.length;
                      avg2 = mockData2.reduce((a, b) => a + b) / mockData2.length;

                      String trend = avg2 > avg1 ? "an increase" : "a decrease";
                      double percentDiff = ((avg2 - avg1).abs() / avg1) * 100;
                      
                      aiAnalysisText = "Overall $selectedMetric showed $trend of ${percentDiff.toStringAsFixed(1)}% on ${date2.day}/${date2.month} compared to ${date1.day}/${date1.month}. " +
                         (avg2 > avg1 
                          ? (selectedMetric == 'Heart Rate' ? "This higher intensity could indicate stress or intense workouts." : "Excellent job staying active!") 
                          : (selectedMetric == 'Steps' ? "Activity dropped significantly." : "Levels were lower and more stable."));

                      setModalState(() { isCalculating = false; isCompared = true; });
                    }, 
                    style: ElevatedButton.styleFrom(backgroundColor: currentColor, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), 
                    child: const Text("Compare Now", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900, fontFamily: "LexendExaNormal"))
                  )),

                if (isCalculating)
                   Expanded(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(color: currentColor), const SizedBox(height: 20), Text("AI is analyzing patient data...", style: TextStyle(color: textSecondary, fontWeight: FontWeight.bold))]))),

                if (isCompared)
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Date 1 (${date1.day}/${date1.month})", style: TextStyle(fontWeight: FontWeight.bold, color: textSecondary, fontSize: 12)), Text("Avg: ${avg1.toInt()}", style: TextStyle(fontWeight: FontWeight.w900, color: textPrimary))]),
                          const SizedBox(height: 10),
                          SizedBox(height: 110, child: _buildMiniChart(mockData1, Colors.grey.shade400, dividerColor)),
                          const SizedBox(height: 25),
                          
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Date 2 (${date2.day}/${date2.month})", style: TextStyle(fontWeight: FontWeight.bold, color: textSecondary, fontSize: 12)), Text("Avg: ${avg2.toInt()}", style: TextStyle(fontWeight: FontWeight.w900, color: currentColor))]),
                          const SizedBox(height: 10),
                          SizedBox(height: 110, child: _buildMiniChart(mockData2, currentColor, dividerColor)),
                          const SizedBox(height: 30),

                          Container(
                            padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: currentColor.withValues(alpha:0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: currentColor.withValues(alpha:0.3))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [Icon(Icons.auto_awesome, color: currentColor, size: 18), const SizedBox(width: 8), Text("AI Insights", style: TextStyle(color: currentColor, fontWeight: FontWeight.w900, fontSize: 14, fontFamily: "LexendExaNormal"))]),
                                const SizedBox(height: 10),
                                Text(aiAnalysisText, style: TextStyle(color: textPrimary, fontSize: 13, height: 1.5, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(width: double.infinity, child: TextButton(onPressed: () => setModalState(() => isCompared = false), child: Text("Re-Calculate", style: TextStyle(color: textSecondary, fontWeight: FontWeight.bold)))),
                        ],
                      ),
                    ),
                  )
              ],
            ),
          );
        }
      ),
    );
  }


  void _showExportDialog(Color surfaceColor, Color textPrimary, Color textSecondary, ThemeProvider theme) {
    showDialog(
      context: context,
      builder: (context) {
        bool isExporting = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: surfaceColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              title: Text("Export Health Data", style: TextStyle(fontWeight: FontWeight.w900, fontFamily: "LexendExaNormal", color: textPrimary)),
              content: isExporting
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: Color(0xFF064E3B)),
                        const SizedBox(height: 20),
                        Text(theme.translate("preparing_export"), style: TextStyle(color: textSecondary, fontWeight: FontWeight.bold)),
                      ],
                    )
                  : Text("Download a comprehensive .CSV file containing all aggregated patient metrics for the current $selectedTimeframe?", style: TextStyle(color: textSecondary, height: 1.4)),
              actions: isExporting ? [] : [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                ElevatedButton(
                  onPressed: () async {
                    setState(() => isExporting = true);
                    await Future.delayed(const Duration(seconds: 2)); 
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Export complete! File saved to Downloads.", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Color(0xFF064E3B), behavior: SnackBarBehavior.floating));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF064E3B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text("Download .CSV", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          }
        );
      }
    );
  }
}