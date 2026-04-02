import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart'; 
import 'usermodel.dart';

class HPUserSelected extends StatefulWidget {
  final UserModel user;

  const HPUserSelected({super.key, required this.user});

  @override
  State<HPUserSelected> createState() => _HPUserSelectedState();
}

class _HPUserSelectedState extends State<HPUserSelected> {
  String selectedMetric = 'Heart Rate';
  String selectedTimeframe = 'Day';

  final Map<String, Color> metricColors = {
    'Heart Rate': const Color(0xFFFF6B6B), 
    'Steps': const Color(0xFFFF9F43),
    'Calories': const Color(0xFFFFD93D), 
    'Blood Glucose': const Color(0xFF4ECDC4), 
    'Env. Noise': const Color(0xFF45B7D1),
  };

  // ==========================================
  // DYNAMIC GRAPH LOGIC (Ported from User Side)
  // ==========================================
  String _getGraphType() => (selectedMetric == 'Steps' || selectedMetric == 'Calories') ? 'Bar' : 'Spline';
  double _getMaxX() => {'Day': 23.0, 'Week': 6.0, 'Month': 3.0, 'Year': 11.0}[selectedTimeframe] ?? 6.0;
  double _getIntervalX() => selectedTimeframe == 'Day' ? 6 : (selectedTimeframe == 'Year' ? 3 : 1);
  double _getMinY() => selectedMetric == 'Heart Rate' ? 50 : 0;
  double _getMaxY() => {'Heart Rate': 150.0, 'Steps': 15000.0, 'Calories': 3500.0, 'Blood Glucose': 150.0, 'Env. Noise': 100.0}[selectedMetric] ?? 150.0;
  double _getIntervalY() => {'Heart Rate': 25.0, 'Steps': 5000.0, 'Calories': 1000.0, 'Blood Glucose': 50.0, 'Env. Noise': 25.0}[selectedMetric] ?? 25.0;

