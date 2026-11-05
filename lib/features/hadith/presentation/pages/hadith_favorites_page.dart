import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/favorite_hadith.dart';
import '../cubit/hadith_favorites_cubit.dart';

class HadithFavoritesPage extends StatelessWidget {
  const HadithFavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الأحاديث المفضلة',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<HadithFavoritesCubit,
          HadithFavoritesStatus>(
        builder: (context, state) {
          final cubit = context.read<HadithFavoritesCubit>();

          if (state == HadithFavoritesStatus.loading ||
              state == HadithFavoritesStatus.initial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state == HadithFavoritesStatus.failure) {
            return const Center(
              child: Text('تعذر تحميل المفضلة'),
            );
          }

          final favorites = cubit.favorites;

          if (favorites.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bookmark_border_rounded,
                      size: 75,
                      color: colors.primary.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'لا توجد أحاديث محفوظة',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'يمكنك إضافة الأحاديث إلى المفضلة '
                          'للرجوع إليها لاحقًا.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final hadith = favorites[index];

              return _buildFavoriteCard(
                context: context,
                hadith: hadith,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFavoriteCard({
    required BuildContext context,
    required FavoriteHadith hadith,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      onTap: () {
        context.push(
          '/hadith/details',
          extra: hadith,
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest
              .withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  color: colors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hadith.bookName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    context.read<HadithFavoritesCubit>().toggle(
                      hadith: hadith,
                    );
                  },
                  icon: Icon(
                    Icons.bookmark,
                    color: colors.primary,
                  ),
                  tooltip: 'إزالة من المفضلة',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              hadith.arab,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.justify,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 21,
                height: 2,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'رقم الحديث: ${hadith.number}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}