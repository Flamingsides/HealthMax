import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart'; // Adjust path if needed
import 'user_bottomnavbar.dart';
import 'user_glassy_profile.dart';

// ==========================================
// 1. MOCK DATA MODELS
// ==========================================
class TargetItem {
  String title;
  String description;
  int currentValue;
  int targetValue;
  int duration; 
  String unit;
  int rewardPoints;

  TargetItem({
    required this.title,
    required this.description,
    required this.currentValue,
    required this.targetValue,
    required this.duration,
    required this.unit,
    required this.rewardPoints,
  });

  double get progress => (currentValue / targetValue).clamp(0.0, 1.0);
  bool get isCompleted => currentValue >= targetValue;
}

class RankingUser {
  final int rank;
  final String name;
  final int score;
  final bool isCurrentUser;

  RankingUser(this.rank, this.name, this.score, {this.isCurrentUser = false});
}

class UserTargetPage extends StatefulWidget {
  const UserTargetPage({super.key});

  @override
  State<UserTargetPage> createState() => _UserTargetPageState();
}

class _UserTargetPageState extends State<UserTargetPage> {
  final Color themeBlue = const Color(0xFF5A84F1);

  // --- SCROLL ANIMATION STATE ---
  late ScrollController _scrollController;
  bool _isScrolled = false;

  // --- MOCK DATA ---
  final int _userScore = 1234;
  final String _username = "Tengku Adam";

  final List<TargetItem> _targets = [
    TargetItem(
      title: "Steps",
      description: "Achieve 10,000 steps in 5 Days.",
      currentValue: 8843,
      targetValue: 10000,
      duration: 5,
      unit: "steps",
      rewardPoints: 123,
    ),
    TargetItem(
      title: "Calorie Balance",
      description: "Maintain a Net Calorie deficit of 1,000 kcal for 10 days straight.",
      currentValue: 1000,
      targetValue: 1000,
      duration: 10,
      unit: "kcal",
      rewardPoints: 550,
    ),
    TargetItem(
      title: "Noise Control",
      description: "Spend less than 2 hours today in environments above 85 dB.",
      currentValue: 1,
      targetValue: 2,
      duration: 1,
      unit: "hours",
      rewardPoints: 50,
    ),
  ];

  final List<RankingUser> _topRankings = [
    RankingUser(1, "Suhaib", 3450),
    RankingUser(2, "Abdul", 3120),
    RankingUser(3, "Bhulan", 2980),
  ];

  late RankingUser _currentUserRank;

  @override
  void initState() {
    super.initState();
    _currentUserRank = RankingUser(42, _username, _userScore, isCurrentUser: true);
    
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

  int get _completedTargets => _targets.where((t) => t.isCompleted).length;

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
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ==========================================
          // 2. ELEGANT APP BAR
          // ==========================================
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
                    "Your Target.",
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
                      Text("Your\nTarget.", style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: "LexendExaNormal", letterSpacing: -1.0, height: 1.1)),
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

