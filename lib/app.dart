import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/premium_theme.dart';
import 'package:provider/provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/widgets/auth_wrapper.dart';
import 'features/home/providers/home_provider.dart';
import 'core/providers/system_status_provider.dart';
import 'features/tasks/providers/tasks_provider.dart';
import 'features/money/providers/money_provider.dart';
import 'features/notes/providers/notes_provider.dart';
import 'features/study/providers/study_provider.dart';
import 'features/money/providers/india_tracker_provider.dart';
import 'core/providers/navigation_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/focus_timer_provider.dart';
import 'features/study/providers/study_assistant_provider.dart';
import 'features/home/providers/bureaucracy_provider.dart';
import 'features/money/providers/job_provider.dart';
import 'features/study/providers/gpa_provider.dart';
import 'features/home/providers/housing_provider.dart';
import 'core/providers/weather_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => SystemStatusProvider()),
        ChangeNotifierProvider(create: (_) => TasksProvider()),
        ChangeNotifierProvider(create: (_) => MoneyProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => StudyProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => IndiaTrackerProvider()),
        ChangeNotifierProvider(create: (_) => BureaucracyProvider()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
        ChangeNotifierProvider(create: (_) => GPAProvider()),
        ChangeNotifierProvider(create: (_) => HousingProvider()),
        ChangeNotifierProvider(create: (_) => StudyAssistantProvider()),
        ChangeNotifierProvider(create: (_) => FocusTimerProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],

      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                title: 'Student Life Manager',
                debugShowCheckedModeBanner: false,
                theme: PremiumTheme.light,
                darkTheme: PremiumTheme.dark,
                themeMode: themeProvider.themeMode,
                home: const AuthWrapper(),
              );
            },
          );
        },
      ),
    );
  }
}
