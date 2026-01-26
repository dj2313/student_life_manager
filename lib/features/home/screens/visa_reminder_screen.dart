import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class VisaReminderScreen extends StatelessWidget {
  const VisaReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📋 Visa Extension'), elevation: 0),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.paddingLG.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExpiryHeadeCard(),
            SizedBox(height: 25.h),
            _buildReminderSettings(),
            SizedBox(height: 25.h),
            Text(
              'Required Documents Checklist',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15.h),
            _buildChecklist(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMD.w),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 50.h),
            backgroundColor: AppColors.primary,
          ),
          child: const Text('Edit Expiry Date'),
        ),
      ),
    );
  }

  Widget _buildExpiryHeadeCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.paddingLG.w),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusLG.r),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            'Current Visa Expires:',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondaryLight,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'March 15, 2026',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer, color: AppColors.error, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                '48 days remaining',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.6,
              minHeight: 10.h,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderSettings() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMD.w),
        child: Column(
          children: [
            _buildSettingRow(
              Icons.notifications_active,
              'Weekly Reminder',
              'Every Monday at 9:00 AM',
            ),
            const Divider(),
            _buildSettingRow(
              Icons.snooze,
              'Snooze Reminder',
              'Stop for 1 week',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
      ),
      subtitle: Text(value, style: TextStyle(fontSize: 12.sp)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }

  Widget _buildChecklist() {
    final list = [
      {'title': 'Passport copy', 'done': true},
      {'title': 'Enrollment proof', 'done': true},
      {'title': 'Bank statement', 'done': false},
      {'title': 'Health insurance', 'done': false},
      {'title': 'Biometric photo', 'done': false},
    ];

    return Column(
      children: list.map((item) {
        bool done = item['done'] as bool;
        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Container(
            decoration: BoxDecoration(
              color: done ? AppColors.success.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusMD.r),
              border: Border.all(
                color: done
                    ? AppColors.success.withOpacity(0.2)
                    : AppColors.borderLight,
              ),
            ),
            child: ListTile(
              leading: Icon(
                done ? Icons.check_circle : Icons.radio_button_unchecked,
                color: done ? AppColors.success : Colors.grey,
              ),
              title: Text(
                item['title'] as String,
                style: TextStyle(
                  fontWeight: done ? FontWeight.bold : FontWeight.normal,
                  decoration: done ? TextDecoration.lineThrough : null,
                ),
              ),
              onTap: () {},
            ),
          ),
        );
      }).toList(),
    );
  }
}
