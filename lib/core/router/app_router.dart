import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/quran/presentation/cubit/surah_details_cubit.dart';
import '../../features/quran/presentation/cubit/surah_list_cubit.dart';
import '../../features/quran/presentation/pages/surah_details_page.dart';
import '../../features/quran/presentation/pages/surah_list_page.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/hadith/domain/entities/favorite_hadith.dart';
import '../../features/hadith/presentation/cubit/hadith_books_cubit.dart';
import '../../features/hadith/presentation/cubit/hadith_list_cubit.dart';
import '../../features/hadith/presentation/cubit/hadith_favorites_cubit.dart';
import '../../features/hadith/presentation/cubit/hadith_of_day_cubit.dart';
import '../../features/hadith/presentation/pages/hadith_home_page.dart';
import '../../features/hadith/presentation/pages/hadith_book_page.dart';
import '../../features/hadith/presentation/pages/hadith_favorites_page.dart';
import '../../features/hadith/presentation/pages/hadith_details_page.dart';
import '../di/injection_container.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),

      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),

      GoRoute(
        path: '/home',
        builder: (context, state) {
          final preferences = sl<SharedPreferences>();

          final city =
              preferences.getString('profile_city') ?? 'Cairo';

          final country =
              preferences.getString('profile_country') ?? 'Egypt';

          return BlocProvider(
            create: (_) => sl<HomeCubit>()
              ..fetchPrayerTimes(
                city: city,
                country: country,
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

      GoRoute(
        path: '/hadith',
        builder: (context, state) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => sl<HadithBooksCubit>()..fetchBooks(),
              ),
              BlocProvider(
                create: (_) =>
                sl<HadithFavoritesCubit>()..fetchFavorites(),
              ),
              BlocProvider(
                create: (_) =>
                sl<HadithOfDayCubit>()..fetchHadithOfDay(),
              ),
            ],
            child: const HadithHomePage(),
          );
        },
      ),

      GoRoute(
        path: '/hadith/book/:slug',
        builder: (context, state) {
          final slug = state.pathParameters['slug']!;
          final bookName =
              state.uri.queryParameters['name'] ?? slug;

          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => sl<HadithListCubit>()
                  ..fetchHadiths(
                    slug: slug,
                    name: bookName,
                  ),
              ),
              BlocProvider(
                create: (_) =>
                sl<HadithFavoritesCubit>()..fetchFavorites(),
              ),
            ],
            child: HadithBookPage(
              slug: slug,
              bookName: bookName,
            ),
          );
        },
      ),

      GoRoute(
        path: '/hadith/favorites',
        builder: (context, state) {
          return BlocProvider(
            create: (_) =>
            sl<HadithFavoritesCubit>()..fetchFavorites(),
            child: const HadithFavoritesPage(),
          );
        },
      ),

      GoRoute(
        path: '/hadith/details',
        builder: (context, state) {
          final hadith = state.extra as FavoriteHadith;

          return HadithDetailsPage(
            hadith: hadith,
          );
        },
      ),
    ],
  );
}