import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class TicketCard extends StatelessWidget {
  final String type; // 'bus' or 'train'
  final String route;
  final String date;
  final String time;
  final String ticketNumber;

  const TicketCard({
    super.key,
    required this.type,
    required this.route,
    required this.date,
    required this.time,
    required this.ticketNumber,
  });

  @override
  Widget build(BuildContext context) {
    final IconData ticketIcon = type == 'bus'
        ? Icons.directions_bus
        : Icons.train;
    final Color ticketColor = type == 'bus'
        ? AppColors.secondary
        : AppColors.primary;

    return Card(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(AppSizes.radiusLG.r),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingMD.w),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: ticketColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM.r),
                    ),
                    child: Icon(ticketIcon, color: ticketColor, size: 32.sp),
                  ),
                  SizedBox(width: AppSizes.spacingMD.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${type == 'bus' ? '🚌' : '🚂'} ${type.toUpperCase()} Ticket',
                          style: Theme.of(
                            context,
                          ).textTheme.labelLarge?.copyWith(color: ticketColor),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          route,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(height: AppSizes.spacingLG.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoColumn(context, 'Date', date),
                  _buildInfoColumn(context, 'Time', time),
                  _buildInfoColumn(context, 'Ticket #', ticketNumber),
                ],
              ),
              SizedBox(height: AppSizes.spacingMD.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.qr_code),
                      label: const Text('View QR'),
                    ),
                  ),
                  SizedBox(width: AppSizes.spacingSM.w),
                  IconButton.filled(
                    onPressed: () {},
                    icon: const Icon(Icons.alarm),
                    style: IconButton.styleFrom(
                      backgroundColor: ticketColor.withOpacity(0.1),
                      foregroundColor: ticketColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
