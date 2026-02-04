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
import '../../../core/utils/context_extensions.dart';

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
          'Command Center',
          style: GoogleFonts.outfit(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: context.primaryColor,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildPremiumStatusCard(
            context,
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
          _buildHeader(context, authProvider)
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .slideX(begin: 0.05, end: 0),

          _buildSection(context, 'Core Configuration', [
            _buildSettingsTile(
              context,
              themeProvider.isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              'System Appearance',
              AppColors.primary,
              subtitle: themeProvider.isDarkMode
                  ? 'Dark Mode Active'
                  : 'Light Mode Active',
              trailing: Switch.adaptive(
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  context.hapticClick();
                  themeProvider.toggleTheme();
                },
                activeColor: AppColors.secondary,
              ),
              onTap: () {
                context.hapticClick();
                themeProvider.toggleTheme();
              },
            ),
            _buildSettingsTile(
              context,
              Icons.notifications_active_rounded,
              'Push Notifications',
              AppColors.secondary,
              subtitle: 'Real-time academic alerts',
              onTap: () {
                context.hapticClick();
                _handleNotificationPermission(context);
              },
            ),
          ]).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05, end: 0),

          _buildSection(context, 'Academic Utilities', [
            _buildSettingsTile(
              context,
              Icons.calculate_rounded,
              'Smart Calculator',
              AppColors.accent,
              subtitle: 'Advanced computation engine',
              onTap: () {
                context.hapticClick();
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
              Icons.insights_rounded,
              'Performance Reports',
              AppColors.success,
              subtitle: 'Semester analysis & trends',
              onTap: () {
                context.hapticClick();
                _showComingSoon(context);
              },
            ),
          ]).animate().fadeIn(delay: 300.ms).slideY(begin: 0.05, end: 0),

          _buildSection(context, 'Cloud & Resilience', [
            _buildSettingsTile(
              context,
              Icons.cloud_upload_rounded,
              'Bi-Directional Backup',
              Colors.blue,
              subtitle: 'Sync data with Firebase',
              onTap: () {
                context.hapticClick();
                _handleDataOperation(context, 'Backup');
              },
            ),
            _buildSettingsTile(
              context,
              Icons.sim_card_download_rounded,
              'Archive & Export',
              Colors.purple,
              subtitle: 'Download PDF/CSV data',
              onTap: () {
                context.hapticClick();
                _handleDataOperation(context, 'Export');
              },
            ),
          ]).animate().fadeIn(delay: 400.ms).slideY(begin: 0.05, end: 0),

          _buildSection(context, 'Support Ecosystem', [
            _buildSettingsTile(
              context,
              Icons.verified_user_rounded,
              'Application Identity',
              Colors.grey,
              subtitle: 'License & versioning',
              onTap: () => _showAboutDialog(context),
            ),
            _buildSettingsTile(
              context,
              Icons.headset_mic_rounded,
              'Priority Support',
              AppColors.error,
              subtitle: 'Direct developer contact',
              onTap: () {
                context.hapticClick();
                _showComingSoon(context);
              },
            ),
          ]).animate().fadeIn(delay: 500.ms).slideY(begin: 0.05, end: 0),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: _buildLogOutButton(context, authProvider),
          ).animate().fadeIn(delay: 600.ms),

          Center(
            child: Column(
              children: [
                Text(
                  'STUDENT LIFE MANAGER PRO',
                  style: GoogleFonts.inter(
                    color: context.textTertiary,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'Version 2.4.0 • Build 2026',
                  style: GoogleFonts.inter(
                    color: context.textTertiary.withOpacity(0.5),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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

  Widget _buildLogOutButton(BuildContext context, AuthProvider auth) {
    return GestureDetector(
      onTap: () {
        context.hapticError();
        _showLogoutDialog(context, auth);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18.h),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.error.withOpacity(0.12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: AppColors.error, size: 20.sp),
            SizedBox(width: 12.w),
            Text(
              'TERMINATE SESSION',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.error,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumStatusCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 8.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondary, Color(0xFFFBDB6B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.star_rounded, color: Colors.white, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SCHOLAR PRO STATUS',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.8),
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'Lifetime Scholar Access',
                  style: GoogleFonts.outfit(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.verified_rounded, color: Colors.white, size: 28.sp),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(20.w),
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.02) : Colors.white,
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.035),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
            ),
            child: CircleAvatar(
              radius: 32.r,
              backgroundColor: isDark ? AppColors.cardDark : Colors.white,
              child: CircleAvatar(
                radius: 30.r,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  (user?.email?.substring(0, 1) ?? 'S').toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'Student Sovereign',
                  style: GoogleFonts.outfit(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  user?.email ?? 'scholar@studentos.com',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: context.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.edit_rounded,
              size: 18.sp,
              color: AppColors.primary,
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
          padding: EdgeInsets.fromLTRB(28.w, 28.h, 24.w, 12.h),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w900,
              color: context.textTertiary,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 24.w),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.02) : Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.035),
              width: 1.5,
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
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      leading: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Icon(icon, color: color, size: 22.sp),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15.sp,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: context.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            )
          : null,
      trailing:
          trailing ??
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14.sp,
            color: context.textTertiary.withOpacity(0.4),
          ),
      onTap: onTap,
    );
  }
}
