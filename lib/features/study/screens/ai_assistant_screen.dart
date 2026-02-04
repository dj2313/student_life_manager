import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../data/models/student_os_models.dart';
import '../providers/study_assistant_provider.dart';

class AIStudyAssistantScreen extends StatefulWidget {
  const AIStudyAssistantScreen({super.key});

  @override
  State<AIStudyAssistantScreen> createState() => _AIStudyAssistantScreenState();
}

class _AIStudyAssistantScreenState extends State<AIStudyAssistantScreen> {
  final TextEditingController _termController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final AIService _aiService = AIService();

  String _translationResult = '';
  List<String> _summaries = [];
  List<Map<String, String>> _flashcards = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AI Study Assistant',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTranslatorSection(),
            SizedBox(height: 32.h),
            _buildSummarizerSection(),
            if (_summaries.isNotEmpty) _buildSummaryResult(),
            if (_flashcards.isNotEmpty) _buildFlashcardsResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslatorSection() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Student German Translator',
            style: GoogleFonts.outfit(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: _termController,
            decoration: InputDecoration(
              hintText: 'Enter term (e.g. Zulassung)',
              suffixIcon: IconButton(
                icon: const Icon(Icons.translate, color: AppColors.primary),
                onPressed: () {
                  context.hapticClick();
                  setState(() {
                    _translationResult = _aiService.translateTerm(
                      _termController.text,
                    );
                  });
                },
              ),
            ),
          ),
          if (_translationResult.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                _translationResult,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummarizerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Note Summarizer & Flashcards',
          style: GoogleFonts.outfit(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        TextField(
          controller: _noteController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Paste your lecture notes here...',
            fillColor: Theme.of(context).cardTheme.color,
            filled: true,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleSummarize,
                icon: const Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text(
                  'Summarize',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _handleFlashcards,
                icon: const Icon(Icons.style_outlined, size: 18),
                label: const Text('Flashcards'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleSummarize() async {
    if (_noteController.text.isEmpty) return;
    context.hapticClick();
    setState(() => _isLoading = true);
    final results = await _aiService.summarizeNote(_noteController.text);

    final aiResult = AIResult(
      id: '',
      summary:
          'Summary for: ${_noteController.text.substring(0, _noteController.text.length > 20 ? 20 : _noteController.text.length)}...',
      bulletPoints: results,
      flashcards: [],
      timestamp: DateTime.now(),
    );

    if (mounted) {
      await context.read<StudyAssistantProvider>().saveResult(aiResult);
      context.hapticSuccess();
    }

    setState(() {
      _summaries = results;
      _isLoading = false;
    });
  }

  Future<void> _handleFlashcards() async {
    if (_noteController.text.isEmpty) return;
    context.hapticClick();
    setState(() => _isLoading = true);
    final cards = await _aiService.generateFlashcards(_noteController.text);

    final flashcards = cards
        .map((c) => Flashcard(front: c['front']!, back: c['back']!))
        .toList();
    final aiResult = AIResult(
      id: '',
      summary:
          'Flashcards for: ${_noteController.text.substring(0, _noteController.text.length > 20 ? 20 : _noteController.text.length)}...',
      bulletPoints: [],
      flashcards: flashcards,
      timestamp: DateTime.now(),
    );

    if (mounted) {
      await context.read<StudyAssistantProvider>().saveResult(aiResult);
      context.hapticSuccess();
    }

    setState(() {
      _flashcards = cards;
      _isLoading = false;
    });
  }

  Widget _buildSummaryResult() {
    return Container(
      margin: EdgeInsets.only(top: 24.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.success.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Takeaways',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
          SizedBox(height: 12.h),
          ..._summaries.map(
            (s) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(s, style: GoogleFonts.inter(fontSize: 13.sp)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcardsResult() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.h),
        Text(
          'Generated Flashcards',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 150.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _flashcards.length,
            separatorBuilder: (_, __) => SizedBox(width: 16.w),
            itemBuilder: (context, index) {
              return Container(
                width: 220.w,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _flashcards[index]['front']!,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Divider(color: Colors.white24, height: 24.h),
                    Text(
                      _flashcards[index]['back']!,
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 12.sp,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
