import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/money_provider.dart';
import '../../../data/models/grocery.dart';

class GroceriesScreen extends StatelessWidget {
  const GroceriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MoneyProvider>(
      builder: (context, provider, child) {
        final textColor = Theme.of(context).colorScheme.primary;
        final groceries = provider.groceries;

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
              'Grocery Logs',
              style: GoogleFonts.outfit(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          body: ListView(
            padding: EdgeInsets.all(24.w),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildWeeklySummary(context, provider),
              SizedBox(height: 32.h),
              _buildSectionTitle(context, 'SHOPPING HISTORY'),
              SizedBox(height: 16.h),
              if (groceries.isEmpty)
                _buildEmptyState(context)
              else
                ...groceries.map((g) => _buildGroceryDayCard(context, g)),
              SizedBox(height: 100.h),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddTripDialog(context, provider),
            backgroundColor: AppColors.secondary,
            icon: const Icon(
              Icons.add_shopping_cart_rounded,
              color: Colors.white,
            ),
            label: Text(
              'New Trip',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
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
        color: AppColors.textTertiaryLight,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Text(
          'No grocery trips logged yet',
          style: GoogleFonts.inter(color: AppColors.textSecondaryLight),
        ),
      ),
    );
  }

  Widget _buildWeeklySummary(BuildContext context, MoneyProvider provider) {
    final spent = provider.groceries.fold(0.0, (sum, g) => sum + g.total);
    const budget = 60.0;
    final ratio = spent / budget;

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Budget',
            style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.white70),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '€${spent.toStringAsFixed(2)} / €${budget.toStringAsFixed(0)}',
                style: GoogleFonts.outfit(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '${(ratio * 100).toStringAsFixed(0)}%',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: ratio > 1.0 ? AppColors.error : AppColors.secondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 6.h,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(
                ratio > 0.9 ? AppColors.error : AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildGroceryDayCard(BuildContext context, Grocery grocery) {
    final textColor = Theme.of(context).colorScheme.primary;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
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
                DateFormat('EEEE, MMM dd').format(grocery.date),
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              Text(
                '€${grocery.total.toStringAsFixed(2)}',
                style: GoogleFonts.outfit(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            DateFormat('HH:mm').format(grocery.date),
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color: AppColors.textSecondaryLight,
            ),
          ),
          SizedBox(height: 16.h),
          const Divider(),
          SizedBox(height: 8.h),
          ...grocery.items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 16.sp,
                    color: AppColors.secondary,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      '${item.quantity ?? 1}x ${item.name}',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: textColor.withOpacity(0.8),
                      ),
                    ),
                  ),
                  if (item.price > 0)
                    Text(
                      '€${item.price.toStringAsFixed(2)}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12.sp,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  void _showAddTripDialog(BuildContext context, MoneyProvider provider) {
    final totalController = TextEditingController();
    final itemsController = TextEditingController();
    DateTime selectedDate = DateTime.now();

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
                'Log Shopping Trip',
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
                controller: totalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Total Bill Amount (€)',
                  hintText: '0.00',
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: itemsController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Quick Items (comma separated)',
                  hintText: 'Milk, Eggs, Bread...',
                ),
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: () {
                    final total = double.tryParse(totalController.text) ?? 0;
                    if (total > 0) {
                      final itemNames = itemsController.text.split(',');
                      final items = itemNames
                          .map(
                            (name) => GroceryItem(name: name.trim(), price: 0),
                          )
                          .toList();
                      provider.addGrocery(
                        Grocery(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          total: total,
                          date: selectedDate,
                          weekNumber: 4,
                          items: items,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Log Trip'),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
            ],
          ),
        ),
      ),
    );
  }
}
