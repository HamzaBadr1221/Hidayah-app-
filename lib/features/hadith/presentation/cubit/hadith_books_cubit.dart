import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/hadith_book.dart';
import '../../domain/usecases/get_hadith_books.dart';

enum HadithBooksStatus {
  initial,
  loading,
  success,
  failure,
}

class HadithBooksCubit extends Cubit<HadithBooksStatus> {
  final GetHadithBooks getHadithBooks;

  HadithBooksCubit(this.getHadithBooks)
      : super(HadithBooksStatus.initial);

  List<HadithBook> books = [];
  String? errorMessage;

  Future<void> fetchBooks() async {
    emit(HadithBooksStatus.loading);
    errorMessage = null;

    try {
      books = await getHadithBooks();
      emit(HadithBooksStatus.success);
    } catch (error) {
      errorMessage = 'تعذر تحميل كتب الحديث. حاول مرة أخرى.';
      emit(HadithBooksStatus.failure);
    }
  }
}