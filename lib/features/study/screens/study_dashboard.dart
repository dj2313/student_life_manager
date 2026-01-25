import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import 'german_learning_screen.dart';

class StudyDashboard extends StatelessWidget {
  const StudyDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.studyTitle)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.paddingMD.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // German Learning Card - TOP PRIORITY
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GermanLearningScreen(),
                  ),
                );
              },
              child: Card(
                elevation: 4,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLG.r),
                  ),
                  padding: EdgeInsets.all(AppSizes.paddingLG.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.translate,
                            color: Colors.white,
                            size: 32.sp,
                          ),
                          SizedBox(width: AppSizes.spacingMD.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '🇩🇪 German Learning - A2',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Next Class: Mon 10:00 AM',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSizes.spacingMD.h),
                      Text(
                        'Tutor: Kalpesh Sir',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: AppSizes.spacingSM.h),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: 8 / 12,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: AppSizes.spacingMD.w),
                          Text(
                            'Weekly Hours: 8/12',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSizes.spacingMD.h),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const GermanLearningScreen(),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white),
                              ),
                              icon: const Icon(Icons.timer),
                              label: const Text('Start Timer'),
                            ),
                          ),
                          SizedBox(width: AppSizes.spacingSM.w),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white),
                              ),
                              icon: const Icon(Icons.calendar_today),
                              label: const Text('View Schedule'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSizes.spacingLG.h),

            // Today's Schedule
            Text(
              '📅 Today\'s Schedule',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: AppSizes.spacingMD.h),
            _buildLectureCard(
              context,
              '10:00',
              'German Class',
              'Kalpesh Sir',
              AppColors.primary,
            ),
            SizedBox(height: AppSizes.spacingSM.h),
            _buildLectureCard(
              context,
              '14:00',
              'Public Uni Lecture',
              'Advanced Mathematics',
              AppColors.secondary,
            ),
            SizedBox(height: AppSizes.spacingLG.h),

            // My Universities
            Text(
              '🏛️ My Universities',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: AppSizes.spacingMD.h),
            Row(
              children: [
                Expanded(
                  child: _buildUniversityCard(
                    context,
                    'Public\nUni',
                    Icons.account_balance,
                    AppColors.primary,
                  ),
                ),
                SizedBox(width: AppSizes.spacingMD.w),
                Expanded(
                  child: _buildUniversityCard(
                    context,
                    'Private\nUni',
                    Icons.business,
                    AppColors.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLectureCard(
    BuildContext context,
    String time,
    String title,
    String subtitle,
    Color color,
  ) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 60.w,
          height: 60.h,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusMD.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                time,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right, color: color),
        onTap: () {},
      ),
    );
  }

  Widget _buildUniversityCard(
    BuildContext context,
    String name,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(AppSizes.radiusLG.r),
        child: Container(
          padding: EdgeInsets.all(AppSizes.paddingLG.w),
          child: Column(
            children: [
              Icon(icon, size: 48.sp, color: color),
              SizedBox(height: AppSizes.spacingSM.h),
              Text(
                name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
