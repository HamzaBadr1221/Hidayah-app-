class Hadith {
  final int number;
  final String arab;
  final String? translation;

  const Hadith({
    required this.number,
    required this.arab,
    this.translation,
  });
}