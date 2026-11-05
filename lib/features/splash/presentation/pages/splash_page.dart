import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injection_container.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _textFade;
  late final Animation<double> _subtitleFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.0,
        0.45,
        curve: Curves.easeIn,
      ),
    );

    _logoScale = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.65,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    _textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.45,
        0.85,
        curve: Curves.easeIn,
      ),
    );

    _subtitleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.65,
        1.0,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();

    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(
      const Duration(milliseconds: 5000),
    );

    if (!mounted) return;

    final preferences = sl<SharedPreferences>();

    final isProfileCompleted =
        preferences.getBool('profile_completed') ?? false;

    if (!mounted) return;

    if (isProfileCompleted) {
      context.go('/home');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _logoFade,
              child: ScaleTransition(
                scale: _logoScale,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(
                          alpha: 0.25,
                        ),
                        blurRadius: 65,
                        spreadRadius: 12,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.nightlight_round,
                    size: 105,
                    color: colors.primary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            FadeTransition(
              opacity: _textFade,
              child: Text(
                'Hidaya',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: colors.onSurface,
                ),
              ),
            ),

            const SizedBox(height: 12),

            FadeTransition(
              opacity: _subtitleFade,
              child: Text(
                'Your Path to Peace',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                  color: colors.onSurface.withValues(
                    alpha: 0.75,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}