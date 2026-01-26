import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/study_provider.dart';
import '../../../data/models/lecture.dart';
import 'german_learning_screen.dart';

class StudyDashboard extends StatelessWidget {
  const StudyDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudyProvider>(
      builder: (context, studyProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
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
                      SizedBox(height: 32.h),
                      _buildSectionTitle('Active Preparation'),
                      SizedBox(height: 16.h),
                      _buildGermanFocusCard(context),
                      SizedBox(height: 32.h),
                      _buildSectionTitle('University Hub'),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildUniSelectionCard(
                              context,
                              'Public Uni',
                              Icons.account_balance_rounded,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: _buildUniSelectionCard(
                              context,
                              'Private Uni',
                              Icons.business_rounded,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32.h),
                      _buildSectionTitle('Today\'s Lectures'),
                      SizedBox(height: 16.h),
                      ...studyProvider.todayLectures.map(
                        (lecture) => _buildLectureItem(
                          context,
                          lecture,
                          lecture.subject == 'German A2'
                              ? AppColors.secondary
                              : AppColors.primary,
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
          color: AppColors.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildStudyStatus(BuildContext context, StudyProvider provider) {
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
              provider.hoursLogged.toString(),
              style: GoogleFonts.outfit(
                fontSize: 48.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildGermanFocusCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GermanLearningScreen()),
        );
      },
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: AppColors.borderLight),
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
                          color: AppColors.primary,
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
                _buildFocusStat('Goal', 'B1 Level'),
                _buildFocusStat('Streak', '14 Days'),
                _buildFocusStat('Next', 'Tomorrow'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusStat(String label, String value) {
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
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildUniSelectionCard(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 28.sp),
          SizedBox(height: 12.h),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLectureItem(
    BuildContext context,
    Lecture lecture,
    Color accentColor,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderLight),
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
              color: AppColors.primary,
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
                    color: AppColors.primary,
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
}
