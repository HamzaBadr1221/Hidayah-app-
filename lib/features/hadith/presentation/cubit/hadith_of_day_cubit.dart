import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/hadith.dart';
import '../../domain/entities/hadith_book.dart';
import '../../domain/usecases/get_hadith_books.dart';
import '../../domain/usecases/get_hadiths.dart';

enum HadithOfDayStatus {
  initial,
  loading,
  success,
  failure,
}

class HadithOfDayCubit extends Cubit<HadithOfDayStatus> {
  final GetHadithBooks getHadithBooks;
  final GetHadiths getHadiths;

  HadithOfDayCubit({
    required this.getHadithBooks,
    required this.getHadiths,
  }) : super(HadithOfDayStatus.initial);

  Hadith? hadith;
  String? bookName;

  Timer? _midnightTimer;
  String? _loadedDate;

  static const int _limit = 20;

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  int _dayNumber(DateTime date) {
    final today = DateTime(date.year, date.month, date.day);
    return today.difference(DateTime(2000, 1, 1)).inDays;
  }

  Future<void> fetchHadithOfDay({bool forceRefresh = false}) async {
    final now = DateTime.now();
    final today = _dateKey(now);

    if (!forceRefresh && _loadedDate == today && hadith != null) {
      _scheduleMidnightRefresh();
      return;
    }

    emit(HadithOfDayStatus.loading);

    try {
      final List<HadithBook> books = await getHadithBooks();

      final availableBooks = books
          .where((book) => book.total > 0)
          .toList();

      if (availableBooks.isEmpty) {
        throw Exception('No hadith books available');
      }

      final totalHadiths = availableBooks.fold<int>(
        0,
            (sum, book) => sum + book.total,
      );

      final dailyIndex = _dayNumber(now) % totalHadiths;

      var remainingIndex = dailyIndex;
      HadithBook? selectedBook;

      for (final book in availableBooks) {
        if (remainingIndex < book.total) {
          selectedBook = book;
          break;
        }

        remainingIndex -= book.total;
      }

      if (selectedBook == null) {
        throw Exception("Could not select today's hadith");
        }

        final page = (remainingIndex ~/ _limit) + 1;
        final itemIndex = remainingIndex % _limit;

        final result = await getHadiths(
          slug: selectedBook.slug,
          page: page,
          limit: _limit,
        );

        if (result.items.isEmpty) {
          throw Exception('No hadiths found on selected page');
        }

        final selectedHadith = itemIndex < result.items.length
            ? result.items[itemIndex]
            : result.items.first;

        hadith = selectedHadith;
        bookName = selectedBook.name;
        _loadedDate = today;

        emit(HadithOfDayStatus.success);
        _scheduleMidnightRefresh();
      } catch (error) {
      emit(HadithOfDayStatus.failure);
      _scheduleMidnightRefresh();
    }
  }

  void _scheduleMidnightRefresh() {
    _midnightTimer?.cancel();

    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    final duration = tomorrow.difference(now);

    _midnightTimer = Timer(duration, () {
      fetchHadithOfDay(forceRefresh: true);
    });
  }

  @override
  Future<void> close() {
    _midnightTimer?.cancel();
    return super.close();
  }
}