import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String priority; // 'high', 'medium', 'low'
  final String? dueDate;
  final bool isCompleted;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TaskCard({
    super.key,
    required this.title,
    required this.priority,
    this.dueDate,
    this.isCompleted = false,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  Color _getPriorityColor() {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.priorityHigh;
      case 'medium':
        return AppColors.priorityMedium;
      case 'low':
        return AppColors.priorityLow;
      default:
        return AppColors.textSecondaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor();

    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.marginSM.h),
      child: Slidable(
        key: ValueKey(title),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onToggle(),
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              icon: Icons.check,
              label: 'Complete',
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onEdit(),
              backgroundColor: AppColors.info,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
            ),
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMD.r),
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: priorityColor, width: 5.w),
              ),
            ),
            child: ListTile(
              leading: Checkbox(
                value: isCompleted,
                onChanged: (_) => onToggle(),
                activeColor: AppColors.success,
              ),
              title: Text(
                title,
                style: TextStyle(
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  color: isCompleted ? AppColors.textSecondaryLight : null,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: dueDate != null
                  ? Text(
                      'Due: $dueDate',
                      style: TextStyle(fontSize: 12.sp, color: priorityColor),
                    )
                  : null,
              trailing: Icon(
                priority.toLowerCase() == 'high'
                    ? Icons.star
                    : Icons.priority_high,
                color: priorityColor.withOpacity(0.5),
                size: 20.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
