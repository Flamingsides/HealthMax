import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:healthmax_frontend/GeneralPages/auth/auth_service.dart';
import 'package:healthmax_frontend/GeneralPages/helper_widgets.dart';
import 'package:riff_switch/riff_switch.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'goal_provider.dart';

class RegistrationQuestions extends StatelessWidget {
  final int numQuestions;
  final int currentIndex;
  final List<Widget>? children;
  const RegistrationQuestions({
    super.key,
    required this.numQuestions,
    required this.currentIndex,
    this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Screen(
      bgDecoration: bgWhite,
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
            child: ProgressBar(current: currentIndex, countBars: numQuestions),
          ),
          ...children ?? [],
        ],
      ),
    );
  }
}

class GenderCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final UserAnswers userAnswers;
  final String selectedGender;
  final void Function(String) setSelectedGender;

  const GenderCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.userAnswers,
    required this.selectedGender,
    required this.setSelectedGender,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withAlpha(30),
      borderRadius: BorderRadius.circular(50),
      child: InkWell(
        onTap: () {
          setSelectedGender(label);
          userAnswers.gender = label.toLowerCase();
        },
        borderRadius: BorderRadius.circular(50),
        child: SizedBox(
          height: 252,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              border: selectedGender == label ? Border.all(color: color, width: 3) : null,
            ),
            padding: const EdgeInsets.fromLTRB(10, 30, 10, 30),
            child: Column(
              children: [
                Icon(icon, size: 150, color: color),
                Text(label, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, fontFamily: "LexendExaNormal", letterSpacing: 1)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UserAnswers {
  String? gender;
  DateTime? dob;
  double? weight;
  String? weightUnit;
  double? height;
  String? heightUnit;
  String? mainGoal;
  String? goalTargetValue;

  UserAnswers({this.gender, this.dob, this.weight, this.weightUnit, this.height, this.heightUnit, this.mainGoal, this.goalTargetValue});

  @override
  String toString() {
    return "Gender: $gender, DOB: ${dob?.toIso8601String().split('T')[0]}, Weight: $weight $weightUnit, Height: $height $heightUnit, Goal: $mainGoal ($goalTargetValue)";
  }
}

class RegistrationGender extends StatefulWidget {
  const RegistrationGender({super.key});
  @override
  State<RegistrationGender> createState() => _RegistrationGenderState();
}

class _RegistrationGenderState extends State<RegistrationGender> {
  UserAnswers userAnswers = UserAnswers();
  String? selectedGender;

  void setSelectedGender(String gender) => setState(() => selectedGender = gender);

  @override
  Widget build(BuildContext context) {
    return RegistrationQuestions(
      numQuestions: 5,
      currentIndex: 0,
      children: [
        const SizedBox(height: 100),
        const Text("Select your Gender", style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold, fontFamily: "LexendExaNormal"), textAlign: TextAlign.center),
        const SizedBox(height: 100),
        Row(
          children: [
            Expanded(child: GenderCard(icon: Icons.male, color: Colors.lightBlueAccent, label: "Male", userAnswers: userAnswers, selectedGender: selectedGender ?? "None", setSelectedGender: setSelectedGender)),
            const SizedBox(width: 10),
            Expanded(child: GenderCard(icon: Icons.female, label: "Female", color: Colors.purpleAccent, userAnswers: userAnswers, selectedGender: selectedGender ?? "None", setSelectedGender: setSelectedGender)),
          ],
        ),
        const SizedBox(height: 100),
        CustomButton(
          label: "Next",
          onPressed: () {
            if (selectedGender == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a gender!"), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating));
              return;
            }
            Navigator.push(context, MaterialPageRoute(builder: (_) => RegistrationDOB(userAnswers: userAnswers)));
          },
        ),
      ],
    );
  }
}

class EnterDOBWidget extends StatefulWidget {
  final UserAnswers userAnswers;
  const EnterDOBWidget({super.key, required this.userAnswers});
  @override
  State<EnterDOBWidget> createState() => _EnterDOBWidgetState();
}

class _EnterDOBWidgetState extends State<EnterDOBWidget> {
  DateTime? selectedDate;

  Future<void> getDate() async {
    DateTime curr = DateTime.now();
    DateTime date18YearsAgo = DateTime(curr.year - 18, curr.month, curr.day);

    DateTime? date = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: date18YearsAgo,
      initialDate: selectedDate ?? date18YearsAgo,
      builder: (context, child) {
        return Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF8E33FF), onPrimary: Colors.white, onSurface: Colors.black87)), child: child!);
      },
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
        widget.userAnswers.dob = date;
      });
    }
  }

  String formatDate(DateTime date) {
    List<String> months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    bool hasDate = selectedDate != null;
    return GestureDetector(
      onTap: getDate,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30),
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: hasDate ? const Color(0xFF8E33FF).withValues(alpha: 0.5) : Colors.grey.shade300, width: 2), boxShadow: [BoxShadow(color: hasDate ? const Color(0xFF8E33FF).withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month_rounded, size: 32, color: hasDate ? const Color(0xFF8E33FF) : Colors.grey.shade400),
            const SizedBox(width: 15),
            Text(hasDate ? formatDate(selectedDate!) : "Select Date", style: TextStyle(color: hasDate ? Colors.black87 : Colors.grey.shade500, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: "LexendExaNormal")),
          ],
        ),
      ),
    );
  }
}