          // ==========================================
          // 3. SCROLLABLE BODY
          // ==========================================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SCORE & TARGET CARD ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: surfaceColor, 
                      borderRadius: BorderRadius.circular(30), 
                      border: isDark ? Border.all(color: dividerColor) : null,
                      boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))]
                    ),
                    child: Column(
                      children: [
                        Text("Your Score : $_userScore", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textPrimary, fontFamily: "LexendExaNormal")),
                        const SizedBox(height: 20),
                        
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: isDark ? bgColor : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: themeBlue, width: 2.5)),
                          child: Column(
                            children: [
                              Text("$_completedTargets/${_targets.length} Achieved!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: themeBlue, fontFamily: "LexendExaNormal")),
                              const SizedBox(height: 4),
                              Text(
                                _targets.length == _completedTargets ? "All targets completed! Great job!" : "Complete ${_targets.length - _completedTargets} more to get extra points!", 
                                style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 25),
                              
                              if (_targets.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  child: Text("No targets set. Tap the button below to start!", style: TextStyle(color: textSecondary, fontWeight: FontWeight.bold)),
                                )
                              else
                                ..._targets.asMap().entries.map((entry) => _buildTargetProgress(entry.value, entry.key, textPrimary, textSecondary, isDark)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- RANKING SECTION ---
                  Text("Ranking", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textPrimary, fontFamily: "LexendExaNormal")),
                  const SizedBox(height: 15),
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: surfaceColor, 
                      borderRadius: BorderRadius.circular(30), 
                      border: Border.all(color: dividerColor), 
                      boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))]
                    ),
                    child: Column(
                      children: [
                        ..._topRankings.map((user) => _buildRankingRow(user, textPrimary)),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            children: [
                              Icon(Icons.circle, size: 4, color: isDark ? Colors.white24 : Colors.black26), const SizedBox(height: 4),
                              Icon(Icons.circle, size: 4, color: isDark ? Colors.white24 : Colors.black26), const SizedBox(height: 4),
                              Icon(Icons.circle, size: 4, color: isDark ? Colors.white24 : Colors.black26),
                            ],
                          ),
                        ),
                        _buildRankingRow(_currentUserRank, textPrimary),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 120), 
                ],
              ),
            ),
          ),
        ],
      ),
      
      // ==========================================
      // 4. FLOATING SET TARGET BUTTON
      // ==========================================
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: FloatingActionButton.extended(
          onPressed: () => _showTargetActionModal(null),
          backgroundColor: themeBlue,
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          label: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text("Set New Target", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: "LexendExaNormal")),
          ),
        ),
      ),
      bottomNavigationBar: const UserBottomNavBar(currentIndex: 4), 
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildTargetProgress(TargetItem target, int index, Color textPrimary, Color textSecondary, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center, 
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(target.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: textPrimary)),
                    const SizedBox(width: 8),
                    if (target.isCompleted)
                      Text("+${target.rewardPoints} pts", style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showTargetActionModal(index), 
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.edit_rounded, size: 16, color: textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(target.description, style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: target.progress,
              minHeight: 6,
              backgroundColor: isDark ? Colors.white10 : Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(target.isCompleted ? const Color(0xFF2ED573) : const Color(0xFFFF4757)),
            ),
          ),
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${target.currentValue} ${target.unit} / ${target.targetValue} ${target.unit}", style: TextStyle(fontSize: 10, color: textSecondary, fontWeight: FontWeight.bold)),
              Text("${(target.progress * 100).toInt()}%", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: textPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankingRow(RankingUser user, Color textPrimary) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(width: 30, child: Text("${user.rank}.", style: TextStyle(fontSize: 16, fontWeight: user.isCurrentUser ? FontWeight.w900 : FontWeight.w600, color: user.isCurrentUser ? themeBlue : textPrimary))),
              Text(user.name, style: TextStyle(fontSize: 16, fontWeight: user.isCurrentUser ? FontWeight.w900 : FontWeight.w600, color: user.isCurrentUser ? themeBlue : textPrimary, fontFamily: user.isCurrentUser ? "LexendExaNormal" : null)),
            ],
          ),
          Text("Score: ${user.score}", style: TextStyle(fontSize: 16, fontWeight: user.isCurrentUser ? FontWeight.w900 : FontWeight.w600, color: user.isCurrentUser ? themeBlue : textPrimary)),
        ],
      ),
    );
  }

  // ==========================================
  // 5. THE UNIFIED CREATE / EDIT MODAL
  // ==========================================
  void _showTargetActionModal(int? editIndex) {
    bool isEditing = editIndex != null;
    TargetItem? existingTarget = isEditing ? _targets[editIndex] : null;

    final List<Map<String, String>> metricOptions = [
      {"title": "Steps", "unit": "steps"},
      {"title": "Calorie Balance", "unit": "kcal"},
      {"title": "Noise Control", "unit": "hours"},
      {"title": "Heart Rate", "unit": "bpm"},
    ];

    String selectedMetricTitle = existingTarget?.title ?? metricOptions[0]["title"]!;
    String selectedUnit = existingTarget?.unit ?? metricOptions[0]["unit"]!;
    
    TextEditingController amountController = TextEditingController(text: isEditing ? existingTarget!.targetValue.toString() : "");
    TextEditingController durationController = TextEditingController(text: isEditing ? existingTarget!.duration.toString() : "");

    // Grab theme data for the modal
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = isDark ? Colors.white54 : Colors.grey.shade600;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, 
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

            return Container(
              decoration: BoxDecoration(color: surfaceColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(35))),
              padding: EdgeInsets.fromLTRB(30, 10, 30, 40 + bottomPadding), 
              child: SingleChildScrollView( 
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 30), decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
                    
                    Text(isEditing ? "Edit Target" : "Set New Target", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary, fontFamily: "LexendExaNormal")),
                    const SizedBox(height: 5),
                    Text(isEditing ? "Modify your current goal parameters." : "Select your metric and set a challenging goal.", style: TextStyle(color: textSecondary, fontSize: 13)),
                    const SizedBox(height: 30),

                    // --- 1. METRIC SELECTOR ---
                    Text("Select Metric", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10, runSpacing: 10,
                      children: metricOptions.map((option) {
                        bool isSelected = selectedMetricTitle == option["title"];
                        return ChoiceChip(
                          label: Text(option["title"]!, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : textPrimary, fontSize: 12)),
                          selected: isSelected,
                          selectedColor: themeBlue,
                          backgroundColor: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
                          showCheckmark: false,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() {
                                selectedMetricTitle = option["title"]!;
                                selectedUnit = option["unit"]!;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 25),

                    // --- 2. INPUT FIELDS ROW ---
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Target Amount", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: amountController,
                                keyboardType: TextInputType.number,
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: textPrimary),
                                decoration: InputDecoration(
                                  filled: true, fillColor: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                  suffixText: selectedUnit,
                                  suffixStyle: TextStyle(fontWeight: FontWeight.bold, color: textSecondary),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Duration", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: durationController,
                                keyboardType: TextInputType.number,
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: textPrimary),
                                decoration: InputDecoration(
                                  filled: true, fillColor: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                  suffixText: "days",
                                  suffixStyle: TextStyle(fontWeight: FontWeight.bold, color: textSecondary),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 40),

                    // --- SAVE BUTTON ---
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (amountController.text.isEmpty || durationController.text.isEmpty) return;
                          
                          int amount = int.parse(amountController.text);
                          int duration = int.parse(durationController.text);
                          
                          String newDesc = "Achieve $amount $selectedUnit in $duration Days.";
                          if (selectedMetricTitle == "Calorie Balance") newDesc = "Maintain a Net Calorie deficit of $amount $selectedUnit for $duration days straight.";

                          setState(() {
                            if (isEditing) {
                              _targets[editIndex].title = selectedMetricTitle;
                              _targets[editIndex].targetValue = amount;
                              _targets[editIndex].duration = duration;
                              _targets[editIndex].unit = selectedUnit;
                              _targets[editIndex].description = newDesc;
                            } else {
                              _targets.add(
                                TargetItem(
                                  title: selectedMetricTitle, description: newDesc, currentValue: 0,
                                  targetValue: amount, duration: duration, unit: selectedUnit,
                                  rewardPoints: (amount / duration).clamp(10, 500).toInt(),
                                )
                              );
                            }
                          });
                          
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: themeBlue, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                        child: Text(isEditing ? "Update Target" : "Save Target", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: "LexendExaNormal")),
                      ),
                    ),

                    if (isEditing) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            setState(() => _targets.removeAt(editIndex));
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Target Removed", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: const Color(0xFFFF4757), behavior: SnackBarBehavior.floating));
                          },
                          child: const Text("Delete Target", style: TextStyle(color: Color(0xFFFF4757), fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}