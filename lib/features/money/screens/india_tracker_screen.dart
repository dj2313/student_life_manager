import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/india_tracker_provider.dart';
import '../../../data/models/india_tracker_models.dart';
import 'package:uuid/uuid.dart';

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
        final textColor = Theme.of(context).colorScheme.primary;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: textColor,
                size: 20.sp,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'India → Germany',
              style: GoogleFonts.outfit(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
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
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildItemsTab(context, provider),
              _buildExpensesTab(context, provider),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddDialog(context, provider),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildItemsTab(BuildContext context, IndiaTrackerProvider provider) {
    if (provider.isLoading)
      return const Center(child: CircularProgressIndicator());

    final categories = ['Clothes', 'Food', 'Electronics', 'Gifts', 'Misc'];

    return ListView(
      padding: EdgeInsets.all(24.w),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildStatCard(
          context,
          'Total Inventory Value',
          '€${provider.totalItemValueEur.toStringAsFixed(2)}',
          Icons.inventory_2_outlined,
        ),
        SizedBox(height: 32.h),
        ...categories.map((cat) {
          final items = provider.items.where((i) => i.category == cat).toList();
          if (items.isEmpty) return const SizedBox.shrink();
          return _buildCategorySection(context, cat, items, provider);
        }),
      ],
    );
  }

  Widget _buildExpensesTab(
    BuildContext context,
    IndiaTrackerProvider provider,
  ) {
    if (provider.isLoading)
      return const Center(child: CircularProgressIndicator());

    return ListView(
      padding: EdgeInsets.all(24.w),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildStatCard(
          context,
          'Total Journey Cost',
          '€${provider.totalTravelExpenseEur.toStringAsFixed(2)}',
          Icons.flight_takeoff_rounded,
        ),
        SizedBox(height: 32.h),
        Text(
          'EXPENSE LOG',
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textTertiaryLight,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 16.h),
        ...provider.travelExpenses.map(
          (exp) => _buildExpenseTile(context, exp),
        ),
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
        ),
        ...items.map((item) => _buildItemTile(context, item, provider)),
      ],
    );
  }

  Widget _buildItemTile(
    BuildContext context,
    IndiaItem item,
    IndiaTrackerProvider provider,
  ) {
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
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Theme.of(context).dividerColor),
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
              child: Text(
                item.name,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '€${item.valueEur.toStringAsFixed(0)}',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
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
    );
  }

  Widget _buildExpenseTile(BuildContext context, IndiaTravelExpense exp) {
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
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12.r),
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
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  exp.description,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: AppColors.textSecondaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '€${exp.amountEur.toStringAsFixed(0)}',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
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
    );
  }

  void _showAddDialog(BuildContext context, IndiaTrackerProvider provider) {
    if (_tabController.index == 0) {
      _showAddItemDialog(context, provider);
    } else {
      _showAddExpenseDialog(context, provider);
    }
  }

  void _showAddItemDialog(BuildContext context, IndiaTrackerProvider provider) {
    final nameController = TextEditingController();
    final qtyController = TextEditingController();
    final inrController = TextEditingController();
    String selectedCategory = 'Clothes';

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
                'Add India Item',
                style: GoogleFonts.outfit(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24.h),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Item Name (e.g. Jeans)',
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
                      decoration: InputDecoration(
                        hintText: 'Quantity',
                        labelText: 'Qty',
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: TextField(
                      controller: inrController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Value in ₹',
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
                      provider.addItem(
                        IndiaItem(
                          id: const Uuid().v4(),
                          name: nameController.text,
                          category: selectedCategory,
                          quantity: int.tryParse(qtyController.text) ?? 1,
                          valueInr: inr,
                          valueEur: inr / 90, // Simple conversion for mock
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add to Inventory'),
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
  ) {
    final titleController = TextEditingController();
    final inrController = TextEditingController();
    String selectedType = 'Flight';

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
                'Add Travel Expense',
                style: GoogleFonts.outfit(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24.h),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'e.g. Flight Ticket',
                  labelText: 'Title',
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: inrController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Amount in ₹',
                  labelText: 'Amount (INR)',
                ),
              ),
              SizedBox(height: 16.h),
              DropdownButtonFormField<String>(
                value: selectedType,
                items: ['Flight', 'Visa', 'Insurance', 'Setup', 'Misc']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => selectedType = v!),
                decoration: const InputDecoration(labelText: 'Expense Type'),
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      final inr = double.tryParse(inrController.text) ?? 0;
                      provider.addTravelExpense(
                        IndiaTravelExpense(
                          id: const Uuid().v4(),
                          title: titleController.text,
                          description: 'Added from app',
                          amountInr: inr,
                          amountEur: inr / 90,
                          date: DateTime.now(),
                          type: selectedType,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Log Expense'),
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
