import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/surah.dart';
import '../../domain/usecases/get_surah_details.dart';

enum SurahDetailsStatus {
  initial,
  loading,
  success,
  failure,
}

class SurahDetailsCubit extends Cubit<SurahDetailsStatus> {
  final GetSurahDetails getSurahDetails;

  SurahDetailsCubit(this.getSurahDetails)
      : super(SurahDetailsStatus.initial);

  Surah? surah;
  String? errorMessage;

  Future<void> fetchSurah(int number) async {
    emit(SurahDetailsStatus.loading);
    errorMessage = null;

    try {
      surah = await getSurahDetails(number);
      emit(SurahDetailsStatus.success);
    } catch (error) {
      errorMessage = 'تعذر تحميل السورة. حاول مرة أخرى.';
      emit(SurahDetailsStatus.failure);
    }
  }
}