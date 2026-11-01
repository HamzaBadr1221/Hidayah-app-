import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/surah.dart';
import '../../domain/usecases/get_surahs.dart';

enum SurahListStatus {
  initial,
  loading,
  success,
  failure,
}

class SurahListCubit extends Cubit<SurahListStatus> {
  final GetSurahs getSurahs;

  SurahListCubit(this.getSurahs)
      : super(SurahListStatus.initial);

  List<Surah> surahs = [];
  String? errorMessage;

  Future<void> fetchSurahs() async {
    emit(SurahListStatus.loading);
    errorMessage = null;

    try {
      surahs = await getSurahs();
      emit(SurahListStatus.success);
    } catch (error) {
      errorMessage = 'تعذر تحميل السور. تأكد من اتصال الإنترنت.';
      emit(SurahListStatus.failure);
    }
  }
}