class RegistrationDOB extends StatelessWidget {
  final UserAnswers userAnswers;
  const RegistrationDOB({super.key, required this.userAnswers});
  @override
  Widget build(BuildContext context) {
    return RegistrationQuestions(
      numQuestions: 5,
      currentIndex: 1,
      children: [
        const SizedBox(height: 100),
        const Text("Enter your date of birth", style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold, fontFamily: "LexendExaNormal"), textAlign: TextAlign.center),
        const SizedBox(height: 100),
        EnterDOBWidget(userAnswers: userAnswers),
        const SizedBox(height: 100),
        CustomButton(
          label: "Next",
          onPressed: () {
            if (userAnswers.dob == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select your date of birth!"), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating));
              return;
            }
            Navigator.push(context, MaterialPageRoute(builder: (_) => RegistrationWeight(userAnswers: userAnswers)));
          },
        ),
      ],
    );
  }
}

class GetUnit extends StatefulWidget {
  final String unit1;
  final String unit2;
  final Function(String unit) onUnitChanged;
  const GetUnit({super.key, required this.unit1, required this.unit2, required this.onUnitChanged});

  @override
  State<GetUnit> createState() => _GetUnitState();
}

class _GetUnitState extends State<GetUnit> {
  bool value = true;
  late String activeUnit;

  @override
  void initState() {
    super.initState();
    activeUnit = widget.unit1;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RiffSwitch(
          width: 150, height: 40, value: value,
          onChanged: (bool newVal) {
            if (value == newVal) return;
            setState(() {
              activeUnit = newVal ? widget.unit1 : widget.unit2;
              value = newVal;
            });
            widget.onUnitChanged(activeUnit);
          },
          type: RiffSwitchType.simple,
          activeText: Text(activeUnit, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          activeColor: const Color.fromARGB(255, 142, 175, 9),
          inactiveThumbColor: const Color.fromARGB(255, 142, 175, 9),
          inactiveText: Text(value ? widget.unit1 : widget.unit2, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          inactiveTrackColor: Colors.white, activeTrackColor: Colors.white, borderColor: Colors.black, borderWidth: 3, elevation: 2, animateToggle: true,
        ),
      ],
    );
  }
}

class PremiumHorizontalRuler extends StatefulWidget {
  final int minValue;
  final int maxValue;
  final int initialValue;
  final Function(int) onChanged;

  const PremiumHorizontalRuler({super.key, required this.minValue, required this.maxValue, required this.initialValue, required this.onChanged});

  @override
  State<PremiumHorizontalRuler> createState() => _PremiumHorizontalRulerState();
}

class _PremiumHorizontalRulerState extends State<PremiumHorizontalRuler> {
  late FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(initialItem: widget.initialValue - widget.minValue);
  }

  @override
  Widget build(BuildContext context) {
    int range = widget.maxValue - widget.minValue + 1;
    return SizedBox(
      height: 140, width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ShaderMask(
            shaderCallback: (Rect bounds) => const LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent], stops: [0.0, 0.35, 0.65, 1.0]).createShader(bounds),
            blendMode: BlendMode.dstIn,
            child: RotatedBox(
              quarterTurns: 3,
              child: ListWheelScrollView.useDelegate(
                controller: _controller, itemExtent: 16, diameterRatio: 2.5, useMagnifier: true, magnification: 1.25, physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (index) => widget.onChanged(index + widget.minValue),
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: range,
                  builder: (context, index) {
                    int val = index + widget.minValue;
                    bool isMajor = val % 10 == 0;
                    bool isMedium = val % 5 == 0 && !isMajor;
                    return RotatedBox(
                      quarterTurns: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: isMajor ? 3 : (isMedium ? 2 : 1.5), height: isMajor ? 45 : (isMedium ? 30 : 20), decoration: BoxDecoration(color: isMajor ? Colors.black87 : Colors.grey.shade400, borderRadius: BorderRadius.circular(2))),
                          if (isMajor) ...[const SizedBox(height: 8), Text("$val", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54))],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: Container(width: 5, height: 90, decoration: BoxDecoration(color: const Color(0xFF8E33FF), borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: const Color(0xFF8E33FF).withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 2)])),
          ),
        ],
      ),
    );
  }
}

