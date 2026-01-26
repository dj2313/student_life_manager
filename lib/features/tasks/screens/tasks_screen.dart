import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/tasks_provider.dart';
import '../../../data/models/todo.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TasksProvider>(
      builder: (context, tasksProvider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCompletionStatus(context, tasksProvider),
                      SizedBox(height: 32.h),
                      _buildTabBar(context),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTaskListView(
                      context,
                      tasksProvider.todayTasks,
                      tasksProvider,
                    ),
                    _buildTaskListView(
                      context,
                      tasksProvider.tomorrowTasks,
                      tasksProvider,
                    ),
                    _buildTaskListView(
                      context,
                      tasksProvider.weekTasks,
                      tasksProvider,
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: Padding(
            padding: EdgeInsets.only(bottom: 80.h),
            child: FloatingActionButton(
              onPressed: () {
                // TODO: Show Add Task Bottom Sheet
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Objectives',
        style: GoogleFonts.outfit(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCompletionStatus(BuildContext context, TasksProvider provider) {
    final textColor = Theme.of(context).colorScheme.primary;
    final ratio = provider.totalCount > 0
        ? provider.completedCount / provider.totalCount
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Velocity',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: AppColors.textSecondaryLight,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${provider.completedCount}/${provider.totalCount}',
              style: GoogleFonts.outfit(
                fontSize: 48.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'Top 5% today',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6.h,
            backgroundColor: textColor.withOpacity(0.05),
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.primary;

    return TabBar(
      controller: _tabController,
      indicatorWeight: 3,
      indicatorColor: AppColors.secondary,
      indicatorSize: TabBarIndicatorSize.label,
      labelColor: textColor,
      unselectedLabelColor: AppColors.textTertiaryLight,
      labelStyle: GoogleFonts.outfit(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.outfit(
        fontSize: 15.sp,
        fontWeight: FontWeight.w400,
      ),
      tabs: const [
        Tab(text: 'Today'),
        Tab(text: 'Tomorrow'),
        Tab(text: 'Week'),
      ],
    );
  }

  Widget _buildTaskListView(
    BuildContext context,
    List<Todo> tasks,
    TasksProvider provider,
  ) {
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          'No tasks for this period',
          style: GoogleFonts.inter(color: AppColors.textSecondaryLight),
        ),
      );
    }

    final priorityTasks = tasks.where((t) => t.priority == 'high').toList();
    final regularTasks = tasks.where((t) => t.priority != 'high').toList();

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        if (priorityTasks.isNotEmpty) ...[
          _buildSectionTitle('📌 Priority'),
          ...priorityTasks.map(
            (task) => _buildSimplifiedTask(context, task, provider),
          ),
          SizedBox(height: 24.h),
        ],
        if (regularTasks.isNotEmpty) ...[
          _buildSectionTitle('Regular'),
          ...regularTasks.map(
            (task) => _buildSimplifiedTask(context, task, provider),
          ),
        ],
        SizedBox(height: 120.h),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.textTertiaryLight,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSimplifiedTask(
    BuildContext context,
    Todo task,
    TasksProvider provider,
  ) {
    final cardColor = Theme.of(context).cardTheme.color;
    final textColor = Theme.of(context).colorScheme.primary;
    final color = task.priority == 'high'
        ? AppColors.primary
        : AppColors.accent;

    return GestureDetector(
      onTap: () => provider.toggleTaskStatus(task.id),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            Container(
              width: 4.w,
              height: 24.h,
              decoration: BoxDecoration(
                color: task.completed ? Colors.grey[200] : color,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: task.completed ? Colors.grey : textColor,
                      decoration: task.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (task.description != null && task.description!.isNotEmpty)
                    Text(
                      task.description!,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                ],
              ),
            ),
            if (task.completed)
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 20.sp,
              )
            else
              Icon(
                Icons.circle_outlined,
                color: AppColors.borderLight,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }
}
