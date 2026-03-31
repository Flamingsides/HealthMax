import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart'; 
import 'user_bottomnavbar.dart';
import 'user_glassy_profile.dart';
import 'goal_provider.dart'; 

class UserTargetPage extends StatefulWidget {
  const UserTargetPage({super.key});

  @override
  State<UserTargetPage> createState() => _UserTargetPageState();
}

class _UserTargetPageState extends State<UserTargetPage> {
  final Color themeBlue = const Color(0xFF5A84F1);
  final Color themePurple = const Color(0xFF8E33FF); 

  late ScrollController _scrollController;
  bool _isScrolled = false;
  
  bool _isAiCalculating = true; 

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isAiCalculating = false);
    });
    
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset > 70 && !_isScrolled) setState(() => _isScrolled = true);
      else if (_scrollController.offset <= 70 && _isScrolled) setState(() => _isScrolled = false);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final goalData = Provider.of<GoalProvider>(context);

    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = isDark ? Colors.white54 : Colors.grey.shade600;
    final dividerColor = Theme.of(context).dividerColor;

    int completedTargets = goalData.targets.where((t) => t.isCompleted).length;

    return Scaffold(
      backgroundColor: bgColor,
      body: goalData.isLoading 
        ? Center(child: CircularProgressIndicator(color: themeBlue)) 
        : CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ==========================================
          // ELEGANT APP BAR
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
            
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: _isScrolled ? 1.0 : 0.0,
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0, top: 10.0),
                child: ShaderMask(
                  shaderCallback: (Rect bounds) => const LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Colors.white, Colors.white, Colors.transparent], stops: [0.0, 0.85, 1.0]).createShader(bounds),
                  blendMode: BlendMode.dstIn,
                  child: const Text("Your Target.", maxLines: 1, softWrap: false, overflow: TextOverflow.clip, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: "LexendExaNormal")),
                ),
              ),
            ),
            actions: [Padding(padding: const EdgeInsets.only(right: 30.0, top: 10.0), child: Center(child: UserGlassyProfile(onTap: () => Navigator.pushNamed(context, '/user_settings'))))],
            
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax, 
              background: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text("Your\nTarget.", style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: "LexendExaNormal", letterSpacing: -1.0, height: 1.1))]),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(30),
              child: Transform.translate(offset: const Offset(0, 1), child: Container(height: 31, width: double.infinity, decoration: BoxDecoration(color: bgColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(40))))),
            ),
          ),

          // ==========================================
          // SCROLLABLE BODY
          // ==========================================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // --- MAIN GOAL CARD WITH LIVE AI PROGRESS ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark ? [themePurple.withValues(alpha:0.2), surfaceColor] : [themePurple.withValues(alpha:0.1), Colors.white],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: themePurple.withValues(alpha:0.5), width: 1.5),
                      boxShadow: isDark ? [] : [BoxShadow(color: themePurple.withValues(alpha:0.15), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: themePurple.withValues(alpha:0.2), shape: BoxShape.circle),
                                  child: Icon(Icons.flag_circle_rounded, color: themePurple, size: 20),
                                ),
                                const SizedBox(width: 10),
                                Text("MAIN GOAL", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: themePurple, letterSpacing: 1.5, fontFamily: "LexendExaNormal")),
                              ],
                            ),
                            GestureDetector(
                              onTap: () => _showMainGoalEditorSheet(goalData, isDark, surfaceColor, textPrimary, textSecondary, dividerColor),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.black.withValues(alpha:0.05), borderRadius: BorderRadius.circular(12)),
                                child: Text("Edit", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textPrimary)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        if (goalData.mainGoal.title == "N/A") ...[
                          Text("No Goal Yet", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textPrimary, fontFamily: "LexendExaNormal")),
                          const SizedBox(height: 8),
                          Text("Set a main health goal to let AI personalize your experience.", style: TextStyle(color: textSecondary, fontSize: 13)),
                        ] else ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(goalData.mainGoal.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textPrimary, fontFamily: "LexendExaNormal")),
                                  const SizedBox(height: 4),
                                  Text("Target: ${goalData.mainGoal.targetValue}", style: TextStyle(color: textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              Text(
                                _isAiCalculating ? "--%" : "${(goalData.mainGoal.aiProgress * 100).toInt()}%", 
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _isAiCalculating ? textSecondary : themePurple, fontFamily: "LexendExaNormal")
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.0, end: _isAiCalculating ? 0.0 : goalData.mainGoal.aiProgress),
                              duration: const Duration(seconds: 1),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, _) => LinearProgressIndicator(
                                value: value,
                                minHeight: 8,
                                backgroundColor: isDark ? Colors.white10 : Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation<Color>(themePurple),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: _isAiCalculating 
                              ? _buildAiLoadingState(isDark)
                              : Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: themePurple.withValues(alpha:0.1),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: themePurple.withValues(alpha:0.3)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.auto_awesome, color: themePurple, size: 18),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          "AI Insight: ${goalData.mainGoal.aiInsightText}", 
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black87, height: 1.4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          )
                        ]
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 25),

                  // --- SCORE & SUB-TARGET CARD ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: surfaceColor, 
                      borderRadius: BorderRadius.circular(30), 
                      border: isDark ? Border.all(color: dividerColor) : null,
                      boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha:0.04), blurRadius: 15, offset: const Offset(0, 8))]
                    ),
                    child: Column(
                      children: [
                        Text("Your Score : ${goalData.userScore}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textPrimary, fontFamily: "LexendExaNormal")),
                        const SizedBox(height: 20),
                        
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: isDark ? bgColor : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: themeBlue, width: 2.5)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text("$completedTargets/${goalData.targets.length} Achieved!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: themeBlue, fontFamily: "LexendExaNormal"), textAlign: TextAlign.center),
                              const SizedBox(height: 4),
                              Text(
                                goalData.targets.length == completedTargets ? "All targets completed! Great job!" : "Complete ${goalData.targets.length - completedTargets} more to get extra points!", 
                                style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w600), textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 35),
                              
                              Text("DAILY GOALS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: textSecondary, letterSpacing: 1.5, fontFamily: "LexendExaNormal")),
                              const SizedBox(height: 15),
                              
                              if (goalData.targets.isEmpty)
                                Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Text("No targets set. Tap the button below to start!", style: TextStyle(color: textSecondary, fontWeight: FontWeight.bold)))
                              else
                                ...goalData.targets.asMap().entries.map((entry) => _buildTargetProgress(entry.value, entry.key, goalData, textPrimary, textSecondary, dividerColor, isDark, surfaceColor)),
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
                      color: surfaceColor, borderRadius: BorderRadius.circular(30), 
                      border: Border.all(color: dividerColor), boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha:0.04), blurRadius: 15, offset: const Offset(0, 8))]
                    ),
                    child: Column(
                      children: [
                        ...goalData.topRankings.map((user) => _buildRankingRow(user, textPrimary)),
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
                        _buildRankingRow(goalData.currentUserRank, textPrimary),
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
      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: FloatingActionButton.extended(
          onPressed: () {}, 
          backgroundColor: themeBlue, elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          label: const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("Set New Target", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: "LexendExaNormal"))),
        ),
      ),
      bottomNavigationBar: const UserBottomNavBar(currentIndex: 4), 
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildAiLoadingState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.black.withValues(alpha:0.05), borderRadius: BorderRadius.circular(15)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: themePurple, strokeWidth: 2)),
          const SizedBox(width: 10),
          Expanded(child: Text("AI is analyzing your recent history...", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white54 : Colors.black54))),
        ],
      ),
    );
  }

  Widget _buildTargetProgress(TargetItem target, int index, GoalProvider goalData, Color textPrimary, Color textSecondary, Color dividerColor, bool isDark, Color surfaceColor) {
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
                    if (target.isCompleted) Text("+${target.rewardPoints} pts", style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showEditSubTargetSheet(target, index, surfaceColor, textPrimary, textSecondary, dividerColor, isDark), 
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
              value: target.progress, minHeight: 6,
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
  // EDIT SUB-TARGET MODAL (SMART LOGIC)
  // ==========================================
  void _showEditSubTargetSheet(TargetItem target, int index, Color surfaceColor, Color textPrimary, Color textSecondary, Color dividerColor, bool isDark) {
    // Determine if this is a device-tracked metric (e.g., steps, kcal) or a manual one (e.g., water/L)
    bool isAutomatic = target.unit.toLowerCase() == 'steps' || target.unit.toLowerCase() == 'kcal';

    // If automatic, user edits the TARGET. If manual, user edits the CURRENT progress.
    TextEditingController inputCtrl = TextEditingController(
      text: isAutomatic ? target.targetValue.toString() : target.currentValue.toString()
    );
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, 
      builder: (context) {
        final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
        return Container(
          decoration: BoxDecoration(color: surfaceColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(35))),
          padding: EdgeInsets.fromLTRB(30, 10, 30, 40 + bottomPadding), 
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 30), decoration: BoxDecoration(color: dividerColor, borderRadius: BorderRadius.circular(10)))),
                
                // --- DYNAMIC TITLES ---
                Text(isAutomatic ? "Edit Daily Target" : "Log Progress", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary, fontFamily: "LexendExaNormal")),
                const SizedBox(height: 5),
                Text(isAutomatic ? "Set a new daily goal for: ${target.title}" : "Update your progress for: ${target.title}", style: TextStyle(color: textSecondary, fontSize: 13)),
                
                if (isAutomatic) ...[
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: themeBlue.withValues(alpha:0.1), borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 16, color: themeBlue),
                        const SizedBox(width: 10),
                        Expanded(child: Text("Current progress is tracked automatically via your connected devices.", style: TextStyle(fontSize: 11, color: themeBlue, fontWeight: FontWeight.w600))),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 30),

                // --- DYNAMIC LABEL ---
                Text(isAutomatic ? "New Target Value (${target.unit})" : "Current Value (${target.unit})", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                const SizedBox(height: 10),
                TextFormField(
                  controller: inputCtrl,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: textPrimary),
                  decoration: InputDecoration(
                    filled: true, fillColor: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      int newValue = int.tryParse(inputCtrl.text) ?? (isAutomatic ? target.targetValue : target.currentValue);
                      
                      setState(() {
                        if (isAutomatic) {
                          target.targetValue = newValue; // Update the Goal
                        } else {
                          target.currentValue = newValue; // Update the Progress
                        }
                        
                        // Recalculate progress logic
                        target.progress = (target.currentValue / target.targetValue).clamp(0.0, 1.0);
                        target.isCompleted = target.currentValue >= target.targetValue;
                      });
                      
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: themeBlue, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                    child: Text(isAutomatic ? "Save Target" : "Save Progress", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: "LexendExaNormal")),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // MAIN GOAL EDITOR MODAL
  // ==========================================
  void _showMainGoalEditorSheet(GoalProvider dataProvider, bool isDark, Color surfaceColor, Color textPrimary, Color textSecondary, Color dividerColor) {
    TextEditingController targetController = TextEditingController(
      text: dataProvider.mainGoal.targetValue == "N/A" ? "" : dataProvider.mainGoal.targetValue.replaceAll(RegExp(r'[^0-9]'), '')
    );
    
    final List<String> goalOptions = ["Lose Weight", "More Steps", "Less Sugar", "Build Muscle"];
    String tempSelectedGoal = dataProvider.mainGoal.title == "N/A" ? goalOptions[0] : dataProvider.mainGoal.title;

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
                    Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 30), decoration: BoxDecoration(color: dividerColor, borderRadius: BorderRadius.circular(10)))),
                    
                    Text("Edit Main Goal", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary, fontFamily: "LexendExaNormal")),
                    const SizedBox(height: 5),
                    Text("Update your primary health objective.", style: TextStyle(color: textSecondary, fontSize: 13)),
                    const SizedBox(height: 30),

                    Wrap(
                      spacing: 10, runSpacing: 10,
                      children: goalOptions.map((goal) {
                        bool isSelected = tempSelectedGoal == goal;
                        return ChoiceChip(
                          label: Text(goal, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : textPrimary, fontSize: 12)),
                          selected: isSelected,
                          selectedColor: themePurple,
                          backgroundColor: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
                          showCheckmark: false,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
                          onSelected: (selected) {
                            if (selected) setModalState(() => tempSelectedGoal = goal);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 25),

                    Text("Target Value", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: targetController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: textPrimary),
                      decoration: InputDecoration(
                        filled: true, fillColor: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                        hintText: "e.g., 60",
                        hintStyle: TextStyle(color: textSecondary),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                    ),
                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (targetController.text.isEmpty) return;
                          
                          String unit = "";
                          if (tempSelectedGoal == "Lose Weight" || tempSelectedGoal == "Build Muscle") unit = "kg";
                          else if (tempSelectedGoal == "More Steps") unit = "steps";
                          else if (tempSelectedGoal == "Less Sugar") unit = "g";

                          dataProvider.updateMainGoal(tempSelectedGoal, "${targetController.text} $unit");
                          Navigator.pop(context);
                          
                          setState(() {
                            _isAiCalculating = true;
                            Future.delayed(const Duration(seconds: 2), () {
                              if (mounted) setState(() => _isAiCalculating = false);
                            });
                          });
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: themePurple, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                        child: const Text("Save Main Goal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: "LexendExaNormal")),
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
}