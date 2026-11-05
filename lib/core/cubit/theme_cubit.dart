import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../../features/home/domain/usecases/get_prayer_times.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final GetPrayerTimes getPrayerTimes;
  final SharedPreferences sharedPreferences;

  Timer? _timer;

  bool _isFetching = false;

  String? _lastFetchedDate;
  DateTime? _lastAttemptAt;

  String? _city;
  String? _country;

  int _locationVersion = 0;

  static const String _maghribKey = 'theme_maghrib';
  static const String _fajrKey = 'theme_fajr';
  static const String _cityKey = 'theme_city';
  static const String _countryKey = 'theme_country';
  static const String _timezoneKey = 'theme_timezone';

  ThemeCubit({
    required this.getPrayerTimes,
    required this.sharedPreferences,
  }) : super(ThemeMode.light) {
    tz_data.initializeTimeZones();
  }

  Future<void> initialize({
    required String city,
    required String country,
  }) async {
    _city = city;
    _country = country;

    await refreshPrayerTimes(
      city: city,
      country: country,
    );

    _updateThemeFromSavedTimes();

    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(minutes: 1),
          (_) {
        final currentCity = _city;
        final currentCountry = _country;

        if (currentCity == null || currentCountry == null) {
          return;
        }

        final today = _getTodayDate();

        final shouldRefresh =
            _lastFetchedDate != today ||
                _lastAttemptAt == null ||
                DateTime.now().difference(_lastAttemptAt!) >=
                    const Duration(minutes: 30);

        if (shouldRefresh && !_isFetching) {
          refreshPrayerTimes(
            city: currentCity,
            country: currentCountry,
          );
        } else {
          _updateThemeFromSavedTimes();
        }
      },
    );
  }

  Future<void> updateLocation({
    required String city,
    required String country,
  }) async {
    if (_city == city && _country == country) {
      return;
    }

    _city = city;
    _country = country;

    _locationVersion++;

    _lastFetchedDate = null;
    _lastAttemptAt = null;

    await refreshPrayerTimes(
      city: city,
      country: country,
    );
  }

  Future<void> refreshPrayerTimes({
    required String city,
    required String country,
  }) async {
    if (_city != city || _country != country) {
      _city = city;
      _country = country;
      _locationVersion++;
    }

    if (_isFetching) return;

    _isFetching = true;

    final requestVersion = _locationVersion;

    try {
      var requestDate = _getApiDate(_cityNow());

      var prayerTimes = await getPrayerTimes(
        city: city,
        country: country,
        date: requestDate,
      );

      if (requestVersion != _locationVersion) return;

      final location = tz.getLocation(prayerTimes.timezone);
      final cityNow = tz.TZDateTime.now(location);

      final correctDate = _getApiDate(cityNow);

      if (correctDate != requestDate) {
        requestDate = correctDate;

        prayerTimes = await getPrayerTimes(
          city: city,
          country: country,
          date: requestDate,
        );
      }

      if (requestVersion != _locationVersion) return;

      await sharedPreferences.setString(
        _fajrKey,
        prayerTimes.fajr,
      );

      await sharedPreferences.setString(
        _maghribKey,
        prayerTimes.maghrib,
      );

      await sharedPreferences.setString(_cityKey, city);
      await sharedPreferences.setString(_countryKey, country);
      await sharedPreferences.setString(
        _timezoneKey,
        prayerTimes.timezone,
      );

      _lastFetchedDate = _getTodayDate();

      _updateThemeFromSavedTimes();
    } catch (error) {
      debugPrint('Theme prayer times error: $error');
      _updateThemeFromSavedTimes();
    } finally {
      _lastAttemptAt = DateTime.now();
      _isFetching = false;

      if (requestVersion != _locationVersion &&
          _city != null &&
          _country != null) {
        refreshPrayerTimes(
          city: _city!,
          country: _country!,
        );
      }
    }
  }

  DateTime _cityNow() {
    final timezone = sharedPreferences.getString(_timezoneKey);

    if (timezone == null) {
      return DateTime.now();
    }

    try {
      return tz.TZDateTime.now(tz.getLocation(timezone));
    } catch (_) {
      return DateTime.now();
    }
  }

  void _updateThemeFromSavedTimes() {
    final savedCity = sharedPreferences.getString(_cityKey);
    final savedCountry = sharedPreferences.getString(_countryKey);

    if (savedCity != _city || savedCountry != _country) {
      return;
    }

    final fajr = sharedPreferences.getString(_fajrKey);
    final maghrib = sharedPreferences.getString(_maghribKey);

    if (fajr == null || maghrib == null) return;

    final fajrMinutes = _timeToMinutes(fajr);
    final maghribMinutes = _timeToMinutes(maghrib);

    if (fajrMinutes == null || maghribMinutes == null) {
      return;
    }

    final now = _cityNow();
    final currentMinutes = now.hour * 60 + now.minute;

    final isNight =
        currentMinutes >= maghribMinutes ||
            currentMinutes < fajrMinutes;

    final newTheme = isNight
        ? ThemeMode.dark
        : ThemeMode.light;

    if (state != newTheme) {
      emit(newTheme);
    }
  }

  int? _timeToMinutes(String time) {
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(time);

    if (match == null) return null;

    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);

    if (hour == null || minute == null) return null;
    if (hour > 23 || minute > 59) return null;

    return hour * 60 + minute;
  }

  String _getApiDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }

  String _getTodayDate() {
    final now = _cityNow();

    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  void toggleTheme() {
    emit(
      state == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark,
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}