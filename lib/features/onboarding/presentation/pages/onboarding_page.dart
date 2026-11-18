import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di/injection.dart';
import '../../../../core/config/app_preferences.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/widgets/app_button.dart';

/// First-run onboarding, shown once per install.
///
/// Page 1 (Round 2) is a setup step: the user picks Theme
/// (Light / Dark / System) and Language (বাংলা / English) before anything
/// else. Choices are written straight into [AppPreferencesService] —
/// the same preference keys Profile/Settings uses — so the app rebuilds
/// instantly with the chosen theme/locale and the choice persists.
/// Pages 2–4 are the value propositions from Round 1.
///
/// A SharedPreferences flag (`AppPreferencesService.onboardingSeen`) is set
/// when the user taps Skip or Get Started, so returning users never see it
/// again. Copy mirrors the website's value propositions.
class OnboardingPage extends StatefulWidget {
  /// Optional completion callback (used by tests); when null the page
  /// marks onboarding as seen and routes to home.
  final VoidCallback? onFinished;

  const OnboardingPage({super.key, this.onFinished});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _index = 0;

  /// 1 setup page + 3 value pages.
  static const _pageCount = 4;

  static const _icons = [
    Icons.search_rounded,
    Icons.phone_in_talk_rounded,
    Icons.verified_rounded,
  ];

  // First-run choices, initialised from the stored preferences (or the
  // app defaults: light theme, Bangla) and kept in local state so the
  // selectors also work when no preferences service is registered
  // (widget tests).
  ThemeMode _themeMode = ThemeMode.light;
  String _languageCode = 'bn';

  AppPreferencesService? get _prefs =>
      sl.isRegistered<AppPreferencesService>()
          ? sl<AppPreferencesService>()
          : null;

  @override
  void initState() {
    super.initState();
    final prefs = _prefs;
    if (prefs != null) {
      _themeMode = prefs.themeMode;
      _languageCode = prefs.locale.languageCode;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _applyTheme(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    await _prefs?.setThemeMode(mode);
  }

  Future<void> _applyLanguage(String code) async {
    setState(() => _languageCode = code);
    await _prefs?.setLocale(Locale(code));
  }

  Future<void> _finish() async {
    if (widget.onFinished != null) {
      widget.onFinished!();
      return;
    }
    if (sl.isRegistered<AppPreferencesService>()) {
      await sl<AppPreferencesService>().setOnboardingSeen();
    }
    if (mounted) context.go('/');
  }

  void _next() {
    if (_index >= _pageCount - 1) {
      _finish();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
      );
    }
  }

  /// One selectable option card (theme / language). Selected state uses
  /// the primary colour border + tint; palette-neutral otherwise.
  Widget _optionCard({
    required Key key,
    required bool selected,
    required VoidCallback onTap,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: selected
          ? AppColors.primary.withAlpha(isDark ? 36 : 22)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: InkWell(
        key: key,
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _setupPage(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final themeOptions = [
      (ThemeMode.light, Icons.light_mode_rounded, l10n.themeOptionLight,
          const Key('setup_theme_light')),
      (ThemeMode.dark, Icons.dark_mode_rounded, l10n.themeOptionDark,
          const Key('setup_theme_dark')),
      (ThemeMode.system, Icons.settings_brightness_rounded,
          l10n.themeOptionSystem, const Key('setup_theme_system')),
    ];
    final languageOptions = [
      ('bn', 'বাংলা', l10n.langOptionBanglaSub, const Key('setup_language_bn')),
      ('en', 'English', l10n.langOptionEnglishSub,
          const Key('setup_language_en')),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xl),
          const Icon(Icons.tune_rounded, size: 44, color: AppColors.primary),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.setupTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.setupSubtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: secondary),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            l10n.prefThemeLabel,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              for (var i = 0; i < themeOptions.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _optionCard(
                    key: themeOptions[i].$4,
                    selected: _themeMode == themeOptions[i].$1,
                    onTap: () => _applyTheme(themeOptions[i].$1),
                    child: Column(
                      children: [
                        Icon(
                          themeOptions[i].$2,
                          size: 26,
                          color: _themeMode == themeOptions[i].$1
                              ? AppColors.primary
                              : secondary,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          themeOptions[i].$3,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.prefLanguageLabel,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < languageOptions.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _optionCard(
                    key: languageOptions[i].$4,
                    selected: _languageCode == languageOptions[i].$1,
                    onTap: () => _applyLanguage(languageOptions[i].$1),
                    child: Column(
                      children: [
                        Text(
                          languageOptions[i].$2,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          languageOptions[i].$3,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: secondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLast = _index == _pageCount - 1;

    final pages = [
      (l10n.onboardingTitle1, l10n.onboardingBody1),
      (l10n.onboardingTitle2, l10n.onboardingBody2),
      (l10n.onboardingTitle3, l10n.onboardingBody3),
    ];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                // Skip
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: TextButton(
                      key: const Key('onboarding_skip_button'),
                      onPressed: _finish,
                      child: Text(l10n.onboardingSkip),
                    ),
                  ),
                ),

                // Pages (0 = theme/language setup, 1–3 = value props)
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pageCount,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (context, i) {
                      if (i == 0) return _setupPage(l10n);
                      final (title, body) = pages[i - 1];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxl,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 132,
                              height: 132,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.accentMint.withAlpha(50),
                                    AppColors.primary.withAlpha(22),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _icons[i - 1],
                                size: 62,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxxl),
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              body,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Page indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pageCount,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _index == i ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _index == i
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusPill,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Next / Get Started
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                  ),
                  child: AppButton(
                    key: const Key('onboarding_next_button'),
                    label: isLast ? l10n.onboardingStart : l10n.onboardingNext,
                    onPressed: _next,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
