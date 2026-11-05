import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/hadith_of_day_cubit.dart';
import '../../../../core/cubit/theme_cubit.dart';
import '../../../../core/di/injection_container.dart';
import '../cubit/hadith_books_cubit.dart';

class HadithHomePage extends StatelessWidget {
  const HadithHomePage({super.key});

  static const Color _darkBackground = Color(0xFF171B1C);
  static const Color _darkSurface = Color(0xFF242B2C);
  static const Color _darkPrimary = Color(0xFF3F795B);
  static const Color _darkAccent = Color(0xFF91B6A0);
  static const Color _darkSecondaryText = Color(0xFFA5AEAA);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text(
          'الأحاديث النبوية',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              context.push('/hadith/favorites');
            },
            icon: const Icon(Icons.bookmark_outline),
            tooltip: 'المفضلة',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              context.read<HadithBooksCubit>().fetchBooks(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeHeader(context),
                const SizedBox(height: 24),
                _buildHadithOfDay(context),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'مكتبة الحديث',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'الكتب المعتمدة',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                BlocBuilder<HadithBooksCubit, HadithBooksStatus>(
                  builder: (context, state) {
                    if (state == HadithBooksStatus.loading ||
                        state == HadithBooksStatus.initial) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (state == HadithBooksStatus.failure) {
                      return _buildError(context);
                    }

                    final books =
                        context.read<HadithBooksCubit>().books;

                    if (books.isEmpty) {
                      return const Center(
                        child: Text('لا توجد كتب متاحة حاليًا'),
                      );
                    }

                    return ListView.separated(
                      itemCount: books.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final book = books[index];

                        return _buildBookCard(
                          context: context,
                          name: book.name,
                          slug: book.slug,
                          total: book.total,
                          index: index,
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(context ,theme),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'السنة النبوية',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'اقرأ، وتدبّر، واجعل من هدي النبي ﷺ نورًا لحياتك.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildHadithOfDay(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocBuilder<HadithOfDayCubit, HadithOfDayStatus>(
      builder: (context, state) {
        final cubit = context.read<HadithOfDayCubit>();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_stories_rounded,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'حديث اليوم',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (state == HadithOfDayStatus.success)
                    const Icon(
                      Icons.today_rounded,
                      color: Colors.white70,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 22),

              if (state == HadithOfDayStatus.loading ||
                  state == HadithOfDayStatus.initial)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                )
              else if (state == HadithOfDayStatus.failure ||
                  cubit.hadith == null)
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'تعذر تحميل حديث اليوم',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: () {
                          cubit.fetchHadithOfDay(
                            forceRefresh: true,
                          );
                        },
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'إعادة المحاولة',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                  Text(
                    cubit.hadith!.arab,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      height: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Divider(color: Colors.white30),
                  const SizedBox(height: 8),
                  Text(
                    '${_getArabicBookName(cubit.bookName ?? '')} • الحديث رقم ${cubit.hadith!.number}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookCard({
    required BuildContext context,
    required String name,
    required String slug,
    required int total,
    required int index,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          context.push(
            '/hadith/book/$slug?name=${Uri.encodeComponent(name)}',
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: colors.primary,
                  size: 27,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getArabicBookName(name),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    total.toString(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                  Text(
                    'حديث',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getArabicBookName(String name) {
    switch (name.toLowerCase()) {
      case 'abu dawud':
        return 'سنن أبي داود';
      case 'ahmad':
        return 'مسند أحمد';
      case 'bukhari':
        return 'صحيح البخاري';
      case 'darimi':
        return 'سنن الدارمي';
      case 'ibnu majah':
        return 'سنن ابن ماجه';
      case 'malik':
        return 'موطأ الإمام مالك';
      case 'muslim':
        return 'صحيح مسلم';
      case 'nasai':
        return 'سنن النسائي';
      case 'tirmidzi':
        return 'جامع الترمذي';
      default:
        return name;
    }
  }

  Widget _buildError(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 45,
              color: colors.error,
            ),
            const SizedBox(height: 12),
            const Text('تعذر تحميل كتب الحديث'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                context.read<HadithBooksCubit>().fetchBooks();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  // Same Bottom Navigation used in HomePage.

  Widget _buildBottomNavigation(BuildContext context,ThemeData theme) {
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
                onTap: () => context.push('/surahs'),
              ),
              _navItem(
                icon: Icons.auto_stories_rounded,
                label: 'Hadith',
                isDark: isDark,
                onTap: () => context.push('/hadith'),
              ),
              _navHomeItem(context,isDark),
              _navItem(
                icon: Icons.favorite_rounded,
                label: 'Azkar',
                isDark: isDark,
                onTap: () => _showComingSoon(context ,'Azkar'),
              ),
              _navItem(
                icon: Icons.settings_rounded,
                label: 'Settings',
                isDark: isDark,
                onTap: () => _showComingSoon(context ,'Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navHomeItem(BuildContext context ,bool isDark) {
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
                  : const [
                Color(0xFF9BF2D5),
                Color(0xFF55CDA8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.45),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark
                    ? _darkAccent
                    : const Color(0xFF68D9B8))
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
                  color: isDark
                      ? const Color(0xFFE8ECEA)
                      : const Color(0xFFD5E8E2),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context ,String feature) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: isDark
                    ? _darkAccent
                    : const Color(0xFF9BF2D5),
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
          backgroundColor:
          isDark ? _darkPrimary : const Color(0xFF176B55),
          behavior: SnackBarBehavior.fixed,
          duration: const Duration(seconds: 2),
          elevation: 0,
        ),
      );
  }
}