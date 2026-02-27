import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/money_provider.dart';
import '../../../data/models/expense.dart';
import 'india_tracker_screen.dart';
import 'groceries_screen.dart';
import 'blocked_account_screen.dart';
import '../widgets/live_currency_converter.dart';
import '../providers/job_provider.dart';
import '../../../data/models/subscription.dart';

import './job_tracker_screen.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/widgets/premium_empty_state.dart';
import '../../../core/services/csv_export_service.dart';
import '../../../core/widgets/premium_shimmer.dart';
import '../../../core/services/ocr_service.dart';

class MoneyDashboard extends StatefulWidget {
  const MoneyDashboard({super.key});

  @override
  State<MoneyDashboard> createState() => _MoneyDashboardState();
}

class _MoneyDashboardState extends State<MoneyDashboard> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MoneyProvider>(
      builder: (context, moneyProvider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: RefreshIndicator(
            onRefresh: () => moneyProvider.fetchBalances(),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(context, moneyProvider),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12.h),
                        _buildMinimalBalanceSection(context, moneyProvider),
                        SizedBox(height: 24.h),
                        _buildQuickActionChips(context, moneyProvider),
                        SizedBox(height: 32.h),
                        _buildIndiaTrackerCard(context),
                        SizedBox(height: 40.h),
                        _buildSpendingAnalytics(context, moneyProvider),
                        SizedBox(height: 40.h),
                        _buildSubscriptionSection(context, moneyProvider),
                        SizedBox(height: 40.h),
                        _buildJobTrackerSection(context),
                        SizedBox(height: 40.h),
                        _buildAccountsSection(context, moneyProvider),
                        SizedBox(height: 40.h),
                        _buildTransactionsSection(context, moneyProvider),
                        SizedBox(height: 120.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context, MoneyProvider provider) {
    return SliverAppBar(
      expandedHeight: 60.h,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'FINANCIAL PORTFOLIO',
        style: GoogleFonts.outfit(
          fontSize: 16.sp,
          fontWeight: FontWeight.w800,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 2.0,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.file_download_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 22.sp,
          ),
          onPressed: () => CSVExportService.exportExpenses(provider.expenses),
        ),
        IconButton(
          icon: Icon(
            Icons.tune_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 22.sp,
          ),
          onPressed: () {},
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildMinimalBalanceSection(
    BuildContext context,
    MoneyProvider provider,
  ) {
    if (provider.isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: PremiumShimmer(
          width: double.infinity,
          height: 180.h,
          borderRadius: 28,
        ),
      );
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final spending = provider.getMonthlySpending();
    final budget = provider.monthlyBudget;
    final rawRatio = budget > 0 ? spending / budget : 0.0;
    final ratio = rawRatio.isFinite ? rawRatio : 0.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1.5),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: AppColors.primary.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL LIQUID ASSETS',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 6.h),
                          child: Text(
                            '€',
                            style: GoogleFonts.outfit(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          provider.totalBalance.toStringAsFixed(2),
                          style: GoogleFonts.outfit(
                            fontSize: 38.sp,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.primary,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'FORECAST END OF MONTH: €${provider.forecastedBalanceEndMonth.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: provider.forecastedBalanceEndMonth < 200
                            ? AppColors.error
                            : AppColors.success,
                      ),
                    ),
                  ],
                ),
                _buildBudgetMiniCircle(ratio, isDark),
              ],
            ),
          ),
          // Add budget settings action
          InkWell(
            onTap: () => _showBudgetEditDialog(context, provider),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
              child: Row(
                children: [
                  Icon(
                    Icons.edit_note_rounded,
                    size: 14.sp,
                    color: AppColors.secondary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'ADJUST MONTHLY TARGET',
                    style: GoogleFonts.inter(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 18.h),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.02)
                  : AppColors.surfaceLight,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(28.r),
              ),
            ),
            child: Row(
              children: [
                _buildCompactStat(
                  'SAVINGS',
                  '€${provider.totalBalance.toStringAsFixed(0)}',
                  AppColors.primary,
                  isDark,
                ),
                SizedBox(width: 32.w),
                _buildCompactStat(
                  'BLOCKED',
                  '€${provider.blockedAccountBalance.toStringAsFixed(0)}',
                  AppColors.secondary,
                  isDark,
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.03)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.03),
                    ),
                  ),
                  child: Text(
                    '${(ratio * 100).toInt()}% BUDGETED',
                    style: GoogleFonts.inter(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w800,
                      color: ratio > 0.9
                          ? AppColors.error
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetMiniCircle(double ratio, bool isDark) {
    final statusColor = ratio > 0.9 ? AppColors.error : AppColors.accent;
    return SizedBox(
      width: 52.w,
      height: 52.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 5,
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.03),
          ),
          CircularProgressIndicator(
            value: ratio.clamp(0, 1),
            strokeWidth: 5,
            strokeCap: StrokeCap.round,
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
          ),
          Icon(
            ratio > 0.9
                ? Icons.warning_amber_rounded
                : Icons.account_balance_rounded,
            size: 20.sp,
            color: statusColor.withOpacity(0.6),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStat(
    String label,
    String value,
    Color color,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9.sp,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionChips(BuildContext context, MoneyProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 75.h,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildActionChip(
              context,
              Icons.add_task_rounded,
              'EXPENSE',
              AppColors.primary,
              isDark,
              () => _showAddExpenseDialog(context, provider),
            ),
            SizedBox(width: 12.w),
            _buildActionChip(
              context,
              Icons.document_scanner_rounded,
              'SCAN',
              AppColors.secondary,
              isDark,
              () => _handleReceiptScan(context, provider),
            ),
            SizedBox(width: 12.w),
            _buildActionChip(
              context,
              Icons.auto_awesome_motion_rounded,
              'RATES',
              AppColors.accent,
              isDark,
              () => _showCurrencyRatesSheet(context),
            ),
            SizedBox(width: 12.w),
            _buildActionChip(
              context,
              Icons.inventory_2_outlined,
              'ITEMS',
              AppColors.success,
              isDark,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GroceriesScreen(),
                ),
              ),
            ),
            SizedBox(width: 12.w),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    bool isDark,
    VoidCallback onTap, {
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: () {
        context.hapticClick();
        onTap();
      },
      child: Container(
        width: 85.w,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: isActive
              ? color
              : (isDark ? Colors.white.withOpacity(0.02) : Colors.white),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isActive
                ? color
                : (isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.04)),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : color.withOpacity(0.8),
              size: 20.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: isActive
                    ? Colors.white
                    : (isDark ? Colors.white38 : Colors.black38),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyRatesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 24.h),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            const LiveCurrencyConverter(),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsSection(BuildContext context, MoneyProvider provider) {
    if (provider.isLoading) {
      return Column(
        children: [
          PremiumShimmer(width: double.infinity, height: 80.h),
          SizedBox(height: 12.h),
          PremiumShimmer(width: double.infinity, height: 80.h),
        ],
      );
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MANAGED ACCOUNTS',
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),
            TextButton(
              onPressed: () => _showUpdateSheet(context, provider),
              child: Text(
                'EDIT PORTFOLIO',
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        _buildMiniAccountTile(
          context,
          'Blocked Account',
          '€${provider.blockedAccountBalance.toStringAsFixed(2)}',
          Icons.verified_user_outlined,
          AppColors.primary,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BlockedAccountScreen(),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        _buildMiniAccountTile(
          context,
          'Personal Savings',
          '€${provider.totalBalance.toStringAsFixed(2)}',
          Icons.wallet_outlined,
          AppColors.secondary,
          () => _showUpdateSheet(context, provider, isBlocked: false),
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
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.02) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.035),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Active Portfolio Balance',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              amount,
              style: GoogleFonts.outfit(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateSheet(
    BuildContext context,
    MoneyProvider provider, {
    bool isBlocked = false,
  }) {
    final personalController = TextEditingController(
      text: provider.totalBalance.toString(),
    );
    final blockedController = TextEditingController(
      text: provider.blockedAccountBalance.toString(),
    );

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Update Balances',
              style: GoogleFonts.outfit(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Adjust your current liquidity across accounts',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: AppColors.textSecondaryLight,
              ),
            ),
            SizedBox(height: 32.h),
            _buildUpdateField(
              context,
              'Personal Account',
              personalController,
              Icons.wallet_outlined,
              AppColors.primary,
            ),
            SizedBox(height: 20.h),
            _buildUpdateField(
              context,
              'Blocked Account',
              blockedController,
              Icons.verified_user_outlined,
              AppColors.secondary,
            ),
            SizedBox(height: 40.h),
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: () {
                  provider.updateBalances(
                    personal: double.tryParse(personalController.text),
                    blocked: double.tryParse(blockedController.text),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: const Text('Save Changes'),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateField(
    BuildContext context,
    String label,
    TextEditingController controller,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondaryLight,
          ),
        ),
        SizedBox(height: 12.h),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: color),
            prefixText: '€ ',
            prefixStyle: GoogleFonts.outfit(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            filled: true,
            fillColor: color.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: color.withOpacity(0.1)),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddExpenseDialog(
    BuildContext context,
    MoneyProvider provider, {
    Expense? expense,
  }) {
    final descController = TextEditingController(text: expense?.description);
    final amountController = TextEditingController(
      text: expense?.amount == 0 ? '' : expense?.amount.toString(),
    );
    final formKey = GlobalKey<FormState>();
    DateTime selectedDate = expense?.date ?? DateTime.now();
    String selectedCategory = expense?.category ?? 'Food';
    bool isBlocked = expense?.isBlockedAccount ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    expense == null ? 'Record Expense' : 'Modify Record',
                    style: GoogleFonts.outfit(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (expense != null)
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.error,
                      ),
                      onPressed: () {
                        provider.deleteExpense(expense);
                        Navigator.pop(context);
                      },
                    ),
                ],
              ),
              SizedBox(height: 24.h),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedDate),
                    );
                    if (time != null) {
                      setState(() {
                        selectedDate = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 18.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        DateFormat(
                          'EEE, MMM dd, yyyy • hh:mm a',
                        ).format(selectedDate),
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Amount (€)',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an amount';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Please enter a valid amount > 0';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items:
                    [
                          'Housing',
                          'Food',
                          'Entertainment',
                          'Education',
                          'Travel',
                          'Govt',
                        ]
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                onChanged: (v) => setState(() => selectedCategory = v!),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              SizedBox(height: 16.h),
              SwitchListTile(
                title: Text(
                  'Blocked Account Transaction',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Withdrawal from blocked assets',
                  style: GoogleFonts.inter(fontSize: 11.sp),
                ),
                value: isBlocked,
                onChanged: (v) => setState(() => isBlocked = v),
                activeColor: AppColors.secondary,
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final newExpense = Expense(
                        id: expense?.id ?? const Uuid().v4(),
                        description: descController.text,
                        amount: double.tryParse(amountController.text) ?? 0,
                        date: selectedDate,
                        category: selectedCategory,
                        isBlockedAccount: isBlocked,
                      );

                      if (expense == null) {
                        provider.addExpense(newExpense);
                      } else {
                        provider.updateExpense(newExpense);
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    expense == null ? 'RECORD SETTLEMENT' : 'UPDATE RECORD',
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpendingAnalytics(BuildContext context, MoneyProvider provider) {
    final categoryData = provider.getCategorySpending();
    final total = categoryData.values.fold(0.0, (sum, item) => sum + item);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SPENDING ANALYTICS',
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textTertiaryLight,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.08),
            ),
          ),
          child: Column(
            children: categoryData.entries.map((entry) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final ratio = total > 0 ? entry.value / total : 0.0;
              final categoryColor = _getCategoryColor(entry.key);
              return Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10.w,
                              height: 10.w,
                              decoration: BoxDecoration(
                                color: categoryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              entry.key.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '€${entry.value.toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 4.h,
                        backgroundColor: isDark
                            ? Colors.white.withOpacity(0.03)
                            : Colors.black.withOpacity(0.03),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          categoryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showBudgetEditDialog(BuildContext context, MoneyProvider provider) {
    final controller = TextEditingController(
      text: provider.monthlyBudget.toStringAsFixed(0),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Set Monthly Budget',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Target Spending (€)',
            prefixIcon: Icon(Icons.euro),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text) ?? 600.0;
              provider.updateMonthlyBudget(val);
              Navigator.pop(context);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionSection(
    BuildContext context,
    MoneyProvider provider,
  ) {
    if (provider.isLoading) {
      return PremiumShimmer(width: double.infinity, height: 120.h);
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RECURRING SUBSCRIPTIONS',
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),
            GestureDetector(
              onTap: () => _showAddSubscriptionDialog(context, provider),
              child: Text(
                'ADD NEW',
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        if (provider.subscriptions.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Text(
                'No active subscriptions',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 100.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: provider.subscriptions.length,
              separatorBuilder: (context, index) => SizedBox(width: 12.w),
              itemBuilder: (context, index) {
                final sub = provider.subscriptions[index];
                return GestureDetector(
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Stop Tracking?'),
                        content: Text('Remove ${sub.name} from subscriptions?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('CANCEL'),
                          ),
                          TextButton(
                            onPressed: () {
                              provider.deleteSubscription(sub.id);
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'DELETE',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    width: 160.w,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                sub.name,
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              _getCategoryIcon(sub.category),
                              size: 14.sp,
                              color: AppColors.secondary,
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '€${sub.amount.toStringAsFixed(2)} / ${sub.frequency}',
                          style: GoogleFonts.outfit(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Next: ${DateFormat('MMM dd').format(sub.nextRenewal)}',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: isDark
                                ? AppColors.textTertiaryDark
                                : AppColors.textTertiaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showAddSubscriptionDialog(
    BuildContext context,
    MoneyProvider provider,
  ) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = 'Entertainment';
    String selectedFrequency = 'Monthly';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'TRACK NEW SUBSCRIPTION',
                style: GoogleFonts.outfit(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 24.h),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Subscription Name (e.g. Netflix)',
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount (€)'),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items:
                          ['Entertainment', 'Education', 'Gym', 'Tool', 'Misc']
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                      onChanged: (v) =>
                          setModalState(() => selectedCategory = v!),
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedFrequency,
                      items: ['Monthly', 'Yearly']
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setModalState(() => selectedFrequency = v!),
                      decoration: const InputDecoration(labelText: 'Frequency'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        amountController.text.isNotEmpty) {
                      final sub = Subscription(
                        id: const Uuid().v4(),
                        name: nameController.text,
                        amount: double.tryParse(amountController.text) ?? 0,
                        category: selectedCategory,
                        nextRenewal: selectedDate,
                        frequency: selectedFrequency,
                      );
                      provider.addSubscription(sub);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('ACTIVATE TRACKING'),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndiaTrackerCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const IndiaTrackerScreen()),
      ),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.02)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.04),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppColors.categoryIndia.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.travel_explore_rounded,
                color: AppColors.categoryIndia,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INDIA → GERMANY',
                    style: GoogleFonts.outfit(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: AppColors.categoryIndia,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Migration & Travel Logistics',
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.categoryIndia.withOpacity(0.5),
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsSection(
    BuildContext context,
    MoneyProvider provider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RECENT SETTLEMENTS',
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                'LEDGER VIEW',
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        if (provider.expenses.isEmpty)
          PremiumEmptyState(
            icon: Icons.account_balance_wallet_outlined,
            title: 'No Settlements',
            subtitle:
                'You haven\'t recorded any expenses yet. Start tracking to see your analytics.',
            actionLabel: 'Record Expense',
            onActionPressed: () => _showAddExpenseDialog(context, provider),
          )
        else
          ...provider.expenses.take(5).map((expense) {
            return _buildTransactionItem(context, expense);
          }),
      ],
    );
  }

  Widget _buildTransactionItem(BuildContext context, Expense expense) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = _getCategoryColor(expense.category);
    final provider = Provider.of<MoneyProvider>(context, listen: false);

    return GestureDetector(
      onTap: () => _showAddExpenseDialog(context, provider, expense: expense),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.015) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.04)
                : Colors.black.withOpacity(0.03),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getCategoryIcon(expense.category),
                color: categoryColor,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        expense.description.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                          color: isDark ? Colors.white : AppColors.primary,
                        ),
                      ),
                      if (expense.isBlockedAccount) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'BLOCKED',
                            style: GoogleFonts.inter(
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    DateFormat('EEE, MMM dd • hh:mm a').format(expense.date),
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '-€${expense.amount.toStringAsFixed(2)}',
              style: GoogleFonts.outfit(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.primary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'housing':
        return AppColors.categoryTransport;
      case 'food':
        return AppColors.categoryGroceries;
      case 'entertainment':
        return AppColors.categoryElectronics;
      case 'education':
        return AppColors.primary;
      case 'travel':
        return AppColors.categoryIndia;
      default:
        return AppColors.categoryMisc;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'housing':
        return Icons.roofing_rounded;
      case 'food':
        return Icons.local_dining_outlined;
      case 'entertainment':
        return Icons.interests_outlined;
      case 'education':
        return Icons.school_outlined;
      case 'travel':
        return Icons.train_outlined;
      default:
        return Icons.all_out_rounded;
    }
  }

  Widget _buildJobTrackerSection(BuildContext context) {
    return Consumer<JobProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: EdgeInsets.all(24.w),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WERKSTUDENT STATUS',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: AppColors.textTertiaryLight,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Employment Threshold',
                        style: GoogleFonts.outfit(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  _buildCircularProgressIndicator(provider.usagePercentage),
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14.sp,
                    color: AppColors.accent,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '${provider.totalDaysWorked.toStringAsFixed(1)} / 140.0 Days Utilized',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: context.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: _buildNaturalButton(
                  'Manage Work Hours',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const JobTrackerScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCircularProgressIndicator(double progress) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 44.w,
      height: 44.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 4,
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.03),
          ),
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 4,
            strokeCap: StrokeCap.round,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
          Text(
            '${(progress * 100).toInt()}%',
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNaturalButton(String label, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.03)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.04),
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: isDark ? Colors.white70 : AppColors.primary,
          ),
        ),
      ),
    );
  }

  void _showScanningDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(32.w),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                    Icons.document_scanner_rounded,
                    size: 48.sp,
                    color: AppColors.secondary,
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 1.5.seconds),
              SizedBox(height: 16.h),
              Text(
                'Extracting Data...',
                style: GoogleFonts.outfit(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleReceiptScan(BuildContext context, MoneyProvider provider) async {
    final ImagePicker picker = ImagePicker();

    // Show source picker
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SELECT RECEIPT SOURCE',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w800,
                fontSize: 12.sp,
              ),
            ),
            SizedBox(height: 24.h),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final XFile? image = await picker.pickImage(source: source);
    if (image == null) return;

    if (!context.mounted) return;
    _showScanningDialog(context);

    try {
      final ocrService = OCRService();
      final data = await ocrService.scanReceipt(File(image.path));
      ocrService.dispose();

      if (!context.mounted) return;
      Navigator.pop(context); // Close scanning dialog

      _showScannedReceiptDialog(context, provider, data);
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to parse receipt. Try again.')),
      );
    }
  }

  void _showScannedReceiptDialog(
    BuildContext context,
    MoneyProvider provider,
    Map<String, dynamic> data,
  ) {
    final amountController = TextEditingController(
      text: data['amount'].toString(),
    );
    final descController = TextEditingController(
      text: '${data['store']} - ${(data['items'] as List).join(', ')}',
    );
    DateTime selectedDate = DateTime.now();
    String selectedCategory = data['category'];
    bool isBlocked = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Receipt Scanned Successfully',
                    style: GoogleFonts.outfit(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColors.secondary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DETECTED ITEMS',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.secondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    ...(data['items'] as List).map(
                      (item) => Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check,
                              size: 14.sp,
                              color: AppColors.success,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              item,
                              style: GoogleFonts.inter(fontSize: 12.sp),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount (€)'),
              ),
              SizedBox(height: 16.h),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items:
                    [
                          'Housing',
                          'Food',
                          'Entertainment',
                          'Education',
                          'Travel',
                          'Govt',
                        ]
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                onChanged: (v) => setState(() => selectedCategory = v!),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              SizedBox(height: 16.h),
              SwitchListTile(
                title: Text(
                  'Blocked Account Transaction',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                value: isBlocked,
                onChanged: (v) => setState(() => isBlocked = v),
                activeColor: AppColors.secondary,
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: () {
                    if (descController.text.isNotEmpty &&
                        amountController.text.isNotEmpty) {
                      final newExpense = Expense(
                        id: const Uuid().v4(),
                        description: descController.text,
                        amount: double.tryParse(amountController.text) ?? 0,
                        date: selectedDate,
                        category: selectedCategory,
                        isBlockedAccount: isBlocked,
                      );
                      provider.addExpense(newExpense);
                      Navigator.pop(context);

                      // Show success snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '€${newExpense.amount.toStringAsFixed(2)} expense logged!',
                          ),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: const Text('CONFIRM & LOG EXPENSE'),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }
}
