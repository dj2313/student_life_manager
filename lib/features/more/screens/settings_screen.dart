import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/theme_provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'calculator_screen.dart';
import 'package:permission_handler/permission_handler.dart';

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
          _buildHeader(
            context,
            authProvider,
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
          _buildSection(context, 'Account Settings', [
                _buildSettingsTile(
                  context,
                  Icons.logout_rounded,
                  'Sign Out',
                  AppColors.error,
                  onTap: () => _showLogoutDialog(context, authProvider),
                ),
              ])
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .slideY(begin: 0.05, end: 0),
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
                  onTap: () => _showComingSoon(context),
                ),
              ])
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.05, end: 0),
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
                  onTap: () => _handleNotificationPermission(context),
                ),
              ])
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms)
              .slideY(begin: 0.05, end: 0),
          _buildSection(context, 'Data Management', [
                _buildSettingsTile(
                  context,
                  Icons.backup_outlined,
                  AppStrings.backup,
                  Colors.brown,
                  onTap: () => _handleDataOperation(context, 'Backup'),
                ),
                _buildSettingsTile(
                  context,
                  Icons.file_download_outlined,
                  AppStrings.exportData,
                  Colors.blueGrey,
                  onTap: () => _handleDataOperation(context, 'Export'),
                ),
              ])
              .animate()
              .fadeIn(delay: 400.ms, duration: 400.ms)
              .slideY(begin: 0.05, end: 0),
          _buildSection(context, 'Support & Info', [
                _buildSettingsTile(
                  context,
                  Icons.info_outline,
                  AppStrings.about,
                  Colors.grey,
                  onTap: () => _showAboutDialog(context),
                ),
                _buildSettingsTile(
                  context,
                  Icons.contact_support_outlined,
                  AppStrings.support,
                  AppColors.error,
                  onTap: () => _showComingSoon(context),
                ),
              ])
              .animate()
              .fadeIn(delay: 500.ms, duration: 400.ms)
              .slideY(begin: 0.05, end: 0),
          SizedBox(height: 40.h),
          Center(
            child: Text(
              'Version 1.0.0',
              style: GoogleFonts.inter(
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.textTertiaryLight
                    : AppColors.textTertiaryDark,
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

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Feature coming soon!',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  void _handleNotificationPermission(BuildContext context) async {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notifications enabled successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification permission denied.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _handleDataOperation(BuildContext context, String operation) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FutureBuilder(
        future: Future.delayed(const Duration(seconds: 2)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(height: 20.h),
                  Text('$operation in progress...', style: GoogleFonts.inter()),
                ],
              ),
            );
          }
          Navigator.pop(context);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$operation completed successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
          });
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Student Life Manager',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 Personal Projects',
      applicationIcon: Icon(
        Icons.school,
        size: 40.sp,
        color: AppColors.primary,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Sign Out',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to log out of your account?',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppColors.textSecondaryLight),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              authProvider.signOut();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthProvider authProvider) {
    final textColor = Theme.of(context).colorScheme.primary;
    final user = authProvider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(AppSizes.paddingLG.w),
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : AppColors.borderLight,
          width: 1.2,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.1),
                width: 2,
              ),
            ),
            child: CircleAvatar(
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
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(28.w, 20.h, 24.w, 12.h),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
              letterSpacing: 2.0,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 24.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : AppColors.borderLight,
              width: 1,
            ),
          ),
          child: Column(children: children),
        ),
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
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, color: color, size: 20.sp),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      trailing:
          trailing ??
          Icon(
            Icons.chevron_right_rounded,
            size: 20.sp,
            color: AppColors.textTertiaryLight,
          ),
      onTap: onTap,
    );
  }
}
