import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/money_provider.dart';
import '../../../data/models/expense.dart';
import 'package:intl/intl.dart';

class MoneyDashboard extends StatelessWidget {
  const MoneyDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MoneyProvider>(
      builder: (context, moneyProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12.h),
                      _buildBalanceSection(context, moneyProvider),
                      SizedBox(height: 32.h),
                      _buildQuickActionChips(context),
                      SizedBox(height: 40.h),
                      _buildAccountsSection(context, moneyProvider),
                      SizedBox(height: 40.h),
                      _buildBudgetPreview(context, moneyProvider),
                      SizedBox(height: 40.h),
                      _buildTransactionsSection(context, moneyProvider),
                      SizedBox(
                        height: 120.h,
                      ), // Spacing for floating bottom bar
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 40.h,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Portfolio',
        style: GoogleFonts.outfit(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
          letterSpacing: 1.2,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications_none_outlined,
            color: AppColors.primary,
            size: 24.sp,
          ),
          onPressed: () {},
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildBalanceSection(BuildContext context, MoneyProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Liquidity',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: AppColors.textSecondaryLight,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '€',
              style: GoogleFonts.outfit(
                fontSize: 24.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.secondary,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              provider.totalBalance.toStringAsFixed(2),
              style: GoogleFonts.outfit(
                fontSize: 48.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.north_east_rounded,
                size: 12.sp,
                color: AppColors.success,
              ),
              SizedBox(width: 4.w),
              Text(
                '+4.2% this month',
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionChips(BuildContext context) {
    return Row(
      children: [
        _buildActionChip(context, Icons.add, 'Expense', AppColors.primary),
        SizedBox(width: 12.w),
        _buildActionChip(
          context,
          Icons.currency_exchange,
          'Convert',
          AppColors.secondary,
        ),
        SizedBox(width: 12.w),
        _buildActionChip(
          context,
          Icons.receipt_long_outlined,
          'Bill',
          AppColors.accent,
        ),
      ],
    );
  }

  Widget _buildActionChip(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withOpacity(0.1), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(height: 6.h),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsSection(BuildContext context, MoneyProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sub-Accounts',
              style: GoogleFonts.outfit(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.sp,
              color: AppColors.primary,
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _buildMiniAccountTile(
          context,
          'Blocked Account',
          '€${provider.blockedAccountBalance.toStringAsFixed(2)}',
          Icons.verified_user_outlined,
          AppColors.primary,
        ),
        SizedBox(height: 12.h),
        _buildMiniAccountTile(
          context,
          'Personal Account',
          '€450.00', // Mock personal account balance
          Icons.wallet_outlined,
          AppColors.secondary,
        ),
      ],
    );
  }

  Widget _buildMiniAccountTile(
    BuildContext context,
    String title,
    String amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.outfit(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetPreview(BuildContext context, MoneyProvider provider) {
    final spending = provider.getMonthlySpending();
    final budget = 600.0;
    final ratio = spending / budget;

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Budget',
                style: GoogleFonts.outfit(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              const Icon(Icons.more_horiz, color: Colors.white70),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '€${spending.toStringAsFixed(0)}/${budget.toStringAsFixed(0)}',
                style: GoogleFonts.outfit(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '${(ratio * 100).toStringAsFixed(0)}%',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6.h,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.secondary,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Remaining: €${(budget - spending).toStringAsFixed(2)}',
            style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsSection(
    BuildContext context,
    MoneyProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: GoogleFonts.outfit(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            Text(
              'See All',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        if (provider.expenses.isEmpty)
          Center(
            child: Text(
              'No expenses recorded yet',
              style: GoogleFonts.inter(color: AppColors.textSecondaryLight),
            ),
          )
        else
          ...provider.expenses
              .take(5)
              .map((expense) => _buildTransactionItem(context, expense)),
      ],
    );
  }

  Widget _buildTransactionItem(BuildContext context, Expense expense) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              _getCategoryIcon(expense.category),
              color: AppColors.primary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(expense.date),
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '-€${expense.amount.toStringAsFixed(2)}',
            style: GoogleFonts.outfit(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'housing':
        return Icons.home_outlined;
      case 'food':
        return Icons.restaurant_rounded;
      case 'entertainment':
        return Icons.movie_filter_outlined;
      case 'education':
        return Icons.school_outlined;
      case 'travel':
        return Icons.train_outlined;
      default:
        return Icons.payment_rounded;
    }
  }
}