  List<double> _getRawData() {
    List<double> baseData = [];
    if (selectedMetric == 'Heart Rate') baseData = [72, 75, 78, 80, 85, 90, 88, 92, 85, 82, 78, 75, 76, 79, 81, 88, 95, 90, 85, 80, 77, 74, 72, 75];
    else if (selectedMetric == 'Steps') baseData = [0, 0, 0, 0, 0, 500, 2500, 5000, 6500, 8000, 9500, 11000, 12500, 14000, 14000, 14000, 14500, 15000, 15000, 15000, 15000, 15000, 15000, 15000]; 
    else if (selectedMetric == 'Calories') baseData = [80, 80, 80, 80, 80, 150, 400, 600, 850, 1100, 1400, 1800, 2100, 2300, 2400, 2450, 2700, 2800, 2800, 2800, 2800, 2800, 2800, 2800];
    else if (selectedMetric == 'Blood Glucose') baseData = [90, 92, 89, 88, 85, 95, 110, 105, 98, 95, 92, 108, 120, 115, 100, 95, 92, 110, 105, 98, 95, 92, 90, 88];
    else if (selectedMetric == 'Env. Noise') baseData = [35, 35, 35, 35, 40, 55, 70, 75, 80, 85, 80, 75, 70, 65, 60, 75, 80, 85, 75, 60, 50, 45, 40, 35];
    
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

    final themePurple = Theme.of(context).primaryColor;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final dividerColor = Theme.of(context).dividerColor;
    
    final currentColor = metricColors[selectedMetric] ?? themePurple;

    return Scaffold(
      backgroundColor: themePurple,
      body: Stack(
        children: [
          Positioned(
            top: 60, left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          Positioned(
            top: 110, left: 30, right: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.user.fullName, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: "LexendExaNormal", letterSpacing: -0.5)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.watch_rounded, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text("Device: ${widget.user.device}", style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(widget.user.infoString, style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600)),
              ],
            ),
          ),

          Column(
            children: [
              const SizedBox(height: 250),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: bgColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40))),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(25, 30, 25, 140),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("ANALYTICS OVERVIEW", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.grey, letterSpacing: 1.2)),
                        const SizedBox(height: 20),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSelector(selectedMetric, (val) => setState(() => selectedMetric = val!), ['Heart Rate', 'Steps', 'Calories', 'Blood Glucose', 'Env. Noise'], isDark, surfaceColor, textPrimary),
                            _buildSelector(selectedTimeframe, (val) => setState(() => selectedTimeframe = val!), ['Day', 'Week', 'Month', 'Year'], isDark, surfaceColor, textPrimary, isTime: true),
                          ],
                        ),
                        
                        const SizedBox(height: 25),
                        Container(
                          height: 240, padding: const EdgeInsets.fromLTRB(10, 25, 25, 15),
                          decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(30), border: Border.all(color: dividerColor), boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 5))]),
                          child: _getGraphType() == 'Spline' ? _buildSplineChart(currentColor, isDark ? Colors.white54 : Colors.grey.shade600, dividerColor) : _buildBarChart(currentColor, isDark ? Colors.white54 : Colors.grey.shade600, dividerColor),
                        ),
                        const SizedBox(height: 25),
                        _buildQuickStats(isDark, textPrimary, currentColor),             
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 25, left: 20, right: 20,
            child: _buildUserActionBar(isDark),
          ),
        ],
      ),
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

  FlTitlesData _buildTitlesData(Color textSecondary) {
    return FlTitlesData(show: true, rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: _getIntervalX(), getTitlesWidget: (value, meta) { final style = TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textSecondary); int v = value.toInt(); if (selectedTimeframe == "Day") { if (v % 6 == 0) return Padding(padding: const EdgeInsets.only(top: 10), child: Text('${v.toString().padLeft(2, '0')}:00', style: style)); } else if (selectedTimeframe == "Week") { const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']; if (v >= 0 && v < days.length) return Padding(padding: const EdgeInsets.only(top: 10), child: Text(days[v], style: style)); } else if (selectedTimeframe == "Month") { if (v >= 0 && v < 4) return Padding(padding: const EdgeInsets.only(top: 10), child: Text('Wk ${v + 1}', style: style)); } else if (selectedTimeframe == "Year") { const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']; if (v % 3 == 0 && v >= 0 && v < months.length) return Padding(padding: const EdgeInsets.only(top: 10), child: Text(months[v], style: style)); } return const SizedBox.shrink(); })), leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: _getIntervalY(), reservedSize: 35, getTitlesWidget: (value, meta) { if (value == _getMinY() || value == _getMaxY()) return const SizedBox.shrink(); String text = selectedMetric == 'Steps' ? '${(value / 1000).toInt()}k' : value.toInt().toString(); return Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textSecondary)); })));
  }

  // ==========================================
  // UI COMPONENT HELPERS
  // ==========================================
  Widget _buildSelector(String val, ValueChanged<String?> onChange, List<String> items, bool isDark, Color surfaceColor, Color textPrimary, {bool isTime = false}) {
    final dropBg = isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(color: dropBg, borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: val, dropdownColor: surfaceColor,
          icon: Padding(padding: const EdgeInsets.only(left: 8.0), child: Icon(isTime ? Icons.calendar_month : Icons.expand_more, size: 16, color: textPrimary)),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textPrimary)))).toList(),
          onChanged: onChange,
        ),
      ),
    );
  }

  Widget _buildQuickStats(bool isDark, Color textPrimary, Color graphColor) {
    String avgVal = "72 bpm";
    if (selectedMetric == 'Steps') avgVal = "8.5k";
    if (selectedMetric == 'Calories') avgVal = "2100 kcal";
    if (selectedMetric == 'Blood Glucose') avgVal = "5.2 mmol/L";
    if (selectedMetric == 'Env. Noise') avgVal = "45 dB";

    return Row(
      children: [
        _statBox("Daily Avg", avgVal, graphColor, textPrimary),
        const SizedBox(width: 15),
        _statBox("Status", "Normal", isDark ? Colors.lightBlueAccent : Colors.blue.shade800, textPrimary),
      ],
    );
  }

  Widget _statBox(String title, String val, Color col, Color textPrimary) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(color: col.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(25), border: Border.all(color: col.withValues(alpha: 0.12))),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5)),
            const SizedBox(height: 6),
            Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildUserActionBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(40),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.2), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _actionItem(Icons.phone_in_talk, "Contact", const Color(0xFF2ED573), () {}),
          _actionItem(Icons.chat_bubble_outline, "Feedback", Colors.white, () {}),
          _actionItem(Icons.person_remove_alt_1_outlined, "Remove", const Color(0xFFFF4757), () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _actionItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}