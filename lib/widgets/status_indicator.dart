import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/providers/system_status_provider.dart';

class StatusIndicator extends StatelessWidget {
  const StatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SystemStatusProvider>(
      builder: (context, statusProvider, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildWifiStatus(statusProvider.connectivityResult),
              SizedBox(width: 16.w),
              _buildBatteryStatus(
                statusProvider.batteryLevel,
                statusProvider.batteryState,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWifiStatus(ConnectivityResult result) {
    IconData icon;
    Color color;

    switch (result) {
      case ConnectivityResult.wifi:
        icon = Icons.wifi_rounded;
        color = AppColors.accent;
        break;
      case ConnectivityResult.mobile:
        icon = Icons.signal_cellular_alt_rounded;
        color = AppColors.accent;
        break;
      default:
        icon = Icons.wifi_off_rounded;
        color = AppColors.secondary;
    }

    return Icon(icon, color: color, size: 18.sp);
  }

  Widget _buildBatteryStatus(int level, BatteryState state) {
    IconData icon;
    Color color;

    if (state == BatteryState.charging) {
      icon = Icons.battery_charging_full_rounded;
      color = Colors.green;
    } else if (level <= 20) {
      icon = Icons.battery_alert_rounded;
      color = AppColors.secondary;
    } else {
      icon = Icons.battery_full_rounded;
      color = AppColors.accent;
    }

    return Row(
      children: [
        Text(
          '$level%',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: 4.w),
        Icon(icon, color: color, size: 18.sp),
      ],
    );
  }
}
