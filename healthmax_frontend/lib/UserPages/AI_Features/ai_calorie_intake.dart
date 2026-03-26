import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'calorie_estimate_service.dart';
import 'nutrition_result_model.dart';

class CaloriePage extends StatefulWidget {
  const CaloriePage({super.key});
  @override
  State<CaloriePage> createState() => _CaloriePageState();
}

class _CaloriePageState extends State<CaloriePage> {
  final _service = CalorieEstimatorService();
  final _textController = TextEditingController();
  NutritionResult? _result;
  bool _loading = false;
  String? _error;

  Future<void> _analyzeText() async {
    if (_textController.text.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _service.estimateFromText(_textController.text);
      setState(() => _result = result);
    } catch (e) {
      print(e.toString());
      setState(() => _error = 'Could not estimate. Try again.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _analyzeImage() async {
    // Show a bottom sheet to let user choose source
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Image Source',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5BA4F5).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Color(0xFF5BA4F5),
                ),
              ),
              title: const Text(
                'Camera',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Take a new photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB300).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.photo_library_rounded,
                  color: Color(0xFFFFB300),
                ),
              ),
              title: const Text(
                'Gallery',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Choose an existing photo'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    // User dismissed the bottom sheet without choosing
    if (source == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source, // <-- uses whichever the user picked
        imageQuality: 85, // compress slightly to save tokens
      );
      if (picked == null) return;

      final result = await _service.estimateFromImage(File(picked.path));
      setState(() => _result = result);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FF),
      appBar: AppBar(
        title: const Text(
          'Calorie Estimator',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: const Color(0xFF5BA4F5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Input card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'e.g. "2 boiled eggs and toast with butter"',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFEAF3FF),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _loading ? null : _analyzeText,
                          icon: const Icon(Icons.search),
                          label: const Text('Estimate'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5BA4F5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: _loading ? null : _analyzeImage,
                        icon: const Icon(Icons.camera_alt_rounded),
                        label: const Text('Photo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB300),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (_loading) ...[
              const SizedBox(height: 40),
              const CircularProgressIndicator(color: Color(0xFF5BA4F5)),
              const SizedBox(height: 12),
              const Text('Analyzing with AI...'),
            ],

            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            ],

            // Results
            if (_result != null) ...[
              const SizedBox(height: 20),
              _ResultCard(result: _result!),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final NutritionResult result;
  const _ResultCard({required this.result});

  Color _confidenceColor(String confidence) {
    // Handle both "high/medium/low" and percentage formats like "85.0%"
    final lower = confidence.toLowerCase();
    if (lower.contains('%')) {
      final value = double.tryParse(lower.replaceAll('%', '').trim()) ?? 0;
      if (value >= 75) return const Color(0xFF4CAF50);
      if (value >= 50) return const Color(0xFFFFB300);
      return const Color(0xFFEF5350);
    }
    if (lower.contains('high')) return const Color(0xFF4CAF50);
    if (lower.contains('medium')) return const Color(0xFFFFB300);
    return const Color(0xFFEF5350);
  }

  IconData _confidenceIcon(String confidence) {
    final lower = confidence.toLowerCase();
    if (lower.contains('%')) {
      final value = double.tryParse(lower.replaceAll('%', '').trim()) ?? 0;
      if (value >= 75) return Icons.check_circle_rounded;
      if (value >= 50) return Icons.warning_amber_rounded;
      return Icons.cancel_rounded;
    }
    if (lower.contains('high')) return Icons.check_circle_rounded;
    if (lower.contains('medium')) return Icons.warning_amber_rounded;
    return Icons.cancel_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final confidenceColor = _confidenceColor(result.confidence);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Confidence banner ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: confidenceColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: confidenceColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  _confidenceIcon(result.confidence),
                  color: confidenceColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Confidence: ${result.confidence}',
                  style: TextStyle(
                    color: confidenceColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Total calories hero ──
          Center(
            child: Column(
              children: [
                Text(
                  '${result.totalCalories}',
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFF9800),
                  ),
                ),
                const Text(
                  'Total Calories (kcal)',
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Macros row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MacroChip(
                'Protein',
                '${result.totalProtein.toStringAsFixed(1)}g',
                const Color(0xFF5BA4F5),
              ),
              _MacroChip(
                'Carbs',
                '${result.totalCarbs.toStringAsFixed(1)}g',
                const Color(0xFF4CAF50),
              ),
              _MacroChip(
                'Fat',
                '${result.totalFat.toStringAsFixed(1)}g',
                const Color(0xFFEF5350),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // ── Per-food breakdown ──
          const Text(
            'Breakdown',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ...result.foods.map(
            (food) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  const Icon(
                    Icons.restaurant_menu_rounded,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${food.name} (${food.amount})',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  Text(
                    '${food.calories} kcal',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Notes ──
          if (result.notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Notes',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Color(0xFF5BA4F5),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.notes,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MacroChip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
      ],
    );
  }
}
