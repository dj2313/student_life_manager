import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class LoanScreen extends StatelessWidget {
  const LoanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🤝 Loan Management'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildActiveLoans(), _buildCompletedLoans()],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildActiveLoans() {
    return ListView(
      padding: EdgeInsets.all(AppSizes.paddingMD.w),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildLoanCard(
          name: 'Rahul Sharma',
          total: 50.0,
          remaining: 30.0,
          dueDate: 'Feb 10, 2026',
          history: [
            {'date': 'Jan 15', 'amount': 10.0},
            {'date': 'Jan 20', 'amount': 10.0},
          ],
        ),
        SizedBox(height: 15.h),
        _buildLoanCard(
          name: 'Priya Patel',
          total: 20.0,
          remaining: 20.0,
          dueDate: 'Jan 30, 2026',
          history: [],
        ),
      ],
    );
  }

  Widget _buildCompletedLoans() {
    return ListView(
      padding: EdgeInsets.all(AppSizes.paddingMD.w),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildLoanCard(
          name: 'Amit Verma',
          total: 100.0,
          remaining: 0.0,
          dueDate: 'Jan 05, 2026',
          isCompleted: true,
          history: [
            {'date': 'Jan 05', 'amount': 100.0},
          ],
        ),
      ],
    );
  }

  Widget _buildLoanCard({
    required String name,
    required double total,
    required double remaining,
    required String dueDate,
    required List<Map<String, dynamic>> history,
    bool isCompleted = false,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMD.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isCompleted)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      '✓ Paid',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                  )
                else
                  Text(
                    'Due: $dueDate',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 15.h),
            Row(
              children: [
                Expanded(
                  child: _buildAmountInfo(
                    'Total',
                    '€${total.toStringAsFixed(0)}',
                  ),
                ),
                Expanded(
                  child: _buildAmountInfo(
                    'Remaining',
                    '€${remaining.toStringAsFixed(0)}',
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15.h),
            _buildLinearProgress(remaining, total, isCompleted),
            if (!isCompleted) ...[
              SizedBox(height: 15.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text('Repay'),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  IconButton(
                    icon: const Icon(Icons.history, color: AppColors.primary),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInfo(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondaryLight,
            fontSize: 12.sp,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLinearProgress(
    double remaining,
    double total,
    bool isCompleted,
  ) {
    double progress = (total - remaining) / total;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 8.h,
        backgroundColor: Colors.grey[200],
        valueColor: AlwaysStoppedAnimation<Color>(
          isCompleted ? AppColors.success : AppColors.primary,
        ),
      ),
    );
  }
}
