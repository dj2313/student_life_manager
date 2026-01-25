import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class ReminderWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String urgency; // 'high', 'medium', 'low'

  const ReminderWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.urgency = 'medium',
  });

  @override
  Widget build(BuildContext context) {
    final Color urgencyColor = _getUrgencyColor();

    return Card(
      color: urgencyColor.withOpacity(0.05),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: urgencyColor, width: 4)),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingLG.w,
            vertical: AppSizes.paddingSM.h,
          ),
          leading: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: urgencyColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: urgencyColor, size: 24.sp),
          ),
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w600, color: urgencyColor),
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(subtitle),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_active,
                color: urgencyColor,
                size: 20.sp,
              ),
              SizedBox(height: 4.h),
              Text(
                urgency.toUpperCase(),
                style: TextStyle(
                  color: urgencyColor,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getUrgencyColor() {
    switch (urgency) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      case 'low':
        return AppColors.success;
      default:
        return AppColors.info;
    }
  }
}