class WeightInputSection extends StatefulWidget {
  final UserAnswers userAnswers;
  const WeightInputSection({super.key, required this.userAnswers});
  @override
  State<WeightInputSection> createState() => _WeightInputSectionState();
}

class _WeightInputSectionState extends State<WeightInputSection> {
  bool isKg = true;
  int selectedWeight = 60;

  @override
  void initState() {
    super.initState();
    widget.userAnswers.weightUnit = "kg";
    widget.userAnswers.weight = selectedWeight.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic,
          children: [
            Text("$selectedWeight", style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Color(0xFF8E33FF))),
            const SizedBox(width: 8),
            Text(isKg ? "kg" : "lb", style: const TextStyle(fontSize: 24, color: Colors.grey, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 20),
        GetUnit(
          unit1: "kg", unit2: "lb",
          onUnitChanged: (unit) {
            setState(() {
              isKg = unit == 'kg';
              selectedWeight = isKg ? 60 : 132; 
              widget.userAnswers.weightUnit = unit;
              widget.userAnswers.weight = selectedWeight.toDouble();
            });
          },
        ),
        const SizedBox(height: 40),
        PremiumHorizontalRuler(
          key: ValueKey(isKg), minValue: isKg ? 30 : 66, maxValue: isKg ? 200 : 440, initialValue: selectedWeight,
          onChanged: (val) {
            setState(() => selectedWeight = val);
            widget.userAnswers.weight = val.toDouble();
          },
        ),
      ],
    );
  }
}

class RegistrationWeight extends StatelessWidget {
  final UserAnswers userAnswers;
  const RegistrationWeight({super.key, required this.userAnswers});
  @override
  Widget build(BuildContext context) {
    return RegistrationQuestions(
      numQuestions: 5,
      currentIndex: 2,
      children: [
        const SizedBox(height: 60),
        const Text("Enter your weight", style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold, fontFamily: "LexendExaNormal"), textAlign: TextAlign.center),
        const SizedBox(height: 40),
        WeightInputSection(userAnswers: userAnswers),
        const SizedBox(height: 60),
        CustomButton(label: "Next", onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegistrationHeight(userAnswers: userAnswers)))),
      ],
    );
  }
}

class HeightInputSection extends StatefulWidget {
  final UserAnswers userAnswers;
  const HeightInputSection({super.key, required this.userAnswers});
  @override
  State<HeightInputSection> createState() => _HeightInputSectionState();
}

class _HeightInputSectionState extends State<HeightInputSection> {
  bool isCm = true;
  int selectedHeight = 170;

  @override
  void initState() {
    super.initState();
    widget.userAnswers.heightUnit = "cm";
    widget.userAnswers.height = selectedHeight.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic,
          children: [
            Text("$selectedHeight", style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Color(0xFF8E33FF))),
            const SizedBox(width: 8),
            Text(isCm ? "cm" : "in", style: const TextStyle(fontSize: 24, color: Colors.grey, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 20),
        GetUnit(
          unit1: "cm", unit2: "in",
          onUnitChanged: (unit) {
            setState(() {
              isCm = unit == 'cm';
              selectedHeight = isCm ? 170 : 67; 
              widget.userAnswers.heightUnit = unit;
              widget.userAnswers.height = selectedHeight.toDouble();
            });
          },
        ),
        const SizedBox(height: 40),
        PremiumHorizontalRuler(
          key: ValueKey(isCm), minValue: isCm ? 100 : 40, maxValue: isCm ? 250 : 100, initialValue: selectedHeight,
          onChanged: (val) {
            setState(() => selectedHeight = val);
            widget.userAnswers.height = val.toDouble();
          },
        ),
      ],
    );
  }
}

