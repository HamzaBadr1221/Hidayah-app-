import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'curved_image_clipper.dart';
import '../../../../core/cubit/theme_cubit.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/last_read_service.dart';
import '../cubit/home_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _clockTimer;
  DateTime _now = DateTime.now();

  int? _lastSurahNumber;
  int? _lastPageNumber;
  bool _loadingLastRead = true;

  final Set<String> _prayed = <String>{};

  // Dark Mode Colors
  static const Color _darkBackground = Color(0xFF171B1C);
  static const Color _darkSurface = Color(0xFF242B2C);
  static const Color _darkElevated = Color(0xFF303A39);
  static const Color _darkPrimary = Color(0xFF3F795B);
  static const Color _darkAccent = Color(0xFF91B6A0);
  static const Color _darkText = Color(0xFFE8ECEA);
  static const Color _darkSecondaryText = Color(0xFFA5AEAA);

  static const List<Map<String, dynamic>> _prayers = [
    {'name': 'Fajr', 'arabic': 'الفجر', 'icon': Icons.nightlight_round},
    {'name': 'Sunrise', 'arabic': 'الشروق', 'icon': Icons.wb_twilight_rounded},
    {'name': 'Dhuhr', 'arabic': 'الظهر', 'icon': Icons.wb_sunny_rounded},
    {'name': 'Asr', 'arabic': 'العصر', 'icon': Icons.sunny},
    {'name': 'Maghrib', 'arabic': 'المغرب', 'icon': Icons.wb_twilight},
    {'name': 'Isha', 'arabic': 'العشاء', 'icon': Icons.nights_stay_rounded},
  ];

  static const List<Map<String, String>> _trackedPrayers = [
    {'name': 'Fajr', 'arabic': 'الفجر'},
    {'name': 'Dhuhr', 'arabic': 'الظهر'},
    {'name': 'Asr', 'arabic': 'العصر'},
    {'name': 'Maghrib', 'arabic': 'المغرب'},
    {'name': 'Isha', 'arabic': 'العشاء'},
  ];

  static const List<String> _surahNames = [
    'Al-Fatihah', 'Al-Baqarah', 'Aal-E-Imran', 'An-Nisa', 'Al-Maidah',
    'Al-Anam', 'Al-Araf', 'Al-Anfal', 'At-Tawbah', 'Yunus',
    'Hud', 'Yusuf', 'Ar-Rad', 'Ibrahim', 'Al-Hijr',
    'An-Nahl', 'Al-Isra', 'Al-Kahf', 'Maryam', 'Ta-Ha',
    'Al-Anbiya', 'Al-Hajj', 'Al-Muminun', 'An-Nur', 'Al-Furqan',
    'Ash-Shuara', 'An-Naml', 'Al-Qasas', 'Al-Ankabut', 'Ar-Rum',
    'Luqman', 'As-Sajdah', 'Al-Ahzab', 'Saba', 'Fatir',
    'Ya-Sin', 'As-Saffat', 'Sad', 'Az-Zumar', 'Ghafir',
    'Fussilat', 'Ash-Shura', 'Az-Zukhruf', 'Ad-Dukhan', 'Al-Jathiyah',
    'Al-Ahqaf', 'Muhammad', 'Al-Fath', 'Al-Hujurat', 'Qaf',
    'Adh-Dhariyat', 'At-Tur', 'An-Najm', 'Al-Qamar', 'Ar-Rahman',
    'Al-Waqiah', 'Al-Hadid', 'Al-Mujadilah', 'Al-Hashr', 'Al-Mumtahanah',
    'As-Saff', 'Al-Jumuah', 'Al-Munafiqun', 'At-Taghabun', 'At-Talaq',
    'At-Tahrim', 'Al-Mulk', 'Al-Qalam', 'Al-Haqqah', 'Al-Maarij',
    'Nuh', 'Al-Jinn', 'Al-Muzzammil', 'Al-Muddaththir', 'Al-Qiyamah',
    'Al-Insan', 'Al-Mursalat', 'An-Naba', 'An-Naziat', 'Abasa',
    'At-Takwir', 'Al-Infitar', 'Al-Mutaffifin', 'Al-Inshiqaq', 'Al-Buruj',
    'At-Tariq', 'Al-Ala', 'Al-Ghashiyah', 'Al-Fajr', 'Al-Balad',
    'Ash-Shams', 'Al-Layl', 'Ad-Duha', 'Ash-Sharh', 'At-Tin',
    'Al-Alaq', 'Al-Qadr', 'Al-Bayyinah', 'Az-Zalzalah', 'Al-Adiyat',
    'Al-Qariah', 'At-Takathur', 'Al-Asr', 'Al-Humazah', 'Al-Fil',
    'Quraysh', 'Al-Maun', 'Al-Kawthar', 'Al-Kafirun', 'An-Nasr',
    'Al-Masad', 'Al-Ikhlas', 'Al-Falaq', 'An-Nas',
  ];

  @override
  void initState() {
    super.initState();
    _scheduleNextMinute();
    _loadLastRead();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<HomeCubit>().fetchPrayerTimes(
        city: 'Cairo',
        country: 'Egypt',
      );
    });
  }

  Future<void> _loadLastRead() async {
    final lastRead = await LastReadService.getLastRead();

    if (!mounted) return;

    setState(() {
      _lastSurahNumber = lastRead?['surahNumber'];
      _lastPageNumber = lastRead?['pageNumber'];
      _loadingLastRead = false;
    });
  }

  Future<void> _openLastRead() async {
    if (_lastSurahNumber == null || _lastPageNumber == null) {
      await context.push('/surahs');
    } else {
      await context.push(
        '/surah/$_lastSurahNumber',
        extra: _lastPageNumber,
      );
    }

    await _loadLastRead();
  }

  void _scheduleNextMinute() {
    _clockTimer?.cancel();

    final now = DateTime.now();
    final secondsUntilNextMinute = 60 - now.second;

    _clockTimer = Timer(
      Duration(
        seconds: secondsUntilNextMinute,
        milliseconds: -now.millisecond,
      ),
          () {
        if (!mounted) return;

        setState(() {
          _now = DateTime.now();
        });

        _scheduleNextMinute();
      },
    );
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? _darkBackground : null,
      extendBody: true,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeroHeader(theme)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildDateCard(theme),
                const SizedBox(height: 24),
                _buildSectionTitle('Prayer Times', 'مواقيت الصلاة', theme),
                const SizedBox(height: 12),
                _buildPrayerTimes(theme),
                const SizedBox(height: 24),
                _buildSectionTitle('Prayer Tracker', 'تابع صلاتك', theme),
                const SizedBox(height: 12),
                _buildPrayerTracker(theme),
                const SizedBox(height: 24),
                _buildSectionTitle('Last Read', 'آخر قراءة', theme),
                const SizedBox(height: 12),
                _buildLastReadCard(theme),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(theme),
    );
  }

  Widget _buildHeroHeader(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 430,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipPath(
            clipper: CurvedImageClipper(),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  isDark
                  ?'assets/images/mosque_night.webp.jpg'
                  :'assets/images/mosque_light.webp.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: isDark ? _darkSurface : const Color(0xFF063D32),
                    );
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.42),
                        Colors.transparent,
                        (isDark ? _darkBackground : const Color(0xFF062D26))
                            .withValues(alpha: 0.96),
                      ],
                      stops: const [0.0, 0.48, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assalamu Alaikum,',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Hamza 👋',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.28),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          tooltip: 'Change theme',
                          onPressed: () {
                            sl<ThemeCubit>().toggleTheme();
                          },
                          icon: Icon(
                            isDark
                                ? Icons.light_mode_rounded
                                : Icons.dark_mode_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Transform.translate(
                    offset: const Offset(0, 53),
                    child: Center(
                      child: Text(
                        DateFormat('hh:mm').format(_now),
                        style: TextStyle(
                          color: isDark ? _darkText : const Color(0xFF087F5B),
                          fontSize: 68,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              color: isDark ? Colors.black54 : Colors.black12,
                              blurRadius: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? _darkText : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? _darkSurface
            : const Color(0xFF0A4035).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? _darkPrimary
              : const Color(0xFF42BFA0).withValues(alpha: 0.30),
        ),
      ),
      child: Column(
        children: [
          Text(
            DateFormat('EEEE, dd MMMM yyyy').format(_now),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Divider(
            color: isDark ? _darkSecondaryText.withValues(alpha: 0.3) : Colors.white30,
          ),
          const SizedBox(height: 8),
          BlocBuilder<HomeCubit, HomeStatus>(
            builder: (context, status) {
              final prayerTimes = context.read<HomeCubit>().prayerTimes;

              if (status == HomeStatus.loading ||
                  status == HomeStatus.initial) {
                return Text(
                  'Loading Hijri date...',
                  style: TextStyle(color: textColor),
                );
              }

              if (prayerTimes == null) {
                return Text(
                  'Hijri date unavailable',
                  style: TextStyle(color: textColor),
                );
              }

              return Text(
                prayerTimes.hijriDate,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      String title,
      String subtitle,
      ThemeData theme,
      ) {
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: isDark ? _darkText : null,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? _darkAccent : const Color(0xFF55CDB0),
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerTimes(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final mainText = isDark ? _darkText : Colors.white;
    final secondaryText = isDark ? _darkSecondaryText : Colors.white70;
    final accent = isDark ? _darkAccent : const Color(0xFFE2CBAE);
    final gold = const Color(0xFFC8B197);

    return BlocBuilder<HomeCubit, HomeStatus>(
      builder: (context, status) {
        final data = context.read<HomeCubit>().prayerTimes;

        if (status == HomeStatus.loading ||
            status == HomeStatus.initial) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: CircularProgressIndicator(
                color: isDark ? _darkAccent : null,
              ),
            ),
          );
        }

        if (data == null) {
          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? _darkSurface : const Color(0xFF0A4035),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? _darkPrimary : Colors.white24,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'تعذر تحميل مواقيت الصلاة',
                  style: TextStyle(color: mainText),
                ),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: () {
                    context.read<HomeCubit>().fetchPrayerTimes(
                      city: 'Cairo',
                      country: 'Egypt',
                    );
                  },
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        final Map<String, String> times = {
          'Fajr': data.fajr,
          'Sunrise': data.sunrise,
          'Dhuhr': data.dhuhr,
          'Asr': data.asr,
          'Maghrib': data.maghrib,
          'Isha': data.isha,
        };

        DateTime? parsePrayerTime(String? rawTime) {
          if (rawTime == null) return null;

          final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(rawTime);
          if (match == null) return null;

          final hour = int.tryParse(match.group(1)!);
          final minute = int.tryParse(match.group(2)!);

          if (hour == null ||
              minute == null ||
              hour > 23 ||
              minute > 59) {
            return null;
          }

          return DateTime(
            _now.year,
            _now.month,
            _now.day,
            hour,
            minute,
          );
        }

        const prayerOrder = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

        String? nextPrayer;
        DateTime? nextPrayerDate;

        for (final name in prayerOrder) {
          final prayerDate = parsePrayerTime(times[name]);

          if (prayerDate != null && prayerDate.isAfter(_now)) {
            nextPrayer = name;
            nextPrayerDate = prayerDate;
            break;
          }
        }

        if (nextPrayer == null) {
          nextPrayer = 'Fajr';
          final fajr = parsePrayerTime(times['Fajr']);
          if (fajr != null) {
            nextPrayerDate = fajr.add(const Duration(days: 1));
          }
        }

        final nextPrayerInfo = _prayers.firstWhere(
              (prayer) => prayer['name'] == nextPrayer,
          orElse: () => _prayers.first,
        );

        final remaining = nextPrayerDate?.difference(_now);
        final remainingText = remaining == null
            ? ''
            : remaining.inHours > 0
            ? '${remaining.inHours}h ${remaining.inMinutes.remainder(60)}m remaining'
            : '${remaining.inMinutes}m remaining';

        Widget glassCard({
          required Widget child,
          required double radius,
          required Color tint,
          EdgeInsets padding = const EdgeInsets.all(14),
        }) {
          return Container(
            padding: padding,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: isDark
                    ? _darkAccent.withValues(alpha: 0.18)
                    : Colors.white.withValues(alpha: 0.16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: child,
          );
        }

        final nextTime = times[nextPrayer]?.split(' ').first ?? '--:--';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            glassCard(
              radius: 26,
              tint: isDark ? _darkSurface : const Color(0xFF0A4035),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: (isDark ? _darkAccent : gold).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (isDark ? _darkAccent : gold).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Icon(
                      nextPrayerInfo['icon'] as IconData,
                      color: accent,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'UP NEXT',
                          style: TextStyle(
                            color: isDark ? _darkAccent : gold,
                            fontSize: 11,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          nextPrayerInfo['name'] as String,
                          style: TextStyle(
                            color: mainText,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          nextPrayerInfo['arabic'] as String,
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        nextTime,
                        style: TextStyle(
                          color: mainText,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (remainingText.isNotEmpty)
                        Text(
                          remainingText,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: isDark ? _darkAccent : gold,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 118,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _prayers.length,
                separatorBuilder: (_, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final prayer = _prayers[index];
                  final name = prayer['name'] as String;
                  final isNext = name == nextPrayer;

                  final prayerContent = SizedBox(
                    width: 76,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          prayer['icon'] as IconData,
                          color: isNext
                              ? accent
                              : (isDark ? _darkSecondaryText : const Color(0xFF8DDCC6)),
                          size: 23,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          name,
                          maxLines: 1,
                          style: TextStyle(
                            color: mainText,
                            fontSize: 12,
                            fontWeight: isNext
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          times[name]?.split(' ').first ?? '--:--',
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );

                  return glassCard(
                    radius: 20,
                    tint: isDark
                        ? (isNext ? _darkPrimary : _darkElevated)
                        : (isNext
                        ? const Color(0xFF176B55)
                        : const Color(0xFF0A4035)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    child: prayerContent,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPrayerTracker(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final mainText = isDark ? _darkText : Colors.white;
    final secondaryText = isDark ? _darkSecondaryText : Colors.white70;
    final accent = isDark ? _darkAccent : const Color(0xFF68D9B8);

    final completed = _trackedPrayers
        .where((prayer) => _prayed.contains(prayer['name']))
        .length;

    final progress = completed / _trackedPrayers.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? _darkSurface : const Color(0xFF0A4035),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? _darkAccent.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.17),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily worship',
                      style: TextStyle(
                        color: mainText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'كل صلاة تقرّبك أكتر',
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: (isDark ? _darkAccent : const Color(0xFFC8B197))
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: (isDark ? _darkAccent : const Color(0xFFC8B197))
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '$completed / 5',
                  style: TextStyle(
                    color: isDark ? _darkAccent : const Color(0xFFE2CBAE),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 158,
            height: 158,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 9,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark
                          ? _darkElevated
                          : Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                ),
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 9,
                    strokeCap: StrokeCap.round,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.mosque_rounded,
                      color: isDark ? _darkAccent : const Color(0xFFC8B197),
                      size: 27,
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '${(progress * 100).round()}%',
                      style: TextStyle(
                        color: mainText,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'completed',
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ..._trackedPrayers.asMap().entries.map((entry) {
            final index = entry.key;
            final prayer = entry.value;
            final name = prayer['name']!;
            final arabic = prayer['arabic']!;
            final checked = _prayed.contains(name);

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == _trackedPrayers.length - 1 ? 0 : 9,
              ),
              child: Material(
                color: checked
                    ? accent.withValues(alpha: 0.10)
                    : (isDark
                    ? _darkElevated
                    : Colors.white.withValues(alpha: 0.045)),
                borderRadius: BorderRadius.circular(17),
                child: InkWell(
                  borderRadius: BorderRadius.circular(17),
                  onTap: () {
                    setState(() {
                      if (checked) {
                        _prayed.remove(name);
                      } else {
                        _prayed.add(name);
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 11,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: checked
                                ? accent.withValues(alpha: 0.18)
                                : (isDark
                                ? _darkSurface
                                : Colors.white.withValues(alpha: 0.07)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            checked
                                ? Icons.check_rounded
                                : Icons.circle_outlined,
                            color: checked
                                ? accent
                                : (isDark ? _darkSecondaryText : Colors.white54),
                            size: 21,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              color: mainText,
                              fontWeight: checked
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          arabic,
                          style: TextStyle(
                            color: isDark ? _darkAccent : const Color(0xFFC8B197),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          checked
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          color: checked
                              ? accent
                              : (isDark ? _darkSecondaryText : Colors.white30),
                          size: 21,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLastReadCard(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    final hasLastRead =
        _lastSurahNumber != null && _lastPageNumber != null;

    final surahName = hasLastRead &&
        _lastSurahNumber! >= 1 &&
        _lastSurahNumber! <= _surahNames.length
        ? _surahNames[_lastSurahNumber! - 1]
        : null;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: _loadingLastRead ? null : _openLastRead,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? const [_darkElevated, _darkSurface]
                  : const [Color(0xFF176B55), Color(0xFF104638)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? _darkPrimary
                  : const Color(0xFF42BFA0).withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.menu_book_rounded,
                size: 48,
                color: isDark ? _darkAccent : Colors.white,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Continue Reading',
                      style: TextStyle(
                        color: isDark ? _darkSecondaryText : Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _loadingLastRead
                          ? 'Loading...'
                          : surahName ?? 'Start Reading Quran',
                      style: TextStyle(
                        color: isDark ? _darkText : Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _loadingLastRead
                          ? 'Please wait'
                          : hasLastRead
                          ? 'Surah $_lastSurahNumber • Page $_lastPageNumber'
                          : 'Tap to choose a Surah',
                      style: TextStyle(
                        color: isDark ? _darkSecondaryText : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: isDark ? _darkText : Colors.white,
                size: 18,
              ),
            ],
          ),
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
                onTap: () => context.push('/surahs'),
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
                color: isDark ? _darkSecondaryText : const Color(0xFFB8D6CF),
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