import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'hp_bottomnavbar.dart';
import 'hp_glassy_profile.dart';
import 'hp_requestspage.dart';

class HPHomePage extends StatefulWidget {
  const HPHomePage({super.key});

  @override
  State<HPHomePage> createState() => _HPHomePageState();
}

class _HPHomePageState extends State<HPHomePage> {
  // --- STATE VARIABLES ---
  String selectedMetric = 'Heart Rate';
  String selectedTimeframe = 'Week';

  final Map<String, Color> metricColors = {
    'Heart Rate': Colors.redAccent,
    'Steps': Colors.blueAccent,
    'Calories': Colors.orangeAccent,
    'Glucose Level': Colors.greenAccent,
  };

  // 1. MAIN BUILD METHOD (The Page Skeleton)
  @override
  Widget build(BuildContext context) {
    final currentColor =
        metricColors[selectedMetric] ?? const Color(0xFF8E33FF);
    const themeColor = Color(0xFF8E33FF);

    return Scaffold(
      backgroundColor: themeColor,
      body: Stack(
        children: [
          // BACKGROUND HEADER TEXT
          Positioned(
            top: 80,
            left: 25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Hi,",
                  style: TextStyle(
                    fontSize: 55,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                Text(
                  "Hospital 1.",
                  style: TextStyle(
                    fontSize: 55,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),

          // PROFILE BUTTON
          Positioned(
            top: 75, 
            right: 25, 
            child: HPGlassyProfile(onTap: () {
              Navigator.pushNamed(context, '/profile');
            })
          ),

          // MAIN WHITE BODY LAYER
          Column(
            children: [
              const SizedBox(height: 220),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    child: Stack(
                      children: [
                        // SCROLLABLE AREA
                        SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(25, 30, 25, 180),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTopStats(),
                              const SizedBox(height: 35),
                              const Text(
                                "ANALYTICS OVERVIEW",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                  color: Colors.grey,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Text(
                                "$selectedMetric Trends",
                                style: TextStyle(
                                  fontSize: 30,
                                  color: currentColor,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildGraphSection(currentColor),
                              const SizedBox(height: 35),
                              const Text(
                                "RECENT PATIENT ALERTS",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                  color: Colors.grey,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 15),
                              _buildAlertTile(
                                "Tengku Adam",
                                "Critical Heart Rate",
                                "142 BPM",
                                Colors.redAccent.withOpacity(0.1),
                              ),
                              _buildAlertTile(
                                "Sarah Jenkins",
                                "Low Glucose Level",
                                "3.2 mmol/L",
                                Colors.orangeAccent.withOpacity(0.1),
                              ),
                              _buildAlertTile(
                                "Mike Ross",
                                "Data Sync Interrupted",
                                "2 hours ago",
                                Colors.grey.withOpacity(0.1),
                              ),
                              const SizedBox(height: 35),
                              _buildSystemHealthCard(),
                            ],
                          ),
                        ),

                        // STATIC ACTION BUTTONS (Floats above ScrollView)
                        Positioned(
                          bottom: 100,
                          left: 25,
                          right: 25,
                          child: _buildStaticActionButtons(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // BOTTOM NAVIGATION BAR
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: HPBottomNavBar(currentIndex: 0, activeColor: themeColor),
          ),
        ],
      ),
    );
  }

  // 2. UI COMPONENT HELPERS (Widgets used in the Build Method)
  // TOP GRID OF BUTTONS (Users, Requests, Attention)
  Widget _buildTopStats() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _statBtn(
                Icons.person,
                "10 Connected Users",
                const Color.fromARGB(255, 158, 243, 202),
                onTap: () =>
                    Navigator.pushNamed(context, '/hp_users'),
              ),
              const SizedBox(height: 12),
              _statBtn(
                Icons.access_time,
                "5 Requests",
                const Color.fromARGB(255, 248, 194, 124),
                onTap: () => Navigator.pushNamed(context, '/hp_requests'),
              ),
            ],
          ),
        ),
        const SizedBox(width: 15),
        _statBtn(
          Icons.warning,
          "3 NEED ATTENTION",
          const Color.fromARGB(255, 251, 51, 51),
          isLarge: true,
          textColor: Colors.white,
        ),
      ],
    );
  }

  // INDIVIDUAL STAT BUTTON BUILDER
  Widget _statBtn(
    IconData icon,
    String text,
    Color color, {
    bool isLarge = false,
    VoidCallback? onTap,
    Color textColor = Colors.black,
  }) {
    // default text is black
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isLarge ? 116 : 52,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: isLarge
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: textColor),
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: textColor,
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Icon(icon, size: 20, color: textColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // GRAPH SECTION (With Metric & Timeframe Dropdowns)
  Widget _buildGraphSection(Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _dropdown(
                ['Heart Rate', 'Steps', 'Glucose Level', 'Calories'],
                selectedMetric,
                (v) => setState(() => selectedMetric = v!),
                textColor: color,
              ),
              _dropdown(
                ['Week', 'Month', 'Year'],
                selectedTimeframe,
                (v) => setState(() => selectedTimeframe = v!),
                textColor: Colors.black,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(height: 180, child: LineChart(_sampleChartData(color))),
        ],
      ),
    );
  }

  // STATIC COMPARE/EXPORT BUTTONS CONTAINER
  Widget _buildStaticActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: _actionBtn(
              "Compare Data",
              Colors.orange.shade100,
              Icons.compare_arrows,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _actionBtn(
              "Export PDF",
              Colors.cyan.shade100,
              Icons.download,
            ),
          ),
        ],
      ),
    );
  }

  // ACTION BUTTON BUILDER
  Widget _actionBtn(String label, Color col, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: col,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: col.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ALERT LOG TILE
  Widget _buildAlertTile(String name, String issue, String value, Color bg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white,
            radius: 15,
            child: Icon(Icons.person, size: 15, color: Colors.black),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  issue,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // DARK SYSTEM HEALTH CARD
  Widget _buildSystemHealthCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_done, color: Colors.greenAccent),
          const SizedBox(width: 15),
          const Expanded(
            child: Text(
              "All hospital systems are operational. Device sync is at 98% efficiency.",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // 3. LOGIC & DATA HELPERS (Non-UI specific methods)
  // DROPDOWN MENU BUILDER
  Widget _dropdown(
    List<String> items,
    String val,
    ValueChanged<String?> onChanged, {
    Color textColor = Colors.black,
  }) {
    return DropdownButton<String>(
      value: val,
      // Fixed: Styling the text visible when the dropdown is closed
      selectedItemBuilder: (BuildContext context) {
        return items.map<Widget>((String item) {
          return Center(
            child: Text(
              item,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          );
        }).toList();
      },
      items: items
          .map(
            (i) => DropdownMenuItem(
              value: i,
              child: Text(
                i, 
                style: const TextStyle(fontSize: 12, color: Colors.black)
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      underline: const SizedBox(),
      icon: Icon(Icons.arrow_drop_down, color: textColor),
    );
  }

  // MOCK DATA FOR FL_CHART
  LineChartData _sampleChartData(Color color) {
    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3),
            FlSpot(2, 4),
            FlSpot(4, 3.5),
            FlSpot(6, 5),
            FlSpot(8, 4.2),
            FlSpot(10, 6),
          ],
          isCurved: true,
          color: color,
          barWidth: 4,
          dotData: const FlDotData(show: false),
        ),
      ],
    );
  }
}