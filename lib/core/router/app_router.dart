import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/quran/presentation/cubit/surah_details_cubit.dart';
import '../../features/quran/presentation/cubit/surah_list_cubit.dart';
import '../../features/quran/presentation/pages/surah_details_page.dart';
import '../../features/quran/presentation/pages/surah_list_page.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../di/injection_container.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) {
          return BlocProvider(
            create: (_) => sl<HomeCubit>()
              ..fetchPrayerTimes(
                city: 'Cairo',
                country: 'Egypt',
              ),
            child: const HomePage(),
          );
        },
      ),

      GoRoute(
        path: '/surahs',
        builder: (context, state) {
          return BlocProvider(
            create: (_) => sl<SurahListCubit>()..fetchSurahs(),
            child: const SurahListPage(),
          );
        },
      ),

      GoRoute(
        path: '/surah/:number',
        builder: (context, state) {
          final number = int.parse(
            state.pathParameters['number']!,
          );

          final initialPage = state.extra as int?;

          return BlocProvider(
            create: (_) =>
            sl<SurahDetailsCubit>()..fetchSurah(number),
            child: SurahDetailsPage(
              surahNumber: number,
              initialPage: initialPage,
            ),
          );
        },
      ),
    ],
  );
}