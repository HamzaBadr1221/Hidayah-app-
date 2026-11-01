import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/cubit/theme_cubit.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_colors.dart';
import '../cubit/surah_list_cubit.dart';

class SurahListPage extends StatefulWidget {
  const SurahListPage({super.key});

  @override
  State<SurahListPage> createState() => _SurahListPageState();
}

class _SurahListPageState extends State<SurahListPage> {
  static const List<int> _featuredSurahNumbers = [1, 18, 36, 67];

  static const Color _darkBackground = Color(0xFF171B1C);
  static const Color _darkSurface = Color(0xFF242B2C);
  static const Color _darkElevated = Color(0xFF303A39);
  static const Color _darkPrimary = Color(0xFF3F795B);
  static const Color _darkAccent = Color(0xFF91B6A0);
  static const Color _darkText = Color(0xFFE8ECEA);
  static const Color _darkSecondaryText = Color(0xFFA5AEAA);

  int? _selectedJuz;
  bool _showAllJuz = false;

  static const List<List<int>> _juzStarts = [
    [1, 1],
    [2, 142],
    [2, 253],
    [3, 93],
    [4, 24],
    [4, 148],
    [5, 82],
    [6, 111],
    [7, 88],
    [8, 41],
    [9, 93],
    [11, 6],
    [12, 53],
    [15, 1],
    [17, 1],
    [18, 75],
    [21, 1],
    [23, 1],
    [25, 21],
    [27, 56],
    [29, 46],
    [33, 31],
    [36, 28],
    [39, 32],
    [41, 47],
    [46, 1],
    [51, 31],
    [58, 1],
    [67, 1],
    [78, 1],
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? _darkBackground : null,
      bottomNavigationBar: _buildBottomNavigation(theme),
      appBar: AppBar(
        backgroundColor: isDark ? _darkSurface : null,
        foregroundColor: isDark ? _darkText : null,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          "The Qur'an",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'تغيير المظهر',
            onPressed: () => sl<ThemeCubit>().toggleTheme(),
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<SurahListCubit, SurahListStatus>(
          builder: (context, status) {
            if (status == SurahListStatus.loading ||
                status == SurahListStatus.initial) {
              return Center(
                child: CircularProgressIndicator(
                  color: isDark ? _darkAccent : AppColors.primary,
                ),
              );
            }

            if (status == SurahListStatus.failure) {
              return _buildError(context);
            }

            final surahs = context.read<SurahListCubit>().surahs;

            final featuredSurahs = surahs
                .where(
                  (surah) => _featuredSurahNumbers.contains(surah.number),
            )
                .toList();

            final displayedSurahs = _getDisplayedSurahs(surahs);

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _buildWelcomeCard(context),
                const SizedBox(height: 24),

                _buildSectionTitle(
                  context,
                  title: 'سور مميزة',
                  subtitle: 'ابدأ بقراءة ما تحب',
                ),
                const SizedBox(height: 12),

                SizedBox(
                  height: 155,
                  child: featuredSurahs.isEmpty
                      ? const Center(
                    child: Text('لا توجد سور للعرض'),
                  )
                      : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: featuredSurahs.length,
                    separatorBuilder: (context, index) =>
                    const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final surah = featuredSurahs[index];

                      return _buildFeaturedSurah(
                        context,
                        surah: surah,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 28),

                _buildSectionTitle(
                  context,
                  title: 'أجزاء القرآن الكريم',
                  subtitle: 'اختر الجزء لعرض السور الموجودة فيه',
                ),
                const SizedBox(height: 14),

                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      for (int i = 1; i <= (_showAllJuz ? 30 : 5); i++)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: ChoiceChip(
                            label: Text(
                              'الجزء $i',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isDark ? _darkText : null,
                              ),
                            ),
                            selected: _selectedJuz == i,
                            selectedColor:
                            isDark ? _darkPrimary : AppColors.primary,
                            backgroundColor: isDark ? _darkSurface : null,
                            side: isDark
                                ? const BorderSide(color: _darkElevated)
                                : null,
                            onSelected: (_) {
                              setState(() {
                                _selectedJuz =
                                _selectedJuz == i ? null : i;
                              });
                            },
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: ActionChip(
                          backgroundColor: isDark ? _darkSurface : null,
                          side: isDark
                              ? const BorderSide(color: _darkElevated)
                              : null,
                          avatar: Icon(
                            _showAllJuz
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: isDark ? _darkAccent : AppColors.primary,
                          ),
                          label: Text(
                            _showAllJuz ? 'عرض أقل' : 'المزيد',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isDark ? _darkText : null,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _showAllJuz = !_showAllJuz;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                if (_selectedJuz != null) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedJuz = null;
                        });
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text(
                        'عرض كل السور',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                _buildSectionTitle(
                  context,
                  title: _selectedJuz == null
                      ? 'كل السور'
                      : 'سور الجزء $_selectedJuz',
                  subtitle: _selectedJuz == null
                      ? '${surahs.length} سورة من القرآن الكريم'
                      : '${displayedSurahs.length} سورة في نطاق الجزء المختار',
                ),
                const SizedBox(height: 12),

                if (displayedSurahs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'لا توجد سور للعرض',
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                  ),

                ...displayedSurahs.map(
                      (surah) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildSurahTile(
                      context,
                      surah: surah,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<dynamic> _getDisplayedSurahs(List<dynamic> surahs) {
    if (_selectedJuz == null) {
      return surahs;
    }

    final index = _selectedJuz! - 1;
    final start = _juzStarts[index];

    final startSurah = start[0];
    final startAyah = start[1];

    int endSurah;
    int endAyah;

    if (index == 29) {
      endSurah = 114;
      endAyah = 6;
    } else {
      final nextStart = _juzStarts[index + 1];
      endSurah = nextStart[0];
      endAyah = nextStart[1];
    }

    return surahs.where((surah) {
      final number = surah.number;

      if (number < startSurah || number > endSurah) {
        return false;
      }

      if (number == endSurah && endAyah == 1) {
        return false;
      }

      if (number == startSurah && number == endSurah) {
        return surah.numberOfAyahs >= startAyah &&
            endAyah > startAyah;
      }

      if (number == startSurah) {
        return surah.numberOfAyahs >= startAyah;
      }

      if (number == endSurah && endAyah > 1) {
        return true;
      }

      return true;
    }).toList();
  }

  Widget _buildWelcomeCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final quranVerse = isDark
        ? 'وَنُنَزِّلُ مِنَ الْقُرْآنِ مَا هُوَ شِفَاءٌ وَرَحْمَةٌ لِلْمُؤْمِنِينَ'
        : 'إِنَّ هَذَا الْقُرْآنَ يَهْدِي لِلَّتِي هِيَ أَقْوَمُ';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? const [
            _darkPrimary,
            _darkSurface,
          ]
              : [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.78),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isDark ? _darkPrimary : AppColors.primary)
                .withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            end: -8,
            top: -8,
            child: Icon(
              Icons.menu_book_rounded,
              size: 100,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'القرآن الكريم',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 25,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                quranVerse,
                textDirection: TextDirection.rtl,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'اجعل لك وردًا يوميًا من كتاب الله',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.90),
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'اقرأ، تدبّر، وارتقِ',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      BuildContext context, {
        required String title,
        required String subtitle,
      }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 4,
          height: 42,
          decoration: BoxDecoration(
            color: isDark ? _darkAccent : AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 23,
                  color: isDark ? _darkText : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 15,
                  color: isDark
                      ? _darkSecondaryText
                      : theme.colorScheme.onSurface.withValues(alpha: 0.90),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedSurah(
      BuildContext context, {
        required dynamic surah,
      }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: 145,
      child: Material(
        color: isDark ? _darkElevated : AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.go('/surah/${surah.number}'),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.20),
                width: 1.3,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const Spacer(),
                Text(
                  surah.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${surah.numberOfAyahs} آية',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withValues(alpha: 0.90),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSurahTile(
      BuildContext context, {
        required dynamic surah,
      }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? _darkSurface : AppColors.primary,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/surah/${surah.number}'),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? _darkElevated : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${surah.number}',
                  style: TextStyle(
                    color: isDark ? _darkAccent : AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 19,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah.name,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${surah.englishName} • '
                          '${surah.numberOfAyahs} آية • '
                          '${surah.revelationType == 'Meccan' ? 'مكية' : 'مدنية'}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withValues(alpha: 0.90),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    final cubit = context.read<SurahListCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: isDark ? _darkAccent : AppColors.primary,
            ),
            const SizedBox(height: 14),
            Text(
              cubit.errorMessage ?? 'حدث خطأ أثناء تحميل السور',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                color: isDark ? _darkText : null,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => cubit.fetchSurahs(),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
            _darkSurface,
            _darkBackground,
            Color(0xFF101415),
          ]
              : const [
            Color(0xFF0B493B),
            Color(0xFF052E27),
            Color(0xFF031F1B),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: isDark
                ? _darkPrimary
                : const Color(0xFF68D9B8).withValues(alpha: 0.22),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 22,
            offset: const Offset(0, -7),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 76,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navItem(
                icon: Icons.menu_book_rounded,
                label: 'Quran',
                isDark: isDark,
                onTap: () => context.go('/surahs'),
              ),
              _navItem(
                icon: Icons.auto_stories_rounded,
                label: 'Hadith',
                isDark: isDark,
                onTap: () => _showComingSoon('Hadith'),
              ),
              _navHomeItem(isDark),
              _navItem(
                icon: Icons.favorite_rounded,
                label: 'Azkar',
                isDark: isDark,
                onTap: () => _showComingSoon('Azkar'),
              ),
              _navItem(
                icon: Icons.settings_rounded,
                label: 'Settings',
                isDark: isDark,
                onTap: () => _showComingSoon('Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navHomeItem(bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go('/home'),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 58,
          height: 55,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [_darkAccent, _darkPrimary]
                  : const [Color(0xFF9BF2D5), Color(0xFF55CDA8)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.45),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? _darkAccent : const Color(0xFF68D9B8))
                    .withValues(alpha: 0.32),
                blurRadius: 16,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.home_rounded,
            color: isDark ? _darkBackground : const Color(0xFF052E27),
            size: 29,
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 62,
          height: 62,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 23,
                color: isDark
                    ? _darkSecondaryText
                    : const Color(0xFFB8D6CF),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? _darkText : const Color(0xFFD5E8E2),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: isDark ? _darkAccent : const Color(0xFF9BF2D5),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$feature screen coming soon',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: isDark ? _darkPrimary : const Color(0xFF176B55),
          behavior: SnackBarBehavior.fixed,
          duration: const Duration(seconds: 2),
          elevation: 0,
        ),
      );
  }
}