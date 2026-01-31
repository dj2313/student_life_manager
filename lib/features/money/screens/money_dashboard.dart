import 'package:flutter/material.dart';
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
import 'loan_screen.dart';
import 'groceries_screen.dart';
import '../widgets/live_currency_converter.dart';

class MoneyDashboard extends StatelessWidget {
  const MoneyDashboard({super.key});

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
                        _buildBalanceSection(context, moneyProvider),
                        SizedBox(height: 32.h),
                        _buildQuickActionChips(context, moneyProvider),
                        SizedBox(height: 40.h),
                        _buildAccountsSection(context, moneyProvider),
                        SizedBox(height: 40.h),
                        _buildMonthlyChart(context, moneyProvider),
                        SizedBox(height: 40.h),
                        const LiveCurrencyConverter(),
                        SizedBox(height: 40.h),
                        _buildBudgetPreview(context, moneyProvider),
                        SizedBox(height: 40.h),
                        _buildIndiaTrackerCard(context),
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
    final textColor = Theme.of(context).colorScheme.primary;
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
          color: textColor,
          letterSpacing: 1.2,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications_none_outlined,
            color: textColor,
            size: 24.sp,
          ),
          onPressed: () {},
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildBalanceSection(BuildContext context, MoneyProvider provider) {
    final textColor = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Liquidity',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: AppColors.textSecondaryLight,
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
                color: textColor,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionChips(BuildContext context, MoneyProvider provider) {
    return Row(
      children: [
        _buildActionChip(
          context,
          Icons.add_rounded,
          'Expense',
          AppColors.primary,
          () => _showAddExpenseDialog(context, provider),
        ),
        SizedBox(width: 12.w),
        _buildActionChip(
          context,
          Icons.handshake_outlined,
          'Loans',
          AppColors.secondary,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoanScreen()),
          ),
        ),
        SizedBox(width: 12.w),
        _buildActionChip(
          context,
          Icons.shopping_cart_outlined,
          'Groceries',
          AppColors.success,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GroceriesScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildActionChip(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
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
      ),
    );
  }

  Widget _buildAccountsSection(BuildContext context, MoneyProvider provider) {
    final textColor = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sub-Accounts',
          style: GoogleFonts.outfit(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        SizedBox(height: 16.h),
        _buildMiniAccountTile(
          context,
          'Blocked Account',
          '€${provider.blockedAccountBalance.toStringAsFixed(2)}',
          Icons.verified_user_outlined,
          textColor,
          () => _showUpdateBalanceDialog(context, provider, isBlocked: true),
        ),
        SizedBox(height: 12.h),
        _buildMiniAccountTile(
          context,
          'Personal Account',
          '€${provider.totalBalance.toStringAsFixed(2)}',
          Icons.wallet_outlined,
          AppColors.secondary,
          () => _showUpdateBalanceDialog(context, provider, isBlocked: false),
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
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
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
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            Text(
              amount,
              style: GoogleFonts.outfit(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateBalanceDialog(
    BuildContext context,
    MoneyProvider provider, {
    required bool isBlocked,
  }) {
    final controller = TextEditingController(
      text: (isBlocked ? provider.blockedAccountBalance : provider.totalBalance)
          .toString(),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update ${isBlocked ? "Blocked" : "Personal"} Balance'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(prefixText: '€ '),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final val = double.tryParse(controller.text) ?? 0;
              if (isBlocked)
                provider.updateBalances(blocked: val);
              else
                provider.updateBalances(personal: val);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context, MoneyProvider provider) {
    final descController = TextEditingController();
    final amountController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String selectedCategory = 'Food';

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
              Text(
                'Log Expense',
                style: GoogleFonts.outfit(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
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
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 16.sp,
                        color: AppColors.secondary,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        DateFormat('MMM dd, HH:mm').format(selectedDate),
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: () {
                    if (descController.text.isNotEmpty &&
                        amountController.text.isNotEmpty) {
                      provider.addExpense(
                        Expense(
                          id: const Uuid().v4(),
                          description: descController.text,
                          amount: double.tryParse(amountController.text) ?? 0,
                          date: selectedDate,
                          category: selectedCategory,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add Expense'),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
            ],
          ),
        ),
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
          Text(
            'Monthly Budget',
            style: GoogleFonts.outfit(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
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
              value: ratio.clamp(0.0, 1.0),
              minHeight: 6.h,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart(BuildContext context, MoneyProvider provider) {
    final categoryData = provider.getCategorySpending();
    List<BarChartGroupData> barGroups = [];
    int i = 0;
    categoryData.forEach((key, value) {
      barGroups.add(
        BarChartGroupData(
          x: i++,
          barRods: [
            BarChartRodData(
              toY: value,
              color: AppColors.secondary,
              width: 16.w,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ],
        ),
      );
    });
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending Analytics',
            style: GoogleFonts.outfit(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            height: 150.h,
            child: BarChart(
              BarChartData(
                barGroups: barGroups,
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= categoryData.keys.length)
                          return const SizedBox.shrink();
                        return Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Text(
                            categoryData.keys
                                .elementAt(value.toInt())
                                .substring(0, 3),
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.textTertiaryLight,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyCard(BuildContext context, MoneyProvider provider) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'INR to Germany (Live)',
                style: GoogleFonts.outfit(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Icon(
                Icons.sync_alt_rounded,
                size: 18.sp,
                color: AppColors.secondary,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹100 INR',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Indian Rupee',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                size: 20.sp,
                color: AppColors.textTertiaryLight,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '€${(provider.inrToEurRate * 100).toStringAsFixed(2)}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                    Text(
                      'Euro (Germany)',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIndiaTrackerCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const IndiaTrackerScreen()),
      ),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9966).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: const Icon(
                Icons.flight_takeoff_rounded,
                color: Color(0xFFFF9966),
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'India → Germany',
                    style: GoogleFonts.outfit(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    'Inventory & Travel Logs',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiaryLight,
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
                color: Theme.of(context).colorScheme.primary,
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
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Theme.of(context).dividerColor),
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
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  DateFormat('MMM dd, HH:mm').format(expense.date),
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
