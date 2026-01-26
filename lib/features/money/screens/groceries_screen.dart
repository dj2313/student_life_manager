import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class GroceriesScreen extends StatelessWidget {
  const GroceriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛒 Groceries Manager'),
        actions: [
          IconButton(icon: const Icon(Icons.calendar_month), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.paddingMD.w),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonthHeader('January 2026'),
            SizedBox(height: 20.h),
            _buildGroceryDayCard(
              day: 'Monday, Jan 20',
              spent: 45.50,
              budget: 60.0,
              items: [
                {'name': 'Milk', 'price': 2.50, 'done': true},
                {'name': 'Bread', 'price': 1.80, 'done': true},
                {'name': 'Vegetables', 'price': 12.20, 'done': true},
                {'name': 'Eggs', 'price': 3.50, 'done': false},
              ],
            ),
            SizedBox(height: 20.h),
            _buildGroceryDayCard(
              day: 'Thursday, Jan 23',
              spent: 22.00,
              budget: 30.0,
              items: [
                {'name': 'Rice', 'price': 15.00, 'done': true},
                {'name': 'Chicken', 'price': 7.00, 'done': true},
              ],
            ),
            SizedBox(height: 30.h),
            _buildWeeklySummary(spent: 180.0, budget: 240.0),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('New Shopping Trip'),
      ),
    );
  }

  Widget _buildMonthHeader(String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSM.r),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.secondary,
        ),
      ),
    );
  }

  Widget _buildGroceryDayCard({
    required String day,
    required double spent,
    required double budget,
    required List<Map<String, dynamic>> items,
  }) {
    double progress = spent / budget;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMD.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  day,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Spent: €${spent.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.9 ? AppColors.error : AppColors.secondary,
              ),
            ),
            SizedBox(height: 15.h),
            const Divider(),
            ...items.map((item) => _buildGroceryItem(item)).toList(),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Item'),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroceryItem(Map<String, dynamic> item) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(
            item['done'] ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20.sp,
            color: item['done'] ? AppColors.secondary : Colors.grey,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              item['name'],
              style: TextStyle(
                decoration: item['done'] ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          Text('€${item['price'].toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _buildWeeklySummary({required double spent, required double budget}) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingLG.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG.r),
      ),
      child: Column(
        children: [
          Text(
            'Weekly Summary',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Total Spent', '€${spent.toStringAsFixed(0)}'),
              _buildSummaryItem(
                'Remaining',
                '€${(budget - spent).toStringAsFixed(0)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12.sp,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
