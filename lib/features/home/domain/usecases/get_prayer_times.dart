import '../entities/prayer_times.dart';
import '../repositories/prayer_repository.dart';

class GetPrayerTimes {
  final PrayerRepository repository;

  GetPrayerTimes(this.repository);

  Future<PrayerTimes> call({
    required String city,
    required String country,
    required String date,
  }) {
    return repository.getPrayerTimes(
      city: city,
      country: country,
      date: date,
    );
  }
}