import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../widgets/german_timer.dart';
import '../widgets/study_progress.dart';

class GermanLearningScreen extends StatelessWidget {
  const GermanLearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  _buildHeaderDescription(),
                  SizedBox(height: 32.h),
                  _buildSectionTitle('Academic Road'),
                  SizedBox(height: 16.h),
                  _buildGoalCard(context),
                  SizedBox(height: 32.h),
                  _buildSectionTitle('Active Mentorship'),
                  SizedBox(height: 16.h),
                  _buildTutorCard(context),
                  SizedBox(height: 32.h),
                  _buildActionRow(context),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          color: AppColors.primary,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: Text(
        'Language Proficiency',
        style: GoogleFonts.outfit(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildHeaderDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🇩🇪 German A2',
          style: GoogleFonts.outfit(
            fontSize: 32.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Targeting Professional Working Proficiency by 2026',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 11.sp,
        fontWeight: FontWeight.w800,
        color: AppColors.textTertiaryLight,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag_rounded, color: AppColors.secondary, size: 24.sp),
              SizedBox(width: 12.w),
              Text(
                'Milestone: B1 Exam',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          const StudyProgress(progress: 0.8, label: 'Completion Velocity'),
          SizedBox(height: 20.h),
          Text(
            'Schedule Intensity: 18h / week',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white12,
                child: Icon(Icons.person_outline_rounded, color: Colors.white),
              ),
              SizedBox(width: 16.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kalpesh Sir',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Lead Language Coach',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24.h),
          const GermanTimer(),
        ],
      ),
    );
  }

  Widget _buildActionRow(BuildContext context) {
    return Row(
      children: [
        _buildActionBtn('Archives', Icons.folder_open_rounded),
        SizedBox(width: 16.w),
        _buildActionBtn('Vocab', Icons.abc_rounded),
      ],
    );
  }

  Widget _buildActionBtn(String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18.sp, color: AppColors.primary),
            SizedBox(width: 8.w),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
