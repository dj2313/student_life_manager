import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../data/models/student_os_models.dart';
import '../providers/job_provider.dart';

class JobTrackerScreen extends StatelessWidget {
  const JobTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVisaLimitCard(context),
                  SizedBox(height: 32.h),
                  _buildSectionTitle(context, 'EARNINGS OVERVIEW'),
                  SizedBox(height: 16.h),
                  _buildEarningsChart(context),
                  SizedBox(height: 32.h),
                  _buildSectionTitle(context, 'CAREER PIPELINE'),
                  SizedBox(height: 16.h),
                  _buildApplicationsList(context),
                  SizedBox(height: 32.h),
                  _buildSectionTitle(context, 'RECENT WORK SESSIONS'),
                  SizedBox(height: 16.h),
                  _buildSessionsList(context),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'add_app',
            onPressed: () => _showAddApplicationSheet(context),
            label: const Text('New Application'),
            icon: const Icon(Icons.rocket_launch_rounded),
            backgroundColor: AppColors.secondary,
          ),
          SizedBox(height: 12.h),
          FloatingActionButton.extended(
            heroTag: 'add_session',
            onPressed: () => _showAddSessionSheet(context),
            label: const Text('Log Hours'),
            icon: const Icon(Icons.timer_outlined),
            backgroundColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120.h,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: EdgeInsets.only(left: 24.w, bottom: 16.h),
        title: Text(
          'Werkstudent',
          style: GoogleFonts.outfit(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 24.sp,
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildVisaLimitCard(BuildContext context) {
    return Consumer<JobProvider>(
      builder: (context, provider, child) {
        final progress = provider.usagePercentage;
        final isWarning = progress > 0.8;

        return Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(
              color: isWarning
                  ? AppColors.error
                  : AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Annual Visa Limit',
                        style: GoogleFonts.inter(
                          color: context.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${provider.totalDaysWorked.toStringAsFixed(1)} / ${provider.annualDayLimit} Days',
                        style: GoogleFonts.outfit(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: isWarning
                              ? AppColors.error
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  _buildCircularProgress(progress, isWarning),
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Icon(
                    isWarning
                        ? Icons.warning_amber_rounded
                        : Icons.info_outline_rounded,
                    size: 16.sp,
                    color: isWarning ? AppColors.error : AppColors.secondary,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      isWarning
                          ? 'Careful! You are approaching the 140-day legal limit.'
                          : 'Rule: 140 full days or 280 half days per year.',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: isWarning
                            ? AppColors.error
                            : context.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCircularProgress(double progress, bool isWarning) {
    return SizedBox(
      width: 60.w,
      height: 60.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 6,
            backgroundColor: (isWarning ? AppColors.error : AppColors.primary)
                .withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation(
              isWarning ? AppColors.error : AppColors.primary,
            ),
          ),
          Text(
            '${(progress * 100).toInt()}%',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsChart(BuildContext context) {
    return Consumer<JobProvider>(
      builder: (context, provider, child) {
        final earnings = provider.monthlyEarnings;
        if (earnings.isEmpty) {
          return Center(
            child: Text(
              'No data yet. Start logging sessions!',
              style: GoogleFonts.inter(color: context.textTertiary),
            ),
          );
        }

        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            children: earnings.entries.map((entry) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60.w,
                      child: Text(
                        entry.key,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: entry.value / 1500,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.05,
                          ),
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.secondary,
                          ),
                          minHeight: 8.h,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      '€${entry.value.toStringAsFixed(0)}',
                      style: GoogleFonts.jetBrainsMono(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildApplicationsList(BuildContext context) {
    return Consumer<JobProvider>(
      builder: (context, provider, child) {
        if (provider.applications.isEmpty) {
          return Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.rocket_launch_rounded,
                  color: AppColors.secondary,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    'Track your job hunt progress here.',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: context.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return SizedBox(
          height: 110.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: provider.applications.length,
            itemBuilder: (context, index) {
              final app = provider.applications[index];
              return Container(
                width: 200.w,
                margin: EdgeInsets.only(right: 16.w),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.role,
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      maxLines: 1,
                    ),
                    Text(
                      app.company,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: context.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      app.status.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSessionsList(BuildContext context) {
    return Consumer<JobProvider>(
      builder: (context, provider, child) {
        if (provider.sessions.isEmpty) return const SizedBox();
        return ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.sessions.length,
          itemBuilder: (context, index) {
            final session = provider.sessions.reversed.toList()[index];
            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.work_outline_rounded,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.company,
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat('MMM dd').format(session.date),
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${session.hours} hrs',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 11.sp,
        fontWeight: FontWeight.w800,
        color: context.textTertiary,
        letterSpacing: 1.5,
      ),
    );
  }

  void _showAddSessionSheet(BuildContext context) {
    final companyController = TextEditingController();
    final hoursController = TextEditingController();
    final provider = context.read<JobProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Log Work Hours',
              style: GoogleFonts.outfit(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24.h),
            TextField(
              controller: companyController,
              decoration: const InputDecoration(labelText: 'Company Name'),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: hoursController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Hours Worked'),
            ),
            SizedBox(height: 32.h),
            ElevatedButton(
              onPressed: () {
                if (companyController.text.isNotEmpty &&
                    hoursController.text.isNotEmpty) {
                  provider.addSession(
                    WorkSession(
                      id: DateTime.now().toString(),
                      date: DateTime.now(),
                      company: companyController.text,
                      hours: double.tryParse(hoursController.text) ?? 0,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Save Session'),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
          ],
        ),
      ),
    );
  }

  void _showAddApplicationSheet(BuildContext context) {
    final roleController = TextEditingController();
    final companyController = TextEditingController();
    final provider = context.read<JobProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'New Application',
              style: GoogleFonts.outfit(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24.h),
            TextField(
              controller: roleController,
              decoration: const InputDecoration(labelText: 'Job Role'),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: companyController,
              decoration: const InputDecoration(labelText: 'Company'),
            ),
            SizedBox(height: 32.h),
            ElevatedButton(
              onPressed: () {
                if (roleController.text.isNotEmpty &&
                    companyController.text.isNotEmpty) {
                  provider.addApplication(
                    JobApplication(
                      id: DateTime.now().toString(),
                      role: roleController.text,
                      company: companyController.text,
                      status: 'Applied',
                      appliedDate: DateTime.now(),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Track Application'),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
          ],
        ),
      ),
    );
  }
}
