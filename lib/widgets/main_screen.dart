import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../features/home/screens/home_dashboard.dart';
import '../features/tasks/screens/tasks_screen.dart';
import '../features/money/screens/money_dashboard.dart';
import '../features/study/screens/study_dashboard.dart';
import '../features/more/screens/settings_screen.dart';
import '../core/constants/app_colors.dart';
import '../core/providers/navigation_provider.dart';
import '../core/providers/theme_provider.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  final List<Widget> _screens = const [
    HomeDashboard(),
    TasksScreen(),
    MoneyDashboard(),
    StudyDashboard(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer2<NavigationProvider, ThemeProvider>(
      builder: (context, navProvider, themeProvider, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: themeProvider.isDarkMode
                ? Brightness.light
                : Brightness.dark,
            statusBarBrightness: themeProvider.isDarkMode
                ? Brightness.dark
                : Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Stack(
              children: [
                SafeArea(
                  bottom: false,
                  child: _screens[navProvider.currentIndex],
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: _buildFloatingBottomBar(context, navProvider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingBottomBar(
    BuildContext context,
    NavigationProvider provider,
  ) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(provider, 0, Icons.home_rounded),
          _buildNavItem(provider, 1, Icons.assignment_rounded),
          _buildNavItem(provider, 2, Icons.account_balance_wallet_rounded),
          _buildNavItem(provider, 3, Icons.school_rounded),
          _buildNavItem(provider, 4, Icons.grid_view_rounded),
        ],
      ),
    );
  }

  Widget _buildNavItem(NavigationProvider provider, int index, IconData icon) {
    final isSelected = provider.currentIndex == index;
    return GestureDetector(
      onTap: () => provider.setIndex(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
            size: isSelected ? 28 : 24,
          ),
          if (isSelected)
            Container(
              margin: EdgeInsets.only(top: 4.h),
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
