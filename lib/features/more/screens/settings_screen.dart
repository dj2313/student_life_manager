import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/theme_provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'calculator_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final textColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppStrings.moreTitle,
          style: GoogleFonts.outfit(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildHeader(context, authProvider),
          _buildSection(context, 'Account Settings', [
            _buildSettingsTile(
              context,
              Icons.logout_rounded,
              'Sign Out',
              AppColors.error,
              onTap: () => _showLogoutDialog(context, authProvider),
            ),
          ]),
          _buildSection(context, 'Finance & Tools', [
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
          _buildSection(context, 'Preferences', [
            _buildSettingsTile(
              context,
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              'Appearance',
              AppColors.accent,
              trailing: Switch.adaptive(
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.toggleTheme(),
                activeColor: AppColors.secondary,
              ),
              onTap: () => themeProvider.toggleTheme(),
            ),
            _buildSettingsTile(
              context,
              Icons.notifications_active_outlined,
              AppStrings.notifications,
              AppColors.info,
            ),
          ]),
          _buildSection(context, 'Data Management', [
            _buildSettingsTile(
              context,
              Icons.backup_outlined,
              AppStrings.backup,
              Colors.brown,
            ),
            _buildSettingsTile(
              context,
              Icons.file_download_outlined,
              AppStrings.exportData,
              Colors.blueGrey,
            ),
          ]),
          _buildSection(context, 'Support & Info', [
            _buildSettingsTile(
              context,
              Icons.info_outline,
              AppStrings.about,
              Colors.grey,
            ),
            _buildSettingsTile(
              context,
              Icons.contact_support_outlined,
              AppStrings.support,
              AppColors.error,
            ),
          ]),
          SizedBox(height: 40.h),
          Center(
            child: Text(
              'Version 1.0.0',
              style: GoogleFonts.inter(
                color: AppColors.textTertiaryLight,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 120.h),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              authProvider.signOut();
              Navigator.pop(context);
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthProvider authProvider) {
    final textColor = Theme.of(context).colorScheme.primary;
    final user = authProvider.user;

    return Container(
      padding: EdgeInsets.all(AppSizes.paddingLG.w),
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.borderLight, width: 1.2),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: AppColors.primary,
            child: Text(
              (user?.email?.substring(0, 1) ?? 'U').toUpperCase(),
              style: GoogleFonts.outfit(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: AppSizes.spacingMD.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'Student User',
                  style: GoogleFonts.outfit(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  user?.email ?? 'Not Logged In',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
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

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 10.h),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textTertiaryLight,
              letterSpacing: 1.5,
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
    Widget? trailing,
  }) {
    final textColor = Theme.of(context).colorScheme.primary;
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w),
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: color, size: 22.sp),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      trailing:
          trailing ??
          Icon(
            Icons.chevron_right,
            size: 20.sp,
            color: AppColors.textTertiaryLight,
          ),
      onTap: onTap ?? () {},
    );
  }
}
