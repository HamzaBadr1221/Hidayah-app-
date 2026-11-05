import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/cubit/theme_cubit.dart';
import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initDependencies();

  final sharedPreferences = sl<SharedPreferences>();

  final isProfileCompleted =
      sharedPreferences.getBool('profile_completed') ?? false;

  final city = isProfileCompleted
      ? sharedPreferences.getString('profile_city') ?? 'Cairo'
      : 'Cairo';

  final country = isProfileCompleted
      ? sharedPreferences.getString('profile_country') ?? 'Egypt'
      : 'Egypt';

  final themeCubit = sl<ThemeCubit>();

  await themeCubit.initialize(
    city: city,
    country: country,
  );

  runApp(
    BlocProvider.value(
      value: themeCubit,
      child: const QuranApp(),
    ),
  );
}

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Hidaya',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}