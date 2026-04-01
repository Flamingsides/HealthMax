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

  bool _isAiMode = true;
  File? _selectedImage;
  final _service = CalorieEstimatorService();
  final _textController = TextEditingController();
  NutritionResult? _result;
  bool _loading = false;
  String? _error;

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
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Text(
              'Select Image Source',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: textPrimary,
                fontFamily: "LexendExaNormal",
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: themeBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.camera_alt_rounded, color: themeBlue),
              ),
              title: Text(
                'Camera',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9F43).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.photo_library_rounded,
                  color: Color(0xFFFF9F43),
                ),
              ),
              title: Text(
                'Gallery',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
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

  Color _getConfidenceColor(String confidence) {
    final lower = confidence.toLowerCase();
    if (lower.contains('%')) {
      final value = double.tryParse(lower.replaceAll('%', '').trim()) ?? 0;
      if (value >= 75) return const Color(0xFF2ED573);
      if (value >= 50) return const Color(0xFFFFB300);
      return const Color(0xFFFF4757);
    }
    if (lower.contains('high')) return const Color(0xFF2ED573);
    if (lower.contains('medium')) return const Color(0xFFFFB300);
    return const Color(0xFFFF4757);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final scaffoldBg = isDark
        ? const Color(0xFF12121A)
        : const Color(0xFF1A1F2C);
    final cardColor = isDark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFE8ECEF);
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.white54 : Colors.black54;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.undo_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
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
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            themeProvider.translate('log_food'),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: textPrimary,
                              fontFamily: "LexendExaNormal",
                              letterSpacing: -1.0,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        height: 45,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black26 : Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: isDark
                              ? Border.all(color: Colors.white10)
                              : Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            _buildTab(
                              themeProvider.translate('ai_assist'),
                              _isAiMode,
                              () => setState(() => _isAiMode = true),
                              textPrimary,
                              isDark,
                            ),
                            _buildTab(
                              themeProvider.translate('manual_write'),
                              !_isAiMode,
                              () => setState(() => _isAiMode = false),
                              textPrimary,
                              isDark,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: _isAiMode
                              ? _buildAiTab(
                                  textPrimary,
                                  textSecondary,
                                  isDark,
                                  themeProvider,
                                )
                              : _buildManualTab(
                                  textPrimary,
                                  textSecondary,
                                  isDark,
                                  themeProvider,
                                ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (_isAiMode) {
                            if (_result == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please analyze food first!"),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
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
                              confidence: _result!.confidence,
                              notes: _result!.notes,
                            );

                            try {
                              await Provider.of<CalorieProvider>(
                                context,
                                listen: false,
                              ).addFoodRecord(newRecord);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Failed to add food. Try again!",
                                  ),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }

                            Navigator.pop(context);
                          } else {
                            if (_manualNameCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please enter a meal name!"),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }

                            int calories =
                                int.tryParse(_manualCalCtrl.text.trim()) ?? 0;
                            String protein =
                                _manualProteinCtrl.text.trim().isEmpty
                                ? "0g"
                                : "${_manualProteinCtrl.text.trim()}g";
                            String carbs = _manualCarbCtrl.text.trim().isEmpty
                                ? "0g"
                                : "${_manualCarbCtrl.text.trim()}g";
                            String fats = _manualFatCtrl.text.trim().isEmpty
                                ? "0g"
                                : "${_manualFatCtrl.text.trim()}g";

                            final newRecord = CalorieRecord(
                              _manualNameCtrl.text.trim(),
                              1,
                              protein,
                              carbs,
                              fats,
                              calories,
                              Icons.restaurant,
                              const Color(0xFF2ED573),
                              DateTime.now(),
                              notes: _manualCommentCtrl.text.trim().isEmpty
                                  ? null
                                  : _manualCommentCtrl.text.trim(),
                            );

                            try {
                              await Provider.of<CalorieProvider>(
                                context,
                                listen: false,
                              ).addFoodRecord(newRecord);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Failed to add food. Try again!",
                                  ),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 65,
                          decoration: BoxDecoration(
                            color: actionGreen,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(35),
                              bottomRight: Radius.circular(35),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check_rounded,
                                color: Colors.black87,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  themeProvider.translate('add_to_intake'),
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: "LexendExaNormal",
                                  ),
                                ),
                              ),
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

  Widget _buildTab(
    String title,
    bool isActive,
    VoidCallback onTap,
    Color textPrimary,
    bool isDark,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? Colors.white12 : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: isActive && !isDark
                ? Border.all(color: Colors.grey.shade300)
                : null,
            boxShadow: isActive && !isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                color: isActive
                    ? textPrimary
                    : textPrimary.withValues(alpha: 0.5),
                fontSize: 12,
                fontFamily: "LexendExaNormal",
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAiTab(
    Color textPrimary,
    Color textSecondary,
    bool isDark,
    ThemeProvider theme,
  ) {
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
              image: _selectedImage != null
                  ? DecorationImage(
                      image: FileImage(_selectedImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
              border: _selectedImage == null
                  ? Border.all(
                      color: isDark ? Colors.white24 : Colors.grey.shade300,
                    )
                  : null,
            ),
            child: _selectedImage == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fastfood_rounded,
                        size: 40,
                        color: textPrimary.withValues(alpha: 0.2),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black54 : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: textPrimary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          theme.translate('upload_or_take'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white54),
                      ),
                      child: Text(
                        theme.translate('retake_picture'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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
            hintText: theme.translate('describe_meal'),
            hintStyle: TextStyle(
              color: textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: isDark ? Colors.white10 : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.send_rounded, color: themeBlue),
              onPressed: _loading ? null : _analyzeText,
            ),
          ),
          onSubmitted: (_) {
            if (!_loading) _analyzeText();
          },
        ),
        const SizedBox(height: 25),
        Row(
          children: [
            Expanded(
              child: Divider(
                color: textPrimary.withValues(alpha: 0.2),
                thickness: 1.5,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  theme.translate('ai_estimation'),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: textPrimary,
                    fontSize: 12,
                    fontFamily: "LexendExaNormal",
                  ),
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: textPrimary.withValues(alpha: 0.2),
                thickness: 1.5,
              ),
            ),
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
                  Text(
                    "Analyzing food data...",
                    style: TextStyle(
                      color: textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                _error!,
                style: const TextStyle(
                  color: Color(0xFFFF4757),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          Column(
            children: [
              if (_result != null) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(
                      _result!.confidence,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: _getConfidenceColor(
                        _result!.confidence,
                      ).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _result!.confidence.toLowerCase().contains('high') ||
                                _result!.confidence.contains(
                                  RegExp(r'[7-9][0-9]'),
                                )
                            ? Icons.check_circle_rounded
                            : Icons.warning_amber_rounded,
                        size: 14,
                        color: _getConfidenceColor(_result!.confidence),
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
              _buildResultRow(
                theme.translate('calories'),
                _result != null ? "${_result!.totalCalories} kcal" : "--- kcal",
                textPrimary,
                isBold: true,
              ),
              _buildResultRow(
                theme.translate('carbohydrates'),
                _result != null
                    ? "${_result!.totalCarbs.toStringAsFixed(0)} g"
                    : "--- g",
                textPrimary,
              ),
              _buildResultRow(
                theme.translate('protein'),
                _result != null
                    ? "${_result!.totalProtein.toStringAsFixed(0)} g"
                    : "--- g",
                textPrimary,
              ),
              _buildResultRow(
                theme.translate('fats'),
                _result != null
                    ? "${_result!.totalFat.toStringAsFixed(0)} g"
                    : "--- g",
                textPrimary,
              ),
              if (_result != null &&
                  _result!.notes.isNotEmpty &&
                  _result!.notes.toLowerCase() != "none") ...[
                const SizedBox(height: 10),
                Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    iconColor: themeBlue,
                    collapsedIconColor: textSecondary,
                    title: Text(
                      theme.translate('ai_analysis_notes'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white10
                              : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 18,
                              color: textSecondary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _result!.notes,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textPrimary,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ],
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildResultRow(
    String label,
    String value,
    Color textPrimary, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
              color: textPrimary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualTab(
    Color textPrimary,
    Color textSecondary,
    bool isDark,
    ThemeProvider theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildManualInput(
          label: null,
          hint: theme.translate('meal_name'),
          controller: _manualNameCtrl,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          isDark: isDark,
        ),
        const SizedBox(height: 25),
        _buildManualInput(
          label: theme.translate('calories'),
          hint: theme.translate('enter_in_gram'),
          controller: _manualCalCtrl,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          isDark: isDark,
          isNumber: true,
        ),
        const SizedBox(height: 15),
        _buildManualInput(
          label: theme.translate('carbohydrates'),
          hint: theme.translate('enter_in_gram'),
          controller: _manualCarbCtrl,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          isDark: isDark,
          isNumber: true,
        ),
        const SizedBox(height: 15),
        _buildManualInput(
          label: theme.translate('protein'),
          hint: theme.translate('enter_in_gram'),
          controller: _manualProteinCtrl,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          isDark: isDark,
          isNumber: true,
        ),
        const SizedBox(height: 15),
        _buildManualInput(
          label: theme.translate('fats'),
          hint: theme.translate('enter_in_gram'),
          controller: _manualFatCtrl,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          isDark: isDark,
          isNumber: true,
        ),
        const SizedBox(height: 25),
        TextField(
          controller: _manualCommentCtrl,
          style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary),
          maxLines: 4,
          decoration: InputDecoration(
            hintText: theme.translate('add_a_comment'),
            hintStyle: TextStyle(
              color: textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: isDark ? Colors.white10 : const Color(0xFFD9D9D9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(20),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildManualInput({
    String? label,
    required String hint,
    required TextEditingController controller,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
    bool isNumber = false,
  }) {
    return Row(
      children: [
        if (label != null)
          Expanded(
            flex: 4,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: textPrimary,
                ),
              ),
            ),
          ),
        Expanded(
          flex: 5,
          child: SizedBox(
            height: 40,
            child: TextField(
              controller: controller,
              keyboardType: isNumber
                  ? TextInputType.number
                  : TextInputType.text,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: textPrimary,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                filled: true,
                fillColor: isDark ? Colors.white10 : const Color(0xFFD9D9D9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
