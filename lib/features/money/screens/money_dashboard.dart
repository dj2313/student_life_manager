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
import 'loan_screen.dart';
import 'groceries_screen.dart';
import '../widgets/live_currency_converter.dart';

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

  Widget _buildMinimalBalanceSection(
    BuildContext context,
    MoneyProvider provider,
  ) {
    final spending = provider.getMonthlySpending();
    const budget = 600.0;
    final ratio = spending / budget;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(32.r),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.08),
          width: 1.5,
        ),
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
                      'TOTAL LIQUIDITY',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textTertiaryLight,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '€',
                          style: GoogleFonts.outfit(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.secondary,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          provider.totalBalance.toStringAsFixed(2),
                          style: GoogleFonts.outfit(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                _buildBudgetMiniCircle(ratio),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.03),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(32.r),
              ),
            ),
            child: Row(
              children: [
                _buildCompactStat(
                  'Personal',
                  '€${provider.totalBalance.toStringAsFixed(0)}',
                  AppColors.primary,
                ),
                SizedBox(width: 24.w),
                _buildCompactStat(
                  'Blocked',
                  '€${provider.blockedAccountBalance.toStringAsFixed(0)}',
                  AppColors.secondary,
                ),
                const Spacer(),
                Text(
                  'Budget: €${spending.toInt()}/$budget',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetMiniCircle(double ratio) {
    return SizedBox(
      width: 48.w,
      height: 48.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: ratio.clamp(0, 1),
            strokeWidth: 4,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              ratio > 0.9 ? AppColors.error : AppColors.success,
            ),
          ),
          Icon(
            ratio > 0.9 ? Icons.warning_rounded : Icons.bolt_rounded,
            size: 16.sp,
            color: ratio > 0.9 ? AppColors.error : AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9.sp,
            color: AppColors.textSecondaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
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
          Icons.currency_exchange_rounded,
          'Rates',
          AppColors.secondary,
          () => _showCurrencyRatesSheet(context),
        ),
        SizedBox(width: 12.w),
        _buildActionChip(
          context,
          Icons.shopping_cart_outlined,
          'Grocery',
          AppColors.success,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GroceriesScreen()),
          ),
        ),
        SizedBox(width: 12.w),
        _buildActionChip(
          context,
          Icons.handshake_outlined,
          'Loans',
          AppColors.accent,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoanScreen()),
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
    VoidCallback onTap, {
    bool isActive = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isActive ? color : color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isActive ? color : color.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isActive ? Colors.white : color, size: 22.sp),
              SizedBox(height: 6.h),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : color,
                ),
              ),
            ],
          ),
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
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showUpdateSheet(context, provider),
              icon: const Icon(Icons.edit_note_rounded, size: 20),
              label: const Text('Manage'),
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
          () => _showUpdateSheet(context, provider, isBlocked: true),
        ),
        SizedBox(height: 12.h),
        _buildMiniAccountTile(
          context,
          'Personal Account',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Active Balance',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: GoogleFonts.outfit(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_right_rounded,
                  size: 16.sp,
                  color: AppColors.textTertiaryLight,
                ),
              ],
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
                initialValue: selectedCategory,
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

  Widget _buildSpendingAnalytics(BuildContext context, MoneyProvider provider) {
    final categoryData = provider.getCategorySpending();
    final total = categoryData.values.fold(0.0, (sum, item) => sum + item);

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
              final ratio = total > 0 ? entry.value / total : 0.0;
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
                              width: 8.w,
                              height: 8.w,
                              decoration: const BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              entry.key,
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '€${entry.value.toStringAsFixed(0)}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 6.h,
                        backgroundColor: AppColors.secondary.withOpacity(0.05),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.secondary,
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
