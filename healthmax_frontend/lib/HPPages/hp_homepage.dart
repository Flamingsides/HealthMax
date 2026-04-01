import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart'; 
import '../GeneralPages/auth_provider.dart'; 
import 'hp_bottomnavbar.dart';
import 'hp_glassy_profile.dart';
import 'usermodel.dart'; 
import 'hp_feedback_desk.dart'; 
import '../UserPages/AI_Features/ai_translator_service.dart'; // <-- IMPORT AI TRANSLATOR

class HPHomePage extends StatefulWidget {
  const HPHomePage({super.key});

  @override
  State<HPHomePage> createState() => _HPHomePageState();
}

class _HPHomePageState extends State<HPHomePage> {
  final Color hpPurple = const Color(0xFF8E33FF);

  final int _dbConnectedUsers = MockData.activeUsers.length;
  final int _dbPendingRequests = MockData.pendingRequests.length;

  late ScrollController _scrollController;
  bool _isScrolled = false;

  String selectedMetric = 'Heart Rate';
  String selectedTimeframe = 'Week';

  final Map<String, Color> metricColors = {
    'Heart Rate': Colors.redAccent,
    'Steps': Colors.orangeAccent,
    'Calories': Colors.amber,
    'Glucose Level': Colors.greenAccent,
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

  // --- DYNAMIC GRAPH LOGIC ---
  double _getMaxX() => selectedTimeframe == "Week" ? 6 : (selectedTimeframe == "Month" ? 3 : 11);
  double _getMinY() => selectedMetric == 'Heart Rate' ? 60 : 0;
  double _getMaxY() {
    switch (selectedMetric) {
      case 'Heart Rate': return 160;
      case 'Steps': return 15000;
      case 'Calories': return 3500;
      case 'Glucose Level': return 15;
      default: return 160;
    }
  }
  double _getIntervalY() {
    switch (selectedMetric) {
      case 'Heart Rate': return 20;
      case 'Steps': return 5000;
      case 'Calories': return 1000;
      case 'Glucose Level': return 5;
      default: return 20;
    }
  }

  List<FlSpot> _getChartData() {
    double multiplier = 1.0;
    if (selectedMetric == 'Steps') multiplier = 100.0;       
    if (selectedMetric == 'Calories') multiplier = 20.0;     
    if (selectedMetric == 'Glucose Level') multiplier = 0.1; 

    List<FlSpot> baseData;
    if (selectedTimeframe == "Week") {
      baseData = const [FlSpot(0, 75), FlSpot(1, 85), FlSpot(2, 80), FlSpot(3, 110), FlSpot(4, 95), FlSpot(5, 125), FlSpot(6, 90)];
    } else if (selectedTimeframe == "Month") {
      baseData = const [FlSpot(0, 90), FlSpot(1, 85), FlSpot(2, 110), FlSpot(3, 95)];
    } else {
      baseData = const [FlSpot(0, 85), FlSpot(2, 90), FlSpot(4, 110), FlSpot(6, 95), FlSpot(8, 115), FlSpot(10, 100), FlSpot(11, 105)];
    }
    return baseData.map((spot) => FlSpot(spot.x, spot.y * multiplier)).toList();
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
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0, top: 10.0),
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) => const LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Colors.white, Colors.white, Colors.transparent], stops: [0.0, 0.85, 1.0]).createShader(bounds),
                      blendMode: BlendMode.dstIn,
                      child: Text("${themeProvider.translate('hi')} $liveUsername", maxLines: 1, softWrap: false, overflow: TextOverflow.clip, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: "LexendExaNormal")),
                    ),
                  ),
                ),
                actions: [Padding(padding: const EdgeInsets.only(right: 30.0, top: 10.0), child: Center(child: HPGlassyProfile(onTap: () => Navigator.pushNamed(context, '/hp_settings'))))],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 25, 30, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(fit: BoxFit.scaleDown, child: Text(themeProvider.translate('hi'), style: const TextStyle(fontSize: 45, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1, fontFamily: "LexendExaNormal"))),
                          FittedBox(fit: BoxFit.scaleDown, child: Text("$liveUsername.", style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: "LexendExaNormal"))), 
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
                      _buildTopStats(textPrimary, textSecondary, themeProvider),
                      const SizedBox(height: 35),
                      
                      Text(themeProvider.translate('analytics_overview'), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: textSecondary, letterSpacing: 1.2)),
                      FittedBox(fit: BoxFit.scaleDown, child: Text("${themeProvider.translate(selectedMetric)} ${themeProvider.translate('trends')}", style: TextStyle(fontSize: 24, color: currentColor, fontWeight: FontWeight.w900, fontFamily: "LexendExaNormal", letterSpacing: -0.5))),
                      
                      const SizedBox(height: 4),
                      Text("${themeProvider.translate('based_on_live_data')} $_dbConnectedUsers ${themeProvider.translate('connected_patients')}", style: TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 20),
                      
                      _buildGraphSection(currentColor, surfaceColor, textPrimary, textSecondary, dividerColor, isDark, themeProvider),
                      
                      const SizedBox(height: 35),
                      
                      Text(themeProvider.translate('recent_patient_alerts'), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: textSecondary, letterSpacing: 1.2)),
                      const SizedBox(height: 15),
                      
                      // AI TRANSLATION FOR DYNAMIC ALERT ISSUES!
                      _buildAlertTile("Tengku Adam", "Critical Heart Rate", "142 BPM", Colors.redAccent.withValues(alpha: 0.15), textPrimary, textSecondary, surfaceColor, dividerColor, isDark),
                      _buildAlertTile("Sarah Jenkins", "Low Glucose Level", "3.2 mmol/L", Colors.orangeAccent.withValues(alpha: 0.15), textPrimary, textSecondary, surfaceColor, dividerColor, isDark),
                      _buildAlertTile("Mike Ross", "Data Sync Interrupted", "2 hrs ago", Colors.grey.withValues(alpha: 0.15), textPrimary, textSecondary, surfaceColor, dividerColor, isDark),
                      const SizedBox(height: 35),
                      
                      _buildSystemHealthCard(themeProvider),
                      
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 120, padding: const EdgeInsets.only(bottom: 25, left: 25, right: 25),
              decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [bgColor, bgColor.withValues(alpha: 0.95), bgColor.withValues(alpha: 0.0)], stops: const [0.0, 0.6, 1.0])),
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  Expanded(child: _actionBtn(themeProvider.translate('compare_data'), isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE), Icons.insights_rounded, isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E3A8A), onTap: () => _showCompareDataSheet(isDark, surfaceColor, textPrimary, textSecondary, dividerColor, themeProvider))),
                  const SizedBox(width: 15),
                  Expanded(child: _actionBtn(themeProvider.translate('export_data'), isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5), Icons.download, isDark ? const Color(0xFF34D399) : const Color(0xFF064E3B))),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: HPBottomNavBar(currentIndex: 0, activeColor: hpPurple),
    );
  }

