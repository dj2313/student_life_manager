import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/money_provider.dart';
import '../../../data/models/expense.dart';
import 'india_tracker_screen.dart';
import 'groceries_screen.dart';
import 'blocked_account_screen.dart';
import '../widgets/live_currency_converter.dart';
import '../providers/job_provider.dart';

import './job_tracker_screen.dart';
import '../../../core/utils/context_extensions.dart';

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
                _buildSliverAppBar(context),
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

  Widget _buildSliverAppBar(BuildContext context) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final spending = provider.getMonthlySpending();
    const budget = 600.0;
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
                  ],
                ),
                _buildBudgetMiniCircle(ratio, isDark),
              ],
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
              () => _simulateScan(context, provider),
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
      text: expense?.amount.toString(),
    );
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
                    if (descController.text.isNotEmpty &&
                        amountController.text.isNotEmpty) {
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
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Text(
                'No recorded transactions',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
                ),
              ),
            ),
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

  void _simulateScan(BuildContext context, MoneyProvider provider) async {
    // Show scanning animation
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
                'Scanning Receipt...',
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

    // Simulate OCR processing
    await Future.delayed(const Duration(seconds: 2));

    if (!context.mounted) return;
    Navigator.pop(context); // Close scanning dialog

    // Simulated receipt data (German supermarket)
    final scannedData = {
      'store': 'REWE',
      'amount': 23.47,
      'category': 'Food',
      'items': ['Milch 1.5%', 'Brot Vollkorn', 'Äpfel 1kg', 'Käse Gouda'],
    };

    // Show parsed receipt with pre-filled expense dialog
    _showScannedReceiptDialog(context, provider, scannedData);
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
