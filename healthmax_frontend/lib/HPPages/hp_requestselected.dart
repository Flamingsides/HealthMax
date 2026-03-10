import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'usermodel.dart';

class HPRequestSelected extends StatefulWidget {
  final UserModel user;

  const HPRequestSelected({super.key, required this.user});

  @override
  State<HPRequestSelected> createState() => _HPRequestSelectedState();
}

class _HPRequestSelectedState extends State<HPRequestSelected> {
  // ---------- 1. MAIN BUILD METHOD ----------
  @override
  Widget build(BuildContext context) {
    const Color themeColor = Color(0xFF8E33FF);

    return Scaffold(
      backgroundColor: themeColor,
      body: Stack(
        children: [
          // A. TOP LAYER: NAVIGATION & HEADER
          Positioned(
            top: 60,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 110,
            left: 30,
            right: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "NEW PATIENT REQUEST",
                  style: TextStyle(
                    color: Colors.white60, 
                    fontWeight: FontWeight.bold, 
                    letterSpacing: 1.5,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.user.fullName,
                  style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 5),
                Text(
                  "Source: ${widget.user.device}",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),

          // B. MIDDLE LAYER: MAIN CONTENT CARD
          Column(
            children: [
              const SizedBox(height: 250),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 35),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(),
                        const SizedBox(height: 40),
                        const Text(
                          "PREVIEW DATA (LAST 24H)",
                          style: TextStyle(
                            fontWeight: FontWeight.w800, 
                            fontSize: 12, 
                            color: Colors.grey,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildPreviewGraph(themeColor),
                        const SizedBox(height: 30),
                        const Text(
                          "The user is requesting medical monitoring for heart rate fluctuations recorded via their wearable device.",
                          style: TextStyle(color: Colors.blueGrey, height: 1.5),
                        ),
                        const SizedBox(height: 120), // Space for floating buttons
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // C. BOTTOM LAYER: DECISION ACTIONS
          Positioned(
            bottom: 40,
            left: 25,
            right: 25,
            child: Row(
              children: [
                Expanded(
                  child: _decisionBtn(
                    "Decline", 
                    Colors.grey.shade100, 
                    Colors.black87, 
                    () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _decisionBtn(
                    "Accept Patient", 
                    themeColor, 
                    Colors.white, 
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${widget.user.fullName} added to your patients.")),
                      );
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ---------- 2. UI COMPONENT HELPERS ----------

  // Helper: Gender, Age, Height, Weight Row
  Widget _buildInfoRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _stat("Gender", widget.user.gender),
        _stat("Height", "${widget.user.height.toInt()}cm"),
        _stat("Weight", "${widget.user.weight.toInt()}kg"),
        _stat("Status", "Pending"),
      ],
    );
  }

  // Helper: Individual Stat Item
  Widget _stat(String label, String val) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }

  // Helper: Quick Preview Chart
  Widget _buildPreviewGraph(Color col) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 3), FlSpot(1, 1.5), FlSpot(2, 4), 
                FlSpot(3, 2.5), FlSpot(4, 5), FlSpot(5, 3.5),
              ],
              isCurved: true,
              color: col,
              barWidth: 4,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: col.withOpacity(0.05)),
            )
          ],
        ),
      ),
    );
  }

  // Helper: Accept/Decline Button Builder
  Widget _decisionBtn(String label, Color bg, Color text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (text == Colors.white)
              BoxShadow(
                color: bg.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              )
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }
}