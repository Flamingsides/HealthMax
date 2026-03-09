import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Run 'flutter pub add fl_chart'

class HPHomePage extends StatelessWidget {
  const HPHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Brighter blue/cyan theme colors
    const primaryColor = Color(0xFF00B4D8); // Bright Cyan/Blue
    const accentColor = Color(0xFF90E0EF);

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: primaryColor,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Requests'),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Header with curved bottom
            Container(
              height: 250,
              padding: const EdgeInsets.fromLTRB(25, 60, 25, 20),
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Hi,", style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold)),
                      Text("Hospital 1", style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child: const Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _buildSmallStat(Icons.person, "12 Connected Users", Colors.greenAccent),
                            const SizedBox(height: 10),
                            _buildSmallStat(Icons.access_time, "5 Requests", Colors.orangeAccent),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      _buildLargeStat("3 NEED ATTENTION", Colors.redAccent),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Text("AVERAGE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Text("Heart Rate Data", style: TextStyle(fontSize: 28, color: primaryColor, fontWeight: FontWeight.bold)),
                  const Text("of 12 Connected Users in a week"),

                  const SizedBox(height: 20),

                  // 3. The Chart Section
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             Text("Heart Rate ▼"),
                             Text("Week ▼"),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 200,
                          child: _buildHeartRateChart(primaryColor),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _buildActionButton("Compare Data", Colors.orange.shade300),
                            const SizedBox(width: 10),
                            _buildActionButton("Export Data", Colors.cyanAccent.shade400),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSmallStat(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildLargeStat(String text, Color color) {
    return Container(
      width: 140,
      height: 100,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(25)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning, size: 40, color: Colors.black),
          Text(text, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
        alignment: Alignment.center,
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeartRateChart(Color lineFillColor) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 85), FlSpot(1, 115), FlSpot(2, 110), FlSpot(3, 90),
              FlSpot(4, 105), FlSpot(5, 95), FlSpot(6, 110), FlSpot(7, 100),
            ],
            isCurved: true,
            color: lineFillColor,
            barWidth: 4,
            belowBarData: BarAreaData(
              show: true,
              color: lineFillColor.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}