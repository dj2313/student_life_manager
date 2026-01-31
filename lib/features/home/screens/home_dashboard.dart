import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/home_provider.dart';
import '../../../data/models/ticket.dart';
import '../../notes/screens/notes_screen.dart';
import './location_screen.dart';
import './support_screen.dart';
import '../../../core/providers/navigation_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../money/providers/money_provider.dart';
import '../../study/providers/study_provider.dart';
import '../../tasks/providers/tasks_provider.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  bool _isNotificationOn = true;
  bool _isSummaryExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer4<HomeProvider, ThemeProvider, MoneyProvider, StudyProvider>(
      builder:
          (
            context,
            homeProvider,
            themeProvider,
            moneyProvider,
            studyProvider,
            child,
          ) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildSliverAppBar(context, homeProvider, themeProvider),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // NEW: Daily Summary Card
                          _buildDailySummaryCard(
                                context,
                                homeProvider,
                                studyProvider,
                                moneyProvider,
                              )
                              .animate()
                              .fadeIn(duration: 500.ms)
                              .slideY(begin: 0.1, end: 0),
                          SizedBox(height: 24.h),

                          // Enhanced Visa Card
                          _buildEnhancedVisaCard(context, homeProvider)
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 100.ms)
                              .slideY(begin: 0.2, end: 0),
                          SizedBox(height: 28.h),

                          // NEW: Quick Stats Row
                          _buildQuickStatsRow(
                                context,
                                moneyProvider,
                                studyProvider,
                                homeProvider,
                              )
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 200.ms)
                              .slideY(begin: 0.1, end: 0),
                          SizedBox(height: 32.h),

                          // Improved Quick Access
                          _buildQuickAccessSection(context),
                          SizedBox(height: 40.h),

                          _buildSectionTitle(context, 'BUREAUCRACY TRACKER'),
                          SizedBox(height: 16.h),
                          _buildBureaucracyChecklist(context, homeProvider),
                          SizedBox(height: 40.h),

                          _buildTicketsSection(context, homeProvider),
                          SizedBox(height: 160.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    HomeProvider provider,
    ThemeProvider themeProvider,
  ) {
    final textColor = Theme.of(context).colorScheme.primary;

    return SliverAppBar(
      expandedHeight: 140.h,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 30.h, 24.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => _showEditProfileDialog(context, provider),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Guten Tag,',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: AppColors.textSecondaryLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          provider.userName,
                          style: GoogleFonts.outfit(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showEditLocationDialog(context, provider),
                    child: _buildWeatherWidget(context, provider),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              _isNotificationOn = !_isNotificationOn;
            });
          },
          icon: Icon(
            _isNotificationOn
                ? Icons.notifications_active_rounded
                : Icons.notifications_off_rounded,
            color: _isNotificationOn
                ? AppColors.secondary
                : AppColors.textTertiaryLight,
            size: 24.sp,
          ),
        ),
        IconButton(
          onPressed: () => themeProvider.toggleTheme(),
          icon: Icon(
            themeProvider.isDarkMode
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            color: textColor,
            size: 24.sp,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: PopupMenuButton<String>(
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            onSelected: (value) {
              if (value == 'edit_profile') {
                _showEditProfileDialog(context, provider);
              } else if (value == 'edit_location') {
                _showEditLocationDialog(context, provider);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit_profile',
                child: Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 12.w),
                    const Text('Edit Profile'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'edit_location',
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.secondary,
                    ),
                    SizedBox(width: 12.w),
                    const Text('Update Location'),
                  ],
                ),
              ),
            ],
            child: CircleAvatar(
              radius: 20.r,
              backgroundImage: const NetworkImage(
                'https://ui-avatars.com/api/?name=Dhruv+P&background=6366f1&color=fff',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherWidget(BuildContext context, HomeProvider provider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(provider.weatherIcon, size: 16.sp, color: AppColors.secondary),
            SizedBox(width: 4.w),
            Text(
              provider.temperature,
              style: GoogleFonts.outfit(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        Text(
          provider.locationName,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: AppColors.textSecondaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 800.ms);
  }

  // NEW: Daily Summary Card
  Widget _buildDailySummaryCard(
    BuildContext context,
    HomeProvider provider,
    StudyProvider studyProvider,
    MoneyProvider moneyProvider,
  ) {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    IconData greetingIcon;

    if (hour < 12) {
      greeting = 'Good Morning';
      greetingIcon = Icons.wb_sunny_rounded;
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
      greetingIcon = Icons.wb_twilight_rounded;
    } else {
      greeting = 'Good Evening';
      greetingIcon = Icons.nightlight_round;
    }

    final formattedDate =
        '${_getDayName(now.weekday)}, ${_getMonthName(now.month)} ${now.day}';

    return InkWell(
      onTap: () => setState(() => _isSummaryExpanded = !_isSummaryExpanded),
      borderRadius: BorderRadius.circular(24.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(_isSummaryExpanded ? 20.w : 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        greetingIcon,
                        color: AppColors.secondary.withOpacity(0.8),
                        size: _isSummaryExpanded ? 22.sp : 18.sp,
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting,
                            style: GoogleFonts.outfit(
                              fontSize: _isSummaryExpanded ? 20.sp : 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          if (!_isSummaryExpanded)
                            Text(
                              DateFormat('HH:mm').format(now),
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (_isSummaryExpanded)
                            Text(
                              formattedDate,
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: AppColors.textSecondaryLight,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  Icon(
                    _isSummaryExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textTertiaryLight,
                    size: 20.sp,
                  ),
                ],
              ),
            ),
            if (_isSummaryExpanded) ...[
              Divider(
                height: 1,
                color: Theme.of(context).dividerColor.withOpacity(0.05),
              ),
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    _buildMinimalOverviewItem(
                      context,
                      Icons.account_balance_wallet_outlined,
                      'Liquidity',
                      '€${moneyProvider.totalBalance.toStringAsFixed(0)}',
                      AppColors.primary,
                    ),
                    SizedBox(height: 12.h),
                    _buildMinimalOverviewItem(
                      context,
                      Icons.menu_book_outlined,
                      'Study Target',
                      '${studyProvider.hoursLoggedThisWeek.toStringAsFixed(1)}h / ${studyProvider.weeklyTargetHours}h',
                      AppColors.secondary,
                    ),
                    SizedBox(height: 12.h),
                    _buildMinimalOverviewItem(
                      context,
                      Icons.check_circle_outline_rounded,
                      'Tasks',
                      '${provider.bureaucracyTasks.where((t) => t.isCompleted).length} of ${provider.bureaucracyTasks.length}',
                      AppColors.success,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalOverviewItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: color, size: 16.sp),
        ),
        SizedBox(width: 12.w),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            color: AppColors.textSecondaryLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  // NEW: Enhanced Visa Card with Actions
  Widget _buildEnhancedVisaCard(BuildContext context, HomeProvider provider) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 12),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.badge_outlined,
                    color: Colors.white70,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Residence Permit',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  provider.visaStatus,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${provider.visaDaysRemaining}',
                style: GoogleFonts.outfit(
                  fontSize: 48.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              SizedBox(width: 8.w),
              Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Text(
                  'Days Left',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: provider.visaDaysRemaining / 90,
              minHeight: 10.h,
              backgroundColor: Colors.white.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildVisaActionButton(
                  context,
                  Icons.calendar_month_outlined,
                  'Calendar',
                  () {},
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildVisaActionButton(
                  context,
                  Icons.notifications_outlined,
                  'Remind',
                  () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisaActionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16.sp),
            SizedBox(width: 6.w),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // NEW: Quick Stats Row
  Widget _buildQuickStatsRow(
    BuildContext context,
    MoneyProvider moneyProvider,
    StudyProvider studyProvider,
    HomeProvider homeProvider,
  ) {
    final tasksProvider = context.read<TasksProvider>();
    final completedTasks =
        homeProvider.bureaucracyTasks.where((t) => t.isCompleted).length +
        tasksProvider.completedCount;
    final totalTasks =
        homeProvider.bureaucracyTasks.length + tasksProvider.totalCount;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard(
          context,
          '💰',
          '€${moneyProvider.totalBalance.toStringAsFixed(0)}',
          'Budget',
          AppColors.success,
        ),
        _buildStatCard(
          context,
          '📚',
          '${studyProvider.hoursLoggedThisWeek.toStringAsFixed(0)}h',
          'Study',
          AppColors.secondary,
        ),
        _buildStatCard(
          context,
          '✅',
          '$completedTasks/$totalTasks',
          'Tasks',
          AppColors.accent,
        ),
        _buildStatCard(
          context,
          '🎯',
          '${totalTasks > 0 ? (completedTasks / totalTasks * 100).toStringAsFixed(0) : 0}%',
          'Score',
          AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String emoji,
    String value,
    String label,
    Color color,
  ) {
    final index = ['Budget', 'Study', 'Tasks', 'Score'].indexOf(label);
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        ),
        child: Column(
          children: [
            Text(emoji, style: TextStyle(fontSize: 20.sp)),
            SizedBox(height: 8.h),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiaryLight,
              ),
            ),
          ],
        ),
      ).animate().scale(delay: (100 * index).ms, duration: 400.ms),
    );
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'QUICK ACCESS'),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildQuickTile(
                  context,
                  Icons.location_on_outlined,
                  'Location',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LocationScreen(),
                      ),
                    );
                  },
                  0,
                ),
                _buildQuickTile(context, Icons.note_alt_outlined, 'Notes', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotesScreen(),
                    ),
                  );
                }, 1),
                _buildQuickTile(
                  context,
                  Icons.help_outline_rounded,
                  'Support',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SupportScreen(),
                      ),
                    );
                  },
                  2,
                ),
                _buildQuickTile(
                  context,
                  Icons.settings_outlined,
                  'Settings',
                  () {
                    navProvider.setIndex(4);
                  },
                  3,
                ),
              ],
            ),
          ],
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

  Widget _buildQuickTile(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
    int index,
  ) {
    final cardColor = Theme.of(context).cardTheme.color;
    final textColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: textColor, size: 26.sp),
          ),
          SizedBox(height: 10.h),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (100 * index).ms).scale(duration: 400.ms);
  }

  Widget _buildBureaucracyChecklist(
    BuildContext context,
    HomeProvider provider,
  ) {
    if (provider.bureaucracyTasks.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1.2),
      ),
      child: Column(
        children: provider.bureaucracyTasks.asMap().entries.map((entry) {
          return InkWell(
            onTap: () => provider.toggleBureaucracyTask(entry.key),
            borderRadius: BorderRadius.circular(12.r),
            child: _buildChecklistItem(context, entry.value),
          );
        }).toList(),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildChecklistItem(BuildContext context, BureaucracyTask task) {
    final textColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: task.isCompleted
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.secondary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              task.icon,
              size: 18.sp,
              color: task.isCompleted
                  ? AppColors.success
                  : AppColors.secondary.withOpacity(0.6),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              task.title,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
          ),
          Icon(
            task.isCompleted
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 20.sp,
            color: task.isCompleted
                ? AppColors.success
                : AppColors.textTertiaryLight,
          ),
        ],
      ),
    );
  }

  Widget _buildTicketsSection(BuildContext context, HomeProvider provider) {
    if (provider.activeTickets.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Tickets',
              style: GoogleFonts.outfit(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            TextButton(
              onPressed: () => Provider.of<NavigationProvider>(
                context,
                listen: false,
              ).setIndex(0),
              child: Text(
                'View All',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ...provider.activeTickets.asMap().entries.map((entry) {
          return _buildTicketCard(context, entry.value)
              .animate()
              .fadeIn(delay: (200 + (100 * entry.key)).ms)
              .slideX(begin: 0.1, end: 0);
        }),
      ],
    );
  }

  Widget _buildTicketCard(BuildContext context, Ticket ticket) {
    final cardColor = Theme.of(context).cardTheme.color;
    final textColor = Theme.of(context).colorScheme.primary;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              ticket.type == 'Train'
                  ? Icons.train_outlined
                  : Icons.directions_bus_outlined,
              color: AppColors.primary,
              size: 26.sp,
            ),
          ),
          SizedBox(width: 18.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.route,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${ticket.ticketNumber} • ${ticket.time}',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.qr_code_2_rounded, size: 36.sp, color: textColor),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, HomeProvider provider) {
    final controller = TextEditingController(text: provider.userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter your name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                provider.updateUserName(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditLocationDialog(BuildContext context, HomeProvider provider) {
    final controller = TextEditingController(text: provider.locationName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Location'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'City, Country'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                provider.updateLocation(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
