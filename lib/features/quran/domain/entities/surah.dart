import 'package:equatable/equatable.dart';

class Ayah extends Equatable {
  final int number;
  final int numberInSurah;
  final String text;

  const Ayah({
    required this.number,
    required this.numberInSurah,
    required this.text,
  });

  @override
  List<Object?> get props => [
    number,
    numberInSurah,
    text,
  ];
}

class Surah extends Equatable {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;
  final List<Ayah> ayahs;

  const Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
    this.ayahs = const [],
  });

  @override
  List<Object?> get props =>
      [
        number,
        name,
        englishName,
        englishNameTranslation,
        numberOfAyahs,
        revelationType,
        ayahs,
      ];
}