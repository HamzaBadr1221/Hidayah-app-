import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
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
import '../network/dio_factory.dart';
import '../cubit/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // api بتاع القران
  sl.registerLazySingleton<Dio>(
        () => DioFactory.createDio(),
    instanceName: 'quranDio',
  );

  sl.registerLazySingleton<QuranRemoteDataSource>(
        () => QuranRemoteDataSourceImpl(sl<Dio>(instanceName: 'quranDio')),
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
        () => ThemeCubit(),
  );

  // api بتاع مواقيت الصلاه
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
}