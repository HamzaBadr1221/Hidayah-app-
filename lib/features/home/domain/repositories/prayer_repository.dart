import '../entities/prayer_times.dart';

abstract class PrayerRepository {
  Future<PrayerTimes> getPrayerTimes({
    required String city,
    required String country,
    required String date,
  });
}