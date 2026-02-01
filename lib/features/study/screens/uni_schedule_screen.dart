import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/study_provider.dart';
import '../../../data/models/lecture.dart';
import '../../../data/models/university.dart';
import './add_university_screen.dart';

class UniScheduleScreen extends StatefulWidget {
  final String uniType;
  const UniScheduleScreen({super.key, required this.uniType});

  @override
  State<UniScheduleScreen> createState() => _UniScheduleScreenState();
}

class _UniScheduleScreenState extends State<UniScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: widget.uniType == 'Public'
              ? AppColors.primary
              : AppColors.accent,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: AppColors.textTertiaryLight,
          labelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 13.sp,
          ),
          tabs: const [
            Tab(text: 'SCHEDULE'),
            Tab(text: 'SAVED UNIVERSITIES'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildScheduleView(lectures),
          _buildUniversityHubView(provider),
        ],
      ),
    );
  }

  Widget _buildScheduleView(List<Lecture> lectures) {
    return CustomScrollView(
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
                    child: Padding(
                      padding: EdgeInsets.only(top: 40.h),
                      child: Text(
                        'No lectures today',
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  )
                else
                  ...lectures.map((l) {
                    final index = lectures.indexOf(l);
                    return _buildLectureDetailCard(l)
                        .animate()
                        .fadeIn(delay: (index * 100).ms, duration: 400.ms)
                        .scale(begin: const Offset(0.98, 0.98));
                  }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUniversityHubView(StudyProvider provider) {
    final universities = provider.getUniversitiesByType(widget.uniType);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SAVED LIST',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textTertiaryLight,
                        letterSpacing: 1.5,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddUniversityScreen(
                              initialType: widget.uniType,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add New'),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                if (universities.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40.h),
                      child: Column(
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 64.sp,
                            color: AppColors.textTertiaryLight.withOpacity(0.2),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No universities saved yet',
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...universities.map((uni) {
                    final index = universities.indexOf(uni);
                    return _buildUniversityCard(uni)
                        .animate()
                        .fadeIn(delay: (index * 100).ms, duration: 400.ms)
                        .slideX(begin: 0.1, end: 0);
                  }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUniversityCard(University uni) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  uni.name,
                  style: GoogleFonts.outfit(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color:
                      (uni.type == 'Public'
                              ? AppColors.primary
                              : AppColors.accent)
                          .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  uni.status,
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: uni.type == 'Public'
                        ? AppColors.primary
                        : AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            uni.course,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppColors.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildUniBadge(Icons.timer_outlined, uni.duration),
              SizedBox(width: 12.w),
              _buildUniBadge(
                Icons.euro_symbol_rounded,
                '€${uni.tuitionFees.toStringAsFixed(0)}',
              ),
              SizedBox(width: 12.w),
              _buildUniBadge(
                Icons.location_on_outlined,
                uni.location.split(',').first,
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: const Text('Details'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: const Text('Update Status'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUniBadge(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: AppColors.textTertiaryLight),
        SizedBox(width: 4.w),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
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
