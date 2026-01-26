import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/premium_theme.dart';
import 'package:provider/provider.dart';
import 'features/onboarding/screens/landing_screen.dart';
import 'features/home/providers/home_provider.dart';
import 'core/providers/system_status_provider.dart';
import 'features/tasks/providers/tasks_provider.dart';
import 'features/money/providers/money_provider.dart';
import 'features/notes/providers/notes_provider.dart';
import 'features/study/providers/study_provider.dart';
import 'core/providers/navigation_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => SystemStatusProvider()),
        ChangeNotifierProvider(create: (_) => TasksProvider()),
        ChangeNotifierProvider(create: (_) => MoneyProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => StudyProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'Student Life Manager',
            debugShowCheckedModeBanner: false,
            theme: PremiumTheme.light,
            darkTheme: PremiumTheme.dark,
            themeMode: ThemeMode.system,
            home: const LandingScreen(),
          );
        },
      ),
    );
  }
}
