import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import 'user_bottomnavbar.dart';
import 'user_glassy_profile.dart'; 
import '../GeneralPages/supabase_health_service.dart'; // Using Cloud Service

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
  String _liveAverageDisplay = "";

  Timer? _liveDataTimer;
  final Random _random = Random();
  double _liveJitter = 0.0;

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
    selectedMetric = widget.initialMetric;
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset > 90 && !_isScrolled) setState(() => _isScrolled = true);
      else if (_scrollController.offset <= 90 && _isScrolled) setState(() => _isScrolled = false);
    });

    _startLiveTimer();
    
    // Automatically try to load cloud data for the initial metric when page opens!
    _loadDataFromCloud(selectedMetric);
  }

  // --- NEW AUTOMATIC CLOUD LOADER ---
  Future<void> _loadDataFromCloud(String metric) async {
    if (!mounted) return;
    setState(() => _isSyncing = true);
    
    final cloudService = SupabaseHealthService();
    List<double>? cloudData = await cloudService.fetchDataFromCloud(metric);
    
    if (cloudData != null && mounted) {
      double aggregate = 0;
      for (var val in cloudData) aggregate += val;
      
      // Calculate averages for non-cumulative metrics
      if (metric != 'Steps' && metric != 'Calories') {
        aggregate = aggregate / 24; 
      }
      
      setState(() {
        _liveHourlyData = cloudData;
        selectedTimeframe = 'Day'; // Force Day view for 24h data
        
        if (metric == 'Steps') _liveAverageDisplay = "${aggregate.toInt()}";
        else if (metric == 'Heart Rate') _liveAverageDisplay = "${aggregate.toInt()} bpm";
        else if (metric == 'Calories') _liveAverageDisplay = "${aggregate.toInt()} kcal";
        else if (metric == 'Blood Glucose') _liveAverageDisplay = "${aggregate.toInt()} mg/dL";
        else _liveAverageDisplay = "${aggregate.toInt()} dB";
      });
    } else {
      // If no cloud data exists for this metric today, fallback to mock data
      setState(() {
        _liveHourlyData = null;
      });
    }
    
    if (mounted) setState(() => _isSyncing = false);
  }

  void _startLiveTimer() {
    _liveDataTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (selectedTimeframe == 'Day' && mounted) {
        setState(() {
          _liveJitter = (_random.nextDouble() * 4) - 2; 
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _liveDataTimer?.cancel();
    super.dispose();
  }

  // --- GRAPH DATA LOGIC ---
  String _getGraphType() {
    return (selectedMetric == 'Steps' || selectedMetric == 'Calories') ? 'Bar' : 'Spline';
  }

  double _getMaxX() {
    switch (selectedTimeframe) {
      case 'Day': return 23; 
      case 'Week': return 6; 
      case 'Month': return 3; 
      case 'Year': return 11; 
      default: return 6;
    }
  }

  double _getIntervalX() {
    if (selectedTimeframe == 'Day') return 6; 
    if (selectedTimeframe == 'Year') return 3; 
    return 1; 
  }

  double _getMinY() => selectedMetric == 'Heart Rate' ? 50 : 0;
  
  double _getMaxY() {
    switch (selectedMetric) {
      case 'Heart Rate': return 150;
      case 'Steps': return 15000;
      case 'Calories': return 3500;
      case 'Blood Glucose': return 150;
      case 'Env. Noise': return 100;
      default: return 150;
    }
  }
  
  double _getIntervalY() {
    switch (selectedMetric) {
      case 'Heart Rate': return 25;
      case 'Steps': return 5000;
      case 'Calories': return 1000;
      case 'Blood Glucose': return 50;
      case 'Env. Noise': return 25;
      default: return 25;
    }
  }

  List<double> _getRawData() {
    // 1. USE REAL CLOUD DATA IF WE HAVE IT
    if (selectedTimeframe == 'Day' && _liveHourlyData != null) {
      return _liveHourlyData!;
    }

    // 2. OTHERWISE, MOCK DATA
    List<double> baseData = [];
    if (selectedMetric == 'Heart Rate') baseData = [72, 75, 78, 80, 85, 90, 88, 92, 85, 82, 78, 75, 76, 79, 81, 88, 95, 90, 85, 80, 77, 74, 72, 75];
    else if (selectedMetric == 'Steps') baseData = [0, 0, 0, 0, 0, 500, 2500, 5000, 6500, 8000, 9500, 11000, 12500, 14000, 14000, 14000, 14500, 15000, 15000, 15000, 15000, 15000, 15000, 15000]; 
    else if (selectedMetric == 'Calories') baseData = [80, 80, 80, 80, 80, 150, 400, 600, 850, 1100, 1400, 1800, 2100, 2300, 2400, 2450, 2700, 2800, 2800, 2800, 2800, 2800, 2800, 2800];
    else if (selectedMetric == 'Blood Glucose') baseData = [90, 92, 89, 88, 85, 95, 110, 105, 98, 95, 92, 108, 120, 115, 100, 95, 92, 110, 105, 98, 95, 92, 90, 88];
    else if (selectedMetric == 'Env. Noise') baseData = [35, 35, 35, 35, 40, 55, 70, 75, 80, 85, 80, 75, 70, 65, 60, 75, 80, 85, 75, 60, 50, 45, 40, 35];

    int requiredLength = (_getMaxX() + 1).toInt();
    List<double> finalData = baseData.sublist(0, requiredLength);

    if (selectedTimeframe == 'Day' && selectedMetric != 'Steps' && selectedMetric != 'Calories' && _liveHourlyData == null) {
      finalData[finalData.length - 1] += _liveJitter;
    }

    return finalData;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

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
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false, 
                backgroundColor: currentColor,
                expandedHeight: 220.0, 
                toolbarHeight: 90.0,
                pinned: true,
                elevation: 0,
                scrolledUnderElevation: 0.0,
                surfaceTintColor: Colors.transparent,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 30.0, top: 10.0),
                    child: Center(
                      child: UserGlassyProfile(
                        onTap: () => Navigator.pushNamed(context, '/user_settings'),
                      ),
                    ),
                  ),
                ],
                title: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: _isScrolled ? 1.0 : 0.0, 
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(selectedMetric, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: "LexendExaNormal")),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 60, 30, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Your", style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: "LexendExaNormal", letterSpacing: -0.5, height: 1.1)),
                          Text("Statistic.", style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white70, fontFamily: "LexendExaNormal", letterSpacing: -0.5, height: 1.1)),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(selectedTimeframe == 'Day' ? "LIVE RECORD" : "LATEST RECORD", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: textSecondary, letterSpacing: 1.2, fontFamily: "LexendExaNormal")),
                              const SizedBox(height: 8),
                              Text(selectedMetric, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textPrimary, fontFamily: "LexendExaNormal", letterSpacing: -0.5)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: currentColor.withValues(alpha:0.15), shape: BoxShape.circle),
                            child: Icon(_getIconForMetric(selectedMetric), color: currentColor, size: 28),
                          )
                        ],
                      ),
                      const SizedBox(height: 30),

                      // --- GRAPH CONTAINER ---
                      Container(
                        padding: const EdgeInsets.fromLTRB(15, 20, 20, 15),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: dividerColor),
                          boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha:0.04), blurRadius: 15, offset: const Offset(0, 8))],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // When metric changes, trigger cloud fetch automatically!
                                Expanded(child: _buildDropdown(['Heart Rate', 'Steps', 'Calories', 'Blood Glucose', 'Env. Noise'], selectedMetric, (v) {
                                  if (v != null) {
                                    setState(() { selectedMetric = v; });
                                    _loadDataFromCloud(v);
                                  }
                                }, surfaceColor, textPrimary, isDark)),
                                const SizedBox(width: 10),
                                Expanded(child: _buildDropdown(['Day', 'Week', 'Month', 'Year'], selectedTimeframe, (v) => setState(() { selectedTimeframe = v!; }), surfaceColor, textPrimary, isDark)),
                              ],
                            ),
                            const SizedBox(height: 30),

                            SizedBox(
                              height: 220,
                              child: _getGraphType() == 'Spline' 
                                ? _buildSplineChart(currentColor, textSecondary, dividerColor)
                                : _buildBarChart(currentColor, textSecondary, dividerColor),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 12),

                      // ==========================================
                      // SUPABASE SYNC BUTTON
                      // ==========================================
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: _isSyncing ? null : () async {
                            setState(() => _isSyncing = true);
                            
                            final cloudService = SupabaseHealthService();
                            
                            // Generate the batch and push to Supabase
                            bool success = await cloudService.generateAndPushData(selectedMetric);
                            
                            if (success) {
                              // Reload data to reflect what was just pushed
                              await _loadDataFromCloud(selectedMetric);
                              
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text("Cloud Sync Complete!", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                    backgroundColor: currentColor,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  ),
                                );
                              }
                            } else {
                              setState(() => _isSyncing = false);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Failed to connect to Supabase."), backgroundColor: Colors.red),
                                );
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: currentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: currentColor.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _isSyncing 
                                  ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: currentColor, strokeWidth: 2))
                                  : Icon(Icons.cloud_sync_rounded, size: 16, color: currentColor),
                                const SizedBox(width: 8),
                                Text(_isSyncing ? "Syncing..." : "Sync Cloud Data", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: currentColor)),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),
                      Text("DATA BREAKDOWN", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: textSecondary, letterSpacing: 1.2, fontFamily: "LexendExaNormal")),
                      const SizedBox(height: 15),
                      
                      Row(
                        children: [
                          Expanded(child: _buildStatCard(_liveHourlyData != null ? "Today's Record" : "Daily Avg", _liveHourlyData != null ? _liveAverageDisplay : _getAverageValue(), isDark ? currentColor : currentColor.withValues(alpha:0.8), isDark ? currentColor.withValues(alpha:0.1) : currentColor.withValues(alpha:0.05), textPrimary)),
                          const SizedBox(width: 15),
                          Expanded(child: _buildStatCard("Status", _liveHourlyData != null ? "Supabase Synced" : "Mock", isDark ? Colors.lightBlueAccent : Colors.blue.shade800, isDark ? Colors.blue.withValues(alpha:0.1) : Colors.blue.shade50, textPrimary)),
                        ],
                      ),
                      
                      const SizedBox(height: 140), 
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ==========================================
          // FIXED FLOATING ACTION BAR
          // ==========================================
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 130, 
              padding: const EdgeInsets.fromLTRB(25, 50, 25, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter, 
                  end: Alignment.topCenter,
                  colors: [
                    bgColor, 
                    bgColor.withValues(alpha:0.95), 
                    bgColor.withValues(alpha:0.0)
                  ],
                  stops: const [0.0, 0.65, 1.0],
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _actionBtn(
                      "Compare Data", 
                      isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE), 
                      Icons.compare_arrows_rounded, 
                      isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E3A8A), 
                      onTap: () => {} // Removed bottom sheet code for brevity
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _actionBtn(
                      "Request Feedback", 
                      isDark ? Color.lerp(currentColor, Colors.black, 0.7)! : Color.lerp(currentColor, Colors.white, 0.85)!, 
                      Icons.chat_bubble_rounded, 
                      currentColor, 
                      onTap: () => {} // Removed bottom sheet code for brevity
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

  // ==========================================
  // GRAPH IMPLEMENTATIONS
  // ==========================================

  Widget _buildSplineChart(Color currentColor, Color textSecondary, Color dividerColor) {
    List<double> rawData = _getRawData();
    List<FlSpot> spots = List.generate(rawData.length, (index) => FlSpot(index.toDouble(), rawData[index]));

    return ClipRect(
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: dividerColor, strokeWidth: 1)),
          titlesData: _buildTitlesData(textSecondary),
          borderData: FlBorderData(show: false),
          minX: 0, maxX: _getMaxX(),
          minY: _getMinY(), maxY: _getMaxY(),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true, curveSmoothness: 0.35,
              color: currentColor, barWidth: 3.5, isStrokeCapRound: true,
              dotData: FlDotData(show: selectedTimeframe != 'Day', getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: currentColor, strokeWidth: 1.5, strokeColor: Theme.of(context).colorScheme.surface)),
              belowBarData: BarAreaData(show: true, color: currentColor.withValues(alpha:0.1)), 
            ),
          ],
        ),
        duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic,
      ),
    );
  }

  Widget _buildBarChart(Color currentColor, Color textSecondary, Color dividerColor) {
    List<double> rawData = _getRawData();
    
    return ClipRect(
      child: BarChart(
        BarChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: dividerColor, strokeWidth: 1)),
          titlesData: _buildTitlesData(textSecondary),
          borderData: FlBorderData(show: false),
          maxY: _getMaxY(),
          barGroups: List.generate(rawData.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: rawData[index], color: currentColor, width: selectedTimeframe == 'Day' ? 6 : 16, 
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)), 
                  backDrawRodData: BackgroundBarChartRodData(show: true, toY: _getMaxY(), color: currentColor.withValues(alpha:0.1)),
                ),
              ],
            );
          }),
        ),
        duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic,
      ),
    );
  }

  FlTitlesData _buildTitlesData(Color textSecondary) {
    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true, reservedSize: 30, interval: _getIntervalX(),
          getTitlesWidget: (value, meta) {
            final style = TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textSecondary);
            int v = value.toInt();

            if (selectedTimeframe == "Day") {
              if (v % 6 == 0) return Padding(padding: const EdgeInsets.only(top: 10), child: Text('${v.toString().padLeft(2, '0')}:00', style: style));
            } else if (selectedTimeframe == "Week") {
              const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              if (v >= 0 && v < days.length) return Padding(padding: const EdgeInsets.only(top: 10), child: Text(days[v], style: style));
            } else if (selectedTimeframe == "Month") {
              if (v >= 0 && v < 4) return Padding(padding: const EdgeInsets.only(top: 10), child: Text('Wk ${v + 1}', style: style));
            } else if (selectedTimeframe == "Year") {
              const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
              if (v % 3 == 0 && v >= 0 && v < months.length) return Padding(padding: const EdgeInsets.only(top: 10), child: Text(months[v], style: style));
            }
            return const SizedBox.shrink();
          }, 
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true, interval: _getIntervalY(), reservedSize: 35,
          getTitlesWidget: (value, meta) {
            if (value == _getMinY() || value == _getMaxY()) return const SizedBox.shrink();
            String text = selectedMetric == 'Steps' ? '${(value / 1000).toInt()}k' : value.toInt().toString();
            return Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textSecondary));
          },
        ),
      ),
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================

  Widget _actionBtn(String label, Color col, IconData icon, Color textColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap, 
      child: Container(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 10), 
        decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(20), border: Border.all(color: textColor.withValues(alpha:0.2))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: textColor), 
            const SizedBox(width: 6),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: textColor, fontFamily: "LexendExaNormal")),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String val, ValueChanged<String?> onChanged, Color surfaceColor, Color textPrimary, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: val, isExpanded: true, dropdownColor: surfaceColor,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: textPrimary, size: 16),
          selectedItemBuilder: (BuildContext context) {
            return items.map<Widget>((String item) => Align(alignment: Alignment.centerLeft, child: Text(item, style: TextStyle(fontWeight: FontWeight.w900, color: textPrimary, fontSize: 11, fontFamily: "LexendExaNormal"), overflow: TextOverflow.ellipsis))).toList();
          },
          onChanged: onChanged,
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 12)))).toList(),
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
          Text(title, style: TextStyle(color: titleColor, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: textPrimary, fontFamily: "LexendExaNormal")),
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

  String _getAverageValue() {
    if (selectedMetric == 'Heart Rate') return "80 bpm";
    if (selectedMetric == 'Steps') return "8,200";
    if (selectedMetric == 'Calories') return "2,100 kcal";
    if (selectedMetric == 'Blood Glucose') return "95 mg/dL";
    if (selectedMetric == 'Env. Noise') return "55 dB";
    return "";
  }

