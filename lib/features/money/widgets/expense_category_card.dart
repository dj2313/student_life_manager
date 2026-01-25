import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_sizes.dart';

class ExpenseCategoryCard extends StatelessWidget {
  final IconData icon;
  final String category;
  final String amount;
  final Color color;

  const ExpenseCategoryCard({
    super.key,
    required this.icon,
    required this.category,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110.w,
      margin: EdgeInsets.only(right: AppSizes.spacingMD.w),
      child: Card(
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(AppSizes.radiusLG.r),
          child: Padding(
            padding: EdgeInsets.all(AppSizes.paddingMD.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28.sp),
                ),
                SizedBox(height: 8.h),
                Text(
                  category,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  amount,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
