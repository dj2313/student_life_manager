import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/context_extensions.dart';
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
import '../providers/bureaucracy_provider.dart';
import './bureaucracy_tracker_screen.dart';
import './housing_tracker_screen.dart';
import '../providers/housing_provider.dart';
import '../../../core/providers/focus_timer_provider.dart';
import '../../../core/providers/weather_provider.dart';
import './focus_zen_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  bool _isNotificationOn = true;
  bool _isSummaryExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initRealLocation();
    });
  }

  Future<void> _initRealLocation() async {
    final weatherProvider = Provider.of<WeatherProvider>(
      context,
      listen: false,
    );
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);

    try {
      // 1. Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Just load weather for whatever city is in profile
        weatherProvider.updateWeather(homeProvider.locationName);
        return;
      }

      // 2. Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          weatherProvider.updateWeather(homeProvider.locationName);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        weatherProvider.updateWeather(homeProvider.locationName);
        return;
      }

      // 3. Get position with a reasonable timeout
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );

      // 4. Update weather by coords
      await weatherProvider.updateWeatherByCoords(
        position.latitude,
        position.longitude,
        'Current Location',
      );

      // 5. Update home provider session location
      homeProvider.updateLocation('Current Location');
    } catch (e) {
      debugPrint('Real Location Detection Failed: $e');
      // Fallback to profile location if GPS fails
      weatherProvider.updateWeather(homeProvider.locationName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer6<
      HomeProvider,
      ThemeProvider,
      MoneyProvider,
      StudyProvider,
      FocusTimerProvider,
      WeatherProvider
    >(
      builder:
          (
            context,
            homeProvider,
            themeProvider,
            moneyProvider,
            studyProvider,
            focusTimerProvider,
            weatherProvider,
            child,
          ) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildSliverAppBar(
                    context,
                    homeProvider,
                    themeProvider,
                    weatherProvider,
                  ),
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
                          ),
                          SizedBox(height: 24.h),

                          // Enhanced Visa Card
                          _buildEnhancedVisaCard(context, homeProvider),
                          SizedBox(height: 28.h),

                          // NEW: Quick Stats Row
                          _buildQuickStatsRow(
                            context,
                            moneyProvider,
                            studyProvider,
                            homeProvider,
                          ),
                          SizedBox(height: 32.h),

                          _buildSectionTitle(context, 'DAILY HELPERS'),
                          SizedBox(height: 16.h),
                          _buildInteractiveWidgets(
                            context,
                            focusTimerProvider,
                            moneyProvider,
                          ),
                          SizedBox(height: 32.h),

                          // Improved Quick Access
                          _buildQuickAccessSection(context),
                          SizedBox(height: 40.h),

                          _buildSectionTitle(context, 'BUREAUCRACY TRACKER'),
                          SizedBox(height: 16.h),
                          _buildBureaucracyQuickAccess(context),
                          SizedBox(height: 32.h),
                          _buildSectionTitle(context, 'HOUSING & SUBLETTING'),
                          SizedBox(height: 16.h),
                          _buildHousingQuickAccess(context),
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
    WeatherProvider weatherProvider,
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
                    onTap: () => _showEditLocationDialog(
                      context,
                      provider,
                      weatherProvider,
                    ),
                    child: _buildWeatherWidget(
                      context,
                      provider,
                      weatherProvider,
                    ),
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
                _showEditLocationDialog(context, provider, weatherProvider);
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

  Widget _buildWeatherWidget(
    BuildContext context,
    HomeProvider provider,
    WeatherProvider weatherProvider,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (weatherProvider.isLoading)
              SizedBox(
                width: 12.w,
                height: 12.w,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            else if (weatherProvider.currentWeather?.iconUrl.isNotEmpty ??
                false)
              Image.network(
                weatherProvider.currentWeather!.iconUrl,
                width: 24.w,
                height: 24.w,
                errorBuilder: (context, error, stackTrace) => Icon(
                  weatherProvider.weatherIcon,
                  size: 16.sp,
                  color: AppColors.secondary,
                ),
              )
            else
              Icon(
                weatherProvider.weatherIcon,
                size: 16.sp,
                color: AppColors.secondary,
              ),
            SizedBox(width: 4.w),
            Text(
              weatherProvider.temperature,
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
            color: context.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
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
            color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
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
                        color: AppColors.secondary.withValues(alpha: 0.8),
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
                color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
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
            color: color.withValues(alpha: 0.08),
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

  Widget _buildEnhancedVisaCard(BuildContext context, HomeProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = (provider.visaDaysRemaining / 90).clamp(0.0, 1.0);
    final statusColor = provider.visaDaysRemaining < 10
        ? AppColors.error
        : AppColors.secondary;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RESIDENCE PERMIT',
                style: GoogleFonts.outfit(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  provider.visaStatus.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${provider.visaDaysRemaining}',
                      style: GoogleFonts.outfit(
                        fontSize: 42.sp,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.primary,
                        height: 1,
                      ),
                    ),
                    Text(
                      'days until expiry',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Circular Progress Indicator for a modern look
              SizedBox(
                height: 56.r,
                width: 56.r,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 6,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.03),
                    ),
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      strokeCap: StrokeCap.round,
                      color: statusColor,
                    ),
                    Center(
                      child: Icon(
                        Icons.verified_user_rounded,
                        size: 20.r,
                        color: statusColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: _buildVisaActionButton(
                  context,
                  Icons.edit_calendar_outlined,
                  'Update Date',
                  () => _showVisaUpdateDialog(context, provider),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildVisaActionButton(
                  context,
                  Icons.description_outlined,
                  'View Document',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.03)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.02),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isDark ? Colors.white70 : Colors.black54,
              size: 16.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          Icons.account_balance_wallet_outlined,
          '€${moneyProvider.totalBalance.toStringAsFixed(0)}',
          'Budget',
          AppColors.primary,
        ),
        _buildStatCard(
          context,
          Icons.auto_stories_outlined,
          '${studyProvider.hoursLoggedThisWeek.toStringAsFixed(0)}h',
          'Study',
          AppColors.secondary,
        ),
        _buildStatCard(
          context,
          Icons.check_circle_outline_rounded,
          '$completedTasks/$totalTasks',
          'Tasks',
          AppColors.success,
        ),
        _buildStatCard(
          context,
          Icons.analytics_outlined,
          '${totalTasks > 0 ? (completedTasks / totalTasks * 100).toStringAsFixed(0) : 0}%',
          'Score',
          Colors.blueGrey,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.04),
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 20.sp, color: color.withValues(alpha: 0.8)),
            SizedBox(height: 12.h),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.primary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 9.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: isDark ? Colors.white24 : Colors.black26,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVisaUpdateDialog(BuildContext context, HomeProvider provider) {
    // This is a placeholder for the actual dialog implementation
    // In a real app, this would show a date picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Update Expiry Date feature coming soon!')),
    );
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    return Consumer3<NavigationProvider, HomeProvider, WeatherProvider>(
      builder: (context, navProvider, homeProvider, weatherProvider, child) {
        final displayLocation =
            weatherProvider.currentWeather?.cityName ??
            homeProvider.locationName;
        final isLocating =
            weatherProvider.isLoading &&
            homeProvider.locationName == 'Current Location';

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
                  isLocating
                      ? Icons.location_searching_rounded
                      : Icons.location_on_outlined,
                  isLocating ? 'Locating...' : displayLocation,
                  () {
                    context.hapticClick();
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
                  context.hapticClick();
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
                    context.hapticClick();
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
                    context.hapticClick();
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
        color: context.textTertiary,
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
                  color: AppColors.shadow.withValues(alpha: 0.04),
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
              color: context.textTertiary,
            ),
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
          return _buildTicketCard(context, entry.value);
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
              color: AppColors.primary.withValues(alpha: 0.12),
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

  Widget _buildBureaucracyQuickAccess(BuildContext context) {
    return Consumer<BureaucracyProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Icon(
                      Icons.account_balance_rounded,
                      color: AppColors.primary,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Administrative Roadmap',
                          style: GoogleFonts.outfit(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${(provider.completionProgress * 100).toInt()}% of essential steps done',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BureaucracyTrackerScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: LinearProgressIndicator(
                  value: provider.completionProgress,
                  minHeight: 6.h,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            ],
          ),
        );
      },
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

  void _showEditLocationDialog(
    BuildContext context,
    HomeProvider provider,
    WeatherProvider weatherProvider,
  ) {
    final controller = TextEditingController(text: provider.locationName);
    bool isDetecting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Update Location',
                style: GoogleFonts.outfit(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Enter a city or use your current position',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: context.textSecondary,
                ),
              ),
              SizedBox(height: 24.h),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'e.g. Berlin, Germany',
                  prefixIcon: const Icon(Icons.location_city_rounded),
                  filled: true,
                  fillColor: Theme.of(context).cardTheme.color,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                onPressed: isDetecting
                    ? null
                    : () async {
                        setModalState(() => isDetecting = true);
                        try {
                          final status = await Permission.location.request();
                          if (status.isGranted) {
                            final position =
                                await Geolocator.getCurrentPosition(
                                  desiredAccuracy: LocationAccuracy.low,
                                );
                            // For simplicity, we'll use a generic label or try to fetch a city name
                            // In a real app, you'd use reverse geocoding here.
                            // We'll just fetch weather by coords directly.
                            await weatherProvider.updateWeatherByCoords(
                              position.latitude,
                              position.longitude,
                              'Current Location',
                            );
                            provider.updateLocation('Current Location');
                            if (context.mounted) Navigator.pop(context);
                          }
                        } catch (e) {
                          debugPrint('Location error: $e');
                        } finally {
                          if (context.mounted) {
                            setModalState(() => isDetecting = false);
                          }
                        }
                      },
                icon: isDetecting
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.my_location_rounded),
                label: Text(
                  isDetecting ? 'Detecting...' : 'Use Current Location',
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50.h),
                  backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                  foregroundColor: AppColors.secondary,
                  elevation: 0,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(0, 50.h),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          provider.updateLocation(controller.text);
                          weatherProvider.updateWeather(controller.text);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(0, 50.h),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveWidgets(
    BuildContext context,
    FocusTimerProvider timerProvider,
    MoneyProvider moneyProvider,
  ) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FocusZenScreen()),
            ),
            child: Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: timerProvider.isRunning
                      ? AppColors.secondary.withValues(alpha: 0.3)
                      : Theme.of(context).dividerColor.withValues(alpha: 0.05),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: AppColors.secondary,
                        size: 20.sp,
                      ),
                      GestureDetector(
                        onTap: () {
                          context.hapticClick();
                          if (timerProvider.isRunning) {
                            timerProvider.stopTimer();
                          } else {
                            timerProvider.startTimer();
                          }
                        },
                        child: Icon(
                          timerProvider.isRunning
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_fill_rounded,
                          color: AppColors.secondary,
                          size: 28.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    timerProvider.formattedTime,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    'Focus Session',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        // Daily Budget Widget
        Expanded(
          child: GestureDetector(
            onTap: () {
              context.hapticClick();
              Provider.of<NavigationProvider>(
                context,
                listen: false,
              ).setIndex(2);
            },
            child: Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    color: AppColors.success,
                    size: 20.sp,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    '€${(25.0 - (moneyProvider.getMonthlySpending() / 30)).toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    'Daily Budget',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHousingQuickAccess(BuildContext context) {
    return Consumer<HousingProvider>(
      builder: (context, provider, child) {
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HousingTrackerScreen(),
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.home_work_rounded,
                    color: AppColors.secondary,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Housing Tracker',
                        style: GoogleFonts.outfit(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${provider.applications.length} active applications',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
