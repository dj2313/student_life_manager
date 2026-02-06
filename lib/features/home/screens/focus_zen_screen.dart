import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/focus_timer_provider.dart';
import '../../../core/constants/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FocusZenScreen extends StatefulWidget {
  const FocusZenScreen({super.key});

  @override
  State<FocusZenScreen> createState() => _FocusZenScreenState();
}

class _FocusZenScreenState extends State<FocusZenScreen> {
  @override
  void initState() {
    super.initState();
    // Hide status bar for true full screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Restore status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FocusTimerProvider>(
      builder: (context, timerProvider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F172A), // Deep Slate
          body: Stack(
            children: [
              // Ambient Background Glow
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppColors.secondary.withOpacity(0.15),
                        Colors.transparent,
                      ],
                      center: Alignment.center,
                      radius: 1.2,
                    ),
                  ),
                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                 .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 10.seconds),
              ),

              // Main Content
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white54),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Text(
                            'DEEP FOCUS',
                            style: GoogleFonts.outfit(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white54,
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(width: 48), // Spacer
                        ],
                      ),
                    ),
                    const Spacer(),

                    // Timer Circle
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 280.r,
                          height: 280.r,
                          child: CircularProgressIndicator(
                            value: timerProvider.progress,
                            strokeWidth: 4,
                            backgroundColor: Colors.white.withOpacity(0.05),
                            valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              timerProvider.formattedTime,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 64.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Stay presence',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: Colors.white38,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.9, 0.9)),

                    const Spacer(),

                    // Controls
                    Padding(
                      padding: EdgeInsets.only(bottom: 60.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildControlButton(
                            timerProvider.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            () {
                              if (timerProvider.isRunning) {
                                timerProvider.stopTimer();
                              } else {
                                timerProvider.startTimer();
                              }
                            },
                          ),
                          SizedBox(width: 40.w),
                          _buildControlButton(
                            Icons.refresh_rounded,
                            () {
                              timerProvider.resetTimer();
                            },
                            isSmaller: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onTap, {bool isSmaller = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isSmaller ? 16.w : 24.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: Colors.white, size: isSmaller ? 24.sp : 32.sp),
      ),
    );
  }
}
