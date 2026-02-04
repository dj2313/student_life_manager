import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/study_provider.dart';
import '../../../data/models/lecture.dart';
import 'german_learning_screen.dart';
import 'uni_schedule_screen.dart';
import 'add_university_screen.dart';
import '../providers/gpa_provider.dart';
import './gpa_manager_screen.dart';
import './ai_assistant_screen.dart';
import '../../../core/utils/context_extensions.dart';

class StudyDashboard extends StatelessWidget {
  const StudyDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudyProvider>(
      builder: (context, studyProvider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStudyStatus(context, studyProvider),
                      SizedBox(height: 24.h),
                      _buildGPAQuickAccess(context),
                      SizedBox(height: 32.h),

                      _buildSectionTitle(context, 'Active Preparation'),
                      SizedBox(height: 16.h),
                      _buildGermanFocusCard(context),
                      SizedBox(height: 24.h),
                      _buildAIQuickAccess(context),
                      SizedBox(height: 32.h),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionTitle(context, 'University Hub'),
                          IconButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AddUniversityScreen(),
                              ),
                            ),
                            icon: Icon(
                              Icons.add_circle_outline_rounded,
                              color: AppColors.primary,
                              size: 24.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildUniSelectionCard(
                              context,
                              'Language',
                              Icons.translate_rounded,
                              AppColors.secondary,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const GermanLearningScreen(),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildUniSelectionCard(
                              context,
                              'Public',
                              Icons.account_balance_rounded,
                              AppColors.primary,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const UniScheduleScreen(
                                    uniType: 'Public',
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildUniSelectionCard(
                              context,
                              'Private',
                              Icons.business_rounded,
                              AppColors.accent,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const UniScheduleScreen(
                                    uniType: 'Private',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32.h),
                      _buildSectionTitle(context, 'Today\'s Lectures'),
                      SizedBox(height: 16.h),
                      ...studyProvider.todayLectures.map(
                        (lecture) => _buildLectureItem(
                          context,
                          lecture,
                          lecture.subject == 'German A2'
                              ? AppColors.secondary
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 100.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Education',
        style: GoogleFonts.outfit(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildStudyStatus(BuildContext context, StudyProvider provider) {
    final textColor = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Learning Velocity',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: AppColors.textSecondaryLight,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Text(
              provider.hoursLoggedThisWeek.toString(),
              style: GoogleFonts.outfit(
                fontSize: 48.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            SizedBox(width: 8.w),
            Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: Text(
                'hours logged this week',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildGermanFocusCard(BuildContext context) {
    final cardColor = Theme.of(context).cardTheme.color;
    final textColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () {
        context.hapticClick();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GermanLearningScreen()),
        );
      },

      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: Theme.of(context).dividerColor),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.translate_rounded,
                    color: AppColors.secondary,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'German A2',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      Text(
                        'Class with Kalpesh Sir',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14.sp,
                  color: AppColors.textTertiaryLight,
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFocusStat(context, 'Goal', 'B1 Level'),
                _buildFocusStat(context, 'Streak', '14 Days'),
                _buildFocusStat(context, 'Next', 'Tomorrow'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusStat(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            color: AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildUniSelectionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final cardColor = Theme.of(context).cardTheme.color;
    final textColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () {
        context.hapticClick();
        onTap();
      },

      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLectureItem(
    BuildContext context,
    Lecture lecture,
    Color accentColor,
  ) {
    final cardColor = Theme.of(context).cardTheme.color;
    final textColor = Theme.of(context).colorScheme.primary;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 16.w),
          Text(
            lecture.time,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(width: 24.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lecture.subject,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                Text(
                  lecture.room,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGPAQuickAccess(BuildContext context) {
    return Consumer<GPAProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.05),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  provider.currentGPA.toStringAsFixed(1),
                  style: GoogleFonts.outfit(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Academic Progress',
                      style: GoogleFonts.outfit(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${provider.totalCredits} ECTS earned so far',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GPAManagerScreen(),
                  ),
                ),
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAIQuickAccess(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.hapticClick();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AIStudyAssistantScreen(),
          ),
        );
      },

      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.accent,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Study Assistant',
                    style: GoogleFonts.outfit(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Summarize notes & generate flashcards',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}
