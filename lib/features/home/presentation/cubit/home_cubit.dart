import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/prayer_times.dart';
import '../../domain/usecases/get_prayer_times.dart';

enum HomeStatus {
  initial,
  loading,
  success,
  failure,
}

class HomeCubit extends Cubit<HomeStatus> {
  final GetPrayerTimes getPrayerTimes;

  HomeCubit(this.getPrayerTimes) : super(HomeStatus.initial);

  PrayerTimes? prayerTimes;
  String? errorMessage;

  Future<void> fetchPrayerTimes({
    required String city,
    required String country,
  }) async {
    emit(HomeStatus.loading);
    errorMessage = null;

    try {
      final now = DateTime.now();
      final date =
          '${now.day.toString().padLeft(2, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.year}';

      prayerTimes = await getPrayerTimes(
        city: city,
        country: country,
        date: date,
      );

      emit(HomeStatus.success);
    } catch (error) {
      errorMessage = 'تعذر تحميل مواقيت الصلاة. حاول مرة أخرى.';
      emit(HomeStatus.failure);
    }
  }
}