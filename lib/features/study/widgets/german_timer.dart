import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class GermanTimer extends StatefulWidget {
  const GermanTimer({super.key});

  @override
  State<GermanTimer> createState() => _GermanTimerState();
}

class _GermanTimerState extends State<GermanTimer> {
  bool _isRunning = false;
  int _seconds = 0;
  int _minutes = 0;
  int _hours = 1;

  void _toggleTimer() {
    setState(() {
      _isRunning = !_isRunning;
    });
    // TODO: Implement actual timer logic
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _seconds = 0;
      _minutes = 45;
      _hours = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingLG.w),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMD.r),
      ),
      child: Column(
        children: [
          Text('Today\'s Time', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: AppSizes.spacingMD.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeUnit(_hours.toString().padLeft(2, '0'), 'h'),
              Text(
                ' : ',
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
              ),
              _buildTimeUnit(_minutes.toString().padLeft(2, '0'), 'm'),
              Text(
                ' : ',
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
              ),
              _buildTimeUnit(_seconds.toString().padLeft(2, '0'), 's'),
            ],
          ),
          SizedBox(height: AppSizes.spacingMD.h),
          Text(
            'Goal: 2h',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          SizedBox(height: AppSizes.spacingLG.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _toggleTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRunning
                      ? AppColors.warning
                      : AppColors.secondary,
                ),
                icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                label: Text(_isRunning ? 'Pause' : 'Start Timer'),
              ),
              if (_isRunning || _seconds > 0 || _minutes > 0) ...[
                SizedBox(width: AppSizes.spacingMD.w),
                IconButton(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.restart_alt),
                  color: AppColors.error,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(String value, String unit) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMD.w,
            vertical: AppSizes.paddingSM.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.cardLight,
            borderRadius: BorderRadius.circular(AppSizes.radiusSM.r),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          unit,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
