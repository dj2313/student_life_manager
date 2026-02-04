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
import 'package:flutter_animate/flutter_animate.dart';
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
                      _buildLearningVelocity(context, studyProvider)
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.1, end: 0),
                      SizedBox(height: 24.h),
                      _buildAcademicProgressRow(context)
                          .animate()
                          .fadeIn(delay: 100.ms)
                          .slideX(begin: 0.1, end: 0),
                      SizedBox(height: 32.h),

                      _buildSectionHeader(context, 'ACTIVE FOCUS'),
                      SizedBox(height: 16.h),
                      _buildGermanFocusCard(context)
                          .animate()
                          .fadeIn(delay: 200.ms)
                          .scale(begin: const Offset(0.98, 0.98)),
                      SizedBox(height: 24.h),
                      _buildAIAssistantNexus(context)
                          .animate()
                          .fadeIn(delay: 300.ms)
                          .shimmer(
                            duration: 2.seconds,
                            color: Colors.white.withOpacity(0.05),
                          ),
                      SizedBox(height: 32.h),

                      _buildUniversityHub(context),
                      SizedBox(height: 32.h),

                      _buildSectionHeader(context, 'LECTURES TODAY'),
                      SizedBox(height: 16.h),
                      if (studyProvider.todayLectures.isEmpty)
                        _buildEmptyLectures(context)
                      else
                        ...studyProvider.todayLectures.map(
                          (lecture) =>
                              _buildLectureItem(
                                    context,
                                    lecture,
                                    lecture.subject == 'German A2'
                                        ? AppColors.secondary
                                        : Theme.of(context).colorScheme.primary,
                                  )
                                  .animate()
                                  .fadeIn(delay: 400.ms)
                                  .slideX(begin: 0.05, end: 0),
                        ),
                      SizedBox(height: 120.h),
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

  Widget _buildLearningVelocity(BuildContext context, StudyProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WEEKLY LEARNING VELOCITY',
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: AppColors.textTertiaryLight,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              provider.hoursLoggedThisWeek.toString(),
              style: GoogleFonts.outfit(
                fontSize: 42.sp,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: -1,
              ),
            ),
            SizedBox(width: 12.w),
            Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HOURS LOGGED',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    '↑ 15% from last week',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            _buildMiniVelocityChart(),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniVelocityChart() {
    return SizedBox(
      width: 100.w,
      height: 40.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [4, 6, 3, 8, 5, 7, 9].map((h) {
          return Container(
            width: 8.w,
            height: (h * 4).h,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(2.r),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAcademicProgressRow(BuildContext context) {
    return Consumer<GPAProvider>(
      builder: (context, provider, child) {
        return Row(
          children: [
            Expanded(
              child: _buildProgressStatCard(
                context,
                'CURRENT GPA',
                provider.currentGPA.toStringAsFixed(1),
                Icons.star_rounded,
                AppColors.primary,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GPAManagerScreen(),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildProgressStatCard(
                context,
                'ECTS EARNED',
                provider.totalCredits.toString(),
                Icons.analytics_rounded,
                AppColors.secondary,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GPAManagerScreen(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.02) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.035),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 18.sp),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 14.sp,
                  color: AppColors.textTertiaryLight,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: AppColors.textTertiaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 10.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
        color: AppColors.textTertiaryLight,
      ),
    );
  }

  Widget _buildAIAssistantNexus(BuildContext context) {
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
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E3A3A), Color(0xFF2D5A5A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 26.sp,
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STUDY NEXUS AI',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Intelligent Analysis',
                    style: GoogleFonts.outfit(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Summarize notes & generate cards',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.bolt_rounded, color: AppColors.secondary, size: 24.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildUniversityHub(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader(context, 'UNIVERSITY ECOSYSTEM'),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddUniversityScreen(),
                ),
              ),
              child: Text(
                'ADD NEW',
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildUniHubCard(
                context,
                'LANGUAGES',
                'German Prep',
                Icons.translate_rounded,
                AppColors.secondary,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GermanLearningScreen(),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              _buildUniHubCard(
                context,
                'PUBLIC UNI',
                'Tech Lectures',
                Icons.account_balance_rounded,
                AppColors.primary,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const UniScheduleScreen(uniType: 'Public'),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              _buildUniHubCard(
                context,
                'PRIVATE UNI',
                'Business Sem',
                Icons.business_rounded,
                AppColors.accent,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const UniScheduleScreen(uniType: 'Private'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUniHubCard(
    BuildContext context,
    String tag,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        context.hapticClick();
        onTap();
      },
      child: Container(
        width: 140.w,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.02) : Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.035),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              tag,
              style: GoogleFonts.inter(
                fontSize: 9.sp,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyLectures(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color!.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.05),
          style: BorderStyle.none, // Or dashed if you have a custom component
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_available_rounded,
            size: 40.sp,
            color: AppColors.textTertiaryLight.withOpacity(0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            'NO LECTURES TODAY',
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textTertiaryLight,
              letterSpacing: 1.2,
            ),
          ),
          Text(
            'Enjoy your focused deep work session',
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color: AppColors.textTertiaryLight.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGermanFocusCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          color: isDark ? Colors.white.withOpacity(0.02) : Colors.white,
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.035),
            width: 1.5,
          ),
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
                        'German Prep: A2',
                        style: GoogleFonts.outfit(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        'Class with Kalpesh Sir',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: AppColors.textTertiaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14.sp,
                  color: AppColors.textTertiaryLight.withOpacity(0.5),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFocusStat(context, 'GOAL', 'B1 Proficiency'),
                _buildFocusStat(context, 'STREAK', '14 DAYS'),
                _buildFocusStat(context, 'EXAM', 'DEC 12'),
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
            fontSize: 9.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.textTertiaryLight,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildLectureItem(
    BuildContext context,
    Lecture lecture,
    Color accentColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.02) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.035),
          width: 1.5,
        ),
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
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(width: 24.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lecture.subject.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  lecture.room,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: AppColors.textTertiaryLight,
                  ),
                ),
              ],
            ),
          ),
          if (lecture.time.contains('10:15')) // Example for "Live" lecture
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'LIVE',
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
