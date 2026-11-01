import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/last_read_service.dart';
import '../../data/surah_page_api.dart';

class SurahDetailsPage extends StatefulWidget {
  final int surahNumber;
  final int? initialPage;

  const SurahDetailsPage({
    super.key,
    required this.surahNumber,
    this.initialPage,
  });

  @override
  State<SurahDetailsPage> createState() => _SurahDetailsPageState();
}

class _SurahDetailsPageState extends State<SurahDetailsPage> {
  final SurahPageApi _api = SurahPageApi();

  PageController? _pageController;

  int? _currentPage;
  bool _initializing = true;
  String? _error;

  static const Color _darkBackground = Color(0xFF171B1C);
  static const Color _darkSurface = Color(0xFF242B2C);
  static const Color _darkAccent = Color(0xFF91B6A0);
  static const Color _darkText = Color(0xFFE8ECEA);

  @override
  void initState() {
    super.initState();
    _initializePages();
  }

  Future<void> _initializePages() async {
    setState(() {
      _initializing = true;
      _error = null;
    });

    try {
      final firstPage = await _api.getFirstPage(widget.surahNumber);

      if (!mounted) return;

      final targetPage = widget.initialPage != null &&
          widget.initialPage! >= 1 &&
          widget.initialPage! <= 604
          ? widget.initialPage!
          : firstPage;

      _pageController?.dispose();

      _pageController = PageController(
        initialPage: targetPage - 1,
      );

      setState(() {
        _currentPage = targetPage;
        _initializing = false;
      });

      await LastReadService.save(
        surahNumber: widget.surahNumber,
        pageNumber: targetPage,
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _initializing = false;
        _error = 'تعذر تحديد صفحة السورة. تأكد من اتصال الإنترنت.';
      });
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  Future<void> _savePage(int pageNumber) async {
    try {
      final surahNumber =
      await _api.getSurahNumberFromPage(pageNumber);

      await LastReadService.save(
        surahNumber: surahNumber,
        pageNumber: pageNumber,
      );
    } catch (e) {
      debugPrint('Error saving last read: $e');
    }
  }

  void _goToPage(int pageNumber) {
    if (pageNumber < 1 || pageNumber > 604) return;

    _pageController?.animateToPage(
      pageNumber - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  String _imageUrl(int pageNumber) {
    final page = pageNumber.toString().padLeft(3, '0');

    return 'https://raw.githubusercontent.com/'
        'akram-seid/quran-hd-images/main/images/$page.jpg';
  }

  Widget _buildPage(int pageNumber, Color paper) {
    return Container(
      color: paper,
      padding: EdgeInsets.zero,
      child: Center(
        child: Image.network(
          _imageUrl(pageNumber),
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;

            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).brightness == Brightness.dark
                    ? _darkAccent
                    : AppColors.primary,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            final isDark =
                Theme.of(context).brightness == Brightness.dark;

            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    size: 44,
                    color: isDark ? _darkAccent : AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'تعذر تحميل صورة الصفحة',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? _darkText : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => setState(() {}),
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(Color paper) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_initializing) {
      return Center(
        child: CircularProgressIndicator(
          color: isDark ? _darkAccent : AppColors.primary,
        ),
      );
    }

    if (_error != null || _pageController == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error ?? 'حدث خطأ أثناء فتح المصحف.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? _darkText : AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _initializePages,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      reverse: true,
      itemCount: 604,
      onPageChanged: (index) {
        final pageNumber = index + 1;

        setState(() {
          _currentPage = pageNumber;
        });

        _savePage(pageNumber);
      },
      itemBuilder: (context, index) {
        return _buildPage(index + 1, paper);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    const paper = Colors.white;

    final background = isDark ? _darkBackground : paper;
    final foreground = isDark ? _darkText : AppColors.primary;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: isDark ? _darkSurface : paper,
        foregroundColor: foreground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/surahs');
            }
          },
        ),
        title: const Text(
          'المصحف الشريف',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: _buildBody(paper),
      ),
      bottomNavigationBar: _currentPage == null
          ? null
          : Container(
        color: isDark ? _darkSurface : paper,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              tooltip: 'الصفحة السابقة',
              onPressed: _currentPage! > 1
                  ? () => _goToPage(_currentPage! - 1)
                  : null,
              color: foreground,
              disabledColor: isDark
                  ? _darkText.withValues(alpha: 0.25)
                  : Colors.black26,
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              'صفحة $_currentPage من 604',
              style: TextStyle(
                color: foreground,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              tooltip: 'الصفحة التالية',
              onPressed: _currentPage! < 604
                  ? () => _goToPage(_currentPage! + 1)
                  : null,
              color: foreground,
              disabledColor: isDark
                  ? _darkText.withValues(alpha: 0.25)
                  : Colors.black26,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }
}