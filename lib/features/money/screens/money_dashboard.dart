import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../widgets/balance_card.dart';
import '../widgets/expense_category_card.dart';
import '../widgets/quick_action_button.dart';

class MoneyDashboard extends StatelessWidget {
  const MoneyDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.moneyTitle),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Financial Overview Cards
            Container(
              padding: EdgeInsets.all(AppSizes.paddingMD.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Balance',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '€2,450',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSizes.spacingLG.h),
                  Row(
                    children: [
                      Expanded(
                        child: BalanceCard(
                          title: 'Blocked Account',
                          amount: '€11,208',
                          icon: Icons.lock,
                          color: AppColors.success,
                        ),
                      ),
                      SizedBox(width: AppSizes.spacingMD.w),
                      Expanded(
                        child: BalanceCard(
                          title: 'Personal',
                          amount: '€450',
                          icon: Icons.account_balance_wallet,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Quick Actions
            Padding(
              padding: EdgeInsets.all(AppSizes.paddingMD.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: AppSizes.spacingMD.h),
                  Row(
                    children: [
                      Expanded(
                        child: QuickActionButton(
                          icon: Icons.add,
                          label: 'Add Expense',
                          color: AppColors.error,
                          onTap: () {},
                        ),
                      ),
                      SizedBox(width: AppSizes.spacingSM.w),
                      Expanded(
                        child: QuickActionButton(
                          icon: Icons.arrow_upward,
                          label: 'Add Income',
                          color: AppColors.success,
                          onTap: () {},
                        ),
                      ),
                      SizedBox(width: AppSizes.spacingSM.w),
                      Expanded(
                        child: QuickActionButton(
                          icon: Icons.handshake,
                          label: 'Loan',
                          color: AppColors.primary,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Monthly Overview Chart Placeholder
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📊 Monthly Overview',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: AppSizes.spacingMD.h),
                  Card(
                    child: Container(
                      height: 200.h,
                      padding: EdgeInsets.all(AppSizes.paddingLG.w),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bar_chart,
                              size: 48.sp,
                              color: AppColors.primary.withOpacity(0.5),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Chart Coming Soon',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: AppColors.textSecondaryLight,
                                  ),
                            ),
                            Text(
                              'Will use fl_chart package',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSizes.spacingLG.h),

            // Categories
            Padding(
              padding: EdgeInsets.only(left: AppSizes.paddingMD.w),
              child: Text(
                'Categories',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            SizedBox(height: AppSizes.spacingMD.h),
            SizedBox(
              height: 140.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD.w),
                children: [
                  ExpenseCategoryCard(
                    icon: Icons.shopping_cart,
                    category: 'Groceries',
                    amount: '€250',
                    color: AppColors.categoryGroceries,
                  ),
                  ExpenseCategoryCard(
                    icon: Icons.train,
                    category: 'Transport',
                    amount: '€180',
                    color: AppColors.categoryTransport,
                  ),
                  ExpenseCategoryCard(
                    icon: Icons.shopping_bag,
                    category: 'India Items',
                    amount: '€300',
                    color: AppColors.categoryIndia,
                  ),
                  ExpenseCategoryCard(
                    icon: Icons.devices,
                    category: 'Electronics',
                    amount: '€150',
                    color: AppColors.categoryElectronics,
                  ),
                  ExpenseCategoryCard(
                    icon: Icons.more_horiz,
                    category: 'Miscellaneous',
                    amount: '€75',
                    color: AppColors.categoryMisc,
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSizes.spacingXL.h),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.currency_exchange),
        label: const Text('Currency Calculator'),
      ),
    );
  }
}
