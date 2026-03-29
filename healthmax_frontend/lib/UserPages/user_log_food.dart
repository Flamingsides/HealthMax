import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../theme_provider.dart';
import 'user_bottomnavbar.dart';
import 'AI_Features/calorie_estimate_service.dart';
import 'AI_Features/nutrition_result_model.dart';
import 'calorie_provider.dart';

class UserLogFoodPage extends StatefulWidget {
  const UserLogFoodPage({super.key});

  @override
  State<UserLogFoodPage> createState() => _UserLogFoodPageState();
}

class _UserLogFoodPageState extends State<UserLogFoodPage> {
  final Color themeBlue = const Color(0xFF5A84F1);
  final Color actionGreen = const Color(0xFF55FF55);

  // --- STATE ---
  bool _isAiMode = true;
  File? _selectedImage;

  // --- AI STATE ---
  final _service = CalorieEstimatorService();
  final _textController = TextEditingController();
  NutritionResult? _result;
  bool _loading = false;
  String? _error;

  // --- MANUAL STATE ---
  final _manualNameCtrl = TextEditingController();
  final _manualCalCtrl = TextEditingController();
  final _manualCarbCtrl = TextEditingController();
  final _manualProteinCtrl = TextEditingController();
  final _manualFatCtrl = TextEditingController();
  final _manualCommentCtrl = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    _manualNameCtrl.dispose();
    _manualCalCtrl.dispose();
    _manualCarbCtrl.dispose();
    _manualProteinCtrl.dispose();
    _manualFatCtrl.dispose();
    _manualCommentCtrl.dispose();
    super.dispose();
  }

  // ==========================================
  // AI LOGIC
  // ==========================================
  Future<void> _analyzeText() async {
    if (_textController.text.trim().isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final result = await _service.estimateFromText(_textController.text);
      setState(() => _result = result);
    } catch (e) {
      setState(() => _error = 'Could not estimate. Try again.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickAndAnalyzeImage() async {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textPrimary = Theme.of(context).colorScheme.onSurface;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.fromLTRB(25, 10, 25, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4, margin: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
            ),
            Text('Select Image Source', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: textPrimary, fontFamily: "LexendExaNormal")),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: themeBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.camera_alt_rounded, color: themeBlue),
              ),
              title: Text('Camera', style: TextStyle(fontWeight: FontWeight.w800, color: textPrimary)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFFF9F43).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.photo_library_rounded, color: Color(0xFFFF9F43)),
              ),
              title: Text('Gallery', style: TextStyle(fontWeight: FontWeight.w800, color: textPrimary)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    setState(() {
      _selectedImage = File(picked.path);
      _loading = true;
      _error = null;
      _result = null;
    });

    try {
      final result = await _service.estimateFromImage(_selectedImage!);
      setState(() => _result = result);
    } catch (e) {
      setState(() => _error = 'Image analysis failed. Please try again.');
    } finally {
      setState(() => _loading = false);
    }
  }

  // Helper method to color-code the AI Confidence
  Color _getConfidenceColor(String confidence) {
    final lower = confidence.toLowerCase();
    if (lower.contains('%')) {
      final value = double.tryParse(lower.replaceAll('%', '').trim()) ?? 0;
      if (value >= 75) return const Color(0xFF2ED573); // Green
      if (value >= 50) return const Color(0xFFFFB300); // Orange
      return const Color(0xFFFF4757); // Red
    }
    if (lower.contains('high')) return const Color(0xFF2ED573);
    if (lower.contains('medium')) return const Color(0xFFFFB300);
    return const Color(0xFFFF4757);
  }

  // ==========================================
  // MAIN UI
  // ==========================================
  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    final scaffoldBg = isDark ? const Color(0xFF12121A) : const Color(0xFF1A1F2C);
    final cardColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE8ECEF);
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.white54 : Colors.black54;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // --- DYNAMIC FLOATING BACK BUTTON ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1), 
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                    ),
                    child: const Icon(Icons.undo_rounded, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),

            // --- THE MAIN CARD ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(35),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 25, 20, 15),
                        child: Text("Log Food.", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textPrimary, fontFamily: "LexendExaNormal", letterSpacing: -1.0)),
                      ),

                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        height: 45,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black26 : Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: isDark ? Border.all(color: Colors.white10) : Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            _buildTab("AI Assist", _isAiMode, () => setState(() => _isAiMode = true), textPrimary, isDark),
                            _buildTab("Manual Write", !_isAiMode, () => setState(() => _isAiMode = false), textPrimary, isDark),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: _isAiMode ? _buildAiTab(textPrimary, textSecondary, isDark) : _buildManualTab(textPrimary, textSecondary, isDark),
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          if (_isAiMode) {
                            if (_result == null) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please analyze food first!"), backgroundColor: Colors.redAccent));
                              return;
                            }

                            final newRecord = CalorieRecord(
                              _result!.label,
                              _result!.servings,
                              "${_result!.totalProtein.toStringAsFixed(0)}g",
                              "${_result!.totalCarbs.toStringAsFixed(0)}g",
                              "${_result!.totalFat.toStringAsFixed(0)}g",
                              _result!.totalCalories,
                              Icons.auto_awesome,
                              themeBlue,
                              DateTime.now(), 
                            );

                            Provider.of<CalorieProvider>(context, listen: false).addFoodRecord(newRecord);
                            Navigator.pop(context);
                          } else {
                            if (_manualNameCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a meal name!"), backgroundColor: Colors.redAccent));
                              return;
                            }

                            int calories = int.tryParse(_manualCalCtrl.text.trim()) ?? 0;
                            String protein = _manualProteinCtrl.text.trim().isEmpty ? "0g" : "${_manualProteinCtrl.text.trim()}g";
                            String carbs = _manualCarbCtrl.text.trim().isEmpty ? "0g" : "${_manualCarbCtrl.text.trim()}g";
                            String fats = _manualFatCtrl.text.trim().isEmpty ? "0g" : "${_manualFatCtrl.text.trim()}g";

                            final newRecord = CalorieRecord(
                              _manualNameCtrl.text.trim(),
                              1, protein, carbs, fats, calories, 
                              Icons.restaurant, const Color(0xFF2ED573), DateTime.now(),
                            );

                            Provider.of<CalorieProvider>(context, listen: false).addFoodRecord(newRecord);
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          width: double.infinity, height: 65,
                          decoration: BoxDecoration(color: actionGreen, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_rounded, color: Colors.black87, size: 24),
                              const SizedBox(width: 8),
                              const Text("Add to My Intake", style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w800, fontFamily: "LexendExaNormal")),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20), 
          ],
        ),
      ),
      bottomNavigationBar: const UserBottomNavBar(currentIndex: 2), 
    );
  }

  // ==========================================
  // WIDGET HELPERS
  // ==========================================

  Widget _buildTab(String title, bool isActive, VoidCallback onTap, Color textPrimary, bool isDark) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive ? (isDark ? Colors.white12 : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: isActive && !isDark ? Border.all(color: Colors.grey.shade300) : null,
            boxShadow: isActive && !isDark ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : [],
          ),
          alignment: Alignment.center,
          child: Text(title, style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.w600, color: isActive ? textPrimary : textPrimary.withOpacity(0.5), fontSize: 12, fontFamily: "LexendExaNormal")),
        ),
      ),
    );
  }

  // ==========================================
  // AI TAB UI
  // ==========================================
  Widget _buildAiTab(Color textPrimary, Color textSecondary, bool isDark) {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickAndAnalyzeImage,
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.white,
              borderRadius: BorderRadius.circular(20),
              image: _selectedImage != null ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover) : null,
              border: _selectedImage == null ? Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300) : null,
            ),
            child: _selectedImage == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fastfood_rounded, size: 40, color: textPrimary.withOpacity(0.2)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(color: isDark ? Colors.black54 : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: textPrimary.withOpacity(0.2))),
                        child: Text("upload or take a picture", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textPrimary)),
                      ),
                    ],
                  )
                : Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white54)),
                      child: const Text("Retake picture", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 15),

        TextField(
          controller: _textController,
          style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: 'or describe your meal here',
            hintStyle: TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
            filled: true, fillColor: isDark ? Colors.white10 : Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            suffixIcon: IconButton(icon: Icon(Icons.send_rounded, color: themeBlue), onPressed: _loading ? null : _analyzeText),
          ),
          onSubmitted: (_) { if (!_loading) _analyzeText(); },
        ),

        const SizedBox(height: 25),

        Row(
          children: [
            Expanded(child: Divider(color: textPrimary.withOpacity(0.2), thickness: 1.5)),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text("AI Estimation", style: TextStyle(fontWeight: FontWeight.w900, color: textPrimary, fontSize: 12, fontFamily: "LexendExaNormal"))),
            Expanded(child: Divider(color: textPrimary.withOpacity(0.2), thickness: 1.5)),
          ],
        ),

        const SizedBox(height: 25),

        if (_loading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(color: themeBlue),
                  const SizedBox(height: 15),
                  Text("Analyzing food data...", style: TextStyle(color: textSecondary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          )
        else if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text(_error!, style: const TextStyle(color: Color(0xFFFF4757), fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
          )
        else
          Column(
            children: [
              if (_result != null) ...[
                // --- NEW: THE DYNAMIC CONFIDENCE BADGE ---
                Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(_result!.confidence).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: _getConfidenceColor(_result!.confidence).withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _result!.confidence.toLowerCase().contains('high') || _result!.confidence.contains(RegExp(r'[7-9][0-9]')) 
                          ? Icons.check_circle_rounded 
                          : Icons.warning_amber_rounded,
                        size: 14, 
                        color: _getConfidenceColor(_result!.confidence)
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "AI Confidence: ${_result!.confidence}",
                        style: TextStyle(
                          color: _getConfidenceColor(_result!.confidence),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              _buildResultRow("Calories :", _result != null ? "${_result!.totalCalories} kcal" : "--- kcal", textPrimary, isBold: true),
              _buildResultRow("Carbohydrates :", _result != null ? "${_result!.totalCarbs.toStringAsFixed(0)} g" : "--- g", textPrimary),
              _buildResultRow("Protein :", _result != null ? "${_result!.totalProtein.toStringAsFixed(0)} g" : "--- g", textPrimary),
              _buildResultRow("Fats :", _result != null ? "${_result!.totalFat.toStringAsFixed(0)} g" : "--- g", textPrimary),
              
              // --- NEW: EXPANDABLE AI NOTES SECTION ---
              if (_result != null && _result!.notes.isNotEmpty && _result!.notes.toLowerCase() != "none") ...[
                const SizedBox(height: 10),
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent), // Hides the ugly default expansion lines
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    iconColor: themeBlue,
                    collapsedIconColor: textSecondary,
                    title: Text("AI Analysis Notes", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textPrimary)),
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline_rounded, size: 18, color: textSecondary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _result!.notes,
                                style: TextStyle(fontSize: 12, color: textPrimary, height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ]
            ],
          ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildResultRow(String label, String value, Color textPrimary, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 15, fontWeight: isBold ? FontWeight.w800 : FontWeight.w500, color: textPrimary)),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: isBold ? FontWeight.w800 : FontWeight.w500, color: textPrimary)),
        ],
      ),
    );
  }

  // ==========================================
  // MANUAL TAB UI
  // ==========================================
  Widget _buildManualTab(Color textPrimary, Color textSecondary, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildManualInput(label: null, hint: "Meal Name", controller: _manualNameCtrl, textPrimary: textPrimary, textSecondary: textSecondary, isDark: isDark),
        const SizedBox(height: 25),
        _buildManualInput(label: "Calories :", hint: "Enter in gram", controller: _manualCalCtrl, textPrimary: textPrimary, textSecondary: textSecondary, isDark: isDark, isNumber: true),
        const SizedBox(height: 15),
        _buildManualInput(label: "Carbohydrates :", hint: "Enter in gram", controller: _manualCarbCtrl, textPrimary: textPrimary, textSecondary: textSecondary, isDark: isDark, isNumber: true),
        const SizedBox(height: 15),
        _buildManualInput(label: "Protein :", hint: "Enter in gram", controller: _manualProteinCtrl, textPrimary: textPrimary, textSecondary: textSecondary, isDark: isDark, isNumber: true),
        const SizedBox(height: 15),
        _buildManualInput(label: "Fats :", hint: "Enter in gram", controller: _manualFatCtrl, textPrimary: textPrimary, textSecondary: textSecondary, isDark: isDark, isNumber: true),
        const SizedBox(height: 25),

        TextField(
          controller: _manualCommentCtrl,
          style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary),
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'add a comment..',
            hintStyle: TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
            filled: true, fillColor: isDark ? Colors.white10 : const Color(0xFFD9D9D9), 
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(20),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildManualInput({String? label, required String hint, required TextEditingController controller, required Color textPrimary, required Color textSecondary, required bool isDark, bool isNumber = false}) {
    return Row(
      children: [
        if (label != null) Expanded(flex: 4, child: Text(label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: textPrimary))),
        Expanded(
          flex: 5,
          child: SizedBox(
            height: 40,
            child: TextField(
              controller: controller, keyboardType: isNumber ? TextInputType.number : TextInputType.text,
              style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary, fontSize: 13), textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: hint, hintStyle: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                filled: true, fillColor: isDark ? Colors.white10 : const Color(0xFFD9D9D9), 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}