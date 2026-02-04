import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/theme_provider.dart';
import '../../auth/screens/signup_screen.dart';
import '../../auth/screens/login_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF0F1115)
            : const Color(0xFFF8F9FB),
        body: Stack(
          children: [
            // Subtle Grid Pattern or Texture
            if (!isDark)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.02,
                  child: Image.network(
                    'https://www.transparenttextures.com/patterns/cubes.png',
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),

            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h),

                    // Minimalist Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMinimalLogo(isDark),
                        Text(
                          'v1.0',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white24 : Colors.black26,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 800.ms),

                    const Spacer(),

                    // UNIQUE PHOTO PRESENTATION (Editorial style)
                    Center(
                          child: Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.03)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(24.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                    isDark ? 0.3 : 0.05,
                                  ),
                                  blurRadius: 40,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16.r),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1515378791036-0648a3ef77b2?q=80&w=2070&auto=format&fit=crop',
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return Container(
                                      color: isDark
                                          ? Colors.white10
                                          : Colors.black.withOpacity(0.02),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1, 1),
                          duration: 1.seconds,
                          curve: Curves.easeOutBack,
                        )
                        .fadeIn(),

                    const Spacer(),

                    // CLEAN TEXT LAYOUT
                    Text(
                          'STUDENT LIFE',
                          style: GoogleFonts.outfit(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 4,
                            color: isDark
                                ? AppColors.secondaryLight
                                : AppColors.secondary,
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .slideX(begin: 0.1, end: 0),

                    SizedBox(height: 8.h),

                    Text(
                          'Simplify\nEverything.',
                          style: GoogleFonts.outfit(
                            fontSize: 48.sp,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1A1C1E),
                            height: 1.0,
                            letterSpacing: -1.5,
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 600.ms)
                        .slideY(begin: 0.2, end: 0),

                    SizedBox(height: 16.h),

                    Text(
                      'The modern workspace curated for the\nnext generation of academic excellence.',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        color: isDark ? Colors.white54 : Colors.black45,
                        height: 1.5,
                      ),
                    ).animate().fadeIn(delay: 800.ms),

                    SizedBox(height: 48.h),

                    // MINIMALIST ACTIONS
                    _buildMinimalActions(context, isDark),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalLogo(bool isDark) {
    return Container(
      width: 40.r,
      height: 40.r,
      decoration: BoxDecoration(
        color: isDark ? Colors.white : const Color(0xFF1A1C1E),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Center(
        child: Icon(
          Icons.auto_awesome_mosaic_rounded,
          color: isDark ? Colors.black : Colors.white,
          size: 20.r,
        ),
      ),
    );
  }

  Widget _buildMinimalActions(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SignupScreen()),
            ),
            child: Container(
              height: 60.h,
              decoration: BoxDecoration(
                color: isDark ? Colors.white : const Color(0xFF1A1C1E),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                ],
              ),
              child: Center(
                child: Text(
                  'Get Started',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ).animate().fadeIn(delay: 1.seconds).slideY(begin: 0.2, end: 0),

        SizedBox(width: 12.w),

        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
            child: Container(
              height: 60.h,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.04),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isDark
                      ? Colors.white12
                      : Colors.black.withOpacity(0.08),
                ),
              ),
              child: Center(
                child: Text(
                  'Sign In',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1C1E),
                  ),
                ),
              ),
            ),
          ),
        ).animate().fadeIn(delay: 1.2.seconds).slideY(begin: 0.2, end: 0),
      ],
    );
  }
}