class RegistrationHeight extends StatelessWidget {
  final UserAnswers userAnswers;
  const RegistrationHeight({super.key, required this.userAnswers});
  @override
  Widget build(BuildContext context) {
    return RegistrationQuestions(
      numQuestions: 5,
      currentIndex: 3,
      children: [
        const SizedBox(height: 60),
        const Text("Enter your height", style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold, fontFamily: "LexendExaNormal"), textAlign: TextAlign.center),
        const SizedBox(height: 40),
        HeightInputSection(userAnswers: userAnswers),
        const SizedBox(height: 60),
        CustomButton(label: "Next", onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegistrationGoal(userAnswers: userAnswers)))),
        const SizedBox(height: 40),
      ],
    );
  }
}

// ==========================================
// DYNAMIC GOAL SETTING WITH REAL AI INTEGRATION
// ==========================================
class RegistrationGoal extends StatefulWidget {
  final UserAnswers userAnswers;
  const RegistrationGoal({super.key, required this.userAnswers});
  @override
  State<RegistrationGoal> createState() => _RegistrationGoalState();
}

class _RegistrationGoalState extends State<RegistrationGoal> {
  final Color themePurple = const Color(0xFF8E33FF);

  String? selectedGoal;
  final TextEditingController _targetCtrl = TextEditingController();
  final TextEditingController _aiChatCtrl = TextEditingController();

  final List<Map<String, String>> commonGoals = [
    {"title": "Lose Weight", "icon": "🔥", "unit": "kg"},
    {"title": "More Steps", "icon": "👟", "unit": "steps/day"},
    {"title": "Less Sugar", "icon": "🍬", "unit": "g/day"},
    {"title": "Build Muscle", "icon": "💪", "unit": "kg"},
  ];

  bool _isAiThinking = false;

