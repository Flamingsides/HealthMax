import 'package:flutter/material.dart';
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
  int duration; // Added explicit duration
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
  final Color bgOffWhite = const Color(0xFFF8F9FA);

  // --- MOCK DATA ---
  final int _userScore = 1234;
  final String _username = "Tengku Adam";

  // Made this a mutable list so we can add/edit/remove!
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
  }

  int get _completedTargets => _targets.where((t) => t.isCompleted).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgOffWhite,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ==========================================
          // 2. ELEGANT APP BAR
          // ==========================================
          SliverAppBar(
            backgroundColor: themeBlue,
            expandedHeight: 180.0,
            toolbarHeight: 90.0,
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 0.0,
            surfaceTintColor: Colors.transparent,
            actions: const [
              Padding(padding: EdgeInsets.only(right: 30.0, top: 10.0), child: Center(child: UserGlassyProfile())),
            ],
            title: const Padding(
              padding: EdgeInsets.only(left: 15.0),
              child: Text("Your\nTarget.", style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: "LexendExaNormal", letterSpacing: -1.0, height: 1.1)),
            ),
            flexibleSpace: const FlexibleSpaceBar(background: SizedBox.shrink()),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(30),
              child: Transform.translate(
                offset: const Offset(0, 1),
                child: Container(height: 31, width: double.infinity, decoration: BoxDecoration(color: bgOffWhite, borderRadius: const BorderRadius.vertical(top: Radius.circular(40)))),
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
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))]),
                    child: Column(
                      children: [
                        Text("Your Score : $_userScore", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, fontFamily: "LexendExaNormal")),
                        const SizedBox(height: 20),
                        
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: themeBlue, width: 2.5)),
                          child: Column(
                            children: [
                              Text("$_completedTargets/${_targets.length} Achieved!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: themeBlue, fontFamily: "LexendExaNormal")),
                              const SizedBox(height: 4),
                              Text(
                                _targets.length == _completedTargets ? "All targets completed! Great job!" : "Complete ${_targets.length - _completedTargets} more to get extra points!", 
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 25),
                              
                              // Check if list is empty
                              if (_targets.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  child: Text("No targets set. Tap the button below to start!", style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold)),
                                )
                              else
                                // Map through dynamic targets and pass the index!
                                ..._targets.asMap().entries.map((entry) => _buildTargetProgress(entry.value, entry.key)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- RANKING SECTION ---
                  const Text("Ranking", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: "LexendExaNormal")),
                  const SizedBox(height: 15),
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))]),
                    child: Column(
                      children: [
                        ..._topRankings.map((user) => _buildRankingRow(user)),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            children: [
                              Icon(Icons.circle, size: 4, color: Colors.black26), SizedBox(height: 4),
                              Icon(Icons.circle, size: 4, color: Colors.black26), SizedBox(height: 4),
                              Icon(Icons.circle, size: 4, color: Colors.black26),
                            ],
                          ),
                        ),
                        _buildRankingRow(_currentUserRank),
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
          onPressed: () => _showTargetActionModal(null), // Null means "Create New"
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

  Widget _buildTargetProgress(TargetItem target, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center, // Center aligned for the button
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(target.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(width: 8),
                    if (target.isCompleted)
                      Text("+${target.rewardPoints} pts", style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              // --- THE NEW EDIT BUTTON ---
              GestureDetector(
                onTap: () => _showTargetActionModal(index), // Pass index to edit
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.edit_rounded, size: 16, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(target.description, style: TextStyle(fontSize: 11, color: Colors.grey.shade800, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: target.progress,
              minHeight: 6,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(target.isCompleted ? const Color(0xFF2ED573) : const Color(0xFFFF4757)),
            ),
          ),
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${target.currentValue} ${target.unit} / ${target.targetValue} ${target.unit}", style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
              Text("${(target.progress * 100).toInt()}%", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankingRow(RankingUser user) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(width: 30, child: Text("${user.rank}.", style: TextStyle(fontSize: 16, fontWeight: user.isCurrentUser ? FontWeight.w900 : FontWeight.w600, color: user.isCurrentUser ? themeBlue : Colors.black87))),
              Text(user.name, style: TextStyle(fontSize: 16, fontWeight: user.isCurrentUser ? FontWeight.w900 : FontWeight.w600, color: user.isCurrentUser ? themeBlue : Colors.black87, fontFamily: user.isCurrentUser ? "LexendExaNormal" : null)),
            ],
          ),
          Text("Score: ${user.score}", style: TextStyle(fontSize: 16, fontWeight: user.isCurrentUser ? FontWeight.w900 : FontWeight.w600, color: user.isCurrentUser ? themeBlue : Colors.black87)),
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

    // Available Metrics
    final List<Map<String, String>> metricOptions = [
      {"title": "Steps", "unit": "steps"},
      {"title": "Calorie Balance", "unit": "kcal"},
      {"title": "Noise Control", "unit": "hours"},
      {"title": "Heart Rate", "unit": "bpm"},
    ];

    // Form State variables
    String selectedMetricTitle = existingTarget?.title ?? metricOptions[0]["title"]!;
    String selectedUnit = existingTarget?.unit ?? metricOptions[0]["unit"]!;
    
    // Controllers for the input fields
    TextEditingController amountController = TextEditingController(text: isEditing ? existingTarget!.targetValue.toString() : "");
    TextEditingController durationController = TextEditingController(text: isEditing ? existingTarget!.duration.toString() : "");

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // Allows keyboard to push modal up
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            
            // Safety measure: dynamically push UI up when keyboard appears
            final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

            return Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(35))),
              padding: EdgeInsets.fromLTRB(30, 10, 30, 40 + bottomPadding), // Dynamic padding!
              child: SingleChildScrollView( // Prevents overflow when keyboard is open
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 30), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
                    
                    Text(isEditing ? "Edit Target" : "Set New Target", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: "LexendExaNormal")),
                    const SizedBox(height: 5),
                    Text(isEditing ? "Modify your current goal parameters." : "Select your metric and set a challenging goal.", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    const SizedBox(height: 30),

                    // --- 1. METRIC SELECTOR (CHOICE CHIPS) ---
                    const Text("Select Metric", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10, runSpacing: 10,
                      children: metricOptions.map((option) {
                        bool isSelected = selectedMetricTitle == option["title"];
                        return ChoiceChip(
                          label: Text(option["title"]!, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87, fontSize: 12)),
                          selected: isSelected,
                          selectedColor: themeBlue,
                          backgroundColor: Colors.grey.shade100,
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
                        // Target Amount Input
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Target Amount", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: amountController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                                decoration: InputDecoration(
                                  filled: true, fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                  suffixText: selectedUnit,
                                  suffixStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade500),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
                        // Duration Input
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Duration", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: durationController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                                decoration: InputDecoration(
                                  filled: true, fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                  suffixText: "days",
                                  suffixStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade500),
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
                          // Very basic validation
                          if (amountController.text.isEmpty || durationController.text.isEmpty) return;
                          
                          int amount = int.parse(amountController.text);
                          int duration = int.parse(durationController.text);
                          
                          // Mock generated description
                          String newDesc = "Achieve $amount $selectedUnit in $duration Days.";
                          if (selectedMetricTitle == "Calorie Balance") newDesc = "Maintain a Net Calorie deficit of $amount $selectedUnit for $duration days straight.";

                          setState(() {
                            if (isEditing) {
                              // Update existing
                              _targets[editIndex].title = selectedMetricTitle;
                              _targets[editIndex].targetValue = amount;
                              _targets[editIndex].duration = duration;
                              _targets[editIndex].unit = selectedUnit;
                              _targets[editIndex].description = newDesc;
                            } else {
                              // Create new
                              _targets.add(
                                TargetItem(
                                  title: selectedMetricTitle,
                                  description: newDesc,
                                  currentValue: 0, // Starts at 0
                                  targetValue: amount,
                                  duration: duration,
                                  unit: selectedUnit,
                                  rewardPoints: (amount / duration).clamp(10, 500).toInt(), // Mock calc
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

                    // --- DYNAMIC REMOVE BUTTON (ONLY SHOWS IF EDITING) ---
                    if (isEditing) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _targets.removeAt(editIndex);
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Target Removed", style: const TextStyle(fontWeight: FontWeight.bold)), backgroundColor: const Color(0xFFFF4757), behavior: SnackBarBehavior.floating));
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