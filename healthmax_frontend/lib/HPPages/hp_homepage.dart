import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart'; 
import 'hp_bottomnavbar.dart';
import 'hp_glassy_profile.dart';

class HPHomePage extends StatefulWidget {
  const HPHomePage({super.key});

  @override
  State<HPHomePage> createState() => _HPHomePageState();
}

class _HPHomePageState extends State<HPHomePage> {
  // --- DATABASE PLACEHOLDERS ---
  final String _dbHospitalName = "Hospital 1";
  final int _dbConnectedUsers = 10;
  final int _dbPendingRequests = 5;
  final int _dbNeedsAttention = 3;

  // --- STATE VARIABLES ---
  String selectedMetric = 'Heart Rate';
  String selectedTimeframe = 'Week';

  final Map<String, Color> metricColors = {
    'Heart Rate': Colors.redAccent,
    'Steps': Colors.blueAccent,
    'Calories': Colors.orangeAccent,
    'Glucose Level': Colors.greenAccent,
  };

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
    // ==========================================
    // THE FIX: Theme variables safely inside build()
    // ==========================================
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    final themePurple = Theme.of(context).primaryColor;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = isDark ? Colors.white54 : Colors.black54;
    final dividerColor = Theme.of(context).dividerColor;
    
    final currentColor = metricColors[selectedMetric] ?? themePurple;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                backgroundColor: themePurple,
                expandedHeight: 220.0, 
                toolbarHeight: 90.0,
                pinned: true,
                elevation: 0,
                scrolledUnderElevation: 0.0,
                surfaceTintColor: Colors.transparent,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 30.0, top: 10.0), 
                    child: Center(child: HPGlassyProfile(onTap: () => Navigator.pushNamed(context, '/hp_settings'))),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 40, 30, 0),
                      child: Text(
                        "Hi,\n$_dbHospitalName.", 
                        style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: "LexendExaNormal", letterSpacing: -1.0, height: 1.1),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopStats(textPrimary),
                      const SizedBox(height: 35),
                      
                      const Text("ANALYTICS OVERVIEW", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.grey, letterSpacing: 1.2)),
                      Text("$selectedMetric Trends", style: TextStyle(fontSize: 26, color: currentColor, fontWeight: FontWeight.w900, fontFamily: "LexendExaNormal", letterSpacing: -0.5)),
                      const SizedBox(height: 20),
                      
                      _buildGraphSection(currentColor, surfaceColor, textPrimary, dividerColor),
                      
                      const SizedBox(height: 35),
                      
                      const Text("RECENT PATIENT ALERTS", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.grey, letterSpacing: 1.2)),
                      const SizedBox(height: 15),
                      _buildAlertTile("Tengku Adam", "Critical Heart Rate", "142 BPM", Colors.redAccent.withOpacity(0.15), textPrimary, textSecondary),
                      _buildAlertTile("Sarah Jenkins", "Low Glucose Level", "3.2 mmol/L", Colors.orangeAccent.withOpacity(0.15), textPrimary, textSecondary),
                      _buildAlertTile("Mike Ross", "Data Sync Interrupted", "2 hours ago", Colors.grey.withOpacity(isDark ? 0.2 : 0.1), textPrimary, textSecondary),
                      const SizedBox(height: 35),
                      
                      _buildSystemHealthCard(),
                      
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Fog Fade Footer (adapts to light/dark background)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 120,
              padding: const EdgeInsets.only(bottom: 25, left: 25, right: 25),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter, end: Alignment.topCenter,
                  colors: [bgColor, bgColor.withOpacity(0.95), bgColor.withOpacity(0.0)],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  Expanded(child: _actionBtn("Compare Data", isDark ? Colors.orange.shade900 : Colors.orange.shade100, Icons.compare_arrows, textPrimary)),
                  const SizedBox(width: 15),
                  Expanded(child: _actionBtn("Export PDF", isDark ? Colors.cyan.shade900 : Colors.cyan.shade100, Icons.download, textPrimary)),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: HPBottomNavBar(currentIndex: 0, activeColor: themePurple),
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================

  Widget _buildTopStats(Color textPrimary) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _statBtn(Icons.person, "$_dbConnectedUsers Connected Users", const Color.fromARGB(255, 158, 243, 202), Colors.black87, onTap: () => Navigator.pushNamed(context, '/hp_users')),
              const SizedBox(height: 12),
              _statBtn(Icons.access_time, "$_dbPendingRequests Requests", const Color.fromARGB(255, 248, 194, 124), Colors.black87, onTap: () => Navigator.pushNamed(context, '/hp_requests')),
            ],
          ),
        ),
        const SizedBox(width: 15),
        _statBtn(Icons.warning_amber_rounded, "$_dbNeedsAttention NEED\nATTENTION", const Color(0xFFFF4757), Colors.white, isLarge: true),
      ],
    );
  }

  Widget _statBtn(IconData icon, String text, Color color, Color textColor, {bool isLarge = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isLarge ? 116 : 52,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]),
        child: isLarge
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: textColor, size: 30),
                  const SizedBox(height: 5),
                  Text(text, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: textColor)),
                ],
              )
            : Row(
                children: [
                  Icon(icon, size: 20, color: textColor),
                  const SizedBox(width: 10),
                  Expanded(child: Text(text, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: textColor))),
                ],
              ),
      ),
    );
  }

  Widget _buildGraphSection(Color currentColor, Color surfaceColor, Color textPrimary, Color dividerColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 20, 25, 15),
      decoration: BoxDecoration(
        color: surfaceColor, 
        borderRadius: BorderRadius.circular(30), 
        border: Border.all(color: dividerColor),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))]
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _dropdown(['Heart Rate', 'Steps', 'Glucose Level', 'Calories'], selectedMetric, (v) => setState(() => selectedMetric = v!), surfaceColor, textPrimary, isMetric: true),
                _dropdown(['Week', 'Month', 'Year'], selectedTimeframe, (v) => setState(() => selectedTimeframe = v!), surfaceColor, textPrimary, isMetric: false),
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
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true, reservedSize: 30, interval: 1,
                      getTitlesWidget: (value, meta) {
                        final style = TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textPrimary);
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
                        if (selectedMetric == 'Steps') {
                          text = '${(value / 1000).toInt()}k';
                        } else if (selectedMetric == 'Glucose Level') {
                          text = value.toStringAsFixed(1);
                        } else {
                          text = value.toInt().toString();
                        }
                        return Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textPrimary));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true, border: Border(left: BorderSide(color: dividerColor, width: 1.5), bottom: BorderSide(color: dividerColor, width: 1.5), right: BorderSide.none, top: BorderSide.none)),
                minX: 0, maxX: _getMaxX(),
                minY: _getMinY(), maxY: _getMaxY(),
                lineBarsData: [
                  LineChartBarData(
                    spots: _getChartData(),
                    isCurved: true, curveSmoothness: 0.35,
                    color: currentColor, barWidth: 3.5, isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: currentColor.withOpacity(0.1)), 
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 400), 
              curve: Curves.easeOutCubic,
            )
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, Color col, IconData icon, Color textColor) {
    return Container(
      height: 55,
      decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: col.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: textColor),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: textColor, fontFamily: "LexendExaNormal")),
        ],
      ),
    );
  }

  Widget _buildAlertTile(String name, String issue, String value, Color bg, Color textPrimary, Color textSecondary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: textPrimary, shape: BoxShape.circle), child: Icon(Icons.person, size: 18, color: bg)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textPrimary)),
                const SizedBox(height: 4),
                Text(issue, style: TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, fontFamily: "LexendExaNormal", color: textPrimary)),
        ],
      ),
    );
  }

  Widget _buildSystemHealthCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.cloud_done, color: Colors.greenAccent)),
          const SizedBox(width: 15),
          const Expanded(child: Text("All hospital systems are operational. Device sync is at 98% efficiency.", style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _dropdown(List<String> items, String val, ValueChanged<String?> onChanged, Color surfaceColor, Color textPrimary, {required bool isMetric}) {
    // Determine background of dropdown based on theme
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final dropBg = isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: dropBg, 
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: val,
          dropdownColor: surfaceColor,
          icon: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(isMetric ? Icons.keyboard_arrow_down_rounded : Icons.calendar_today_outlined, color: textPrimary, size: 16),
          ),
          selectedItemBuilder: (BuildContext context) {
            return items.map<Widget>((String item) {
              return Center(
                child: Text(item, style: TextStyle(fontWeight: FontWeight.w900, color: textPrimary, fontSize: 13, fontFamily: "LexendExaNormal")),
              );
            }).toList();
          },
          onChanged: onChanged,
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 13)))).toList(),
        ),
      ),
    );
  }
}