  // --- 1. FULLY WIRED GEMINI AI CLASSIFIER ---
  void _submitAiPrompt() async {
    if (_aiChatCtrl.text.isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() => _isAiThinking = true);

    try {
      final apiKey = dotenv.env["GEMINI_API_KEY"];
      if (apiKey == null || apiKey.isEmpty) throw "Gemini API key missing in .env!";

      // Initialize model specifically asking for JSON
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(responseMimeType: 'application/json'),
      );

      final prompt = '''
      You are an AI assistant in a health app helping a user set a goal.
      The user says: "${_aiChatCtrl.text}"
      
      Classify their intent into EXACTLY ONE of these titles:
      - "Lose Weight"
      - "More Steps"
      - "Less Sugar"
      - "Build Muscle"

      Rules:
      1. If they mention getting stronger, gaining mass, getting buff, or lifting weights, pick "Build Muscle".
      2. If they mention walking, running, or a marathon, pick "More Steps".
      3. Extract any numerical target they mentioned (e.g. "60", "10000"). If no number is mentioned, return "".

      Return ONLY a JSON object exactly like this:
      {"title": "Build Muscle", "target": "75"}
      ''';

      final response = await model.generateContent([Content.text(prompt)]);
      
      // Clean up potential markdown formatting block
      final jsonStr = response.text!.replaceAll(RegExp(r'```json|```'), '').trim();
      final data = jsonDecode(jsonStr);

      if (mounted) {
        setState(() {
          _isAiThinking = false;
          
          // Verify the AI returned a valid title, else fallback safely
          if (commonGoals.any((g) => g["title"] == data["title"])) {
            selectedGoal = data["title"];
          } else {
            selectedGoal = "Lose Weight"; 
          }
          
          _targetCtrl.text = data["target"]?.toString() ?? "";
          _aiChatCtrl.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("AI detected: ${data["title"]}!"),
            backgroundColor: themePurple,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print("AI Goal Error: $e");
      if (mounted) {
        setState(() => _isAiThinking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("AI couldn't process that. Please select manually."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _finishRegistration(bool skip) {
    final goalData = Provider.of<GoalProvider>(context, listen: false);

    if (skip) {
      widget.userAnswers.mainGoal = "N/A";
      widget.userAnswers.goalTargetValue = "N/A";
      goalData.updateMainGoal("N/A", "N/A"); // Handles skips perfectly!
    } else {
      if (selectedGoal == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a goal or skip."), backgroundColor: Colors.redAccent));
        return;
      }

      String targetVal = _targetCtrl.text.isEmpty ? "N/A" : _targetCtrl.text;
      String unit = commonGoals.firstWhere((g) => g["title"] == selectedGoal, orElse: () => {"unit": ""})["unit"]!;
      String finalTarget = targetVal == "N/A" ? "N/A" : "$targetVal $unit";

      widget.userAnswers.mainGoal = selectedGoal;
      widget.userAnswers.goalTargetValue = finalTarget;

      goalData.updateMainGoal(selectedGoal!, finalTarget);
    }

    double weight = widget.userAnswers.weight!;
    double height = widget.userAnswers.height!;
    if (widget.userAnswers.weightUnit == "lb") weight *= 2.20462; 
    if (widget.userAnswers.heightUnit == "in") height *= 0.3937007874; 

    final auth = AuthService();
    try {
      auth.initialiseUserDetails(widget.userAnswers.gender!, widget.userAnswers.dob!, height, weight);
    } on PostgrestException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.message}. Try again later."), backgroundColor: Colors.redAccent));
      return;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent));
      return;
    }

    Navigator.pushNamedAndRemoveUntil(context, '/user_homepage', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    String dynamicPrompt = "Target Value";
    if (selectedGoal == "Lose Weight") {
      dynamicPrompt = "Target Weight (Currently ${widget.userAnswers.weight?.toInt() ?? 0} ${widget.userAnswers.weightUnit})";
    }

    return RegistrationQuestions(
      numQuestions: 5,
      currentIndex: 4,
      children: [
        const SizedBox(height: 40),
        const Text("What is your Main Goal?", style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold, fontFamily: "LexendExaNormal"), textAlign: TextAlign.center),
        const SizedBox(height: 10),
        const Text("HealthMax works best when we know what you're aiming for.", style: TextStyle(color: Colors.black54, fontSize: 14), textAlign: TextAlign.center),
        const SizedBox(height: 30),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            spacing: 10, runSpacing: 10, alignment: WrapAlignment.center,
            children: commonGoals.map((goal) {
              bool isSelected = selectedGoal == goal["title"];
              return ChoiceChip(
                label: Text("${goal["icon"]} ${goal["title"]}", style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87)),
                selected: isSelected, selectedColor: themePurple, backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? themePurple : Colors.grey.shade300, width: 2)),
                onSelected: (selected) {
                  setState(() {
                    selectedGoal = selected ? goal["title"] : null;
                    _targetCtrl.clear();
                  });
                },
              );
            }).toList(),
          ),
        ),

        if (selectedGoal != null) ...[
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: TextField(
              controller: _targetCtrl, keyboardType: TextInputType.number, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900), textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: dynamicPrompt, labelStyle: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.bold),
                floatingLabelBehavior: FloatingLabelBehavior.always, filled: true, fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey.shade300, width: 2)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: themePurple, width: 2)),
                suffixText: commonGoals.firstWhere((g) => g["title"] == selectedGoal, orElse: () => {"unit": ""})["unit"],
                suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            ),
          ),
        ],

        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade300, thickness: 2, indent: 40, endIndent: 10)),
            const Text("OR", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w900)),
            Expanded(child: Divider(color: Colors.grey.shade300, thickness: 2, indent: 10, endIndent: 40)),
          ],
        ),
        const SizedBox(height: 30),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Container(
            decoration: BoxDecoration(boxShadow: [BoxShadow(color: themePurple.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))]),
            child: TextField(
              controller: _aiChatCtrl, style: const TextStyle(fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Tell AI your goal (e.g. "I want to run a 5k")', hintStyle: const TextStyle(color: Colors.black38, fontSize: 13, fontWeight: FontWeight.w500),
                filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: _isAiThinking ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: themePurple, strokeWidth: 2)) : Icon(Icons.auto_awesome, color: themePurple),
                    onPressed: _isAiThinking ? null : _submitAiPrompt,
                  ),
                ),
              ),
              onSubmitted: (_) { if (!_isAiThinking) _submitAiPrompt(); },
            ),
          ),
        ),

        const SizedBox(height: 60),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ElevatedButton(
            onPressed: () => _finishRegistration(false),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFB300), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 8, shadowColor: const Color(0xFFFFB300).withValues(alpha: 0.6)),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("Complete Registration", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, fontFamily: "LexendExaNormal", letterSpacing: 0.5)), SizedBox(width: 10), Icon(Icons.check_circle_rounded, size: 24)]),
          ),
        ),

        const SizedBox(height: 15),
        TextButton(onPressed: () => _finishRegistration(true), child: const Text("I don't have a specific goal yet (Skip)", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, decoration: TextDecoration.underline))),
        const SizedBox(height: 40),
      ],
    );
  }
}