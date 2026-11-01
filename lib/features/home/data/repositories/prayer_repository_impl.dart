import '../../domain/entities/prayer_times.dart';
import '../../domain/repositories/prayer_repository.dart';
import '../data_sources/prayer_remote_data_source.dart';

class PrayerRepositoryImpl implements PrayerRepository {
final PrayerRemoteDataSource remoteDataSource;

PrayerRepositoryImpl(this.remoteDataSource);

@override
Future<PrayerTimes> getPrayerTimes({
required String city,
required String country,
required String date,
}) async {
final data = await remoteDataSource.getPrayerTimes(
city: city,
country: country,
date: date,
);

final timings = data['timings'] as Map<String, dynamic>;
final dateData = data['date'] as Map<String, dynamic>;
final hijri = dateData['hijri'] as Map<String, dynamic>;
final hijriMonth = hijri['month'] as Map<String, dynamic>;

final day = _toArabicNumbers(hijri['day'].toString());
final month = hijriMonth['ar']?.toString() ?? '';
final year = _toArabicNumbers(hijri['year'].toString());

return PrayerTimes(
fajr: timings['Fajr'].toString(),
sunrise: timings['Sunrise'].toString(),
dhuhr: timings['Dhuhr'].toString(),
asr: timings['Asr'].toString(),
maghrib: timings['Maghrib'].toString(),
isha: timings['Isha'].toString(),
hijriDate: '$day $month $year هـ',
city: city,
country: country,
);
}

String _toArabicNumbers(String value) {
const englishNumbers = '0123456789';
const arabicNumbers = '٠١٢٣٤٥٦٧٨٩';

return value.split('').map((character) {
final index = englishNumbers.indexOf(character);
return index == -1 ? character : arabicNumbers[index];
}).join();
}
}