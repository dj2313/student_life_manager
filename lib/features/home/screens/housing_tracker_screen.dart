import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/housing_provider.dart';
import '../../../data/models/student_os_models.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/context_extensions.dart';

class HousingTrackerScreen extends StatelessWidget {
  const HousingTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDepositOverview(context),
                  SizedBox(height: 32.h),
                  _buildSectionTitle('Active Applications'),
                  SizedBox(height: 16.h),
                  _buildApplicationsList(context),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.hapticClick();
        },

        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_home_work_rounded, color: Colors.white),
        label: Text(
          'New Application',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120.h,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Housing Tracker',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        titlePadding: EdgeInsets.only(left: 56.w, bottom: 16.h),
      ),
    );
  }

  Widget _buildDepositOverview(BuildContext context) {
    return Consumer<HousingProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.secondary,
                AppColors.secondary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Potential Deposit Returns',
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '€${provider.totalPotentialReturn.toStringAsFixed(0)}',
                style: GoogleFonts.outfit(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16.h),
              ...provider.deposits.map(
                (d) => _buildDepositItem(context, d, provider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDepositItem(
    BuildContext context,
    HousingDeposit deposit,
    HousingProvider provider,
  ) {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Icon(Icons.home_outlined, color: Colors.white, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deposit.propertyAddress,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Paid: 01 Oct 2023',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: deposit.isReturned,
            onChanged: (_) {
              context.hapticSuccess();
              provider.toggleDepositReturned(deposit.id);
            },
            checkColor: AppColors.secondary,
            activeColor: Colors.white,
            side: const BorderSide(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildApplicationsList(BuildContext context) {
    return Consumer<HousingProvider>(
      builder: (context, provider, child) {
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.applications.length,
          separatorBuilder: (_, __) => SizedBox(height: 16.h),
          itemBuilder: (context, index) {
            final app = provider.applications[index];
            return _buildApplicationCard(context, app);
          },
        );
      },
    );
  }

  Widget _buildApplicationCard(BuildContext context, HousingApplication app) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  app.platform,
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Text(
                '€${app.price.toStringAsFixed(0)}',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            app.title,
            style: GoogleFonts.outfit(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14.sp,
                color: context.textSecondary,
              ),
              SizedBox(width: 4.w),
              Text(
                app.location,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Applied: ${app.appliedDate.day}/${app.appliedDate.month}',
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  color: context.textTertiary,
                ),
              ),
              _buildStatusBadge(app.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final bool isViewing = status == 'Viewing';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isViewing
            ? AppColors.secondary.withOpacity(0.1)
            : AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
          color: isViewing ? AppColors.secondary : AppColors.primary,
        ),
      ),
    );
  }
}
