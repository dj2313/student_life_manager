import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../widgets/reminder_widget.dart';
import '../widgets/ticket_card.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.homeTitle),
        actions: [
          IconButton(icon: const Icon(Icons.location_on), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(AppSizes.paddingMD.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // My Location Card
            Card(
              child: ListTile(
                leading: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_city,
                    color: AppColors.primary,
                    size: 24.sp,
                  ),
                ),
                title: const Text('📍 My Location'),
                subtitle: const Text('Street, City, Germany'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.map),
                      onPressed: () {},
                      tooltip: 'View Map',
                    ),
                    IconButton(
                      icon: const Icon(Icons.directions),
                      onPressed: () {},
                      tooltip: 'Get Directions',
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSizes.spacingLG.h),

            // Reminders Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🔔 Reminders',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '1 new',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.spacingMD.h),
            const ReminderWidget(
              icon: Icons.badge,
              title: 'Visa Extension Due',
              subtitle: 'in 5 days - Feb 1, 2026',
              urgency: 'high',
            ),
            SizedBox(height: AppSizes.spacingLG.h),

            // Tickets Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🎫 My Tickets',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                TextButton(onPressed: () {}, child: const Text('View All')),
              ],
            ),
            SizedBox(height: AppSizes.spacingMD.h),
            const TicketCard(
              type: 'bus',
              route: 'City Center → Campus',
              date: 'Jan 25, 2026',
              time: '10:30 AM',
              ticketNumber: 'BUS123456',
            ),
            SizedBox(height: AppSizes.spacingSM.h),
            const TicketCard(
              type: 'train',
              route: 'Berlin → Munich',
              date: 'Feb 5, 2026',
              time: '14:45',
              ticketNumber: 'TRAIN789012',
            ),
            SizedBox(height: AppSizes.spacingLG.h),

            // Quick Notes Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '📝 Quick Notes',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(icon: const Icon(Icons.add), onPressed: () {}),
              ],
            ),
            SizedBox(height: AppSizes.spacingMD.h),
            _buildNoteCard(
              context,
              '📌 Grocery List',
              'Last edited: 2 hours ago',
            ),
            SizedBox(height: AppSizes.spacingSM.h),
            _buildNoteCard(
              context,
              '💡 German Words to Remember',
              'Last edited: Today',
            ),
            SizedBox(height: AppSizes.spacingSM.h),
            _buildNoteCard(
              context,
              '📋 Important Phone Numbers',
              'Last edited: Yesterday',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, String title, String subtitle) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.note, color: AppColors.secondary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
