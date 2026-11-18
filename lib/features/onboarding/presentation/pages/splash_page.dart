import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di/injection.dart';
import '../../../../core/config/app_preferences.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/widgets/brand_logo.dart';

/// Smart splash screen — the app's first impression.
///
/// Clean light background (Round 2 light theme) with a scaling/fading
/// brand mark and the website tagline. Shows for at most ~1.8s, then
/// routes:
/// - first run  -> onboarding (`/onboarding`)
/// - returning  -> home (`/`)
/// Session restore already happened in `main()` before `runApp`, and the
/// router's auth guard handles protected destinations from there.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  Timer? _timer;

  /// Total splash dwell time (kept short: max ~2s per brand requirement).
  static const Duration dwell = Duration(milliseconds: 1800);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _scale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
    _timer = Timer(dwell, _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    var seen = true; // if prefs are unavailable, never trap the user here
    if (sl.isRegistered<AppPreferencesService>()) {
      seen = sl<AppPreferencesService>().onboardingSeen;
    }
    context.go(seen ? '/' : '/onboarding');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BrandLogo(
                    size: 96,
                    wordmarkColor: AppColors.textPrimaryLight,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      l10n.heroTitle, // "আপনার পছন্দের ঘর খুঁজুন সহজেই"
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        // Deep emerald (not mint) for readability on light.
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
