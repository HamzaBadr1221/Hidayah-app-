import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/favorite_hadith.dart';
import '../../domain/entities/hadith.dart';
import '../cubit/hadith_list_cubit.dart';
import '../cubit/hadith_favorites_cubit.dart';

class HadithBookPage extends StatefulWidget {
  final String slug;
  final String bookName;

  const HadithBookPage({
    super.key,
    required this.slug,
    required this.bookName,
  });

  @override
  State<HadithBookPage> createState() => _HadithBookPageState();
}

class _HadithBookPageState extends State<HadithBookPage> {
  final TextEditingController _searchController =
  TextEditingController();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      if (_searchController.text.isEmpty) {
        context.read<HadithListCubit>().loadMore();
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.bookName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              textDirection: TextDirection.rtl,
              onChanged: (value) {
                context.read<HadithListCubit>().search(value);
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'ابحث في الأحاديث المحمّلة...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    context
                        .read<HadithListCubit>()
                        .search('');
                    setState(() {});
                  },
                  icon: const Icon(Icons.close),
                ),
                filled: true,
                fillColor: colors.surfaceContainerHighest
                    .withValues(alpha: 0.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: BlocBuilder<HadithListCubit, HadithListStatus>(
              builder: (context, state) {
                final cubit = context.read<HadithListCubit>();

                if (state == HadithListStatus.loading ||
                    state == HadithListStatus.initial) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state == HadithListStatus.failure) {
                  return _buildError(context, cubit);
                }

                final hadiths = cubit.filteredHadiths;

                if (hadiths.isEmpty) {
                  return const Center(
                    child: Text('لا توجد نتائج مطابقة للبحث'),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: hadiths.length +
                      (cubit.hasMore &&
                          _searchController.text.isEmpty
                          ? 1
                          : 0),
                  itemBuilder: (context, index) {
                    if (index == hadiths.length) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    return _buildHadithCard(
                      context,
                      hadiths[index],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHadithCard(
      BuildContext context,
      Hadith hadith,
      ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final favoriteHadith = FavoriteHadith(
      number: hadith.number,
      arab: hadith.arab,
      translation: hadith.translation,
      bookName: widget.bookName,
      bookSlug: widget.slug,
    );

    return InkWell(
      onTap: () {
        context.push(
          '/hadith/details',
          extra: favoriteHadith,
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'حديث ${hadith.number}',
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Spacer(),

                BlocBuilder<HadithFavoritesCubit,
                    HadithFavoritesStatus>(
                  builder: (context, state) {
                    final favoritesCubit =
                    context.read<HadithFavoritesCubit>();

                    final isFavorite = favoritesCubit.isFavorite(
                      bookSlug: widget.slug,
                      number: hadith.number,
                    );

                    return IconButton(
                      onPressed: () {
                        favoritesCubit.toggle(
                          hadith: favoriteHadith,
                        );
                      },
                      tooltip: isFavorite ? 'إلغاء الحفظ' : 'حفظ الحديث',
                      icon: Icon(
                        isFavorite
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: isFavorite
                            ? colors.primary
                            : Colors.white,
                        size: 27,
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 18),

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
              widget.bookName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(
      BuildContext context,
      HadithListCubit cubit,
      ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 45,
          ),
          const SizedBox(height: 12),
          Text(cubit.errorMessage ?? 'حدث خطأ أثناء التحميل'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: cubit.retry,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}