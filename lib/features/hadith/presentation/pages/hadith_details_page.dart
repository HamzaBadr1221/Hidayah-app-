import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/favorite_hadith.dart';

class HadithDetailsPage extends StatelessWidget {
  final FavoriteHadith hadith;

  const HadithDetailsPage({
    super.key,
    required this.hadith,
  });

  String get shareText {
    return '${hadith.arab}\n\n'
        '${hadith.bookName} - الحديث رقم ${hadith.number}';
  }

  Future<void> copyHadith(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(text: shareText),
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ الحديث بنجاح'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الحديث'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => copyHadith(context),
            icon: const Icon(Icons.copy),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(
                  alpha: 0.08,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    hadith.bookName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('الحديث رقم ${hadith.number}'),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Text(
              'نص الحديث',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                hadith.arab,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.justify,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 22,
                  height: 2,
                ),
              ),
            ),
            const SizedBox(height: 25),
            if (hadith.translation != null &&
                hadith.translation!.isNotEmpty) ...[
              Text(
                'الترجمة',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                hadith.translation!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 25),
            ],
            ElevatedButton.icon(
              onPressed: () => copyHadith(context),
              icon: const Icon(Icons.copy),
              label: const Text('نسخ الحديث'),
            ),
          ],
        ),
      ),
    );
  }
}