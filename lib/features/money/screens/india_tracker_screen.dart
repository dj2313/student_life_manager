import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/india_tracker_provider.dart';
import '../providers/money_provider.dart';
import '../../../data/models/india_tracker_models.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class IndiaTrackerScreen extends StatefulWidget {
  const IndiaTrackerScreen({super.key});

  @override
  State<IndiaTrackerScreen> createState() => _IndiaTrackerScreenState();
}

class _IndiaTrackerScreenState extends State<IndiaTrackerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IndiaTrackerProvider>(
      builder: (context, provider, child) {
        return Consumer<MoneyProvider>(
          builder: (context, moneyProvider, child) {
            final textColor = Theme.of(context).colorScheme.primary;

            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leadingWidth: 120.w,
                leading: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: textColor,
                        size: 20.sp,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    _buildCurrencySelector(context, moneyProvider),
                  ],
                ),
                title: Text(
                  'India → Germany',
                  style: GoogleFonts.outfit(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                centerTitle: true,
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.secondary,
                  labelColor: textColor,
                  unselectedLabelColor: AppColors.textTertiaryLight,
                  tabs: const [
                    Tab(text: 'Items Inventory'),
                    Tab(text: 'Travel Expenses'),
                  ],
                ),
              ),
              body: Column(
                children: [
                  _buildReadinessProgress(context, provider),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildItemsTab(context, provider, moneyProvider),
                        _buildExpensesTab(context, provider, moneyProvider),
                      ],
                    ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () =>
                    _showAddDialog(context, provider, moneyProvider),
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildItemsTab(
    BuildContext context,
    IndiaTrackerProvider provider,
    MoneyProvider moneyProvider,
  ) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final categories = ['Clothes', 'Food', 'Electronics', 'Gifts', 'Misc'];
    final convertedTotal = moneyProvider.convertCurrency(
      provider.totalItemValueEur,
      'EUR',
      moneyProvider.selectedCurrency,
    );
    final symbol = moneyProvider.getCurrencySymbol(
      moneyProvider.selectedCurrency,
    );

    return ListView(
      padding: EdgeInsets.all(24.w),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildStatCard(
          context,
          'Total Inventory Value',
          '$symbol${convertedTotal.toStringAsFixed(2)}',
          Icons.inventory_2_outlined,
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        SizedBox(height: 32.h),
        ...categories.map((cat) {
          final items = provider.items.where((i) => i.category == cat).toList();
          if (items.isEmpty) return const SizedBox.shrink();
          return _buildCategorySection(
            context,
            cat,
            items,
            provider,
            moneyProvider,
          );
        }),
      ],
    );
  }

  Widget _buildExpensesTab(
    BuildContext context,
    IndiaTrackerProvider provider,
    MoneyProvider moneyProvider,
  ) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final convertedTotal = moneyProvider.convertCurrency(
      provider.totalTravelExpenseEur,
      'EUR',
      moneyProvider.selectedCurrency,
    );
    final symbol = moneyProvider.getCurrencySymbol(
      moneyProvider.selectedCurrency,
    );

    return ListView(
      padding: EdgeInsets.all(24.w),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildStatCard(
          context,
          'Total Journey Cost',
          '$symbol${convertedTotal.toStringAsFixed(2)}',
          Icons.flight_takeoff_rounded,
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        SizedBox(height: 32.h),
        Text(
          'EXPENSE LOG',
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textTertiaryLight,
            letterSpacing: 1.5,
          ),
        ).animate().fadeIn(delay: 200.ms),
        SizedBox(height: 16.h),
        ...provider.travelExpenses.indexed.map((item) {
          final index = item.$1;
          final exp = item.$2;
          return _buildExpenseTile(context, exp, moneyProvider)
              .animate(delay: (100 * index).ms)
              .fadeIn()
              .slideX(begin: 0.1, end: 0);
        }),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(icon, color: Colors.white, size: 28.sp),
          ),
          SizedBox(width: 20.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: Colors.white70,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    String cat,
    List<IndiaItem> items,
    IndiaTrackerProvider provider,
    MoneyProvider moneyProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 12.h, top: 24.h),
          child: Text(
            cat.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textTertiaryLight,
              letterSpacing: 1.5,
            ),
          ),
        ).animate().fadeIn(),
        ...items.indexed.map(
          (item) => _buildItemTile(context, item.$2, provider, moneyProvider)
              .animate(delay: (50 * item.$1).ms)
              .fadeIn()
              .slideX(begin: 0.1, end: 0),
        ),
      ],
    );
  }

  Widget _buildItemTile(
    BuildContext context,
    IndiaItem item,
    IndiaTrackerProvider provider,
    MoneyProvider moneyProvider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final convertedVal = moneyProvider.convertCurrency(
      item.valueEur,
      'EUR',
      moneyProvider.selectedCurrency,
    );
    final symbol = moneyProvider.getCurrencySymbol(
      moneyProvider.selectedCurrency,
    );

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => provider.deleteItem(item.id),
      child: GestureDetector(
        onLongPress: () =>
            _showAddItemDialog(context, provider, moneyProvider, item: item),
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.015) : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.035),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${item.quantity}x',
                  style: GoogleFonts.jetBrainsMono(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                    fontSize: 12.sp,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        color: isDark ? Colors.white : AppColors.primary,
                      ),
                    ),
                    Text(
                      DateFormat('EEE, MMM dd • hh:mm a').format(item.date),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$symbol${convertedVal.toStringAsFixed(0)}',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.primary,
                    ),
                  ),
                  Text(
                    '₹${item.valueInr.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: AppColors.textSecondaryLight,
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

  Widget _buildExpenseTile(
    BuildContext context,
    IndiaTravelExpense exp,
    MoneyProvider moneyProvider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<IndiaTrackerProvider>(context, listen: false);
    final convertedVal = moneyProvider.convertCurrency(
      exp.amountEur,
      'EUR',
      moneyProvider.selectedCurrency,
    );
    final symbol = moneyProvider.getCurrencySymbol(
      moneyProvider.selectedCurrency,
    );

    return Dismissible(
      key: Key(exp.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => provider.deleteTravelExpense(exp.id),
      child: GestureDetector(
        onLongPress: () => _showAddExpenseDialog(
          context,
          provider,
          moneyProvider,
          expense: exp,
        ),
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.015) : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.035),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  exp.type == 'Flight'
                      ? Icons.flight_takeoff_rounded
                      : Icons.description_outlined,
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
                      exp.title,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.primary,
                      ),
                    ),
                    Text(
                      DateFormat('EEE, MMM dd • hh:mm a').format(exp.date),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$symbol${convertedVal.toStringAsFixed(0)}',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.primary,
                    ),
                  ),
                  Text(
                    '₹${exp.amountInr.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: AppColors.textSecondaryLight,
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

  void _showAddDialog(
    BuildContext context,
    IndiaTrackerProvider provider,
    MoneyProvider moneyProvider,
  ) {
    if (_tabController.index == 0) {
      _showAddItemDialog(context, provider, moneyProvider);
    } else {
      _showAddExpenseDialog(context, provider, moneyProvider);
    }
  }

  void _showAddItemDialog(
    BuildContext context,
    IndiaTrackerProvider provider,
    MoneyProvider moneyProvider, {
    IndiaItem? item,
  }) {
    // ... same as before but using moneyProvider for rate
    final nameController = TextEditingController(text: item?.name);
    final qtyController = TextEditingController(
      text: item?.quantity.toString(),
    );
    final inrController = TextEditingController(
      text: item?.valueInr.toStringAsFixed(0),
    );
    String selectedCategory = item?.category ?? 'Clothes';

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
                item == null ? 'Add India Item' : 'Update India Item',
                style: GoogleFonts.outfit(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24.h),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Item Name',
                  labelText: 'Name',
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: qtyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Qty'),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: TextField(
                      controller: inrController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Value (INR)',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: ['Clothes', 'Food', 'Electronics', 'Gifts', 'Misc']
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
                    if (nameController.text.isNotEmpty) {
                      final inr = double.tryParse(inrController.text) ?? 0;
                      final newItem = IndiaItem(
                        id: item?.id ?? const Uuid().v4(),
                        name: nameController.text,
                        category: selectedCategory,
                        quantity: int.tryParse(qtyController.text) ?? 1,
                        valueInr: inr,
                        valueEur: inr * moneyProvider.inrToEurRate,
                        date: item?.date ?? DateTime.now(),
                      );

                      if (item == null) {
                        provider.addItem(newItem);
                      } else {
                        provider.updateItem(newItem);
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    item == null ? 'Add to Inventory' : 'Update Item',
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

  void _showAddExpenseDialog(
    BuildContext context,
    IndiaTrackerProvider provider,
    MoneyProvider moneyProvider, {
    IndiaTravelExpense? expense,
  }) {
    final titleController = TextEditingController(text: expense?.title);
    final inrController = TextEditingController(
      text: expense?.amountInr.toStringAsFixed(0),
    );
    String selectedType = expense?.type ?? 'Flight';

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
                expense == null ? 'Add Travel Expense' : 'Update Expense',
                style: GoogleFonts.outfit(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24.h),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Flight Ticket',
                  labelText: 'Title',
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: inrController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount (INR)'),
              ),
              SizedBox(height: 16.h),
              DropdownButtonFormField<String>(
                value: selectedType,
                items: ['Flight', 'Visa', 'Insurance', 'Setup', 'Misc']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => selectedType = v!),
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      final inr = double.tryParse(inrController.text) ?? 0;
                      final newExpense = IndiaTravelExpense(
                        id: expense?.id ?? const Uuid().v4(),
                        title: titleController.text,
                        description: expense?.description ?? 'Added from app',
                        amountInr: inr,
                        amountEur: inr * moneyProvider.inrToEurRate,
                        date: expense?.date ?? DateTime.now(),
                        type: selectedType,
                      );

                      if (expense == null) {
                        provider.addTravelExpense(newExpense);
                      } else {
                        provider.updateTravelExpense(newExpense);
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    expense == null ? 'Log Expense' : 'Update Expense',
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

  Widget _buildCurrencySelector(BuildContext context, MoneyProvider provider) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: AppColors.secondary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              provider.selectedCurrency,
              style: GoogleFonts.jetBrainsMono(
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
                fontSize: 12.sp,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.secondary,
              size: 16.sp,
            ),
          ],
        ),
      ),
      onSelected: (String code) => provider.setSelectedCurrency(code),
      itemBuilder: (BuildContext context) {
        return provider.supportedCurrencies.map((String code) {
          return PopupMenuItem<String>(
            value: code,
            child: Row(
              children: [
                Text(
                  provider.getCurrencySymbol(code),
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 12.w),
                Text(code, style: GoogleFonts.inter()),
              ],
            ),
          );
        }).toList();
      },
    );
  }

  Widget _buildReadinessProgress(
    BuildContext context,
    IndiaTrackerProvider provider,
  ) {
    final progress = provider.readinessScore;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 8.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.04),
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
                    'Migration Readiness'.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: AppColors.secondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${(progress * 100).toInt()}% Prepared',
                    style: GoogleFonts.outfit(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.primary,
                    ),
                  ),
                ],
              ),
              Icon(
                    progress >= 1.0
                        ? Icons.verified_rounded
                        : Icons.rocket_launch_outlined,
                    color: progress >= 1.0
                        ? AppColors.success
                        : AppColors.secondary,
                    size: 28.sp,
                  )
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .scale(
                    duration: 2.seconds,
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                  ),
            ],
          ),
          SizedBox(height: 16.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10.h,
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 0.8 ? AppColors.success : AppColors.secondary,
              ),
            ),
          ).animate().shimmer(
            duration: 2.seconds,
            color: Colors.white.withOpacity(0.2),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }
}
