import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/study_provider.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../data/models/study_models.dart';

class GermanLearningScreen extends StatelessWidget {
  const GermanLearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'German Learning',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<StudyProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressCard(
                  context,
                  provider,
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
                SizedBox(height: 24.h),
                _buildFeesCard(
                  context,
                  provider,
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                SizedBox(height: 32.h),
                _buildSectionTitle(
                  context,
                  'LEVEL STATUS',
                ).animate().fadeIn(delay: 300.ms),
                SizedBox(height: 16.h),
                _buildLevelGrid(context, provider)
                    .animate()
                    .fadeIn(delay: 400.ms)
                    .scale(begin: const Offset(0.95, 0.95)),
                SizedBox(height: 32.h),
                _buildSectionTitle(context, 'STUDY GOALS'),
                SizedBox(height: 16.h),
                ...provider.goals
                    .map((goal) => _buildGoalCard(context, goal))
                    .toList(),
                SizedBox(height: 32.h),
                _buildSectionTitle(context, 'RECENT SESSIONS'),
                SizedBox(height: 16.h),
                ...provider.sessions
                    .map((session) => _buildSessionTile(context, session))
                    .toList(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Consumer<StudyProvider>(
        builder: (context, provider, child) => FloatingActionButton.extended(
          onPressed: () {
            context.hapticClick();
            _showAddSessionSheet(context, provider);
          },
          label: const Text('New Session'),
          icon: const Icon(Icons.add),
          backgroundColor: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 11.sp,
        fontWeight: FontWeight.w800,
        color: context.textTertiary,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, StudyProvider provider) {
    final progress = provider.hoursLoggedThisWeek / provider.weeklyTargetHours;
    return Container(
      padding: EdgeInsets.all(28.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withBlue(255)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GERMAN LEVEL: ${provider.germanLevel}',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withOpacity(0.7),
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${provider.hoursLoggedThisWeek} / ${provider.weeklyTargetHours} hrs',
                    style: GoogleFonts.outfit(
                      fontSize: 34.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Stack(
            children: [
              Container(
                height: 10.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5.r),
                ),
              ),
              AnimatedFractionallySizedBox(
                duration: 1.seconds,
                widthFactor: progress.clamp(0.01, 1.0),
                child: Container(
                  height: 10.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.secondary, Color(0xFFFBDB6B)],
                    ),
                    borderRadius: BorderRadius.circular(5.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Velocity: ${(progress * 100).toInt()}% towards goal',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (provider.examDates.containsKey(provider.germanLevel))
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'Exam: ${DateFormat('MMM dd').format(provider.examDates[provider.germanLevel]!)}',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeesCard(BuildContext context, StudyProvider provider) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.payments_outlined,
              color: AppColors.success,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Class Fees',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: context.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '€${provider.germanClassFees.toStringAsFixed(2)}',
                  style: GoogleFonts.outfit(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showUpdateFeesDialog(context, provider),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showUpdateFeesDialog(BuildContext context, StudyProvider provider) {
    final controller = TextEditingController(
      text: provider.germanClassFees.toString(),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Class Fees'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Fees (€)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final fees = double.tryParse(controller.text) ?? 0;
              provider.updateGermanFees(fees);
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelGrid(BuildContext context, StudyProvider provider) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 14.w,
      crossAxisSpacing: 14.w,
      childAspectRatio: 1,
      children: provider.germanProgress.entries.map((entry) {
        final level = entry.key;
        final status = entry.value;
        final isCurrent = provider.germanLevel == level;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        Color accentColor;
        IconData? icon;

        switch (status) {
          case 'Cleared':
            accentColor = AppColors.primary;
            icon = Icons.verified_rounded;
            break;
          case 'Running':
            accentColor = AppColors.accent;
            icon = Icons.bolt_rounded;
            break;
          case 'Completed':
            accentColor = AppColors.secondary;
            icon = Icons.emoji_events_rounded;
            break;
          default:
            accentColor = AppColors.textTertiaryLight;
            icon = Icons.lock_outline_rounded;
        }

        return GestureDetector(
          onTap: () {
            context.hapticClick();
            _showLevelStatusDialog(context, provider, level);
          },
          child: Container(
            decoration: BoxDecoration(
              color: isCurrent
                  ? accentColor.withOpacity(0.1)
                  : (isDark ? Colors.white.withOpacity(0.02) : Colors.white),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: isCurrent
                    ? accentColor
                    : (isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.035)),
                width: isCurrent ? 2 : 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isCurrent || status != 'Pending'
                      ? accentColor
                      : accentColor.withOpacity(0.3),
                  size: 22.sp,
                ),
                SizedBox(height: 8.h),
                Text(
                  level,
                  style: GoogleFonts.outfit(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: isCurrent || status != 'Pending'
                        ? accentColor
                        : accentColor.withOpacity(0.35),
                  ),
                ),
                Text(
                  status.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: isCurrent || status != 'Pending'
                        ? accentColor.withOpacity(0.7)
                        : accentColor.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showLevelStatusDialog(
    BuildContext context,
    StudyProvider provider,
    String level,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: ['Cleared', 'Running', 'Completed', 'Pending'].map((status) {
          return ListTile(
            title: Text(status),
            onTap: () {
              provider.updateLevelStatus(level, status);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, dynamic goal) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                goal.title,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                ),
              ),
              const Icon(Icons.flag_rounded, color: AppColors.secondary),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Deadline: ${DateFormat('MMM dd').format(goal.deadline)}',
            style: GoogleFonts.inter(
              color: context.textSecondary,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 16.h),
          LinearProgressIndicator(
            value: goal.currentProgress / goal.targetProgress,
            backgroundColor: Theme.of(context).dividerColor,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            borderRadius: BorderRadius.circular(4.r),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionTile(BuildContext context, dynamic session) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: const Icon(Icons.history_rounded, color: AppColors.primary),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.topicsCovered,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  '${DateFormat('MMM dd').format(session.date)} • ${session.durationHours} hours',
                  style: GoogleFonts.inter(
                    color: context.textSecondary,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSessionSheet(BuildContext context, StudyProvider provider) {
    final topicsController = TextEditingController();
    final hoursController = TextEditingController(text: '1.0');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24.w,
          right: 24.w,
          top: 24.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Study Session',
              style: GoogleFonts.outfit(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24.h),
            TextField(
              controller: topicsController,
              decoration: const InputDecoration(labelText: 'Topics Covered'),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: hoursController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Hours'),
            ),
            SizedBox(height: 32.h),
            ElevatedButton(
              onPressed: () {
                final session = GermanSession(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  date: DateTime.now(),
                  durationHours: double.tryParse(hoursController.text) ?? 1.0,
                  topicsCovered: topicsController.text,
                );
                provider.logSession(session);
                Navigator.pop(context);
              },
              child: const Text('Save Session'),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
