import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'usermodel.dart';

class HPUserSelected extends StatefulWidget {
  final UserModel user;

  const HPUserSelected({super.key, required this.user});

  @override
  State<HPUserSelected> createState() => _HPUserSelectedState();
}

class _HPUserSelectedState extends State<HPUserSelected> {
  // ---------- 1. STATE & DATA ----------  
  String selectedMetric = 'Heart Rate';
  String selectedTimeframe = 'Week';

  // ---------- 2. MAIN BUILD METHOD ---------- 
  @override
  Widget build(BuildContext context) {
    const Color themeColor = Color(0xFF8E33FF);

    return Scaffold(
      backgroundColor: themeColor,
      body: Stack(
        children: [
          // A. TOP LAYER: NAVIGATION
          Positioned(
            top: 60, left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // B. TOP LAYER: USER PROFILE HEADER
          Positioned(
            top: 100, left: 25, right: 25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.user.fullName,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.watch_rounded, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text("Device: ${widget.user.device}",
                      style: const TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(widget.user.infoString,
                  style: const TextStyle(fontSize: 14, color: Colors.white54)),
              ],
            ),
          ),

          // C. MIDDLE LAYER: ANALYTICS CONTAINER
          Column(
            children: [
              const SizedBox(height: 220),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(25, 30, 25, 140),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("ANALYTICS OVERVIEW", 
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.grey, letterSpacing: 1.1)),
                        const SizedBox(height: 20),
                        
                        // Selectors (Metric & Time)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSelector(selectedMetric, (val) => setState(() => selectedMetric = val!), ['Heart Rate', 'Steps', 'Glucose']),
                            _buildSelector(selectedTimeframe, (val) => setState(() => selectedTimeframe = val!), ['Day', 'Week', 'Month'], isTime: true),
                          ],
                        ),
                        
                        const SizedBox(height: 25),
                        _buildGraphSection(themeColor), // The Chart
                        const SizedBox(height: 25),
                        _buildQuickStats(),            // The Stat Boxes
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // D. BOTTOM LAYER: FLOATING ACTIONS
          Positioned(
            bottom: 30, left: 20, right: 20,
            child: _buildUserActionBar(),
          ),
        ],
      ),
    );
  }

  // ---------- 3. UI COMPONENT HELPERS (In order of appearance) ----------
  // Helper: Dropdown Selectors
  Widget _buildSelector(String val, ValueChanged<String?> onChange, List<String> items, {bool isTime = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(14)),
      child: DropdownButton<String>(
        value: val,
        underline: const SizedBox(),
        icon: Icon(isTime ? Icons.calendar_month : Icons.expand_more, size: 16, color: Colors.grey),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)))).toList(),
        onChanged: onChange,
      ),
    );
  }

  // Helper: Graph Container
  Widget _buildGraphSection(Color color) {
    return Container(
      height: 230,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade100),
      ),
      padding: const EdgeInsets.fromLTRB(10, 25, 25, 15),
      child: LineChart(_sampleChartData(color)),
    );
  }

  // Helper: Quick Stats Row
  Widget _buildQuickStats() {
    return Row(
      children: [
        _statBox("Daily Avg", "72 bpm", Colors.orangeAccent),
        const SizedBox(width: 15),
        _statBox("Status", "Normal", Colors.blueAccent),
      ],
    );
  }

  // Helper: Individual Stat Box
  Widget _statBox(String title, String val, Color col) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: col.withOpacity(0.06), 
          borderRadius: BorderRadius.circular(20), 
          border: Border.all(color: col.withOpacity(0.12))
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  // Helper: User Action Bar (Contact, Feedback, Remove)
  Widget _buildUserActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A).withOpacity(0.95),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _actionItem(Icons.add_ic_call, "Contact", Colors.greenAccent, () {}),
          _actionItem(Icons.chat_bubble_outline, "Feedback", Colors.white, () {}),
          _actionItem(Icons.person_remove_outlined, "Remove", Colors.redAccent, () {}),
        ],
      ),
    );
  }

  // Helper: Individual Action Item
  Widget _actionItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ---------- 4. CHART LOGIC & DATA MAPPING ----------
  LineChartData _sampleChartData(Color color) {
    return LineChartData(
      gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.shade200, strokeWidth: 1)),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (v, m) => _getBottomTitles(v))),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: const TextStyle(color: Colors.grey, fontSize: 10)))),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: _generateMockSpots(),
          isCurved: true,
          color: color,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(show: true, color: color.withOpacity(0.1)),
        ),
      ],
    );
  }

  Widget _getBottomTitles(double value) {
    String text = '';
    if (selectedTimeframe == 'Day' && value % 4 == 0) text = '${value.toInt()}h';
    if (selectedTimeframe == 'Week') text = 'D${value.toInt()}';
    if (selectedTimeframe == 'Month') text = 'W${value.toInt()}';
    return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 10)));
  }

  List<FlSpot> _generateMockSpots() {
    switch (selectedTimeframe) {
      case 'Day': return const [FlSpot(8, 72), FlSpot(12, 85), FlSpot(16, 78), FlSpot(20, 92), FlSpot(24, 68)];
      case 'Week': return const [FlSpot(1, 70), FlSpot(2, 75), FlSpot(3, 72), FlSpot(4, 85), FlSpot(5, 78), FlSpot(6, 90), FlSpot(7, 82)];
      case 'Month': return const [FlSpot(1, 75), FlSpot(2, 82), FlSpot(3, 70), FlSpot(4, 88)];
      default: return const [FlSpot(0, 0)];
    }
  }
}