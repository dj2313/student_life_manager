import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../data/models/student_os_models.dart';
import '../providers/bureaucracy_provider.dart';

class BureaucracyTrackerScreen extends StatelessWidget {
  const BureaucracyTrackerScreen({super.key});

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
                  _buildProgressHeader(context),
                  SizedBox(height: 32.h),
                  _buildSectionTitle(context, 'REQUIRED STEPS'),
                  SizedBox(height: 16.h),
                  Consumer<BureaucracyProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.tasks.length,
                        itemBuilder: (context, index) {
                          final task = provider.tasks[index];
                          return _buildTaskCard(context, task, provider)
                              .animate(delay: (100 * index).ms)
                              .fadeIn()
                              .slideX(begin: 0.1, end: 0);
                        },
                      );
                    },
                  ),
                  SizedBox(height: 40.h),
                  _buildDocumentationTip(context),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120.h,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: EdgeInsets.only(left: 24.w, bottom: 16.h),
        title: Text(
          'Bureaucracy',
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

  Widget _buildProgressHeader(BuildContext context) {
    return Consumer<BureaucracyProvider>(
      builder: (context, provider, child) {
        final progress = provider.completionProgress;
        return Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFF6366F1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Overall Progress',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10.h,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Unlock your full German experience by completing these essential steps.',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
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

  Widget _buildTaskCard(
    BuildContext context,
    BureaucracyTask task,
    BureaucracyProvider provider,
  ) {
    final isCompleted = task.status == BureaucracyStatus.completed;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isCompleted
              ? AppColors.success.withOpacity(0.5)
              : Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          leading: GestureDetector(
            onTap: () {
              context.hapticClick();
              final newStatus = isCompleted
                  ? BureaucracyStatus.pending
                  : BureaucracyStatus.completed;
              if (newStatus == BureaucracyStatus.completed) {
                context.hapticSuccess();
              }
              provider.updateTaskStatus(task.id, newStatus);
            },

            child: AnimatedContainer(
              duration: 300.ms,
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.success : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted
                      ? AppColors.success
                      : Theme.of(context).dividerColor,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.check,
                size: 16.sp,
                color: isCompleted ? Colors.white : Colors.transparent,
              ),
            ),
          ),
          title: Text(
            task.title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
              decoration: isCompleted ? TextDecoration.lineThrough : null,
              color: isCompleted ? context.textSecondary : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.category,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  color: isCompleted
                      ? AppColors.success
                      : context.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                DateFormat('EEE, MMM dd • hh:mm a').format(task.createdAt),
                style: GoogleFonts.inter(
                  fontSize: 9.sp,
                  color: context.textTertiary,
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.description,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: context.textSecondary,
                    ),
                  ),
                  if (task.requiredDocuments.isNotEmpty) ...[
                    SizedBox(height: 16.h),
                    Text(
                      'Required Documents:',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    ...task.requiredDocuments.map(
                      (doc) => Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 14.sp,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              doc,
                              style: GoogleFonts.inter(fontSize: 12.sp),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      _buildStatusButton(
                        context,
                        'In Progress',
                        BureaucracyStatus.inProgress,
                        task.status == BureaucracyStatus.inProgress,
                        () => provider.updateTaskStatus(
                          task.id,
                          BureaucracyStatus.inProgress,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      _buildStatusButton(
                        context,
                        'Reset',
                        BureaucracyStatus.pending,
                        false,
                        () => provider.updateTaskStatus(
                          task.id,
                          BureaucracyStatus.pending,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(
    BuildContext context,
    String label,
    BureaucracyStatus status,
    bool active,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: () {
        context.hapticClick();
        onTap();
      },

      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary
              : AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentationTip(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: AppColors.secondary,
            size: 28.sp,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pro Tip:',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
                Text(
                  'Always keep digital copies of your documents in a "Cloud" folder for easy access.',
                  style: GoogleFonts.inter(fontSize: 12.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