List<String> _getAvailablePeriodsForTimeframe() {
  switch (selectedTimeframe) {
    case 'Day':
      return ['Today', 'Yesterday'];
    case 'Week':
      return ['This Week', 'Last Week'];
    case 'Month':
      return ['This Month', 'Last Month'];
    case 'Year':
      return ['This Year', 'Last Year'];
    default:
      return ['Period 1', 'Period 2'];
  }
}

// ==========================================
// BOTTOM SHEETS
// ==========================================

void _showCompareDataSheet(bool isDark, Color surfaceColor, Color textPrimary, Color textSecondary, Color dividerColor) {
    final List<String> availablePeriods = _getAvailablePeriodsForTimeframe();
    String period1 = availablePeriods[0];
    String period2 = availablePeriods[1];
    bool showChart = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(color: surfaceColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(35))),
              padding: const EdgeInsets.fromLTRB(30, 10, 30, 40),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 25), decoration: BoxDecoration(color: dividerColor, borderRadius: BorderRadius.circular(10))),
                    Text("Compare $selectedMetric", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: "LexendExaNormal", color: textPrimary)),
                    const SizedBox(height: 5),
                    Text(showChart ? "Trend analysis complete." : "Select two timeframes to analyze your trends.", style: TextStyle(color: textSecondary, fontSize: 13)),
                    const SizedBox(height: 30),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: !showChart 
                        ? Column(
                            key: const ValueKey('form'),
                            children: [
                              Row(
                                children: [
                                  Expanded(child: _buildDropdown(availablePeriods, period1, (val) => setModalState(() => period1 = val!), surfaceColor, textPrimary, isDark)),
                                  Padding(padding: const EdgeInsets.symmetric(horizontal: 15), child: Text("VS", style: TextStyle(fontWeight: FontWeight.w900, color: textSecondary, fontSize: 12, fontFamily: "LexendExaNormal"))),
                                  Expanded(child: _buildDropdown(availablePeriods, period2, (val) => setModalState(() => period2 = val!), surfaceColor, textPrimary, isDark)),
                                ],
                              ),
                              const SizedBox(height: 35),
                              SizedBox(
                                width: double.infinity, height: 55,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (period1 == period2) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select two different timeframes."), backgroundColor: Colors.redAccent));
                                      return;
                                    }
                                    setModalState(() => showChart = true);
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: userBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0),
                                  child: const Text("Generate Comparison", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: "LexendExaNormal")),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            key: const ValueKey('chart'),
                            children: [
                              Container(
                                height: 200, padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
                                decoration: BoxDecoration(color: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: dividerColor)),
                                child: ClipRect(
                                  child: LineChart(
                                    LineChartData(
                                      gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: dividerColor, strokeWidth: 1)),
                                      titlesData: _buildTitlesData(textSecondary),
                                      borderData: FlBorderData(show: true, border: Border(left: BorderSide(color: dividerColor), bottom: BorderSide(color: dividerColor), top: BorderSide.none, right: BorderSide.none)),
                                      minX: 0, maxX: _getMaxX(), 
                                      minY: _getMinY(), maxY: _getMaxY(), 
                                      lineBarsData: [
                                        LineChartBarData(spots: _getPeriodMockData(selectedMetric, period1), isCurved: true, color: userBlue, barWidth: 3.5, isStrokeCapRound: true, dotData: const FlDotData(show: false)),
                                        LineChartBarData(spots: _getPeriodMockData(selectedMetric, period2), isCurved: true, color: Colors.orangeAccent, barWidth: 3.5, isStrokeCapRound: true, dotData: const FlDotData(show: false)),
                                      ],
                                    ),
                                    duration: const Duration(milliseconds: 600), curve: Curves.easeOutCubic,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(children: [Container(width: 12, height: 12, decoration:  BoxDecoration(color: userBlue, shape: BoxShape.circle)), const SizedBox(width: 8), Text(period1, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textPrimary))]),
                                  const SizedBox(width: 25),
                                  Row(children: [Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.orangeAccent, shape: BoxShape.circle)), const SizedBox(width: 8), Text(period2, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textPrimary))]),
                                ],
                              ),
                              const SizedBox(height: 30),
                              SizedBox(
                                width: double.infinity, height: 55,
                                child: TextButton(
                                  onPressed: () => setModalState(() => showChart = false),
                                  style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: dividerColor))),
                                  child: Text("Start New Comparison", style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                                ),
                              ),
                            ],
                          ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showRequestFeedbackSheet(Color surfaceColor, Color textPrimary, Color textSecondary, Color dividerColor, bool isDark, Color currentColor) {
    final TextEditingController noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(color: surfaceColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(35))),
            padding: const EdgeInsets.fromLTRB(30, 10, 30, 30),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 25), decoration: BoxDecoration(color: dividerColor, borderRadius: BorderRadius.circular(10)))),
                  Text("Request Clinical Feedback", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: "LexendExaNormal", color: textPrimary)),
                  const SizedBox(height: 5),
                  Text("Send your recent $selectedMetric data to your healthcare provider for review.", style: TextStyle(color: textSecondary, fontSize: 13)),
                  const SizedBox(height: 25),

                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: currentColor.withValues(alpha:0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: currentColor.withValues(alpha:0.3))),
                    child: Row(
                      children: [
                        Icon(_getIconForMetric(selectedMetric), color: currentColor, size: 24),
                        const SizedBox(width: 12),
                        Text("Attaching 7-Day $selectedMetric Log", style: TextStyle(fontWeight: FontWeight.bold, color: currentColor, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  Text("ADDITIONAL NOTES (OPTIONAL)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textSecondary, letterSpacing: 1.0)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: noteController,
                    maxLines: 3,
                    style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: "E.g., I've been feeling dizzy in the mornings...",
                      hintStyle: TextStyle(color: textSecondary.withValues(alpha:0.7), fontSize: 14),
                      filled: true, fillColor: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity, height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Feedback request sent to your provider!", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          backgroundColor: currentColor, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: currentColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0),
                      child: const Text("Send Data to Provider", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: "LexendExaNormal")),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<FlSpot> _getPeriodMockData(String metric, String period) {
    List<double> rawValues = _getRawData(); 
    double modifier = 1.0;
    if (period.contains('Yesterday') || period.contains('Last')) modifier = 0.85;
    else if (period.contains('2')) modifier = 0.70;
    else if (period.contains('3')) modifier = 1.15;

    return List.generate(rawValues.length, (i) {
      double value = rawValues[i] * modifier;
      value = value.clamp(_getMinY(), _getMaxY()); 
      return FlSpot(i.toDouble(), value);
    });
  }
}