class FavoriteHadith {
  final int number;
  final String arab;
  final String? translation;
  final String bookName;
  final String bookSlug;

  const FavoriteHadith({
    required this.number,
    required this.arab,
    this.translation,
    required this.bookName,
    required this.bookSlug,
  });

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'arab': arab,
      'translation': translation,
      'bookName': bookName,
      'bookSlug': bookSlug,
    };
  }

  factory FavoriteHadith.fromJson(Map<String, dynamic> json) {
    return FavoriteHadith(
      number: (json['number'] as num).toInt(),
      arab: json['arab'] as String,
      translation: json['translation'] as String?,
      bookName: json['bookName'] as String,
      bookSlug: json['bookSlug'] as String,
    );
  }
}