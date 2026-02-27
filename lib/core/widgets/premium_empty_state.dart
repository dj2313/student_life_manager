import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class PremiumEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onActionPressed;
  final String? actionLabel;

  const PremiumEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onActionPressed,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
                padding: EdgeInsets.all(32.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(isDark ? 0.05 : 0.03),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 64.sp,
                  color: AppColors.primary.withOpacity(0.5),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                duration: 2000.ms,
                begin: const Offset(1, 1),
                end: const Offset(1.05, 1.05),
                curve: Curves.easeInOut,
              ),
          SizedBox(height: 24.h),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.primary,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48.w),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                height: 1.5,
              ),
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
          if (onActionPressed != null && actionLabel != null) ...[
            SizedBox(height: 32.h),
            ElevatedButton(
              onPressed: onActionPressed,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Text(
                actionLabel!,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ).animate().fadeIn(delay: 600.ms).scale(),
          ],
        ],
      ),
    );
  }
}
