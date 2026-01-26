import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import 'calculator_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.moreTitle), elevation: 0),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildHeader(),
          _buildSection('Finance & Tools', [
            _buildSettingsTile(
              context,
              Icons.currency_exchange,
              AppStrings.currencyCalculator,
              AppColors.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CalculatorScreen(),
                  ),
                );
              },
            ),
            _buildSettingsTile(
              context,
              Icons.bar_chart,
              AppStrings.reports,
              AppColors.secondary,
            ),
          ]),
          _buildSection('Preferences', [
            _buildSettingsTile(
              context,
              Icons.dark_mode,
              AppStrings.darkMode,
              AppColors.accent,
            ),
            _buildSettingsTile(
              context,
              Icons.notifications,
              AppStrings.notifications,
              AppColors.info,
            ),
          ]),
          _buildSection('Data Management', [
            _buildSettingsTile(
              context,
              Icons.backup,
              AppStrings.backup,
              Colors.brown,
            ),
            _buildSettingsTile(
              context,
              Icons.file_download,
              AppStrings.exportData,
              Colors.blueGrey,
            ),
          ]),
          _buildSection('Support & Info', [
            _buildSettingsTile(
              context,
              Icons.info,
              AppStrings.about,
              Colors.grey,
            ),
            _buildSettingsTile(
              context,
              Icons.contact_support,
              AppStrings.support,
              AppColors.error,
            ),
          ]),
          SizedBox(height: 40.h),
          Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                color: AppColors.textTertiaryLight,
                fontSize: 12.sp,
              ),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingLG.w),
      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, size: 35.sp, color: Colors.white),
          ),
          SizedBox(width: AppSizes.spacingMD.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Student User',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              Text(
                'student@example.com',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSizes.paddingMD.w,
            20.h,
            AppSizes.paddingMD.w,
            10.h,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    IconData icon,
    String title,
    Color color, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: color, size: 20.sp),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
      ),
      trailing: Icon(Icons.chevron_right, size: 20.sp, color: Colors.grey),
      onTap: onTap ?? () {},
    );
  }
}
