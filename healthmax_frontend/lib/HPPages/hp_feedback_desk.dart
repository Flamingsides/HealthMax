import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import 'usermodel.dart'; 

class HPFeedbackDeskPage extends StatefulWidget {
  const HPFeedbackDeskPage({super.key});

  @override
  State<HPFeedbackDeskPage> createState() => _HPFeedbackDeskPageState();
}

class _HPFeedbackDeskPageState extends State<HPFeedbackDeskPage> {
  final Color hpPurple = const Color(0xFF8E33FF);
  
  // Directly wiring the state to our centralized MockData!
  late List<FeedbackRequest> _requestQueue;

  @override
  void initState() {
    super.initState();
    _requestQueue = List.from(MockData.feedbackRequests);
  }

  void _removeRequest(int index) {
    setState(() {
      _requestQueue.removeAt(index);
      MockData.feedbackRequests.removeAt(index); // Removes it globally so avatars update!
    });
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

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: hpPurple,
            expandedHeight: 180.0,
            toolbarHeight: 70.0,
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 0.0,
            surfaceTintColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.only(left: 15.0, top: 10.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                onPressed: () => Navigator.pop(context),
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
                      const Text(
                        "Consult Desk.",
                        style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: "LexendExaNormal", letterSpacing: -1.0),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${_requestQueue.length} Patients awaiting feedback",
                        style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600),
                      ),
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
                  Text("TRIAGE QUEUE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: textSecondary, letterSpacing: 1.2, fontFamily: "LexendExaNormal")),
                  const SizedBox(height: 15),

                  _requestQueue.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50.0),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.check_circle_outline_rounded, size: 60, color: hpPurple.withOpacity(0.5)),
                                const SizedBox(height: 15),
                                Text("All caught up!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary)),
                                const SizedBox(height: 5),
                                Text("No pending patient requests.", style: TextStyle(fontSize: 13, color: textSecondary)),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _requestQueue.length,
                          itemBuilder: (context, index) {
                            final request = _requestQueue[index];
                            return _buildRequestCard(request, index, surfaceColor, bgColor, textPrimary, textSecondary, dividerColor, isDark);
                          },
                        ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(FeedbackRequest request, int index, Color surfaceColor, Color bgColor, Color textPrimary, Color textSecondary, Color dividerColor, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: dividerColor),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () => _showFeedbackSheet(request, index, surfaceColor, textPrimary, textSecondary, dividerColor, isDark),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(radius: 18, backgroundColor: bgColor, child: Icon(Icons.person, size: 18, color: hpPurple)),
                        const SizedBox(width: 12),
                        Text(request.user.fullName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textPrimary)),
                      ],
                    ),
                    Text(request.timeAgo, style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: request.color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.analytics_outlined, size: 14, color: request.color),
                      const SizedBox(width: 8),
                      Text("Needs review: ${request.metric}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: request.color)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFeedbackSheet(FeedbackRequest request, int index, Color surfaceColor, Color textPrimary, Color textSecondary, Color dividerColor, bool isDark) {
    final TextEditingController replyController = TextEditingController();

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
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(request.user.fullName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: "LexendExaNormal", color: textPrimary)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: request.color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                        child: Text(request.metric, style: TextStyle(color: request.color, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text("Requested advice on recent trends.", style: TextStyle(color: textSecondary, fontSize: 13)),
                  const SizedBox(height: 25),

                  Container(
                    height: 140,
                    padding: const EdgeInsets.fromLTRB(15, 20, 25, 10),
                    decoration: BoxDecoration(color: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: dividerColor)),
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false), titlesData: const FlTitlesData(show: false), borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [FlSpot(0, 1), FlSpot(1, 1.5), FlSpot(2, 1.2), FlSpot(3, 2.5), FlSpot(4, 2.0)],
                            isCurved: true, color: request.color, barWidth: 3, isStrokeCapRound: true,
                            belowBarData: BarAreaData(show: true, color: request.color.withOpacity(0.1)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  Text("DOCTOR'S NOTES", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textSecondary, letterSpacing: 1.0)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: replyController,
                    maxLines: 4,
                    style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: "Type your medical advice here...",
                      hintStyle: TextStyle(color: textSecondary.withOpacity(0.7), fontSize: 14),
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
                        if (replyController.text.isEmpty) return;
                        Navigator.pop(context); 
                        _removeRequest(index);  

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("Feedback sent to patient successfully!", style: TextStyle(fontWeight: FontWeight.bold)),
                            backgroundColor: hpPurple, behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          )
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: hpPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0),
                      child: const Text("Send Feedback", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: "LexendExaNormal")),
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
}