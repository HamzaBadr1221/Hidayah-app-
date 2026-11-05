import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/hadith.dart';
import '../../domain/entities/hadith_page.dart';
import '../../domain/usecases/get_hadiths.dart';

enum HadithListStatus {
  initial,
  loading,
  loadingMore,
  success,
  failure,
}

class HadithListCubit extends Cubit<HadithListStatus> {
  final GetHadiths getHadiths;

  HadithListCubit(this.getHadiths)
      : super(HadithListStatus.initial);

  List<Hadith> hadiths = [];
  List<Hadith> filteredHadiths = [];

  String? errorMessage;
  String? bookSlug;
  String? bookName;

  int currentPage = 1;
  int totalPages = 1;

  final int limit = 20;

  bool get hasMore => currentPage < totalPages;

  String normalizeArabic(String text) {
    return text
        .replaceAll(
      RegExp(r'[\u064B-\u065F\u0670\u0640]'),
      '',
    )
        .replaceAll(RegExp('[أإآٱ]'), 'ا')
        .replaceAll('ى', 'ي')
        .toLowerCase()
        .trim();
  }

  Future<void> fetchHadiths({
    required String slug,
    required String name,
  }) async {
    bookSlug = slug;
    bookName = name;

    currentPage = 1;
    totalPages = 1;

    hadiths = [];
    filteredHadiths = [];
    errorMessage = null;

    emit(HadithListStatus.loading);

    try {
      final HadithPage result = await getHadiths(
        slug: slug,
        page: currentPage,
        limit: limit,
      );

      hadiths = result.items;
      filteredHadiths = List.from(hadiths);

      currentPage = result.currentPage;
      totalPages = result.totalPages;

      emit(HadithListStatus.success);
    } catch (error) {
      errorMessage = 'تعذر تحميل الأحاديث. حاول مرة أخرى.';
      emit(HadithListStatus.failure);
    }
  }

  Future<void> loadMore() async {
    if (state == HadithListStatus.loading ||
        state == HadithListStatus.loadingMore ||
        !hasMore ||
        bookSlug == null) {
      return;
    }

    emit(HadithListStatus.loadingMore);

    try {
      final result = await getHadiths(
        slug: bookSlug!,
        page: currentPage + 1,
        limit: limit,
      );

      hadiths.addAll(result.items);

      currentPage = result.currentPage;
      totalPages = result.totalPages;

      final query = _lastSearchQuery;
      _filterHadiths(query);

      emit(HadithListStatus.success);
    } catch (error) {
      errorMessage = 'تعذر تحميل المزيد من الأحاديث.';
      emit(HadithListStatus.success);
    }
  }

  String _lastSearchQuery = '';

  void search(String query) {
    _lastSearchQuery = query;
    _filterHadiths(query);
    emit(HadithListStatus.success);
  }

  void _filterHadiths(String query) {
    final searchQuery = normalizeArabic(query);

    if (searchQuery.isEmpty) {
      filteredHadiths = List.from(hadiths);
      return;
    }

    filteredHadiths = hadiths.where((hadith) {
      final arabicText = normalizeArabic(hadith.arab);

      final translationText =
      normalizeArabic(hadith.translation ?? '');

      return arabicText.contains(searchQuery) ||
          translationText.contains(searchQuery);
    }).toList();
  }

  Future<void> retry() async {
    if (bookSlug == null || bookName == null) return;

    await fetchHadiths(
      slug: bookSlug!,
      name: bookName!,
    );
  }
}