import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class StudyProgress extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String label;

  const StudyProgress({super.key, required this.progress, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            Text(
              '${(progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.spacingSM.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusSM.r),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12.h,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressColor(progress),
            ),
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) {
      return AppColors.success;
    } else if (progress >= 0.5) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }
}
