import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; 
import 'package:provider/provider.dart';
import '../theme_provider.dart'; // Adjust path if needed
import 'user_bottomnavbar.dart';
import 'user_glassy_profile.dart';

class UserStatisticPage extends StatefulWidget {
  const UserStatisticPage({super.key});

  @override
  State<UserStatisticPage> createState() => _UserStatisticPageState();
}

class _UserStatisticPageState extends State<UserStatisticPage> {
  final Color themeBlue = const Color(0xFF5A84F1);

  // --- SCROLL ANIMATION STATE ---
  late ScrollController _scrollController;
  bool _isScrolled = false;

  // --- STATE VARIABLES ---
  String _selectedTimeframe = "Day";
  String _selectedMetric = "Heart Rate";

  final List<String> _timeframes = ["Day", "Week", "Month", "6 Month", "Year"];
  final List<String> _metrics = ["Heart Rate", "Steps", "Blood Glucose", "Env. Noise"];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset > 70 && !_isScrolled) {
        setState(() => _isScrolled = true);
      } else if (_scrollController.offset <= 70 && _isScrolled) {
        setState(() => _isScrolled = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // --- MOCK DATA LOGIC ---
  String get _currentAverage {
    if (_selectedMetric == "Heart Rate") return "84";
    if (_selectedMetric == "Steps") return "6,789";
    if (_selectedMetric == "Blood Glucose") return "95";
    return "65"; 
  }

  String get _currentUnit {
    if (_selectedMetric == "Heart Rate") return "bpm";
    if (_selectedMetric == "Steps") return "steps";
    if (_selectedMetric == "Blood Glucose") return "mg/dL";
    return "dB";
  }

  Color get _currentMetricColor {
    switch (_selectedMetric) {
      case "Heart Rate": return const Color(0xFFFF4757);    
      case "Steps": return const Color(0xFFFF9F43);         
      case "Blood Glucose": return const Color(0xFF2ED573); 
      case "Env. Noise": return const Color(0xFF5A84F1);    
      default: return const Color(0xFFFF4757);
    }
  }

  double _getMaxX() {
    switch (_selectedTimeframe) {
      case "Day": return 14;   
      case "Week": return 6;   
      case "Month": return 4;  
      case "6 Month": return 5; 
      case "Year": return 11;  
      default: return 14;
    }
  }

  List<FlSpot> _getChartData() {
    if (_selectedTimeframe == "Day") {
      return const [FlSpot(0, 80), FlSpot(2, 105), FlSpot(4, 95), FlSpot(6, 120), FlSpot(8, 100), FlSpot(10, 150), FlSpot(12, 90), FlSpot(14, 110)];
    } else if (_selectedTimeframe == "Week") {
      return const [FlSpot(0, 75), FlSpot(1, 85), FlSpot(2, 80), FlSpot(3, 110), FlSpot(4, 95), FlSpot(5, 125), FlSpot(6, 90)];
    } else if (_selectedTimeframe == "Month") {
      return const [FlSpot(0, 90), FlSpot(1, 85), FlSpot(2, 110), FlSpot(3, 105), FlSpot(4, 95)];
    } else if (_selectedTimeframe == "6 Month") {
      return const [FlSpot(0, 80), FlSpot(1, 95), FlSpot(2, 85), FlSpot(3, 110), FlSpot(4, 90), FlSpot(5, 100)];
    } else {
      return const [FlSpot(0, 85), FlSpot(2, 90), FlSpot(4, 110), FlSpot(6, 95), FlSpot(8, 115), FlSpot(10, 100), FlSpot(11, 105)];
    }
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta, Color textColor) {
    final style = TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor);
    String text = '';

    if (_selectedTimeframe == "Day") {
      if (value % 4 == 0) text = '${10 + value.toInt()}:00';
    } else if (_selectedTimeframe == "Week") {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      if (value.toInt() >= 0 && value.toInt() < days.length) text = days[value.toInt()];
    } else if (_selectedTimeframe == "Month") {
      text = 'Wk ${value.toInt() + 1}';
    } else if (_selectedTimeframe == "6 Month") {
      const months = ['Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      if (value.toInt() >= 0 && value.toInt() < months.length) text = months[value.toInt()];
    } else if (_selectedTimeframe == "Year") {
      if (value.toInt() % 3 == 0) {
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        text = months[value.toInt()];
      }
    }

    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(padding: const EdgeInsets.only(top: 10.0), child: Text(text, style: style));
  }

  @override
  Widget build(BuildContext context) {
    // ==========================================
    // DYNAMIC THEME VARIABLES
    // ==========================================
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = isDark ? Colors.white54 : Colors.grey.shade600;
    final dividerColor = Theme.of(context).dividerColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // --- APP BAR ---
              SliverAppBar(
                automaticallyImplyLeading: false,
                backgroundColor: themeBlue,
                expandedHeight: 200.0,
                toolbarHeight: 90.0,
                pinned: true,
                elevation: 0,
                scrolledUnderElevation: 0.0,
                surfaceTintColor: Colors.transparent,
                
                // --- THE FOLDED TITLE ---
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
                      child: const Text(
                        "Your Statistics.",
                        maxLines: 1, softWrap: false, overflow: TextOverflow.clip, 
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: "LexendExaNormal"),
                      ),
                    ),
                  ),
                ),
                actions: const [
                  Padding(padding: EdgeInsets.only(right: 30.0, top: 10.0), child: Center(child: UserGlassyProfile())),
                ],
                
                // --- THE EXPANDED LARGE TEXT ---
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax, 
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Your\nStatistics.", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: "LexendExaNormal", letterSpacing: -1.0, height: 1.1)),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // --- TIMEFRAME PILL ---
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Container(
                    height: 60, width: double.infinity,
                    decoration: BoxDecoration(color: bgColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40))),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(25, 10, 25, 5),
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: surfaceColor, 
                          borderRadius: BorderRadius.circular(30), 
                          border: isDark ? Border.all(color: dividerColor) : null,
                          boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _timeframes.map((timeframe) => _buildTimeframeTab(timeframe)).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // --- CONTENT ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      
                      // --- AVERAGE & METRIC DROPDOWN ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("AVERAGE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textSecondary, letterSpacing: 1.0)),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(_currentAverage, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textPrimary, fontFamily: "LexendExaNormal")),
                                  const SizedBox(width: 5),
                                  Text(_currentUnit, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textSecondary)),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2C2C2E) : Colors.white, 
                              borderRadius: BorderRadius.circular(20), 
                              border: Border.all(color: dividerColor), 
                              boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))]
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedMetric,
                                dropdownColor: surfaceColor,
                                icon: Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: textPrimary),
                                style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary, fontFamily: "LexendExaNormal", fontSize: 12),
                                onChanged: (String? newValue) => setState(() => _selectedMetric = newValue!),
                                items: _metrics.map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 25),
                      
                      // --- DYNAMIC MAIN LINE CHART ---
                      Container(
                        height: 280,
                        padding: const EdgeInsets.fromLTRB(15, 25, 25, 15),
                        decoration: BoxDecoration(
                          color: surfaceColor, 
                          borderRadius: BorderRadius.circular(30), 
                          border: Border.all(color: dividerColor),
                          boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))]
                        ),
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
                                  getTitlesWidget: (v, m) => _bottomTitleWidgets(v, m, textSecondary), 
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true, interval: 20, reservedSize: 42,
                                  getTitlesWidget: (value, meta) {
                                    if (value < 60 || value > 140) return const SizedBox.shrink();
                                    return Text("${value.toInt()}", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textSecondary));
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: true, border: Border(left: BorderSide(color: dividerColor, width: 1.5), bottom: BorderSide(color: dividerColor, width: 1.5), right: BorderSide.none, top: BorderSide.none)),
                            minX: 0, maxX: _getMaxX(),
                            minY: 60, maxY: 150,
                            lineBarsData: [
                              LineChartBarData(
                                spots: _getChartData(),
                                isCurved: true, curveSmoothness: 0.35,
                                color: _currentMetricColor,
                                barWidth: 3.5, isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: _currentMetricColor.withOpacity(0.1), 
                                )
                              ),
                            ],
                          ),
                          duration: const Duration(milliseconds: 400), 
                          curve: Curves.easeOutCubic,
                        ),
                      ),

                      const SizedBox(height: 40),
                      
                      // --- HIGHLIGHTS SECTION ---
                      Text("Highlights", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textPrimary, fontFamily: "LexendExaNormal")),
                      const SizedBox(height: 15),
                      
                      Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: surfaceColor, 
                          borderRadius: BorderRadius.circular(30), 
                          border: Border.all(color: dividerColor), 
                          boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))]
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("$_selectedMetric level", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: themeBlue, fontFamily: "LexendExaNormal")),
                            const SizedBox(height: 10),
                            Text("Your $_selectedMetric trend is looking healthy based on your recent averages.", style: TextStyle(fontSize: 13, color: textSecondary, height: 1.4)),
                            const SizedBox(height: 25),
                            
                            // Data Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Today", style: TextStyle(color: _currentMetricColor, fontWeight: FontWeight.w600, fontSize: 13)),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(_currentAverage, style: TextStyle(color: _currentMetricColor, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: "LexendExaNormal")),
                                        const SizedBox(width: 4),
                                        Text(_currentUnit, style: TextStyle(color: _currentMetricColor, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Average", style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(_currentAverage, style: TextStyle(color: textSecondary, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: "LexendExaNormal")),
                                        const SizedBox(width: 4),
                                        Text(_currentUnit, style: TextStyle(color: textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Mini Dual-Line Chart
                            SizedBox(
                              height: 120,
                              child: LineChart(
                                LineChartData(
                                  gridData: const FlGridData(show: false),
                                  titlesData: const FlTitlesData(show: false),
                                  borderData: FlBorderData(show: false),
                                  minX: 0, maxX: 6, minY: 0, maxY: 10,
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: const [FlSpot(0, 2), FlSpot(1.5, 2.5), FlSpot(2.5, 4), FlSpot(3.5, 1.5), FlSpot(4.5, 5), FlSpot(5.5, 4), FlSpot(6, 8)],
                                      isCurved: true, color: isDark ? Colors.white24 : Colors.grey.shade300, barWidth: 3, isStrokeCapRound: true,
                                      dotData: FlDotData(show: true, checkToShowDot: (spot, barData) => spot.x == 6, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 5, color: isDark ? Colors.white24 : Colors.grey.shade300, strokeWidth: 0)),
                                    ),
                                    LineChartBarData(
                                      spots: const [FlSpot(0, 1.5), FlSpot(1, 1.8), FlSpot(2, 0.5), FlSpot(2.8, 6), FlSpot(3.5, 3), FlSpot(4.5, 7.5), FlSpot(5.5, 4.5), FlSpot(6, 7)],
                                      isCurved: true, color: _currentMetricColor, barWidth: 3, isStrokeCapRound: true,
                                      dotData: FlDotData(show: true, checkToShowDot: (spot, barData) => spot.x == 6, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 5, color: _currentMetricColor, strokeWidth: 0)), 
                                    ),
                                  ],
                                ),
                                duration: const Duration(milliseconds: 400),
                              ),
                            )
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 140), 
                    ],
                  ),
                ),
              ),
            ],
          ),

          // --- FOG-FADE BOTTOM BUTTONS ---
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 140, 
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
                  Expanded(
                    child: Container(
                      height: 55,
                      decoration: BoxDecoration(boxShadow: [BoxShadow(color: const Color(0xFFFF9F43).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF9F43), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0),
                        child: const Text("Compare Data", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: "LexendExaNormal")),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      height: 55,
                      decoration: BoxDecoration(boxShadow: [BoxShadow(color: const Color(0xFF2ED573).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2ED573), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0),
                        child: const Text("Request Feedback", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11, fontFamily: "LexendExaNormal")),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const UserBottomNavBar(currentIndex: 3),
    );
  }

  // --- HELPER WIDGET ---
  Widget _buildTimeframeTab(String title) {
    bool isSelected = _selectedTimeframe == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTimeframe = title),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: isSelected ? themeBlue : Colors.transparent, borderRadius: BorderRadius.circular(30)),
          child: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w600, color: isSelected ? Colors.white : Colors.grey.shade500, fontSize: 12)),
        ),
      ),
    );
  }
}