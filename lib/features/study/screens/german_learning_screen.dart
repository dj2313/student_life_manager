import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../widgets/german_timer.dart';
import '../widgets/study_progress.dart';

class GermanLearningScreen extends StatelessWidget {
  const GermanLearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🇩🇪 German A2 Learning')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.paddingMD.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Study Plan Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.paddingLG.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.book, color: AppColors.primary, size: 24.sp),
                        SizedBox(width: AppSizes.spacingMD.w),
                        Text(
                          '📚 Study Plan',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.spacingMD.h),
                    Text(
                      'Goal: Complete A2 by March',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    SizedBox(height: AppSizes.spacingLG.h),
                    Text(
                      'Weekly Schedule:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppSizes.spacingSM.h),
                    _buildScheduleItem('Mon-Fri: 2 hours/day'),
                    _buildScheduleItem('Sat-Sun: 4 hours/day'),
                    SizedBox(height: AppSizes.spacingLG.h),
                    const StudyProgress(progress: 0.8, label: 'Progress: 80%'),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSizes.spacingMD.h),

            // Tutor Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.paddingLG.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: AppColors.secondary,
                          size: 24.sp,
                        ),
                        SizedBox(width: AppSizes.spacingMD.w),
                        Text(
                          '👨‍🏫 Tutor: Kalpesh Sir',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.spacingMD.h),
                    Text(
                      'Timings:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppSizes.spacingSM.h),
                    _buildTimingItem('Monday: 10:00 AM - 12:00 PM'),
                    _buildTimingItem('Wednesday: 3:00 PM - 5:00 PM'),
                    _buildTimingItem('Friday: 10:00 AM - 12:00 PM'),
                    SizedBox(height: AppSizes.spacingLG.h),
                    const GermanTimer(),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSizes.spacingMD.h),

            // Weekly Summary
            Card(
              color: AppColors.primary.withOpacity(0.1),
              child: Padding(
                padding: EdgeInsets.all(AppSizes.paddingLG.w),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '📊 This Week',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '8h / 12h target',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.spacingMD.h),
                    LinearProgressIndicator(
                      value: 8 / 12,
                      minHeight: 8,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSizes.spacingMD.h),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.notes),
                    label: const Text('Practice Notes'),
                  ),
                ),
                SizedBox(width: AppSizes.spacingMD.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.note),
                    label: const Text('Vocabulary'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.spacingSM.h),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            size: 16.sp,
            color: AppColors.textSecondaryLight,
          ),
          SizedBox(width: AppSizes.spacingSM.w),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildTimingItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.spacingSM.h),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.h,
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppSizes.spacingSM.w),
          Text(text),
        ],
      ),
    );
  }
}
