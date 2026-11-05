import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/quran/data/data_sources/quran_remote_data_source.dart';
import '../../features/quran/data/repositories/quran_repository_impl.dart';
import '../../features/quran/domain/repositories/quran_repository.dart';
import '../../features/quran/domain/usecases/get_surah_details.dart';
import '../../features/quran/domain/usecases/get_surahs.dart';
import '../../features/quran/presentation/cubit/surah_details_cubit.dart';
import '../../features/quran/presentation/cubit/surah_list_cubit.dart';
import '../../features/home/data/data_sources/prayer_remote_data_source.dart';
import '../../features/home/data/repositories/prayer_repository_impl.dart';
import '../../features/home/domain/repositories/prayer_repository.dart';
import '../../features/home/domain/usecases/get_prayer_times.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/hadith/presentation/cubit/hadith_of_day_cubit.dart';
import '../../features/hadith/data/datasources/hadith_remote_data_source.dart';
import '../../features/hadith/data/datasources/hadith_local_data_source.dart';
import '../../features/hadith/data/repositories/hadith_repository_impl.dart';
import '../../features/hadith/data/repositories/hadith_favorites_repository_impl.dart';
import '../../features/hadith/domain/repositories/hadith_repository.dart';
import '../../features/hadith/domain/repositories/hadith_favorites_repository.dart';
import '../../features/hadith/domain/usecases/get_hadith_books.dart';
import '../../features/hadith/domain/usecases/get_hadiths.dart';
import '../../features/hadith/domain/usecases/get_favorites.dart';
import '../../features/hadith/domain/usecases/toggle_favorite.dart';
import '../../features/hadith/presentation/cubit/hadith_books_cubit.dart';
import '../../features/hadith/presentation/cubit/hadith_list_cubit.dart';
import '../../features/hadith/presentation/cubit/hadith_favorites_cubit.dart';
import '../network/dio_factory.dart';
import '../cubit/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {

  final sharedPreferences = await SharedPreferences.getInstance();

  sl.registerLazySingleton<SharedPreferences>(
        () => sharedPreferences,
  );


  sl.registerLazySingleton<Dio>(
        () => DioFactory.createDio(),
    instanceName: 'quranDio',
  );

  sl.registerLazySingleton<QuranRemoteDataSource>(
        () => QuranRemoteDataSourceImpl(
      sl<Dio>(instanceName: 'quranDio'),
    ),
  );

  sl.registerLazySingleton<QuranRepository>(
        () => QuranRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<GetSurahs>(
        () => GetSurahs(sl()),
  );

  sl.registerLazySingleton<GetSurahDetails>(
        () => GetSurahDetails(sl()),
  );

  sl.registerFactory<SurahListCubit>(
        () => SurahListCubit(sl()),
  );

  sl.registerFactory<SurahDetailsCubit>(
        () => SurahDetailsCubit(sl()),
  );


  sl.registerLazySingleton<ThemeCubit>(
        () => ThemeCubit(
          getPrayerTimes:  sl<GetPrayerTimes>(),
          sharedPreferences: sl<SharedPreferences>(),
        ),
  );


  sl.registerLazySingleton<Dio>(
        () => Dio(
      BaseOptions(
        baseUrl: 'https://api.aladhan.com/v1/',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
        },
      ),
    ),
    instanceName: 'prayerDio',
  );

  sl.registerLazySingleton<PrayerRemoteDataSource>(
        () => PrayerRemoteDataSourceImpl(
      sl<Dio>(instanceName: 'prayerDio'),
    ),
  );

  sl.registerLazySingleton<PrayerRepository>(
        () => PrayerRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<GetPrayerTimes>(
        () => GetPrayerTimes(sl()),
  );

  sl.registerFactory<HomeCubit>(
        () => HomeCubit(sl()),
  );

  sl.registerLazySingleton<Dio>(
        () => Dio(
      BaseOptions(
        baseUrl: 'https://hadis-api-id.vercel.app/',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
        },
      ),
    ),
    instanceName: 'hadithDio',
  );

  sl.registerLazySingleton<HadithRemoteDataSource>(
        () => HadithRemoteDataSourceImpl(
      sl<Dio>(instanceName: 'hadithDio'),
    ),
  );

  sl.registerLazySingleton<HadithLocalDataSource>(
        () => HadithLocalDataSourceImpl(
      sl<SharedPreferences>(),
    ),
  );
  sl.registerLazySingleton<HadithRepository>(
        () => HadithRepositoryImpl(
      sl<HadithRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<HadithFavoritesRepository>(
        () => HadithFavoritesRepositoryImpl(
      sl<HadithLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton(
        () => GetHadithBooks(sl<HadithRepository>()),
  );

  sl.registerLazySingleton(
        () => GetHadiths(sl<HadithRepository>()),
  );

  sl.registerLazySingleton(
        () => GetFavorites(sl<HadithFavoritesRepository>()),
  );

  sl.registerLazySingleton(
        () => ToggleFavorite(sl<HadithFavoritesRepository>()),
  );

  sl.registerFactory(
        () => HadithBooksCubit(sl<GetHadithBooks>()),
  );

  sl.registerFactory(
        () => HadithListCubit(sl<GetHadiths>()),
  );

  sl.registerFactory(
        () => HadithFavoritesCubit(
      getFavorites: sl<GetFavorites>(),
      toggleFavorite: sl<ToggleFavorite>(),
    ),
  );
  sl.registerFactory(
      () => HadithOfDayCubit(
        getHadithBooks: sl<GetHadithBooks>(),
        getHadiths: sl<GetHadiths>(),
      ),
  );
}