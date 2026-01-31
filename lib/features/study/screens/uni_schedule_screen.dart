import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/study_provider.dart';
import '../../../data/models/lecture.dart';

class UniScheduleScreen extends StatefulWidget {
  final String uniType;
  const UniScheduleScreen({super.key, required this.uniType});

  @override
  State<UniScheduleScreen> createState() => _UniScheduleScreenState();
}

class _UniScheduleScreenState extends State<UniScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StudyProvider>(context);
    final lectures = provider.todayLectures
        .where((l) => l.uniType == widget.uniType)
        .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          '${widget.uniType} University',
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
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBanner(),
                  SizedBox(height: 32.h),
                  Text(
                    'TODAY\'S SCHEDULE',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textTertiaryLight,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  if (lectures.isEmpty)
                    Center(
                      child: Text(
                        'No lectures today',
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    )
                  else
                    ...lectures.map((l) => _buildLectureDetailCard(l)).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: widget.uniType == 'Public'
            ? AppColors.primary
            : AppColors.accent,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            widget.uniType == 'Public'
                ? Icons.account_balance_rounded
                : Icons.business_rounded,
            color: Colors.white,
            size: 32.sp,
          ),
          SizedBox(height: 16.h),
          Text(
            widget.uniType == 'Public'
                ? 'State University'
                : 'Management School',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            widget.uniType == 'Public' ? 'TU Berlin' : 'GISMA Berlin',
            style: GoogleFonts.outfit(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLectureDetailCard(Lecture lecture) {
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
                lecture.time,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  lecture.room,
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            lecture.subject,
            style: GoogleFonts.outfit(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Prof. ${lecture.professor}',
            style: GoogleFonts.inter(
              color: AppColors.textSecondaryLight,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.note_add_outlined, size: 18),
                  label: const Text('Add Notes'),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.notification_add_outlined, size: 18),
                  label: const Text('Remind Me'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