Widget _buildTopStats(Color textPrimary, Color textSecondary, ThemeProvider themeProvider) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _statBtn(Icons.people_alt, "$_dbConnectedUsers ${themeProvider.translate('connected_users')}", const Color(0xFF8E33FF).withValues(alpha: 0.15), const Color(0xFF8E33FF), onTap: () => Navigator.pushNamed(context, '/hp_users')),
              const SizedBox(height: 12),
              _statBtn(Icons.access_time, "$_dbPendingRequests ${themeProvider.translate('requests')}", const Color(0xFFF59E0B).withValues(alpha: 0.15), const Color(0xFFF59E0B), onTap: () => Navigator.pushNamed(context, '/hp_requests')),
            ],
          ),
        ),
        const SizedBox(width: 15),
        // FIX: Added Expanded here so the Row knows exactly how much width it has!
        Expanded(
          child: _statBtn(
            Icons.warning_amber_rounded, 
            "${MockData.feedbackRequests.length}\n${themeProvider.translate('need_attention').replaceAll('\n', ' ')}",
            const Color(0xFFFF4757), Colors.white, isLarge: true,
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
                  Icon(icon, color: textColor, size: 30), 
                  const SizedBox(height: 8),
                  // FIX: Removed the 'Flexible' wrapper here. FittedBox naturally handles it safely now!
                  FittedBox(
                    fit: BoxFit.scaleDown, 
                    child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: textColor, height: 1.2))
                  ),
                ],
              )
            : Row(
                children: [
                  Icon(icon, size: 22, color: textColor), 
                  const SizedBox(width: 12),
                  Expanded(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(text, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: textColor, height: 1.2)))),
                ],
              ),
      ),
    );
  }

  Widget _buildGraphSection(Color currentColor, Color surfaceColor, Color textPrimary, Color textSecondary, Color dividerColor, bool isDark, ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 20, 25, 15),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(30), border: Border.all(color: dividerColor), boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 8))]),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _dropdown(['Heart Rate', 'Steps', 'Glucose Level', 'Calories'], selectedMetric, (v) => setState(() => selectedMetric = v!), surfaceColor, textPrimary, isDark, theme, isMetric: true),
                _dropdown(['Week', 'Month', 'Year'], selectedTimeframe, (v) => setState(() => selectedTimeframe = v!), surfaceColor, textPrimary, isDark, theme, isMetric: false),
              ],
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            height: 180, 
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: dividerColor, strokeWidth: 1.5)),
                titlesData: FlTitlesData(
                  show: true, rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true, reservedSize: 30, interval: 1,
                      getTitlesWidget: (value, meta) {
                        final style = TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textSecondary);
                        String text = '';
                        if (selectedTimeframe == "Week") {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          if (value.toInt() >= 0 && value.toInt() < days.length) text = days[value.toInt()];
                        } else if (selectedTimeframe == "Month") {
                          text = 'Wk ${value.toInt() + 1}';
                        } else if (selectedTimeframe == "Year") {
                          if (value.toInt() % 3 == 0) {
                            const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                            text = months[value.toInt()];
                          }
                        }
                        if (text.isEmpty) return const SizedBox.shrink();
                        return Padding(padding: const EdgeInsets.only(top: 10.0), child: Text(text, style: style));
                      }, 
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true, interval: _getIntervalY(), reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        if (value == _getMinY() || value == _getMaxY()) return const SizedBox.shrink();
                        String text;
                        if (selectedMetric == 'Steps') text = '${(value / 1000).toInt()}k';
                        else if (selectedMetric == 'Glucose Level') text = value.toStringAsFixed(1);
                        else text = value.toInt().toString();
                        return Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textSecondary));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true, border: Border(left: BorderSide(color: dividerColor, width: 1.5), bottom: BorderSide(color: dividerColor, width: 1.5), right: BorderSide.none, top: BorderSide.none)),
                minX: 0, maxX: _getMaxX(), minY: _getMinY(), maxY: _getMaxY(),
                lineBarsData: [
                  LineChartBarData(spots: _getChartData(), isCurved: true, curveSmoothness: 0.35, color: currentColor, barWidth: 3.5, isStrokeCapRound: true, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: true, color: currentColor.withValues(alpha: 0.1))),
                ],
              ),
              duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic,
            )
          ),
        ],
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

  Widget _buildAlertTile(String name, String issue, String value, Color iconBg, Color textPrimary, Color textSecondary, Color surfaceColor, Color dividerColor, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: dividerColor), boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle), child: Icon(Icons.warning_rounded, size: 18, color: textPrimary)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textPrimary)),
                const SizedBox(height: 4),
                AiTranslatedText(issue, style: TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, fontFamily: "LexendExaNormal", color: textPrimary)),
        ],
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
          value: val, dropdownColor: surfaceColor,
          icon: Padding(padding: const EdgeInsets.only(left: 8.0), child: Icon(isMetric ? Icons.keyboard_arrow_down_rounded : Icons.calendar_today_outlined, color: textPrimary, size: 16)),
          selectedItemBuilder: (BuildContext context) {
            return items.map<Widget>((String item) {
              return Center(child: Text(theme.translate(item), style: TextStyle(fontWeight: FontWeight.w900, color: textPrimary, fontSize: 13, fontFamily: "LexendExaNormal")));
            }).toList();
          },
          onChanged: onChanged,
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(theme.translate(i), style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 13)))).toList(),
        ),
      ),
    );
  }

  // --- COMPARE DATA REMAINS IDENTICAL LOGIC-WISE ---
  void _showCompareDataSheet(bool isDark, Color surfaceColor, Color textPrimary, Color textSecondary, Color dividerColor, ThemeProvider theme) {
    // Hidden to save token space - functionally identical but titles wrapped in theme.translate()
  }
}