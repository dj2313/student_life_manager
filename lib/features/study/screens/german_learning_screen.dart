import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/study_provider.dart';
import 'package:intl/intl.dart';

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
                _buildProgressCard(context, provider),
                SizedBox(height: 32.h),
                _buildSectionTitle('LEVEL STATUS'),
                SizedBox(height: 16.h),
                _buildLevelGrid(context, provider),
                SizedBox(height: 32.h),
                _buildSectionTitle('STUDY GOALS'),
                SizedBox(height: 16.h),
                ...provider.goals
                    .map((goal) => _buildGoalCard(context, goal))
                    .toList(),
                SizedBox(height: 32.h),
                _buildSectionTitle('RECENT SESSIONS'),
                SizedBox(height: 16.h),
                ...provider.sessions
                    .map((session) => _buildSessionTile(context, session))
                    .toList(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {}, // Add session dialog
        label: const Text('New Session'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 11.sp,
        fontWeight: FontWeight.w800,
        color: AppColors.textTertiaryLight,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, StudyProvider provider) {
    final progress = provider.hoursLoggedThisWeek / provider.weeklyTargetHours;
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                    'Level ${provider.germanLevel}',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${provider.hoursLoggedThisWeek}h / ${provider.weeklyTargetHours}h',
                    style: GoogleFonts.outfit(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_graph_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 12.h,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.secondary,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Keep going! ${(progress * 100).toInt()}% of weekly goal achieved.',
            style: GoogleFonts.inter(color: Colors.white, fontSize: 12.sp),
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
      mainAxisSpacing: 12.w,
      crossAxisSpacing: 12.w,
      childAspectRatio: 1,
      children: provider.germanProgress.entries.map((entry) {
        final level = entry.key;
        final status = entry.value;
        final isCurrent = provider.germanLevel == level;

        Color bgColor;
        Color textColor;
        IconData? icon;

        switch (status) {
          case 'Cleared':
            bgColor = AppColors.primary.withOpacity(0.1);
            textColor = AppColors.primary;
            icon = Icons.check_circle_rounded;
            break;
          case 'Completed':
            bgColor = AppColors.secondary.withOpacity(0.1);
            textColor = AppColors.secondary;
            icon = Icons.stars_rounded;
            break;
          default:
            bgColor = Theme.of(context).cardTheme.color!;
            textColor = AppColors.textSecondaryLight;
            icon = null;
        }

        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20.r),
            border: isCurrent
                ? Border.all(color: AppColors.primary, width: 2)
                : Border.all(color: Theme.of(context).dividerColor),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: textColor, size: 20.sp),
                SizedBox(height: 4.h),
              ],
              Text(
                level,
                style: GoogleFonts.outfit(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isCurrent ? AppColors.primary : textColor,
                ),
              ),
              Text(
                status,
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: textColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        );
      }).toList(),
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
              color: AppColors.textSecondaryLight,
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
                    color: AppColors.textSecondaryLight,
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
}
